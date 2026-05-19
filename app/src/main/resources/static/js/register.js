const citiesByCountry = {
    "United States": [
        "Boston", "Chicago", "Honolulu", "Key Largo", "Los Angeles", "Miami", "Monterey",
        "New York", "Orlando", "Phoenix", "San Diego", "San Francisco", "Seattle", "Tampa"
    ]
};

function debounce(fn, delay = 350) {
    let timer;
    return (...args) => {
        clearTimeout(timer);
        timer = setTimeout(() => fn(...args), delay);
    };
}

function setUsernameStatus(type, message) {
    const icon = document.querySelector('[data-username-icon]');
    const help = document.querySelector('[data-username-help]');
    if (!icon || !help) return;

    icon.className = 'field-status-icon';
    help.className = 'field-help';

    if (!type) {
        icon.textContent = '';
        help.textContent = message || 'Choose a unique username.';
        return;
    }

    icon.classList.add(type);
    help.classList.add(type);
    icon.textContent = type === 'ok' ? '✓' : '✕';
    help.textContent = message;
}

async function checkUsernameAvailability(username) {
    const trimmed = username.trim();
    if (trimmed.length < 3) {
        setUsernameStatus('bad', 'Username must be at least 3 characters.');
        return;
    }

    setUsernameStatus(null, 'Checking username...');

    try {
        const response = await fetch(`/api/auth/username-available?username=${encodeURIComponent(trimmed)}`);
        const result = await response.json();
        if (result.available) {
            setUsernameStatus('ok', 'Username is available.');
        } else {
            setUsernameStatus('bad', 'Username is already taken.');
        }
    } catch (error) {
        setUsernameStatus('bad', 'Could not check username right now.');
    }
}

function populateCountries() {
    const country = document.querySelector('[data-country-select]');
    if (!country) return;

    country.innerHTML = '';
    Object.keys(citiesByCountry).forEach(name => {
        const option = document.createElement('option');
        option.value = name;
        option.textContent = name;
        country.appendChild(option);
    });

    if (!country.value) country.value = 'United States';
}

function populateCities() {
    const country = document.querySelector('[data-country-select]');
    const city = document.querySelector('[data-city-select]');
    if (!country || !city) return;

    const selectedCity = city.dataset.selected || city.value;
    const cities = citiesByCountry[country.value] || [];
    city.innerHTML = '<option value="">Select a city</option>';

    cities.forEach(name => {
        const option = document.createElement('option');
        option.value = name;
        option.textContent = name;
        if (selectedCity === name) option.selected = true;
        city.appendChild(option);
    });

    city.dataset.selected = '';
}

document.addEventListener('DOMContentLoaded', () => {
    const username = document.querySelector('[data-username-input]');
    if (username) {
        const debouncedCheck = debounce(event => checkUsernameAvailability(event.target.value));
        username.addEventListener('input', debouncedCheck);
        username.addEventListener('blur', event => checkUsernameAvailability(event.target.value));
    }

    populateCountries();
    populateCities();

    const country = document.querySelector('[data-country-select]');
    if (country) country.addEventListener('change', populateCities);
});
