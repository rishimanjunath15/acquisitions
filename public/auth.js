// API Base URL - Update this if your backend runs on a different port
const API_BASE_URL = 'http://localhost:3000/api';

// Helper function to display messages
function showMessage(message, type = 'success') {
    const messageElement = document.getElementById('message');
    if (messageElement) {
        messageElement.textContent = message;
        messageElement.className = `message ${type}`;
        messageElement.style.display = 'block';
        
        // Auto-hide after 5 seconds
        setTimeout(() => {
            messageElement.style.display = 'none';
        }, 5000);
    }
}

// Sign Up function
async function signUp(name, email, password) {
    try {
        const response = await fetch(`${API_BASE_URL}/auth/sign-up`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ name, email, password, role: 'user' }),
        });

        const data = await response.json();

        if (response.ok) {
            showMessage('Sign up successful! Redirecting to sign in...', 'success');
            setTimeout(() => {
                window.location.href = 'signin.html';
            }, 2000);
        } else {
            showMessage(data.error || 'Sign up failed. Please try again.', 'error');
        }
    } catch (error) {
        console.error('Sign up error:', error);
        showMessage('An error occurred. Please check your connection and try again.', 'error');
    }
}

// Sign In function
async function signIn(email, password) {
    try {
        const response = await fetch(`${API_BASE_URL}/auth/sign-in`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            credentials: 'include', // Important for cookies
            body: JSON.stringify({ email, password }),
        });

        const data = await response.json();

        if (response.ok) {
            // Store user info in localStorage
            localStorage.setItem('user', JSON.stringify(data.user));
            showMessage('Sign in successful! Redirecting...', 'success');
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 1500);
        } else {
            showMessage(data.error || 'Sign in failed. Please check your credentials.', 'error');
        }
    } catch (error) {
        console.error('Sign in error:', error);
        showMessage('An error occurred. Please check your connection and try again.', 'error');
    }
}

// Sign Out function
async function signOut() {
    try {
        const response = await fetch(`${API_BASE_URL}/auth/sign-out`, {
            method: 'POST',
            credentials: 'include', // Important for cookies
        });

        if (response.ok) {
            // Clear user info from localStorage
            localStorage.removeItem('user');
            showMessage('Signed out successfully!', 'success');
            setTimeout(() => {
                window.location.href = 'index.html';
            }, 1000);
        } else {
            showMessage('Sign out failed. Please try again.', 'error');
        }
    } catch (error) {
        console.error('Sign out error:', error);
        showMessage('An error occurred. Please try again.', 'error');
    }
}

// Check if user is logged in
function isLoggedIn() {
    return localStorage.getItem('user') !== null;
}

// Get current user
function getCurrentUser() {
    const userStr = localStorage.getItem('user');
    return userStr ? JSON.parse(userStr) : null;
}

// Update navigation based on login status
function updateNavigation() {
    const navButtons = document.getElementById('nav-buttons');
    if (!navButtons) return;

    if (isLoggedIn()) {
        navButtons.innerHTML = `
            <button onclick="signOut()" class="btn btn-danger">Sign Out</button>
        `;
    } else {
        navButtons.innerHTML = `
            <a href="signin.html" class="btn btn-primary">Sign In</a>
            <a href="signup.html" class="btn btn-secondary">Sign Up</a>
        `;
    }
}

// Display user info on home page
function displayUserInfo() {
    const userInfoElement = document.getElementById('user-info');
    if (!userInfoElement) return;

    if (isLoggedIn()) {
        const user = getCurrentUser();
        userInfoElement.textContent = `Welcome back, ${user.name || user.email}!`;
    } else {
        userInfoElement.textContent = 'Please sign in or sign up to continue';
    }
}
