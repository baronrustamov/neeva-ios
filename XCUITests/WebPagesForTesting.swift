import Foundation
import GCDWebServers
import Shared

// XCUITests that require custom localhost pages can add handlers here.
// This file is compiled as part of Client target, but it is in the XCUITest directory
// because it is for XCUITest purposes.

extension WebServer {
    func registerHandlersForTestMethods() {
        self.registerHandlerForMethod(
            "GET",
            module: "test-fixture",
            resource: "find-in-page-test.html"
        ) { (request: GCDWebServerRequest?) in

            let node =
                "<span>  And the beast shall come forth surrounded by a roiling cloud of vengeance. The house of the unbelievers shall be razed and they shall be scorched to the earth. Their tags shall blink until the end of days. from The Book of Mozilla, 12:10 And the beast shall be made legion. Its numbers shall be increased a thousand thousand fold. The din of a million keyboards like unto a great storm shall cover the earth, and the followers of Mammon shall tremble. from The Book of Mozilla, 3:31 (Red Letter Edition) </span>"

            let repeatCount = 1000
            let textNodes = [String](repeating: node, count: repeatCount).reduce("", +)
            return GCDWebServerDataResponse(html: "<html><body>\(textNodes)</body></html>")
        }

        [
            "mock-neeva-home", "mock-neeva-signin",
            "test-indexeddb-private", "test-window-opener", "test-password", "test-password-submit",
            "test-password-2", "test-password-submit-2", "empty-login-form",
            "empty-login-form-submit",
            "test-example", "test-example-link", "test-mozilla-book", "test-mozilla-org",
            "test-popup-blocker", "test-user-agent", "test-pdf",
        ].forEach {
            addHTMLFixture(name: $0)
        }
    }

    private func addHTMLFixture(name: String) {
        if let path = Bundle.main.path(forResource: "test-fixtures/\(name)", ofType: "html") {
            self.registerGETHandler(forPath: "/test-fixture/\(name).html", filePath: path)
        }
    }
}
