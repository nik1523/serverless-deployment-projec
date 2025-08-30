#!/bin/bash

echo "Installing test dependencies..."
pip install -r requirements-dev.txt

echo "Running unit tests..."
pytest src/tests/test_handler.py -v -m "not integration"

echo "Starting local API for integration tests..."
sam local start-api --port 3000 &
API_PID=$!

# Wait for API to start
sleep 10

echo "Running integration tests..."
API_URL=http://localhost:3000 pytest src/tests/test_integration.py -v

# Clean up
kill $API_PID

echo "Tests completed!"
