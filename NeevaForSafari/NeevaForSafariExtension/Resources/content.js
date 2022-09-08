// 
// Search Engine host methods.
const SearchEngineHosts = {
    Google: [
        "google.com",
        "google.ad",
        "google.ae",
        "google.com.af",
        "google.com.ag",
        "google.com.ai",
        "google.al",
        "google.am",
        "google.co.ao",
        "google.com.ar",
        "google.as",
        "google.at",
        "google.com.au",
        "google.az",
        "google.ba",
        "google.com.bd",
        "google.be",
        "google.bf",
        "google.bg",
        "google.com.bh",
        "google.bi",
        "google.bj",
        "google.com.bn",
        "google.com.bo",
        "google.com.br",
        "google.bs",
        "google.bt",
        "google.co.bw",
        "google.by",
        "google.com.bz",
        "google.ca",
        "google.cd",
        "google.cf",
        "google.cg",
        "google.ch",
        "google.ci",
        "google.co.ck",
        "google.cl",
        "google.cm",
        "google.cn",
        "google.com.co",
        "google.co.cr",
        "google.com.cu",
        "google.cv",
        "google.com.cy",
        "google.cz",
        "google.de",
        "google.dj",
        "google.dk",
        "google.dm",
        "google.com.do",
        "google.dz",
        "google.com.ec",
        "google.ee",
        "google.com.eg",
        "google.es",
        "google.com.et",
        "google.fi",
        "google.com.fj",
        "google.fm",
        "google.fr",
        "google.ga",
        "google.ge",
        "google.gg",
        "google.com.gh",
        "google.com.gi",
        "google.gl",
        "google.gm",
        "google.gr",
        "google.com.gt",
        "google.gy",
        "google.com.hk",
        "google.hn",
        "google.hr",
        "google.ht",
        "google.hu",
        "google.co.id",
        "google.ie",
        "google.co.il",
        "google.im",
        "google.co.in",
        "google.iq",
        "google.is",
        "google.it",
        "google.je",
        "google.com.jm",
        "google.jo",
        "google.co.jp",
        "google.co.ke",
        "google.com.kh",
        "google.ki",
        "google.kg",
        "google.co.kr",
        "google.com.kw",
        "google.kz",
        "google.la",
        "google.com.lb",
        "google.li",
        "google.lk",
        "google.co.ls",
        "google.lt",
        "google.lu",
        "google.lv",
        "google.com.ly",
        "google.co.ma",
        "google.md",
        "google.me",
        "google.mg",
        "google.mk",
        "google.ml",
        "google.com.mm",
        "google.mn",
        "google.ms",
        "google.com.mt",
        "google.mu",
        "google.mv",
        "google.mw",
        "google.com.mx",
        "google.com.my",
        "google.co.mz",
        "google.com.na",
        "google.com.ng",
        "google.com.ni",
        "google.ne",
        "google.nl",
        "google.no",
        "google.com.np",
        "google.nr",
        "google.nu",
        "google.co.nz",
        "google.com.om",
        "google.com.pa",
        "google.com.pe",
        "google.com.pg",
        "google.com.ph",
        "google.com.pk",
        "google.pl",
        "google.pn",
        "google.com.pr",
        "google.ps",
        "google.pt",
        "google.com.py",
        "google.com.qa",
        "google.ro",
        "google.ru",
        "google.rw",
        "google.com.sa",
        "google.com.sb",
        "google.sc",
        "google.se",
        "google.com.sg",
        "google.sh",
        "google.si",
        "google.sk",
        "google.com.sl",
        "google.sn",
        "google.so",
        "google.sm",
        "google.sr",
        "google.st",
        "google.com.sv",
        "google.td",
        "google.tg",
        "google.co.th",
        "google.com.tj",
        "google.tl",
        "google.tm",
        "google.tn",
        "google.to",
        "google.com.tr",
        "google.tt",
        "google.com.tw",
        "google.co.tz",
        "google.com.ua",
        "google.co.ug",
        "google.co.uk",
        "google.com.uy",
        "google.co.uz",
        "google.com.vc",
        "google.co.ve",
        "google.vg",
        "google.co.vi",
        "google.com.vn",
        "google.vu",
        "google.ws",
        "google.rs",
        "google.co.za",
        "google.co.zm",
        "google.co.zw",
        "google.cat",
    ],
	Bing: ["bing.com"],
	Ecosia: ["ecosia.com"],
	Yahoo: [
        "search.yahoo",
        "hk.search.yahoo",
    ],
    DuckDuckGo: ["duckduckgo.com"],
    Yandex: ["yandex.com"],
    Baidu: ["baidu.com"],
    So: [
         "so.com",
         "m.so.com",
    ],
    Sogou: [
        "sogou.com",
        "wap.sogou.com",
    ],
    Neeva: ["neeva.com"]
}

function searchEngineHostsContais(host) {
    for (var key in SearchEngineHosts) {
        if (SearchEngineHosts[key].includes(host)) {
            return true;
        }
    }

    return false;
}

function trimURLHost(host) {
    if (host == null) {
        return host;
    }

    // Remove www if it was added to the host.
    host = host.replace("www.", "");

    return host;
}

//
// Navigiation handling methods.
browser.runtime.sendMessage({ "getPreference": "neevaRedirect"}).then((response) => {
    const searchQuery = navigateIfNeeded(window.location);
    let referrerURL = window.document.referrer;
    let referrerHost = trimURLHost(referrerURL.replace("https://", ""));

    if (searchQuery != null && response["value"] && !searchEngineHostsContais(referrerHost)) {
        let url = `https://neeva.com/search?q=${searchQuery}&src=ios_safari_extension`;
        window.location.replace(url);
    }
});

function navigateIfNeeded(location) {
    var value = null;
    var host = trimURLHost(location.host);

    switch (true) {
        case SearchEngineHosts.Google.includes(host):
        case SearchEngineHosts.Bing.includes(host):
        case SearchEngineHosts.Ecosia.includes(host):
        case SearchEngineHosts.Yahoo.includes(host):
            // yahoo uses p for the search query name instead of q
            if (location.pathname === "/search") {
                value = getParameterByName((location.host === "search.yahoo.com") ? "p" : "q");
            }

            break;
        case SearchEngineHosts.DuckDuckGo.includes(host):
            // duckduckgo doesn't include the /search path
            value = getParameterByName("q");
            break;
        case SearchEngineHosts.Yandex.includes(host):
            if (location.pathname === "/search/touch/") {
                value =  getParameterByName("text");
            }

            break;
        case SearchEngineHosts.Baidu.includes(host):
        case SearchEngineHosts.So.includes(host):
            if (location.pathname === "/s") {
                value = getParameterByName((location.host === "www.baidu.com") ? "oq" : "src");
            }

            break;
        case SearchEngineHosts.Sogou.includes(host):
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
