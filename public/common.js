// Common JavaScript functionality shared across pages
const API_BASE = 'http://localhost:3000';

// Utility functions
function displayResponse(message, type = 'success') {
    const responseOutput = document.getElementById('responseOutput');
    if (!responseOutput) return;
    
    const timestamp = new Date().toLocaleTimeString();
    const formattedMessage = `[${timestamp}] ${message}\n\n`;
    
    responseOutput.textContent = formattedMessage + responseOutput.textContent;
    
    // Add visual feedback
    responseOutput.className = type === 'error' ? 'error' : 'success';
    
    // Scroll to top of response
    responseOutput.scrollTop = 0;
}

// Authentication state management
class AuthManager {
    constructor() {
        this.token = localStorage.getItem('authToken');
        this.user = JSON.parse(localStorage.getItem('currentUser')) || null;
    }

    setAuth(token, user) {
        this.token = token;
        this.user = user;
        localStorage.setItem('authToken', token);
        localStorage.setItem('currentUser', JSON.stringify(user));
    }

    clearAuth() {
        this.token = null;
        this.user = null;
        localStorage.removeItem('authToken');
        localStorage.removeItem('currentUser');
    }

    isAuthenticated() {
        return !!(this.token && this.user);
    }

    getAuthHeaders() {
        return {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.token}`
        };
    }
}

// Global auth manager instance
const auth = new AuthManager();

// API helper functions
async function makeRequest(url, options = {}) {
    try {
        const response = await fetch(url, {
            credentials: 'include',
            ...options
        });
        
        const data = await response.json();
        
        return {
            success: response.ok,
            status: response.status,
            data: data
        };
    } catch (error) {
        return {
            success: false,
            error: error.message
        };
    }
}

// Navigation active state
document.addEventListener('DOMContentLoaded', function() {
    const currentPage = window.location.pathname.split('/').pop() || 'index.html';
    const navLinks = document.querySelectorAll('.nav-menu a');
    
    navLinks.forEach(link => {
        const linkPage = link.getAttribute('href');
        if (linkPage === currentPage) {
            link.classList.add('active');
        } else {
            link.classList.remove('active');
        }
    });
});

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { AuthManager, makeRequest, displayResponse, API_BASE };
}