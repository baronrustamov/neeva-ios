// Used to communicate between extension and the application
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    var sending = browser.runtime.sendNativeMessage("application.id", request);
    sending.then(sendResponse, onError);

    return true;
});

function onError(error) {
    console.log(`Error: ${error}`);
}
