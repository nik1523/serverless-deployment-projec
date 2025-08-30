#!/bin/bash

ENV=${1:-dev}
REQUESTS=${2:-100}

if [ "$ENV" = "dev" ]; then
  URL="https://19y33kq4ti.execute-api.ap-south-1.amazonaws.com/Prod/hello/"
elif [ "$ENV" = "prod" ]; then
  URL="https://d793b22f5g.execute-api.ap-south-1.amazonaws.com/Prod/hello/"
else
  echo "Usage: $0 <dev|prod> [number_of_requests]"
  exit 1
fi

echo "Load testing ${ENV} environment with ${REQUESTS} requests..."
echo "URL: $URL"

# Simple load test
for i in $(seq 1 $REQUESTS); do
  curl -s "$URL" > /dev/null &
  if [ $((i % 10)) -eq 0 ]; then
    echo "Sent $i requests..."
    sleep 1
  fi
done

wait
echo "Load test completed. Check CloudWatch metrics for scaling behavior."
