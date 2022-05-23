//
//  ViewController.swift
//  Neeva for Safari
//
//  Created by Evan Crow on 5/23/22.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            self.createWebView()
            self.webView.navigationDelegate = self
            self.webView.scrollView.isScrollEnabled = false

            self.webView.configuration.userContentController.add(self, name: "controller")
            self.webView.loadFileURL(Bundle.main.url(forResource: "Main", withExtension: "html")!, allowingReadAccessTo: Bundle.main.resourceURL!)
        }
    }

    func createWebView() {
        webView = WKWebView()
        view.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.superview!.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.superview!.bottomAnchor).isActive = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Override point for customization.
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Override point for customization.
    }
}
