browser.runtime.sendMessage({ "getPreference": "neevaRedirect"}).then((response) => {
    const searchQuery = navigateIfNeeded(window.location);
    const possibleReferalURLs = ["https://www.google.com/", "https://www.bing.com/", "https://www.ecosia.com/",
                                  "https://search.yahoo.com/", "https://duckduckgo.com/", "https://yandex.com/",
                                  "https://www.baidu.com/", "https://www.so.com/", "https://www.sogou.com/", "https://neeva.com/"];

    referrerURL = window.document.referrer;

    if (searchQuery != null && response["value"] && !possibleReferalURLs.includes(referrerURL)) {
        const url = `https://neeva.com/search?q=${searchQuery}&src=nvobar`;
        window.location.replace(url);
    }
});

function navigateIfNeeded(location) {
    var value = null;
    switch (location.host) {
        case "www.google.com":
        case "www.bing.com":
        case "www.ecosia.org":
        case"search.yahoo.com":
            // yahoo uses p for the search query name instead of q
            if (location.pathname === "/search") {
                value = getParameterByName((location.host === "search.yahoo.com") ? "p" : "q");
            }

            break;
        case "duckduckgo.com":
            // duckduckgo doesn't include the /search path
            value = getParameterByName("q");
            break;
        case "yandex.com":
            if (location.pathname === "/search/touch/") {
                value =  getParameterByName("text");
            }

            break;
        case "www.baidu.com":
        case "www.so.com":
            if (location.pathname === "/s") {
                value = getParameterByName((location.host === "www.baidu.com") ? "oq" : "src");
            }

            break;
        case "www.sogou.com":
            if (location.pathname === "/web") {
                value = getParameterByName("query");
            }

            break;
        default:
            break;
    }

    return value;
}

function getParameterByName(name, url = window.location.href) {
    name = name.replace(/[\[\]]/g, '\\$&');
    var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
        results = regex.exec(url);

    if (!results) return null;
    if (!results[2]) return '';

    return decodeURIComponent(results[2].replace(/\+/g, ' '));
}
