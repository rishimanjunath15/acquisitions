// Signup page functionality
document.addEventListener('DOMContentLoaded', function() {
    const signupForm = document.getElementById('signupForm');
    
    if (signupForm) {
        signupForm.addEventListener('submit', handleSignup);
    }
    
    displayResponse('📝 Ready to create your account!');
});

async function handleSignup(e) {
    e.preventDefault();
    
    const formData = new FormData(e.target);
    const password = formData.get('password');
    const confirmPassword = formData.get('confirmPassword');
    
    // Validate password confirmation
    if (password !== confirmPassword) {
        displayResponse('❌ Passwords do not match!', 'error');
        return;
    }
    
    const userData = {
        name: formData.get('name'),
        email: formData.get('email'),
        password: password
    };
    
    displayResponse('📝 Creating account...');
    
    const result = await makeRequest(`${API_BASE}/api/auth/signup`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(userData)
    });
    
    if (result.success) {
        displayResponse(`✅ Account created successfully!\n${JSON.stringify(result.data, null, 2)}`);
        
        // Store auth data and redirect to welcome page
        if (result.data.token && result.data.user) {
            auth.setAuth(result.data.token, result.data.user);
            displayResponse('🎉 Redirecting to welcome page...');
            setTimeout(() => {
                window.location.href = 'welcome.html';
            }, 2000);
        }
        
        signupForm.reset();
    } else {
        displayResponse(`❌ Signup failed:\n${JSON.stringify(result.data || result.error, null, 2)}`, 'error');
    }
}