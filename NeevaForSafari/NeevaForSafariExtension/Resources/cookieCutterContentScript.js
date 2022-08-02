// Inject the Cookie Cutter script into the webpage.
const scriptUrl = browser.runtime.getURL('scripts/cookieCutterEngine.js');
const element = document.createElement('script');
element.src = scriptUrl;
document.head.appendChild(element);

// Add a listener to pass messages from the Cookie Cutter script
// to the SafariWebExtensionHandler.
window.addEventListener("cookie-cutter-update", function(event) {
    let data = event.detail;
    let domain = data.domain;
    let update = data.update.cookieCutterUpdate;

    browser.runtime.sendMessage({ "cookieCutterUpdate": update, domain: domain }).then((response) => {
        window.dispatchEvent(new CustomEvent('cookie-cutter-update-response', { 
            detail: { respondingTo: update, response: response }
        }));
    }); 
}, false);
