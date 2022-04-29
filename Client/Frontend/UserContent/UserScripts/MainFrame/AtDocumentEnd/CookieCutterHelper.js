"use strict";

import { CookieCategoryType, CookieEngine } from 'cookie-cutter';

var cookiePreferences = { marketing: false, analytic: false, social: false }; 

function setPreference(preferences) {
    cookiePreferences["marketing"] = preferences["marketing"];
    cookiePreferences["analytic"] = preferences["analytic"];
    cookiePreferences["social"] = preferences["social"];
}

Object.defineProperty(window.__firefox__, "setPreference", {
    enumerable: false,
    configurable: false,
    writable: false,
    value: setPreference
});

// Checks if the Cookie Cutter handler has been injected by iOS.
// Without it, could cause other scripts to fail.
if (webkit.messageHandlers.cookieCutterHandler != undefined) {
    webkit.messageHandlers.cookieCutterHandler.postMessage({ update: "get-preferences"});

    // Not used by iOS.
    CookieEngine.flagSite(async () => {});

    // These are handled by the iOS app, can return default values.
    CookieEngine.isCookieConsentingEnabled(async () => true);
    CookieEngine.isFlaggedSite(async () => false);

    // Tell the iOS app to increase the count of cookies handled.
    CookieEngine.incrementCookieStats(async () => {
        webkit.messageHandlers.cookieCutterHandler.postMessage({ update: "increase-cookie-stats"});
    });

    // Tell the iOS app that a cookie notice has been handled.
    CookieEngine.notifyNoticeHandledOnPage(async () => {
        webkit.messageHandlers.cookieCutterHandler.postMessage({ update: "cookie-notice-handled"});
    });

    // Needed if the page is reloaded.
    CookieEngine.getHostname(() => window.location);

    //
    // User preferences, passed down from the iOS app.
    CookieEngine.areAllEnabled(async () => {
        return cookiePreferences["marketing"] && cookiePreferences["analytic"] && cookiePreferences["social"];
    });

    CookieEngine.isTypeEnabled(async (type) => {
        switch (type) {
        case CookieCategoryType.Marketing:
        case CookieCategoryType.DoNotSell:
            return cookiePreferences.marketing;
        case CookieCategoryType.Analytics:
        case CookieCategoryType.Preferences:
            return cookiePreferences.analytic;
        case CookieCategoryType.Social:
        case CookieCategoryType.Unknown:
            return cookiePreferences.social;
        default:
            return false;
        }
    });

    //
    // TODO: Logging
    CookieEngine.logProviderUsage(async (provider) => {});

    // Run!
    CookieEngine.runCookieCutter();

    webkit.messageHandlers.cookieCutterHandler.postMessage({ update: "started-running"});
}
  