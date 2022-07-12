//
// Elements
const neevaRedirectToggle = document.getElementById("neevaRedirectToggle");
const navigateToNeevaButton = document.getElementById("navigateToNeevaButton");

// Cookie Cutter
const cookieCutterToggle = document.getElementById("cookieCutterToggle");
const cookieCutterSettingsSection = document.getElementById("cookieCutterSettings");

const acceptCookiesPicker = document.getElementById("acceptCookiesPicker");
const acceptCookiesSection = document.getElementById("acceptCookiesSection");

const declineCookiesPicker = document.getElementById("declineCookiesPicker");
const declineCookiesSection = document.getElementById("declineCookiesSection");

//
// Preference Keys
const neevaRedirectKey = "neevaRedirect";
const cookieCutterKey = "cookieCutter";
const acceptCookiesKey = "acceptCookies";

function savePreference(preferenceName, value) {
    browser.runtime.sendMessage({ "savePreference": preferenceName, "value": value });
};

function getPreference(preferenceName) {
    return browser.runtime.sendMessage({ "getPreference": preferenceName }).then((response) => {
        return response["value"];
    });
}

function setPreference(preferenceName, toggle) {
    getPreference(preferenceName).then((value) => {
        toggle.checked = value;

        if (toggle == cookieCutterToggle) {
            updateCookieCutterSettingsDisplayState();
        }
    });
};

//
// Toggles
neevaRedirectToggle.onclick = function() {
    savePreference(neevaRedirectKey, neevaRedirectToggle.checked);
};

cookieCutterToggle.onclick = function() {
    updateCookieCutterSettingsDisplayState();

    if (!cookieCutterToggle.checked) {
        savePreference(acceptCookiesKey, false);
    }
   
    savePreference(cookieCutterKey, cookieCutterToggle.checked);
};

//
// Cookie Cutter settings
acceptCookiesPicker.onclick = function() {
    updateCookiePreferencesState(true);
};

acceptCookiesSection.onclick = function() {
    updateCookiePreferencesState(true);
};

declineCookiesPicker.onclick = function() {
    updateCookiePreferencesState(false);
};

declineCookiesSection.onclick = function() {
    updateCookiePreferencesState(false);
};

function updateCookiePreferencesState(acceptCookies, savePreferenceToDevice = true) {
    acceptCookiesPicker.checked = acceptCookies;
    declineCookiesPicker.checked = !acceptCookies;

    if (savePreferenceToDevice) {
        savePreference(acceptCookiesKey, acceptCookies);
    }
}

function updateCookieCutterSettingsDisplayState() {
    cookieCutterSettingsSection.style.display = cookieCutterToggle.checked ? "block" : "none";

    getPreference(acceptCookiesKey).then((value) => {
        updateCookiePreferencesState(value, false);
    });
};

//
// Buttons
navigateToNeevaButton.onclick = function() {
    window.open("https://neeva.com");
};

// This code was used to open the Neeva app store page when we had a button for it in the extension.
// Leaving it here in case we need it sometime in the future.
// document.getElementById("downloadNeevaAppButton").onclick = function() {
//     window.open("https://apps.apple.com/us/app/neeva-browser-search-engine/id1543288638");
// };

//
// On Run
setPreference(neevaRedirectKey, neevaRedirectToggle);
setPreference(cookieCutterKey, cookieCutterToggle);