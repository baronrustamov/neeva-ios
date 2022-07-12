"use strict";

import { CookieCategoryType, CookieEngine } from 'cookie-cutter';

var cookiePreferences = { marketing: false, analytic: false, social: false };
var isFlagged = false;

function runEngine() {
    // Not used by iOS.
    CookieEngine.flagSite(async () => {
        publishUpdate({ cookieCutterUpdate: "flag-site" });
    });

    // These are handled by the iOS app, can return default values.
    CookieEngine.isCookieConsentingEnabled(async () => true);
    CookieEngine.isFlaggedSite(async () => isFlagged);

    // Tell the iOS app to increase the count of cookies handled.
    CookieEngine.incrementCookieStats(async () => {
        publishUpdate({ cookieCutterUpdate: "increase-cookie-stats" });
    });

    // Tell the iOS app that a cookie notice has been handled.
    CookieEngine.notifyNoticeHandledOnPage(async () => {
        publishUpdate({ cookieCutterUpdate: "cookie-notice-handled" });
    });

    // Needed if the page is reloaded.
    CookieEngine.getHostname(() => window.location);

    //
    // User preferences, passed down from the iOS app.
    CookieEngine.areAllEnabled(async () => {
        return cookiePreferences["marketing"] && cookiePreferences["analytic"] && cookiePreferences["social"];
    });

    CookieEngine.isTypeEnabled(async (type) => {
        console.log("isTypeEnabled: " + type);
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
    CookieEngine.logProviderUsage(async (provider) => {
        publishUpdate({ cookieCutterUpdate: "log-provider-usage", provider: provider });
    });

    // Run!
    CookieEngine.runCookieCutter();

    publishUpdate({ cookieCutterUpdate: "started-running" });
}

function setPreferences(preferences) {
    isFlagged = preferences["isFlagged"];

    console.log("Is flagged: " + isFlagged);

    if (preferences["cookieCutterEnabled"]) {
        cookiePreferences["marketing"] = preferences["marketing"];
        cookiePreferences["analytic"] = preferences["analytic"];
        cookiePreferences["social"] = preferences["social"];
    
        runEngine();
    }
}

function publishUpdate(update) {
    window.dispatchEvent(new CustomEvent("cookie-cutter-update", { detail: { update, domain: window.location.host }}));
}

publishUpdate({ cookieCutterUpdate: "get-preferences" });

window.addEventListener("cookie-cutter-update-response", function(event) {
    let data = event.detail
    let response = data.response;

    if (data.respondingTo == "get-preferences") {
        setPreferences(response);
    }
}, false);
