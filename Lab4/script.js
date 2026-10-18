// script.js - used by index.html, register.html and welcome.html.
// Handles client-side validation and talks to the PHP endpoints with fetch() (Ajax).

const messages = document.getElementById('messages');
const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function showErrors(list) {
    messages.innerHTML = '';
    list.forEach(text => {
        const p = document.createElement('p');
        p.textContent = text;
        messages.appendChild(p);
    });
    messages.hidden = list.length === 0;
}

// Send the form to its PHP endpoint. Success -> welcome page,
// otherwise the errors from PHP are shown on the same page.
async function submitAjax(form) {
    try {
        const response = await fetch(form.getAttribute('action'), {
            method: 'POST',
            body: new FormData(form)
        });
        const data = await response.json();
        if (data.success) {
            window.location.href = 'welcome.html';
        } else {
            showErrors(data.errors);
        }
    } catch (err) {
        showErrors(['Could not reach the server. Is Apache running?']);
    }
}

// ---------- Login (index.html) ----------
const loginForm = document.getElementById('loginForm');
if (loginForm) {
    loginForm.addEventListener('submit', function (e) {
        e.preventDefault();
        const errors = [];
        const email = loginForm.email.value.trim();

        if (email === '') errors.push('Email is empty.');
        else if (!emailPattern.test(email)) errors.push('Email format is not valid.');
        if (loginForm.password.value === '') errors.push('Password is empty.');

        showErrors(errors);
        if (errors.length === 0) submitAjax(loginForm);
    });
}

// ---------- Registration (register.html) ----------
const registerForm = document.getElementById('registerForm');
if (registerForm) {

    async function emailExists(email) {
        const r = await fetch('check_email.php?email=' + encodeURIComponent(email));
        const data = await r.json();
        return data.exists === true;
    }

    // Live check when the user leaves the email field
    registerForm.email.addEventListener('blur', async function () {
        const email = registerForm.email.value.trim();
        try {
            if (emailPattern.test(email) && await emailExists(email)) {
                showErrors(['Email Already Exists']);
            }
        } catch (err) { /* the final check on submit will report problems */ }
    });

    registerForm.addEventListener('submit', async function (e) {
        e.preventDefault();
        const errors = [];
        const email = registerForm.email.value.trim();

        // Say exactly which field is empty
        if (registerForm.name.value.trim() === '') errors.push('Name is empty.');
        if (email === '') errors.push('Email is empty.');
        else if (!emailPattern.test(email)) errors.push('Email format is not valid.');
        if (registerForm.password.value === '') errors.push('Password is empty.');
        if (registerForm.confirm_password.value === '') errors.push('Confirm password is empty.');

        if (registerForm.password.value !== '' && registerForm.confirm_password.value !== ''
            && registerForm.password.value !== registerForm.confirm_password.value) {
            errors.push('Password and confirm password do not match.');
        }

        // Unique email
        if (errors.length === 0) {
            try {
                if (await emailExists(email)) errors.push('Email Already Exists');
            } catch (err) {
                errors.push('Could not reach the server. Is Apache running?');
            }
        }

        showErrors(errors);
        if (errors.length === 0) submitAjax(registerForm);
    });
}

// ---------- Welcome page (welcome.html) ----------
const welcomeText = document.getElementById('welcomeText');
if (welcomeText) {
    fetch('session.php')
        .then(r => r.json())
        .then(data => {
            if (data.loggedIn) {
                welcomeText.textContent = 'Welcome ' + data.name;   // textContent: safe against HTML injection
            } else {
                window.location.href = 'index.html';
            }
        })
        .catch(() => { window.location.href = 'index.html'; });

    document.getElementById('logout').addEventListener('click', function (e) {
        e.preventDefault();
        fetch('session.php?logout=1').then(() => { window.location.href = 'index.html'; });
    });
}
