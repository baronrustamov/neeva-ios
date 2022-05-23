//
//  SafariWebExtensionHandler.swift
//  Neeva for Safari Extension
//
//  Created by Evan Crow on 5/23/22.
//

import SafariServices
import os.log

enum ExtensionRequests: String {
    case SavePreference = "savePreference"
    case GetPreference = "getPreference"
}

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    let defaults = UserDefaults.standard

    func beginRequest(with context: NSExtensionContext) {
        let item = context.inputItems[0] as! NSExtensionItem
        let data = item.userInfo?["message"] as? [String: Any]

        if let savePreference = data?[ExtensionRequests.SavePreference.rawValue] as? String, let value = data?["value"] {
            os_log(.default, "Saving user preference %{private}@ (NEEVA FOR SAFARI)", savePreference)
            defaults.set(value, forKey: savePreference)
        } else if let getPreference = data?[ExtensionRequests.GetPreference.rawValue] as? String {
            os_log(.default, "Retriving user preference  %{private}@ (NEEVA FOR SAFARI)", getPreference)

            let response = NSExtensionItem()
            response.userInfo = [ SFExtensionMessageKey: ["value":  defaults.bool(forKey: getPreference)]]
            context.completeRequest(returningItems: [response]) { _ in
                os_log(.default, "Returned data to extension %{private}@ (NEEVA FOR SAFARI)", response.userInfo!)
            }
        } else {
            os_log(.default, "Received request with no usable instructions (NEEVA FOR SAFARI)")
        }
    }
}
