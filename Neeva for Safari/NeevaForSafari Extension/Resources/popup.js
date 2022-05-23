document.getElementById("neevaRedirectToggle").onclick = function() {
    browser.runtime.sendMessage({ "savePreference": "neevaRedirect", "value": document.getElementById("neevaRedirectToggle").checked });
};

document.getElementById("navigateToNeevaButton").onclick = function() {
    window.open("https://neeva.com");
};

// This code was used to open the Neeva app store page when we had a button for it in the extension.
// Leaving it here in case we need it sometime in the future.
// document.getElementById("downloadNeevaAppButton").onclick = function() {
//     window.open("https://apps.apple.com/us/app/neeva-browser-search-engine/id1543288638");
// };

browser.runtime.sendMessage({ "getPreference": "neevaRedirect"}).then((response) => {
    document.getElementById("neevaRedirectToggle").checked = response["value"]
});
