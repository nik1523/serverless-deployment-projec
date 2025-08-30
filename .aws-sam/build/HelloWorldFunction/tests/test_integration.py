import requests
import pytest
import os

class TestAPIIntegration:
    """Integration tests for the deployed API"""
    
    @pytest.fixture
    def api_url(self):
        """Get API URL from environment or use default"""
        return os.environ.get('API_URL', 'http://localhost:3000')
    
    def test_hello_endpoint(self, api_url):
        """Test the /hello endpoint"""
        response = requests.get(f"{api_url}/hello")
        
        assert response.status_code == 200
        assert response.headers['content-type'] == 'application/json'
        
        data = response.json()
        assert data['message'] == 'Hello from Serverless Application!'
        assert 'timestamp' in data
        assert 'environment' in data
    
    def test_hello_endpoint_cors(self, api_url):
        """Test CORS headers"""
        response = requests.get(f"{api_url}/hello")
        
        assert response.headers.get('Access-Control-Allow-Origin') == '*'
    
    def test_invalid_endpoint(self, api_url):
        """Test invalid endpoint returns 404"""
        response = requests.get(f"{api_url}/invalid")
        
        assert response.status_code == 404
