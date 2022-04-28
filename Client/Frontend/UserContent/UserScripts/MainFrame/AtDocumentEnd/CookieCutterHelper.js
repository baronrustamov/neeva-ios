"use strict";

import { CookieEngine } from 'cookie-cutter';

// Not used by iOS.
CookieEngine.flagSite(async () => {});

// These are handled by the iOS app, can return default values.
CookieEngine.isCookieConsentingEnabled(async () => true);
CookieEngine.isFlaggedSite(async () => false);

// Tell the iOS app to increase the count of cookies handled.
CookieEngine.incrementCookieStats(async () => {
    webkit.messageHandlers.cookieCutterHandler.postMessage({ update: "increase cookie stats"});
});

// Tell the iOS app that a cookie notice has been handled.
CookieEngine.notifyNoticeHandledOnPage(async () => {
    webkit.messageHandlers.cookieCutterHandler.postMessage({ update: "cookie notice handled"});
});

// Needed if the page is reloaded.
CookieEngine.getHostname(() => window.location);

//
// User preferences, passed down from the iOS app.
// Set to true for testing.
// TODO: Pass values from iOS app, and return them here.
CookieEngine.areAllEnabled(async () => true);
CookieEngine.isTypeEnabled(async (type) => true);

//
// TODO: Logging
CookieEngine.logProviderUsage(async (provider) => {});

// Run!
CookieEngine.runCookieCutter();

if (webkit.messageHandlers.cookieCutterHandler != undefined) {
    webkit.messageHandlers.cookieCutterHandler.postMessage({ update: "started running"});
}