// Signin page functionality
document.addEventListener('DOMContentLoaded', function() {
    const signinForm = document.getElementById('signinForm');
    
    if (signinForm) {
        signinForm.addEventListener('submit', handleSignin);
    }
    
    displayResponse('🔐 Ready to sign in!');
    
    // Check if already authenticated
    if (auth.isAuthenticated()) {
        displayResponse('✅ You are already signed in! Redirecting to welcome page...');
        setTimeout(() => {
            window.location.href = 'welcome.html';
        }, 2000);
    }
});

async function handleSignin(e) {
    e.preventDefault();
    
    const formData = new FormData(e.target);
    const loginData = {
        email: formData.get('email'),
        password: formData.get('password')
    };
    
    displayResponse('🔐 Signing in...');
    
    const result = await makeRequest(`${API_BASE}/api/auth/signin`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(loginData)
    });
    
    if (result.success) {
        displayResponse(`✅ Sign in successful!\n${JSON.stringify(result.data, null, 2)}`);
        
        // Store auth data and redirect to welcome page
        if (result.data.token && result.data.user) {
            auth.setAuth(result.data.token, result.data.user);
            displayResponse('🎉 Redirecting to welcome page...');
            setTimeout(() => {
                window.location.href = 'welcome.html';
            }, 2000);
        }
        
        signinForm.reset();
    } else {
        displayResponse(`❌ Sign in failed:\n${JSON.stringify(result.data || result.error, null, 2)}`, 'error');
    }
}