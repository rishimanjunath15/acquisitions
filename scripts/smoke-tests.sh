#!/bin/bash
# 🧪 Post-deployment smoke tests
# This script runs after deployment to verify everything is working

echo "🧪 Starting smoke tests..."

# Configuration
APP_URL=${APP_URL:-"http://localhost:3000"}
MAX_RETRIES=30
RETRY_INTERVAL=10

echo "📍 Testing URL: $APP_URL"

# Function to test endpoint
test_endpoint() {
    local endpoint=$1
    local expected_status=$2
    local description=$3
    
    echo "🔍 Testing $description..."
    
    for i in $(seq 1 $MAX_RETRIES); do
        response=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL$endpoint")
        
        if [ "$response" = "$expected_status" ]; then
            echo "✅ $description - OK ($response)"
            return 0
        else
            echo "⏳ Attempt $i/$MAX_RETRIES - Got $response, expected $expected_status"
            sleep $RETRY_INTERVAL
        fi
    done
    
    echo "❌ $description - FAILED after $MAX_RETRIES attempts"
    return 1
}

# Function to test JSON response
test_json_endpoint() {
    local endpoint=$1
    local expected_key=$2
    local description=$3
    
    echo "🔍 Testing $description..."
    
    for i in $(seq 1 $MAX_RETRIES); do
        response=$(curl -s "$APP_URL$endpoint")
        
        if echo "$response" | grep -q "\"$expected_key\""; then
            echo "✅ $description - OK"
            echo "📋 Response: $response"
            return 0
        else
            echo "⏳ Attempt $i/$MAX_RETRIES - Invalid response"
            sleep $RETRY_INTERVAL
        fi
    done
    
    echo "❌ $description - FAILED after $MAX_RETRIES attempts"
    return 1
}

# Run smoke tests
echo "🚀 Starting comprehensive smoke tests..."

# Test 1: Health check endpoint
test_json_endpoint "/health" "status" "Health Check Endpoint" || exit 1

# Test 2: Main API endpoint
test_json_endpoint "/api" "message" "Main API Endpoint" || exit 1

# Test 3: Frontend accessibility
test_endpoint "/" "200" "Frontend Page" || exit 1

# Test 4: Auth endpoints structure
test_endpoint "/api/auth/signup" "400" "Auth Signup Endpoint (POST required)" || exit 1
test_endpoint "/api/auth/signin" "400" "Auth Signin Endpoint (POST required)" || exit 1

# Test 5: Static files
test_endpoint "/styles.css" "200" "CSS Static Files" || exit 1

# Test 6: API documentation (if available)
echo "🔍 Testing API documentation availability..."
response=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL/api/docs")
if [ "$response" = "200" ]; then
    echo "✅ API Documentation - Available"
elif [ "$response" = "404" ]; then
    echo "ℹ️  API Documentation - Not configured (optional)"
else
    echo "⚠️  API Documentation - Unexpected response: $response"
fi

# Advanced health check
echo "🔍 Testing detailed health information..."
health_response=$(curl -s "$APP_URL/health")
if echo "$health_response" | grep -q "uptime"; then
    echo "✅ Detailed Health Check - OK"
    uptime=$(echo "$health_response" | grep -o '"uptime":[0-9.]*' | cut -d':' -f2)
    echo "📊 Application uptime: ${uptime}s"
else
    echo "⚠️  Detailed Health Check - Basic health only"
fi

# Performance check
echo "🔍 Testing response time..."
start_time=$(date +%s.%N)
curl -s "$APP_URL/health" > /dev/null
end_time=$(date +%s.%N)
response_time=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "N/A")

if [ "$response_time" != "N/A" ]; then
    echo "📊 Response time: ${response_time}s"
    if (( $(echo "$response_time < 2.0" | bc 2>/dev/null) )); then
        echo "✅ Performance - Good response time"
    else
        echo "⚠️  Performance - Slow response time (>2s)"
    fi
fi

echo ""
echo "🎉 All smoke tests completed successfully!"
echo "✅ Application is healthy and responding correctly"
echo "🚀 Deployment verification complete"

exit 0