#!/bin/bash

echo "🎮 INTERACTIVE MANUAL TESTING MENU"
echo "=================================="

DEV_API="https://19y33kq4ti.execute-api.ap-south-1.amazonaws.com/Prod/hello/"
PROD_API="https://d793b22f5g.execute-api.ap-south-1.amazonaws.com/Prod/hello/"

show_menu() {
    echo ""
    echo "Select a test to run:"
    echo "1.  Test Dev API"
    echo "2.  Test Prod API"
    echo "3.  Load Test (10 requests)"
    echo "4.  Load Test (50 requests)"
    echo "5.  Test Secrets Manager"
    echo "6.  Test Database Write"
    echo "7.  Check Infrastructure"
    echo "8.  View CloudWatch Metrics"
    echo "9.  Check X-Ray Traces"
    echo "10. Test Error Scenarios"
    echo "11. Performance Benchmark"
    echo "12. Security Compliance Check"
    echo "13. Run All Tests"
    echo "0.  Exit"
    echo ""
    read -p "Enter your choice (0-13): " choice
}

test_api() {
    local env=$1
    local url=$2
    echo ""
    echo "🔍 Testing $env API..."
    echo "URL: $url"
    echo ""
    
    start_time=$(date +%s%3N)
    response=$(curl -s -w "HTTP_CODE:%{http_code};TIME:%{time_total}" "$url")
    end_time=$(date +%s%3N)
    
    http_code=$(echo "$response" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
    time_total=$(echo "$response" | grep -o "TIME:[0-9.]*" | cut -d: -f2)
    json_response=$(echo "$response" | sed 's/HTTP_CODE:[0-9]*;TIME:[0-9.]*//')
    
    echo "Status Code: $http_code"
    echo "Response Time: ${time_total}s"
    echo "Response:"
    echo "$json_response" | jq . 2>/dev/null || echo "$json_response"
    
    read -p "Press Enter to continue..."
}

load_test() {
    local requests=$1
    echo ""
    echo "🔥 Running load test with $requests requests..."
    echo "Target: Production API"
    echo ""
    
    start_time=$(date +%s)
    success_count=0
    
    for i in $(seq 1 $requests); do
        if curl -s "$PROD_API" > /dev/null; then
            success_count=$((success_count + 1))
        fi
        echo -n "."
        if [ $((i % 10)) -eq 0 ]; then
            echo " $i/$requests"
        fi
    done
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    echo ""
    echo "Results:"
    echo "• Total Requests: $requests"
    echo "• Successful: $success_count"
    echo "• Failed: $((requests - success_count))"
    echo "• Success Rate: $(echo "scale=1; $success_count * 100 / $requests" | bc)%"
    echo "• Total Time: ${duration}s"
    echo "• Avg Response Time: $(echo "scale=3; $duration / $requests" | bc)s"
    echo "• Requests/Second: $(echo "scale=1; $requests / $duration" | bc)"
    
    read -p "Press Enter to continue..."
}

test_secrets() {
    echo ""
    echo "🔐 Testing Secrets Manager Integration..."
    echo ""
    
    # Test current secrets
    response=$(curl -s "$PROD_API")
    has_secrets=$(echo "$response" | jq -r '.hasSecrets')
    
    echo "Current Status: $has_secrets"
    
    if [ "$has_secrets" = "true" ]; then
        echo "✅ Secrets are being loaded successfully"
        
        # Update a secret
        echo ""
        read -p "Update a test secret? (y/n): " update_secret
        if [ "$update_secret" = "y" ]; then
            new_value="test_$(date +%s)"
            echo "Updating secret 'test_key' to '$new_value'..."
            ./infrastructure/scripts/update-secrets.sh prod test_key "$new_value"
            echo "✅ Secret updated"
        fi
    else
        echo "❌ Secrets not loading properly"
    fi
    
    read -p "Press Enter to continue..."
}

test_database() {
    echo ""
    echo "💾 Testing Database Integration..."
    echo ""
    
    # Make API calls to generate database entries
    echo "Making API calls to generate database entries..."
    for i in {1..5}; do
        curl -s "$PROD_API" > /dev/null
        echo "Request $i sent"
    done
    
    echo ""
    echo "Checking DynamoDB tables..."
    aws dynamodb list-tables \
        --query 'TableNames[?contains(@, `serverless-app`)]' \
        --output table
    
    # Check table item count
    TABLE_NAME=$(aws dynamodb list-tables \
        --query 'TableNames[?contains(@, `serverless-app-prod`)]' \
        --output text)
    
    if [ ! -z "$TABLE_NAME" ]; then
        echo ""
        echo "Scanning table: $TABLE_NAME"
        ITEM_COUNT=$(aws dynamodb scan \
            --table-name "$TABLE_NAME" \
            --select COUNT \
            --query 'Count' \
            --output text)
        echo "Items in table: $ITEM_COUNT"
    fi
    
    read -p "Press Enter to continue..."
}

check_infrastructure() {
    echo ""
    echo "🏗️ Checking Infrastructure Status..."
    echo ""
    
    echo "CloudFormation Stacks:"
    aws cloudformation list-stacks \
        --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
        --query 'StackSummaries[?contains(StackName, `serverless`)].{Name:StackName, Status:StackStatus, Updated:LastUpdatedTime}' \
        --output table
    
    echo ""
    echo "Lambda Functions:"
    aws lambda list-functions \
        --query 'Functions[?contains(FunctionName, `serverless-app`)].{Name:FunctionName, Runtime:Runtime, Status:State}' \
        --output table
    
    echo ""
    echo "DynamoDB Tables:"
    aws dynamodb list-tables \
        --query 'TableNames[?contains(@, `serverless-app`)]' \
        --output table
    
    read -p "Press Enter to continue..."
}

performance_benchmark() {
    echo ""
    echo "⚡ Performance Benchmark Test..."
    echo ""
    
    echo "Testing cold start vs warm requests..."
    
    # Cold start test
    echo "1. Cold start test (after 5 minute wait simulation):"
    start_time=$(date +%s%3N)
    curl -s "$PROD_API" > /dev/null
    end_time=$(date +%s%3N)
    cold_start_time=$((end_time - start_time))
    echo "Cold start time: ${cold_start_time}ms"
    
    # Warm requests
    echo ""
    echo "2. Warm request tests (5 consecutive calls):"
    total_warm_time=0
    for i in {1..5}; do
        start_time=$(date +%s%3N)
        curl -s "$PROD_API" > /dev/null
        end_time=$(date +%s%3N)
        warm_time=$((end_time - start_time))
        total_warm_time=$((total_warm_time + warm_time))
        echo "Warm request $i: ${warm_time}ms"
    done
    
    avg_warm_time=$((total_warm_time / 5))
    echo ""
    echo "Performance Summary:"
    echo "• Cold Start: ${cold_start_time}ms"
    echo "• Average Warm: ${avg_warm_time}ms"
    echo "• Performance Improvement: $((cold_start_time - avg_warm_time))ms"
    
    read -p "Press Enter to continue..."
}

security_compliance() {
    echo ""
    echo "🛡️ Security & Compliance Check..."
    echo ""
    
    ./governance/compliance-check.sh prod
    
    read -p "Press Enter to continue..."
}

run_all_tests() {
    echo ""
    echo "🚀 Running All Tests..."
    echo ""
    
    ./testing/manual-test-suite.sh
    
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
    
    case $choice in
        1) test_api "Development" "$DEV_API" ;;
        2) test_api "Production" "$PROD_API" ;;
        3) load_test 10 ;;
        4) load_test 50 ;;
        5) test_secrets ;;
        6) test_database ;;
        7) check_infrastructure ;;
        8) echo "Opening CloudWatch..."; xdg-open "https://ap-south-1.console.aws.amazon.com/cloudwatch/home" 2>/dev/null || echo "Visit: https://ap-south-1.console.aws.amazon.com/cloudwatch/home" ;;
        9) echo "Opening X-Ray..."; xdg-open "https://ap-south-1.console.aws.amazon.com/xray/home" 2>/dev/null || echo "Visit: https://ap-south-1.console.aws.amazon.com/xray/home" ;;
        10) echo "Testing error scenarios..."; curl -s "https://d793b22f5g.execute-api.ap-south-1.amazonaws.com/Prod/invalid/" ;;
        11) performance_benchmark ;;
        12) security_compliance ;;
        13) run_all_tests ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
done
