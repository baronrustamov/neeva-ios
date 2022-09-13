/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

private let log = Logger.storage

// Copied from mozilla/application-services:
public class LoginRecord {
    /// The guid of this record. When inserting records, you should set this
    /// to the empty string. If you provide a non-empty one to `add`, and it
    /// collides with an existing record, a `LoginsStoreError.DuplicateGuid`
    /// will be emitted.
    public var id: String

    /// This record's hostname. Required. Attempting to insert
    /// or update a record to have a blank hostname, will result in a
    /// `LoginsStoreError.InvalidLogin`.
    public var hostname: String

    /// This record's password. Required. Attempting to insert
    /// or update a record to have a blank password, will result in a
    /// `LoginsStoreError.InvalidLogin`.
    public var password: String

    /// This record's username, if any.
    public var username: String

    /// The challenge string for HTTP Basic authentication.
    ///
    /// Exactly one of `httpRealm` or `formSubmitURL` is allowed to be present,
    /// and attempting to insert or update a record to have both or neither will
    /// result in an `LoginsStoreError.InvalidLogin`.
    public var httpRealm: String?

    /// The submission URL for the form where this login may be entered.
    ///
    /// As mentioned above, exactly one of `httpRealm` or `formSubmitURL` is allowed
    /// to be present, and attempting to insert or update a record to have
    /// both or neither will result in an `LoginsStoreError.InvalidLogin`.
    public var formSubmitURL: String?

    /// A lower bound on the number of times this record has been "used".
    ///
    /// A use is recorded (and `timeLastUsed` is updated accordingly) in
    /// the following scenarios:
    ///
    /// - Newly inserted records have 1 use.
    /// - Updating a record locally (that is, updates that occur from a
    ///   sync do not count here) increments the use count.
    /// - Calling `touch` on the corresponding id.
    ///
    /// This is ignored by `add` and `update`.
    public var timesUsed: Int = 0

    /// An upper bound on the time of creation in milliseconds from the unix epoch.
    ///
    /// This is ignored by `add` and `update`.
    public var timeCreated: Int64 = 0

    /// A lower bound on the time of last use in milliseconds from the unix epoch.
    ///
    /// This is ignored by `add` and `update`.
    public var timeLastUsed: Int64 = 0

    /// A lower bound on the time of last use in milliseconds from the unix epoch.
    ///
    /// This is ignored by `add` and `update`.
    public var timePasswordChanged: Int64 = 0

    /// HTML field name of the username, if known.
    public var usernameField: String

    /// HTML field name of the password, if known.
    public var passwordField: String

    public func toJSONDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "password": password,
            "hostname": hostname,

            "timesUsed": timesUsed,
            "timeCreated": timeCreated,
            "timeLastUsed": timeLastUsed,
            "timePasswordChanged": timePasswordChanged,

            "username": username,
            "passwordField": passwordField,
            "usernameField": usernameField,
        ]

        if let httpRealm = self.httpRealm {
            dict["httpRealm"] = httpRealm
        }

        if let formSubmitURL = self.formSubmitURL {
            dict["formSubmitURL"] = formSubmitURL
        }

        return dict
    }

    // TODO: handle errors in these... (they shouldn't ever happen
    // outside of bugs since we write the json in rust, but still)

    public convenience init(fromJSONDict dict: [String: Any]) {
        self.init(
            id: dict["id"] as? String ?? "",
            password: dict["password"] as? String ?? "",
            hostname: dict["hostname"] as? String ?? "",

            username: dict["username"] as? String ?? "",

            formSubmitURL: dict["formSubmitURL"] as? String,
            httpRealm: dict["httpRealm"] as? String,

            timesUsed: (dict["timesUsed"] as? Int) ?? 0,
            timeLastUsed: (dict["timeLastUsed"] as? Int64) ?? 0,
            timeCreated: (dict["timeCreated"] as? Int64) ?? 0,
            timePasswordChanged: (dict["timePasswordChanged"] as? Int64) ?? 0,

            usernameField: dict["usernameField"] as? String ?? "",
            passwordField: dict["passwordField"] as? String ?? ""
        )
    }

    init(
        id: String,
        password: String,
        hostname: String,
        username: String,
        formSubmitURL: String?,
        httpRealm: String?,
        timesUsed: Int?,
        timeLastUsed: Int64?,
        timeCreated: Int64?,
        timePasswordChanged: Int64?,
        usernameField: String,
        passwordField: String
    ) {
        self.id = id
        self.password = password
        self.hostname = hostname
        self.username = username
        self.formSubmitURL = formSubmitURL
        self.httpRealm = httpRealm
        self.timesUsed = timesUsed ?? 0
        self.timeLastUsed = timeLastUsed ?? 0
        self.timeCreated = timeCreated ?? 0
        self.timePasswordChanged = timePasswordChanged ?? 0
        self.usernameField = usernameField
        self.passwordField = passwordField
    }

    public convenience init(fromJSONString json: String) throws {
        let dict = try JSONSerialization.jsonObject(
            with: json.data(using: .utf8)!,
            options: [])
        self.init(fromJSONDict: dict as? [String: Any] ?? [String: Any]())
    }

    public static func fromJSONArray(_ jsonArray: String) throws -> [LoginRecord] {
        if let arr = try JSONSerialization.jsonObject(
            with: jsonArray.data(using: .utf8)!,
            options: []) as? [[String: Any]]
        {
            return arr.map { (dict) -> LoginRecord in
                LoginRecord(fromJSONDict: dict)
            }
        }
        return [LoginRecord]()
    }
}

extension LoginRecord {
    public convenience init(credentials: URLCredential, protectionSpace: URLProtectionSpace) {
        let hostname: String
        if let _ = protectionSpace.`protocol` {
            hostname = protectionSpace.urlString()
        } else {
            hostname = protectionSpace.host
        }

        let httpRealm = protectionSpace.realm
        let username = credentials.user
        let password = credentials.password

        self.init(fromJSONDict: [
            "hostname": hostname,
            "httpRealm": httpRealm as Any,
            "username": username ?? "",
            "password": password ?? "",
        ])
    }

    public var credentials: URLCredential {
        return URLCredential(user: username, password: password, persistence: .forSession)
    }

    public var protectionSpace: URLProtectionSpace {
        return URLProtectionSpace.fromOrigin(hostname)
    }

    public var hasMalformedHostname: Bool {
        let hostnameURL = hostname.asURL
        guard let _ = hostnameURL?.host else {
            return true
        }

        return false
    }

    public var isValid: Maybe<()> {
        // Referenced from https://mxr.mozilla.org/mozilla-central/source/toolkit/components/passwordmgr/nsLoginManager.js?rev=f76692f0fcf8&mark=280-281#271

        // Logins with empty hostnames are not valid.
        if hostname.isEmpty {
            return Maybe(
                failure: LoginRecordError(description: "Can't add a login with an empty hostname."))
        }

        // Logins with empty passwords are not valid.
        if password.isEmpty {
            return Maybe(
                failure: LoginRecordError(description: "Can't add a login with an empty password."))
        }

        // Logins with both a formSubmitURL and httpRealm are not valid.
        if let _ = formSubmitURL, let _ = httpRealm {
            return Maybe(
                failure: LoginRecordError(
                    description: "Can't add a login with both a httpRealm and formSubmitURL."))
        }

        // Login must have at least a formSubmitURL or httpRealm.
        if (formSubmitURL == nil) && (httpRealm == nil) {
            return Maybe(
                failure: LoginRecordError(
                    description: "Can't add a login without a httpRealm or formSubmitURL."))
        }

        // All good.
        return Maybe(success: ())
    }
}

public class LoginRecordError: MaybeErrorType {
    public let description: String
    public init(description: String) {
        self.description = description
    }
}

// This is currently a no-op implementation as password form autofill is disabled.
// TODO: Implement a proper backingstore for login data.
public class RustLogins {
    let databasePath: String
    let encryptionKey: String
    let salt: String

    let queue: DispatchQueue

    fileprivate(set) var isOpen: Bool = false

    private var didAttemptToMoveToBackup = false

    public init(databasePath: String, encryptionKey: String, salt: String) {
        self.databasePath = databasePath
        self.encryptionKey = encryptionKey
        self.salt = salt

        self.queue = DispatchQueue(label: "RustLogins queue: \(databasePath)", attributes: [])
    }

    // Migrate and return the salt, or create a new salt
    // Also, in the event of an error, returns a new salt.
    public static func setupPlaintextHeaderAndGetSalt(databasePath: String, encryptionKey: String)
        -> String
    {
        let saltOf32Chars = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return saltOf32Chars
    }

    // Open the db, and if it fails, it moves the db and creates a new db file and opens it.
    private func open() -> NSError? {
        isOpen = true
        return nil
    }

    private func close() -> NSError? {
        return nil
    }

    public func reopenIfClosed() -> NSError? {
        var error: NSError?

        queue.sync {
            guard !isOpen else { return }

            error = open()
        }

        return error
    }

    public func interrupt() {
    }

    public func forceClose() -> NSError? {
        var error: NSError?

        interrupt()

        queue.sync {
            guard isOpen else { return }

            error = close()
        }

        return error
    }

    public func sync( /*unlockInfo: SyncUnlockInfo*/) -> Success {
        let deferred = Success()
        deferred.fill(Maybe(success: ()))
        return deferred
    }

    public func get(id: String) -> Deferred<Maybe<LoginRecord?>> {
        let deferred = Deferred<Maybe<LoginRecord?>>()
        let err = NSError()
        deferred.fill(Maybe(failure: err))
        return deferred
    }

    public func searchLoginsWithQuery(_ query: String?) -> Deferred<Maybe<Cursor<LoginRecord>>> {
        return list().bind({ result in
            if let error = result.failureValue {
                return deferMaybe(error)
            }

            guard let records = result.successValue else {
                return deferMaybe(ArrayCursor(data: []))
            }

            guard let query = query?.lowercased(), !query.isEmpty else {
                return deferMaybe(ArrayCursor(data: records))
            }

            let filteredRecords = records.filter({
                $0.hostname.lowercased().contains(query) || $0.username.lowercased().contains(query)
            })
            return deferMaybe(ArrayCursor(data: filteredRecords))
        })
    }

    public func getLoginsForProtectionSpace(
        _ protectionSpace: URLProtectionSpace, withUsername username: String? = nil
    ) -> Deferred<Maybe<Cursor<LoginRecord>>> {
        return list().bind({ result in
            if let error = result.failureValue {
                return deferMaybe(error)
            }

            guard let records = result.successValue else {
                return deferMaybe(ArrayCursor(data: []))
            }

            let filteredRecords: [LoginRecord]
            if let username = username {
                filteredRecords = records.filter({
                    $0.username == username
                        && ($0.hostname == protectionSpace.urlString()
                            || $0.hostname == protectionSpace.host)
                })
            } else {
                filteredRecords = records.filter({
                    $0.hostname == protectionSpace.urlString()
                        || $0.hostname == protectionSpace.host
                })
            }
            return deferMaybe(ArrayCursor(data: filteredRecords))
        })
    }

    public func hasSyncedLogins() -> Deferred<Maybe<Bool>> {
        return list().bind({ result in
            if let error = result.failureValue {
                return deferMaybe(error)
            }

            return deferMaybe((result.successValue?.count ?? 0) > 0)
        })
    }

    public func list() -> Deferred<Maybe<[LoginRecord]>> {
        let deferred = Deferred<Maybe<[LoginRecord]>>()
        let err = NSError()
        deferred.fill(Maybe(failure: err))
        return deferred
    }

    public func add(login: LoginRecord) -> Deferred<Maybe<String>> {
        let deferred = Deferred<Maybe<String>>()
        let err = NSError()
        deferred.fill(Maybe(failure: err))
        return deferred
    }

    public func use(login: LoginRecord) -> Success {
        login.timesUsed += 1
        login.timeLastUsed = Int64(Date.nowMicroseconds())

        return update(login: login)
    }

    public func update(login: LoginRecord) -> Success {
        let deferred = Success()
        deferred.fill(Maybe(success: ()))
        return deferred
    }

    public func delete(ids: [String]) -> Deferred<[Maybe<Bool>]> {
        return all(ids.map({ delete(id: $0) }))
    }

    public func delete(id: String) -> Deferred<Maybe<Bool>> {
        let deferred = Deferred<Maybe<Bool>>()
        let err = NSError()
        deferred.fill(Maybe(failure: err))
        return deferred
    }

    public func reset() -> Success {
        let deferred = Success()
        deferred.fill(Maybe(success: ()))
        return deferred
    }

    public func wipeLocal() -> Success {
        let deferred = Success()
        deferred.fill(Maybe(success: ()))
        return deferred
    }
}
