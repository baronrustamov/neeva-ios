// swift-format-ignore-file
// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

/// Input type for client logs.
///
/// Client logs are generic, and cover every type of log that the client
/// may want to pass, including counters, pingbacks, trace information, errors,
/// etc. Log messages from the client are batched, and each batch contains
/// base information invariant across the lifetime of the client.
public struct ClientLogInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - base: Base information to send along with a log batch. This information is
  /// invariant across each log message within a batch.
  ///
  /// DEPRECATED:
  /// Removed from client code 2020-07-31
  ///   - web: 0.2.105
  ///   - ios: 0.4.1
  ///   - log: One or more log messages. Since log messages can be batched, we expose
  /// an interface for sending multiple logs at once. If this list is empty,
  /// the log call is a NOOP.
  public init(base: Swift.Optional<ClientLogBase?> = nil, log: [ClientLog]) {
    graphQLMap = ["base": base, "log": log]
  }

  /// Base information to send along with a log batch. This information is
  /// invariant across each log message within a batch.
  ///
  /// DEPRECATED:
  /// Removed from client code 2020-07-31
  /// - web: 0.2.105
  /// - ios: 0.4.1
  public var base: Swift.Optional<ClientLogBase?> {
    get {
      return graphQLMap["base"] as? Swift.Optional<ClientLogBase?> ?? Swift.Optional<ClientLogBase?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "base")
    }
  }

  /// One or more log messages. Since log messages can be batched, we expose
  /// an interface for sending multiple logs at once. If this list is empty,
  /// the log call is a NOOP.
  public var log: [ClientLog] {
    get {
      return graphQLMap["log"] as! [ClientLog]
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "log")
    }
  }
}

public struct ClientLogBase: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - id: Which client this log request comes from. This should be of the form
  /// used to identify the client on its platform; i.e. 'co.neeva.app.ios'
  /// or 'co.neeva.app.web'.
  ///   - version: The version number of the client. Version numbering will vary based
  /// on the client ID.
  ///   - environment: The client environment, e.g. dev or prod.
  public init(id: String, version: String, environment: ClientLogEnvironment) {
    graphQLMap = ["id": id, "version": version, "environment": environment]
  }

  /// Which client this log request comes from. This should be of the form
  /// used to identify the client on its platform; i.e. 'co.neeva.app.ios'
  /// or 'co.neeva.app.web'.
  public var id: String {
    get {
      return graphQLMap["id"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  /// The version number of the client. Version numbering will vary based
  /// on the client ID.
  public var version: String {
    get {
      return graphQLMap["version"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "version")
    }
  }

  /// The client environment, e.g. dev or prod.
  public var environment: ClientLogEnvironment {
    get {
      return graphQLMap["environment"] as! ClientLogEnvironment
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "environment")
    }
  }
}

public enum ClientLogEnvironment: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case dev
  case prod
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Dev": self = .dev
      case "Prod": self = .prod
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .dev: return "Dev"
      case .prod: return "Prod"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ClientLogEnvironment, rhs: ClientLogEnvironment) -> Bool {
    switch (lhs, rhs) {
      case (.dev, .dev): return true
      case (.prod, .prod): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ClientLogEnvironment] {
    return [
      .dev,
      .prod,
    ]
  }
}

/// A client log message. This represents a single log message sent by the
/// client as part of a log batch. All but one of the subfields should be
/// nil.
public struct ClientLog: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - counter
  ///   - graphql
  ///   - tracking
  ///   - interactionEvent: DEPRECATED
  /// Moving to new interaction input, InteractionEventInput
  /// Version:
  /// - webui: 0.2.18
  /// - nativeui: 0.2.20
  /// Date: 12/27/2019.
  ///   - interactionV3Event
  ///   - searchPerfEvent
  ///   - suggestPerfEvent
  ///   - appleMapkitResourcePerfEvent
  ///   - perfTrace
  public init(counter: Swift.Optional<ClientLogCounter?> = nil, graphql: Swift.Optional<ClientLogGraphql?> = nil, tracking: Swift.Optional<ClientLogTracking?> = nil, interactionEvent: Swift.Optional<InteractionEventInput?> = nil, interactionV3Event: Swift.Optional<InteractionV3EventInput?> = nil, searchPerfEvent: Swift.Optional<SearchPerfEventInput?> = nil, suggestPerfEvent: Swift.Optional<SuggestPerfEventInput?> = nil, appleMapkitResourcePerfEvent: Swift.Optional<AppleMapkitResourcePerfEventInput?> = nil, perfTrace: Swift.Optional<PerfTraceInput?> = nil) {
    graphQLMap = ["counter": counter, "graphql": graphql, "tracking": tracking, "interactionEvent": interactionEvent, "interactionV3Event": interactionV3Event, "searchPerfEvent": searchPerfEvent, "suggestPerfEvent": suggestPerfEvent, "appleMapkitResourcePerfEvent": appleMapkitResourcePerfEvent, "perfTrace": perfTrace]
  }

  public var counter: Swift.Optional<ClientLogCounter?> {
    get {
      return graphQLMap["counter"] as? Swift.Optional<ClientLogCounter?> ?? Swift.Optional<ClientLogCounter?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "counter")
    }
  }

  public var graphql: Swift.Optional<ClientLogGraphql?> {
    get {
      return graphQLMap["graphql"] as? Swift.Optional<ClientLogGraphql?> ?? Swift.Optional<ClientLogGraphql?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "graphql")
    }
  }

  public var tracking: Swift.Optional<ClientLogTracking?> {
    get {
      return graphQLMap["tracking"] as? Swift.Optional<ClientLogTracking?> ?? Swift.Optional<ClientLogTracking?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "tracking")
    }
  }

  /// DEPRECATED
  /// Moving to new interaction input, InteractionEventInput
  /// Version:
  /// - webui: 0.2.18
  /// - nativeui: 0.2.20
  /// Date: 12/27/2019.
  public var interactionEvent: Swift.Optional<InteractionEventInput?> {
    get {
      return graphQLMap["interactionEvent"] as? Swift.Optional<InteractionEventInput?> ?? Swift.Optional<InteractionEventInput?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "interactionEvent")
    }
  }

  public var interactionV3Event: Swift.Optional<InteractionV3EventInput?> {
    get {
      return graphQLMap["interactionV3Event"] as? Swift.Optional<InteractionV3EventInput?> ?? Swift.Optional<InteractionV3EventInput?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "interactionV3Event")
    }
  }

  public var searchPerfEvent: Swift.Optional<SearchPerfEventInput?> {
    get {
      return graphQLMap["searchPerfEvent"] as? Swift.Optional<SearchPerfEventInput?> ?? Swift.Optional<SearchPerfEventInput?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "searchPerfEvent")
    }
  }

  public var suggestPerfEvent: Swift.Optional<SuggestPerfEventInput?> {
    get {
      return graphQLMap["suggestPerfEvent"] as? Swift.Optional<SuggestPerfEventInput?> ?? Swift.Optional<SuggestPerfEventInput?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "suggestPerfEvent")
    }
  }

  public var appleMapkitResourcePerfEvent: Swift.Optional<AppleMapkitResourcePerfEventInput?> {
    get {
      return graphQLMap["appleMapkitResourcePerfEvent"] as? Swift.Optional<AppleMapkitResourcePerfEventInput?> ?? Swift.Optional<AppleMapkitResourcePerfEventInput?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "appleMapkitResourcePerfEvent")
    }
  }

  public var perfTrace: Swift.Optional<PerfTraceInput?> {
    get {
      return graphQLMap["perfTrace"] as? Swift.Optional<PerfTraceInput?> ?? Swift.Optional<PerfTraceInput?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "perfTrace")
    }
  }
}

/// Information to be exposed as a counter. The effect will be to increment
/// whatever path is provided.
public struct ClientLogCounter: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - path: The path of the counter, which may be an arbitrary string.
  ///   - attributes: Arbitrary key/value pairs to associate with the counter.
  public init(path: String, attributes: Swift.Optional<[ClientLogCounterAttribute]?> = nil) {
    graphQLMap = ["path": path, "attributes": attributes]
  }

  /// The path of the counter, which may be an arbitrary string.
  public var path: String {
    get {
      return graphQLMap["path"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "path")
    }
  }

  /// Arbitrary key/value pairs to associate with the counter.
  public var attributes: Swift.Optional<[ClientLogCounterAttribute]?> {
    get {
      return graphQLMap["attributes"] as? Swift.Optional<[ClientLogCounterAttribute]?> ?? Swift.Optional<[ClientLogCounterAttribute]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attributes")
    }
  }
}

public struct ClientLogCounterAttribute: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - key
  ///   - value
  public init(key: Swift.Optional<String?> = nil, value: Swift.Optional<String?> = nil) {
    graphQLMap = ["key": key, "value": value]
  }

  public var key: Swift.Optional<String?> {
    get {
      return graphQLMap["key"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "key")
    }
  }

  public var value: Swift.Optional<String?> {
    get {
      return graphQLMap["value"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "value")
    }
  }
}

/// Information about a graphql call from the client side.
public struct ClientLogGraphql: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - name: The query name.
  ///   - type: The type of query, Mutation or Query.
  ///   - status: The status of the query as of this log message.
  ///   - elapsedTimeMs: If the status is Complete or Error (in other words, if the query is
  /// completed), this will give the total time elapsed from "Loading"
  /// to the completion status.
  ///   - errorInfo: Error information about this query. If the query does not end in an
  /// error, then this will be empty.
  public init(name: Swift.Optional<String?> = nil, type: Swift.Optional<ClientLogGraphqlType?> = nil, status: Swift.Optional<ClientLogGraphqlStatus?> = nil, elapsedTimeMs: Swift.Optional<Int?> = nil, errorInfo: Swift.Optional<ClientLogGraphqlErrorInfo?> = nil) {
    graphQLMap = ["name": name, "type": type, "status": status, "elapsedTimeMs": elapsedTimeMs, "errorInfo": errorInfo]
  }

  /// The query name.
  public var name: Swift.Optional<String?> {
    get {
      return graphQLMap["name"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  /// The type of query, Mutation or Query.
  public var type: Swift.Optional<ClientLogGraphqlType?> {
    get {
      return graphQLMap["type"] as? Swift.Optional<ClientLogGraphqlType?> ?? Swift.Optional<ClientLogGraphqlType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  /// The status of the query as of this log message.
  public var status: Swift.Optional<ClientLogGraphqlStatus?> {
    get {
      return graphQLMap["status"] as? Swift.Optional<ClientLogGraphqlStatus?> ?? Swift.Optional<ClientLogGraphqlStatus?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "status")
    }
  }

  /// If the status is Complete or Error (in other words, if the query is
  /// completed), this will give the total time elapsed from "Loading"
  /// to the completion status.
  public var elapsedTimeMs: Swift.Optional<Int?> {
    get {
      return graphQLMap["elapsedTimeMs"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "elapsedTimeMs")
    }
  }

  /// Error information about this query. If the query does not end in an
  /// error, then this will be empty.
  public var errorInfo: Swift.Optional<ClientLogGraphqlErrorInfo?> {
    get {
      return graphQLMap["errorInfo"] as? Swift.Optional<ClientLogGraphqlErrorInfo?> ?? Swift.Optional<ClientLogGraphqlErrorInfo?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "errorInfo")
    }
  }
}

public enum ClientLogGraphqlType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case query
  case mutation
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Query": self = .query
      case "Mutation": self = .mutation
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .query: return "Query"
      case .mutation: return "Mutation"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ClientLogGraphqlType, rhs: ClientLogGraphqlType) -> Bool {
    switch (lhs, rhs) {
      case (.query, .query): return true
      case (.mutation, .mutation): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ClientLogGraphqlType] {
    return [
      .query,
      .mutation,
    ]
  }
}

public enum ClientLogGraphqlStatus: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case started
  case complete
  case error
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Started": self = .started
      case "Complete": self = .complete
      case "Error": self = .error
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .started: return "Started"
      case .complete: return "Complete"
      case .error: return "Error"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ClientLogGraphqlStatus, rhs: ClientLogGraphqlStatus) -> Bool {
    switch (lhs, rhs) {
      case (.started, .started): return true
      case (.complete, .complete): return true
      case (.error, .error): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ClientLogGraphqlStatus] {
    return [
      .started,
      .complete,
      .error,
    ]
  }
}

public struct ClientLogGraphqlErrorInfo: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - type: Type of the error.
  ///   - httpResponseCode: HTTP response code, if one exists.
  public init(type: Swift.Optional<ClientLogGraphqlErrorInfoType?> = nil, httpResponseCode: Swift.Optional<Int?> = nil) {
    graphQLMap = ["type": type, "httpResponseCode": httpResponseCode]
  }

  /// Type of the error.
  public var type: Swift.Optional<ClientLogGraphqlErrorInfoType?> {
    get {
      return graphQLMap["type"] as? Swift.Optional<ClientLogGraphqlErrorInfoType?> ?? Swift.Optional<ClientLogGraphqlErrorInfoType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  /// HTTP response code, if one exists.
  public var httpResponseCode: Swift.Optional<Int?> {
    get {
      return graphQLMap["httpResponseCode"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "httpResponseCode")
    }
  }
}

public enum ClientLogGraphqlErrorInfoType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case httpError
  case graphqlError
  case networkError
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "HttpError": self = .httpError
      case "GraphqlError": self = .graphqlError
      case "NetworkError": self = .networkError
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .httpError: return "HttpError"
      case .graphqlError: return "GraphqlError"
      case .networkError: return "NetworkError"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ClientLogGraphqlErrorInfoType, rhs: ClientLogGraphqlErrorInfoType) -> Bool {
    switch (lhs, rhs) {
      case (.httpError, .httpError): return true
      case (.graphqlError, .graphqlError): return true
      case (.networkError, .networkError): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ClientLogGraphqlErrorInfoType] {
    return [
      .httpError,
      .graphqlError,
      .networkError,
    ]
  }
}

public struct ClientLogTracking: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - topDomain: Top domain of the frame
  ///   - frameDomain: Domain of the frame which loads the tracking url
  ///   - originAndPath: Origin and path of the tracker url
  ///   - logType: Type of the data, generated rule or potential tracker
  public init(topDomain: String, frameDomain: String, originAndPath: String, logType: Swift.Optional<ClientLogTrackingLogType?> = nil) {
    graphQLMap = ["topDomain": topDomain, "frameDomain": frameDomain, "originAndPath": originAndPath, "logType": logType]
  }

  /// Top domain of the frame
  public var topDomain: String {
    get {
      return graphQLMap["topDomain"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "topDomain")
    }
  }

  /// Domain of the frame which loads the tracking url
  public var frameDomain: String {
    get {
      return graphQLMap["frameDomain"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "frameDomain")
    }
  }

  /// Origin and path of the tracker url
  public var originAndPath: String {
    get {
      return graphQLMap["originAndPath"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "originAndPath")
    }
  }

  /// Type of the data, generated rule or potential tracker
  public var logType: Swift.Optional<ClientLogTrackingLogType?> {
    get {
      return graphQLMap["logType"] as? Swift.Optional<ClientLogTrackingLogType?> ?? Swift.Optional<ClientLogTrackingLogType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "logType")
    }
  }
}

public enum ClientLogTrackingLogType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Potential tracker, url appeared in 3P context and domain not owned by the main site.
  case potentialTracker
  /// Small gif returned in response. This is a beacon url
  case smallGifRule
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "PotentialTracker": self = .potentialTracker
      case "SmallGifRule": self = .smallGifRule
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .potentialTracker: return "PotentialTracker"
      case .smallGifRule: return "SmallGifRule"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ClientLogTrackingLogType, rhs: ClientLogTrackingLogType) -> Bool {
    switch (lhs, rhs) {
      case (.potentialTracker, .potentialTracker): return true
      case (.smallGifRule, .smallGifRule): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ClientLogTrackingLogType] {
    return [
      .potentialTracker,
      .smallGifRule,
    ]
  }
}

/// Input type for logInteraction mutation.
///
/// Though this is not officially deprecated (and still works), new interactions
/// should be added to the interactionV3Event instead.
public struct InteractionEventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - loggingContexts: Array of all logging contexts
  ///   - pageType: Type of Page search, activity, etc
  ///   - serverResultType: Type of result
  ///   - parentEventId: Event ID of query/activity event which generated this result
  ///   - resultId: DocId of the result for which the event being recorded
  ///   - type: Type of interaction
  ///   - pageEventAttributes: Page Attribute data
  ///   - resultGroupAttributes: Result Group Attributes
  public init(loggingContexts: Swift.Optional<[LoggingContext]?> = nil, pageType: Swift.Optional<String?> = nil, serverResultType: Swift.Optional<String?> = nil, parentEventId: Swift.Optional<String?> = nil, resultId: Swift.Optional<String?> = nil, type: Swift.Optional<InteractionType?> = nil, pageEventAttributes: Swift.Optional<PageEventAttributes?> = nil, resultGroupAttributes: Swift.Optional<ResultGroupAttributes?> = nil) {
    graphQLMap = ["loggingContexts": loggingContexts, "pageType": pageType, "serverResultType": serverResultType, "parentEventID": parentEventId, "resultID": resultId, "type": type, "pageEventAttributes": pageEventAttributes, "resultGroupAttributes": resultGroupAttributes]
  }

  /// Array of all logging contexts
  public var loggingContexts: Swift.Optional<[LoggingContext]?> {
    get {
      return graphQLMap["loggingContexts"] as? Swift.Optional<[LoggingContext]?> ?? Swift.Optional<[LoggingContext]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "loggingContexts")
    }
  }

  /// Type of Page search, activity, etc
  public var pageType: Swift.Optional<String?> {
    get {
      return graphQLMap["pageType"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "pageType")
    }
  }

  /// Type of result
  public var serverResultType: Swift.Optional<String?> {
    get {
      return graphQLMap["serverResultType"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "serverResultType")
    }
  }

  /// Event ID of query/activity event which generated this result
  public var parentEventId: Swift.Optional<String?> {
    get {
      return graphQLMap["parentEventID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "parentEventID")
    }
  }

  /// DocId of the result for which the event being recorded
  public var resultId: Swift.Optional<String?> {
    get {
      return graphQLMap["resultID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultID")
    }
  }

  /// Type of interaction
  public var type: Swift.Optional<InteractionType?> {
    get {
      return graphQLMap["type"] as? Swift.Optional<InteractionType?> ?? Swift.Optional<InteractionType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  /// Page Attribute data
  public var pageEventAttributes: Swift.Optional<PageEventAttributes?> {
    get {
      return graphQLMap["pageEventAttributes"] as? Swift.Optional<PageEventAttributes?> ?? Swift.Optional<PageEventAttributes?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "pageEventAttributes")
    }
  }

  /// Result Group Attributes
  public var resultGroupAttributes: Swift.Optional<ResultGroupAttributes?> {
    get {
      return graphQLMap["resultGroupAttributes"] as? Swift.Optional<ResultGroupAttributes?> ?? Swift.Optional<ResultGroupAttributes?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultGroupAttributes")
    }
  }
}

/// Logging context collects all ambient data, not specific to element type.
/// Individual contexts may contain different macros based on it's location in hierarchy.
/// For eg. Top level context may collect macros related to page
public struct LoggingContext: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - docId
  ///   - macros
  ///   - category: Logging category, e.g. page/group/container/result.
  ///   - serverResultType: ResultType sent by metadata
  ///   - placeActionType: Type of action on place results
  ///   - universalActionType: Type of action on carousel links
  ///   - oneBoxActionType: Type of action on onebox
  ///   - resultGroupActionType: Type of action on result group
  ///   - resultActionType: An ActionLink or Link from a result
  public init(docId: Swift.Optional<String?> = nil, macros: Swift.Optional<[PopulatedClientMacro]?> = nil, category: Swift.Optional<String?> = nil, serverResultType: Swift.Optional<String?> = nil, placeActionType: Swift.Optional<PlaceActionType?> = nil, universalActionType: Swift.Optional<UniversalActionType?> = nil, oneBoxActionType: Swift.Optional<OneBoxActionType?> = nil, resultGroupActionType: Swift.Optional<ResultGroupActionType?> = nil, resultActionType: Swift.Optional<ResultActionType?> = nil) {
    graphQLMap = ["docID": docId, "macros": macros, "category": category, "serverResultType": serverResultType, "placeActionType": placeActionType, "universalActionType": universalActionType, "oneBoxActionType": oneBoxActionType, "resultGroupActionType": resultGroupActionType, "resultActionType": resultActionType]
  }

  public var docId: Swift.Optional<String?> {
    get {
      return graphQLMap["docID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "docID")
    }
  }

  public var macros: Swift.Optional<[PopulatedClientMacro]?> {
    get {
      return graphQLMap["macros"] as? Swift.Optional<[PopulatedClientMacro]?> ?? Swift.Optional<[PopulatedClientMacro]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "macros")
    }
  }

  /// Logging category, e.g. page/group/container/result.
  public var category: Swift.Optional<String?> {
    get {
      return graphQLMap["category"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  /// ResultType sent by metadata
  public var serverResultType: Swift.Optional<String?> {
    get {
      return graphQLMap["serverResultType"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "serverResultType")
    }
  }

  /// Type of action on place results
  public var placeActionType: Swift.Optional<PlaceActionType?> {
    get {
      return graphQLMap["placeActionType"] as? Swift.Optional<PlaceActionType?> ?? Swift.Optional<PlaceActionType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "placeActionType")
    }
  }

  /// Type of action on carousel links
  public var universalActionType: Swift.Optional<UniversalActionType?> {
    get {
      return graphQLMap["universalActionType"] as? Swift.Optional<UniversalActionType?> ?? Swift.Optional<UniversalActionType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "universalActionType")
    }
  }

  /// Type of action on onebox
  public var oneBoxActionType: Swift.Optional<OneBoxActionType?> {
    get {
      return graphQLMap["oneBoxActionType"] as? Swift.Optional<OneBoxActionType?> ?? Swift.Optional<OneBoxActionType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "oneBoxActionType")
    }
  }

  /// Type of action on result group
  public var resultGroupActionType: Swift.Optional<ResultGroupActionType?> {
    get {
      return graphQLMap["resultGroupActionType"] as? Swift.Optional<ResultGroupActionType?> ?? Swift.Optional<ResultGroupActionType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultGroupActionType")
    }
  }

  /// An ActionLink or Link from a result
  public var resultActionType: Swift.Optional<ResultActionType?> {
    get {
      return graphQLMap["resultActionType"] as? Swift.Optional<ResultActionType?> ?? Swift.Optional<ResultActionType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultActionType")
    }
  }
}

/// A macro populated and returned by the client.
public struct PopulatedClientMacro: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - type: Type of the macro being populated.
  ///   - value: Client-populated value of the macro. The format of this may vary depending
  /// on the type of the macro being returned. Please see documentation on the
  /// ClientMacroType enum for more details about format.
  public init(type: ClientMacroType, value: String) {
    graphQLMap = ["type": type, "value": value]
  }

  /// Type of the macro being populated.
  public var type: ClientMacroType {
    get {
      return graphQLMap["type"] as! ClientMacroType
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  /// Client-populated value of the macro. The format of this may vary depending
  /// on the type of the macro being returned. Please see documentation on the
  /// ClientMacroType enum for more details about format.
  public var value: String {
    get {
      return graphQLMap["value"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "value")
    }
  }
}

/// Enum of types of data that the client should be able to fill out and
/// report when returning log messages.
public enum ClientMacroType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Height of the viewport in pixels.
  case viewportHeight
  /// Width of the viewport in pixels.
  case viewportWidth
  /// Height of the scroll in pixels.
  case scrollHeight
  /// Right or left click
  case clickType
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ViewportHeight": self = .viewportHeight
      case "ViewportWidth": self = .viewportWidth
      case "ScrollHeight": self = .scrollHeight
      case "ClickType": self = .clickType
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .viewportHeight: return "ViewportHeight"
      case .viewportWidth: return "ViewportWidth"
      case .scrollHeight: return "ScrollHeight"
      case .clickType: return "ClickType"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ClientMacroType, rhs: ClientMacroType) -> Bool {
    switch (lhs, rhs) {
      case (.viewportHeight, .viewportHeight): return true
      case (.viewportWidth, .viewportWidth): return true
      case (.scrollHeight, .scrollHeight): return true
      case (.clickType, .clickType): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ClientMacroType] {
    return [
      .viewportHeight,
      .viewportWidth,
      .scrollHeight,
      .clickType,
    ]
  }
}

/// Enum for action taken on on place click
public enum PlaceActionType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Clicked call of local listing
  case call
  /// Clicked on telephone to call
  case telephone
  /// Clicked direction of local listing
  case direction
  /// Clicked on Address of the listing
  case address
  /// Clicked website of local listing
  case website
  /// Clicked on website url
  case websiteUrl
  /// Clicked on Place Name
  case name
  /// Clicked on Yelp URL
  case yelpUrl
  /// Clicked on operating status/hours
  case operatingStatus
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Call": self = .call
      case "Telephone": self = .telephone
      case "Direction": self = .direction
      case "Address": self = .address
      case "Website": self = .website
      case "WebsiteUrl": self = .websiteUrl
      case "Name": self = .name
      case "YelpUrl": self = .yelpUrl
      case "OperatingStatus": self = .operatingStatus
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .call: return "Call"
      case .telephone: return "Telephone"
      case .direction: return "Direction"
      case .address: return "Address"
      case .website: return "Website"
      case .websiteUrl: return "WebsiteUrl"
      case .name: return "Name"
      case .yelpUrl: return "YelpUrl"
      case .operatingStatus: return "OperatingStatus"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: PlaceActionType, rhs: PlaceActionType) -> Bool {
    switch (lhs, rhs) {
      case (.call, .call): return true
      case (.telephone, .telephone): return true
      case (.direction, .direction): return true
      case (.address, .address): return true
      case (.website, .website): return true
      case (.websiteUrl, .websiteUrl): return true
      case (.name, .name): return true
      case (.yelpUrl, .yelpUrl): return true
      case (.operatingStatus, .operatingStatus): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [PlaceActionType] {
    return [
      .call,
      .telephone,
      .direction,
      .address,
      .website,
      .websiteUrl,
      .name,
      .yelpUrl,
      .operatingStatus,
    ]
  }
}

public enum UniversalActionType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// User clicked section link on top of the universal
  case sectionTitleClick
  /// More click
  case moreClick
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "SectionTitleClick": self = .sectionTitleClick
      case "MoreClick": self = .moreClick
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .sectionTitleClick: return "SectionTitleClick"
      case .moreClick: return "MoreClick"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: UniversalActionType, rhs: UniversalActionType) -> Bool {
    switch (lhs, rhs) {
      case (.sectionTitleClick, .sectionTitleClick): return true
      case (.moreClick, .moreClick): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [UniversalActionType] {
    return [
      .sectionTitleClick,
      .moreClick,
    ]
  }
}

public enum OneBoxActionType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Opened onebox
  case `open`
  /// Closed onebox
  case close
  /// Temperature unit is changed
  case tempUnitChange
  /// Daily forecast change
  case dailyForecast
  /// Stock time range
  case stockTimeRange
  /// The user clicks expand
  case expand
  /// The user clicks collapse
  case collapse
  /// The user clicks previous
  case previous
  /// The user clicks next
  case next
  /// The user clicks to switch tab
  case switchTab
  /// User clicked to change product in buying guide
  case buyingGuideNavigationClick
  /// The user clicks expand on a rich caption
  case richCaptionExpand
  /// User clicked to view the user who wrote a tech Q 'n A answer
  case techQnaAttributionClick
  /// User clicked to toggle the full tech Q 'n A result
  case techQnaShowAllToggleClick
  /// User click to expand RHS
  case expandRhs
  /// User clicks on the primary action URL
  case primaryActionUrl
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Open": self = .open
      case "Close": self = .close
      case "TempUnitChange": self = .tempUnitChange
      case "DailyForecast": self = .dailyForecast
      case "StockTimeRange": self = .stockTimeRange
      case "Expand": self = .expand
      case "Collapse": self = .collapse
      case "Previous": self = .previous
      case "Next": self = .next
      case "SwitchTab": self = .switchTab
      case "BuyingGuideNavigationClick": self = .buyingGuideNavigationClick
      case "RichCaptionExpand": self = .richCaptionExpand
      case "TechQNAAttributionClick": self = .techQnaAttributionClick
      case "TechQNAShowAllToggleClick": self = .techQnaShowAllToggleClick
      case "ExpandRhs": self = .expandRhs
      case "PrimaryActionURL": self = .primaryActionUrl
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .open: return "Open"
      case .close: return "Close"
      case .tempUnitChange: return "TempUnitChange"
      case .dailyForecast: return "DailyForecast"
      case .stockTimeRange: return "StockTimeRange"
      case .expand: return "Expand"
      case .collapse: return "Collapse"
      case .previous: return "Previous"
      case .next: return "Next"
      case .switchTab: return "SwitchTab"
      case .buyingGuideNavigationClick: return "BuyingGuideNavigationClick"
      case .richCaptionExpand: return "RichCaptionExpand"
      case .techQnaAttributionClick: return "TechQNAAttributionClick"
      case .techQnaShowAllToggleClick: return "TechQNAShowAllToggleClick"
      case .expandRhs: return "ExpandRhs"
      case .primaryActionUrl: return "PrimaryActionURL"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: OneBoxActionType, rhs: OneBoxActionType) -> Bool {
    switch (lhs, rhs) {
      case (.open, .open): return true
      case (.close, .close): return true
      case (.tempUnitChange, .tempUnitChange): return true
      case (.dailyForecast, .dailyForecast): return true
      case (.stockTimeRange, .stockTimeRange): return true
      case (.expand, .expand): return true
      case (.collapse, .collapse): return true
      case (.previous, .previous): return true
      case (.next, .next): return true
      case (.switchTab, .switchTab): return true
      case (.buyingGuideNavigationClick, .buyingGuideNavigationClick): return true
      case (.richCaptionExpand, .richCaptionExpand): return true
      case (.techQnaAttributionClick, .techQnaAttributionClick): return true
      case (.techQnaShowAllToggleClick, .techQnaShowAllToggleClick): return true
      case (.expandRhs, .expandRhs): return true
      case (.primaryActionUrl, .primaryActionUrl): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [OneBoxActionType] {
    return [
      .open,
      .close,
      .tempUnitChange,
      .dailyForecast,
      .stockTimeRange,
      .expand,
      .collapse,
      .previous,
      .next,
      .switchTab,
      .buyingGuideNavigationClick,
      .richCaptionExpand,
      .techQnaAttributionClick,
      .techQnaShowAllToggleClick,
      .expandRhs,
      .primaryActionUrl,
    ]
  }
}

/// Result group action type
public enum ResultGroupActionType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// The user clicks show more
  case showMore
  /// The user clicks show less
  case showLess
  /// The user clicks undo done
  case done
  /// The user clicks undo done
  case undoDone
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ShowMore": self = .showMore
      case "ShowLess": self = .showLess
      case "Done": self = .done
      case "UndoDone": self = .undoDone
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .showMore: return "ShowMore"
      case .showLess: return "ShowLess"
      case .done: return "Done"
      case .undoDone: return "UndoDone"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ResultGroupActionType, rhs: ResultGroupActionType) -> Bool {
    switch (lhs, rhs) {
      case (.showMore, .showMore): return true
      case (.showLess, .showLess): return true
      case (.done, .done): return true
      case (.undoDone, .undoDone): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ResultGroupActionType] {
    return [
      .showMore,
      .showLess,
      .done,
      .undoDone,
    ]
  }
}

public enum ResultActionType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Clicked ReviewWidget All Reviews
  case allReviewsClick
  /// Clicked to CamelCamelCamel
  case camelCamelCamelPricePage
  /// Clicked QNA All Questions
  case qnaAllQuestionsClick
  /// Clicked on Expert Review RHS
  case expertReview
  /// Clicked on Retailer item on RHS
  case retailer
  /// Clicked on Photos item on RHS
  case photo
  /// Clicked on Related Products on RHS
  case relatedProduct
  /// Rich Entity click on header URL
  case richEntityHeaderLink
  /// Rich Entity social profile click
  case richEntitySocialProfile
  /// Rich Entity fact link click
  case richEntityFact
  /// Rich entity click on inline Wikipedia URL
  case richEntityInlineLink
  /// Rich entity click on related search entity
  case richEntityRelatedSearchClick
  /// Rich entity show entire snippet paragraph
  case richEntityToggleFullSnippet
  /// Rich entity show all facts
  case richEntityToggleAllFacts
  /// Rich entity show all facts values
  case richEntityToggleAllValues
  /// Rich entity click on a TV episode
  case richEntityTvEpisodeClick
  /// Rich entity click to toggle all episodes view
  case richEntityTvEpisodeAllToggle
  /// User clicked to view the Tweet on twitter.com
  case twitterStatusClick
  /// User clicked to view the link from the Tweet
  case twitterDisplayUrlClick
  /// User clicked to view the tweet owner's profile
  case twitterProfileUrlClick
  /// User clicked to view KG related answer
  case knowledgeGraphAnswerNodeClick
  /// Deprecated
  case techQnaAttributionClick
  /// User clicked to change product in buying guide
  case buyingGuideNavigationClick
  /// User clicked out from a rich caption
  case richCaptionClick
  /// User click to trigger internal query
  case internalQuery
  /// User clicks on an inline SRP product result
  case inlineSrpProduct
  /// User clicks to toggle a related QnA result
  case relatedQnaToggle
  /// User clicks to view the full answer from a related QnA result
  case relatedQnAActionLink
  /// User clicks on purchase link
  case purchaseLink
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "AllReviewsClick": self = .allReviewsClick
      case "CamelCamelCamelPricePage": self = .camelCamelCamelPricePage
      case "QNAAllQuestionsClick": self = .qnaAllQuestionsClick
      case "ExpertReview": self = .expertReview
      case "Retailer": self = .retailer
      case "Photo": self = .photo
      case "RelatedProduct": self = .relatedProduct
      case "RichEntityHeaderLink": self = .richEntityHeaderLink
      case "RichEntitySocialProfile": self = .richEntitySocialProfile
      case "RichEntityFact": self = .richEntityFact
      case "RichEntityInlineLink": self = .richEntityInlineLink
      case "RichEntityRelatedSearchClick": self = .richEntityRelatedSearchClick
      case "RichEntityToggleFullSnippet": self = .richEntityToggleFullSnippet
      case "RichEntityToggleAllFacts": self = .richEntityToggleAllFacts
      case "RichEntityToggleAllValues": self = .richEntityToggleAllValues
      case "RichEntityTVEpisodeClick": self = .richEntityTvEpisodeClick
      case "RichEntityTVEpisodeAllToggle": self = .richEntityTvEpisodeAllToggle
      case "TwitterStatusClick": self = .twitterStatusClick
      case "TwitterDisplayURLClick": self = .twitterDisplayUrlClick
      case "TwitterProfileURLClick": self = .twitterProfileUrlClick
      case "KnowledgeGraphAnswerNodeClick": self = .knowledgeGraphAnswerNodeClick
      case "TechQNAAttributionClick": self = .techQnaAttributionClick
      case "BuyingGuideNavigationClick": self = .buyingGuideNavigationClick
      case "RichCaptionClick": self = .richCaptionClick
      case "InternalQuery": self = .internalQuery
      case "InlineSrpProduct": self = .inlineSrpProduct
      case "RelatedQnaToggle": self = .relatedQnaToggle
      case "RelatedQnAActionLink": self = .relatedQnAActionLink
      case "PurchaseLink": self = .purchaseLink
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .allReviewsClick: return "AllReviewsClick"
      case .camelCamelCamelPricePage: return "CamelCamelCamelPricePage"
      case .qnaAllQuestionsClick: return "QNAAllQuestionsClick"
      case .expertReview: return "ExpertReview"
      case .retailer: return "Retailer"
      case .photo: return "Photo"
      case .relatedProduct: return "RelatedProduct"
      case .richEntityHeaderLink: return "RichEntityHeaderLink"
      case .richEntitySocialProfile: return "RichEntitySocialProfile"
      case .richEntityFact: return "RichEntityFact"
      case .richEntityInlineLink: return "RichEntityInlineLink"
      case .richEntityRelatedSearchClick: return "RichEntityRelatedSearchClick"
      case .richEntityToggleFullSnippet: return "RichEntityToggleFullSnippet"
      case .richEntityToggleAllFacts: return "RichEntityToggleAllFacts"
      case .richEntityToggleAllValues: return "RichEntityToggleAllValues"
      case .richEntityTvEpisodeClick: return "RichEntityTVEpisodeClick"
      case .richEntityTvEpisodeAllToggle: return "RichEntityTVEpisodeAllToggle"
      case .twitterStatusClick: return "TwitterStatusClick"
      case .twitterDisplayUrlClick: return "TwitterDisplayURLClick"
      case .twitterProfileUrlClick: return "TwitterProfileURLClick"
      case .knowledgeGraphAnswerNodeClick: return "KnowledgeGraphAnswerNodeClick"
      case .techQnaAttributionClick: return "TechQNAAttributionClick"
      case .buyingGuideNavigationClick: return "BuyingGuideNavigationClick"
      case .richCaptionClick: return "RichCaptionClick"
      case .internalQuery: return "InternalQuery"
      case .inlineSrpProduct: return "InlineSrpProduct"
      case .relatedQnaToggle: return "RelatedQnaToggle"
      case .relatedQnAActionLink: return "RelatedQnAActionLink"
      case .purchaseLink: return "PurchaseLink"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ResultActionType, rhs: ResultActionType) -> Bool {
    switch (lhs, rhs) {
      case (.allReviewsClick, .allReviewsClick): return true
      case (.camelCamelCamelPricePage, .camelCamelCamelPricePage): return true
      case (.qnaAllQuestionsClick, .qnaAllQuestionsClick): return true
      case (.expertReview, .expertReview): return true
      case (.retailer, .retailer): return true
      case (.photo, .photo): return true
      case (.relatedProduct, .relatedProduct): return true
      case (.richEntityHeaderLink, .richEntityHeaderLink): return true
      case (.richEntitySocialProfile, .richEntitySocialProfile): return true
      case (.richEntityFact, .richEntityFact): return true
      case (.richEntityInlineLink, .richEntityInlineLink): return true
      case (.richEntityRelatedSearchClick, .richEntityRelatedSearchClick): return true
      case (.richEntityToggleFullSnippet, .richEntityToggleFullSnippet): return true
      case (.richEntityToggleAllFacts, .richEntityToggleAllFacts): return true
      case (.richEntityToggleAllValues, .richEntityToggleAllValues): return true
      case (.richEntityTvEpisodeClick, .richEntityTvEpisodeClick): return true
      case (.richEntityTvEpisodeAllToggle, .richEntityTvEpisodeAllToggle): return true
      case (.twitterStatusClick, .twitterStatusClick): return true
      case (.twitterDisplayUrlClick, .twitterDisplayUrlClick): return true
      case (.twitterProfileUrlClick, .twitterProfileUrlClick): return true
      case (.knowledgeGraphAnswerNodeClick, .knowledgeGraphAnswerNodeClick): return true
      case (.techQnaAttributionClick, .techQnaAttributionClick): return true
      case (.buyingGuideNavigationClick, .buyingGuideNavigationClick): return true
      case (.richCaptionClick, .richCaptionClick): return true
      case (.internalQuery, .internalQuery): return true
      case (.inlineSrpProduct, .inlineSrpProduct): return true
      case (.relatedQnaToggle, .relatedQnaToggle): return true
      case (.relatedQnAActionLink, .relatedQnAActionLink): return true
      case (.purchaseLink, .purchaseLink): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ResultActionType] {
    return [
      .allReviewsClick,
      .camelCamelCamelPricePage,
      .qnaAllQuestionsClick,
      .expertReview,
      .retailer,
      .photo,
      .relatedProduct,
      .richEntityHeaderLink,
      .richEntitySocialProfile,
      .richEntityFact,
      .richEntityInlineLink,
      .richEntityRelatedSearchClick,
      .richEntityToggleFullSnippet,
      .richEntityToggleAllFacts,
      .richEntityToggleAllValues,
      .richEntityTvEpisodeClick,
      .richEntityTvEpisodeAllToggle,
      .twitterStatusClick,
      .twitterDisplayUrlClick,
      .twitterProfileUrlClick,
      .knowledgeGraphAnswerNodeClick,
      .techQnaAttributionClick,
      .buyingGuideNavigationClick,
      .richCaptionClick,
      .internalQuery,
      .inlineSrpProduct,
      .relatedQnaToggle,
      .relatedQnAActionLink,
      .purchaseLink,
    ]
  }
}

/// This enum needs to be keep in sync with
/// fedsearch/request/interaction_logger_request.go
///
/// and need to add to fedsearch/mixer/packer.go
/// to start collecting the data.
///
/// Keep this enum in sync with InteractionType in file
/// neeva/logs/avro_schemas/interaction/interaction_log_v2_entry.avsc
public enum InteractionType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// The user sees the item for a minimum number of seconds.
  /// DEPRECATED
  /// Removed from client code 2020-09-24
  /// webui: 0.2.144
  /// nativeui: 0.7.2
  case view
  /// The user sees an item for a longer period of time.
  /// DEPRECATED
  /// Removed from client code 2020-09-24
  /// webui: 0.2.144
  /// nativeui: 0.7.2
  case longView
  /// The user hovers over the item.
  /// DEPRECATED
  /// Removed from client code 2020-09-24
  /// webui: 0.2.144
  /// nativeui: 0.7.2
  case hover
  /// The user clicks on the item.
  case click
  /// The user clicks on like
  case like
  /// The user click undo like
  case undoLike
  /// The user clicked on hide
  case hide
  /// The user clicked on Undo hide
  case undoHide
  /// The user clicked on hide always
  case hideAlways
  /// The user created a space
  case createSpace
  /// The user added to space
  case addToSpace
  /// The user copied to space
  case copyToSpace
  /// The user removed it from space
  case removeFromSpace
  /// The user deleted the snapshot from the space entity
  case deleteSnapshotFromSpaceEntity
  /// The user edited the space entity
  case editSpaceEntity
  /// The user renamed the space entity
  case renameSpaceEntity
  /// The user shared space
  case shareSpace
  /// The user renamed space
  case renameSpace
  /// The user edited space
  case editSpace
  /// The user deleted space
  case deleteSpace
  /// The user left the space
  case leaveSpace
  /// The user accepted a space sharing invite
  case acceptSpaceInvite
  /// The user declined a space sharing invite
  case declineSpaceInvite
  /// The user clicked to view an original snapshot page
  case viewOriginalSnapshotPage
  /// The user added comment to space
  case addCommentToSpace
  /// The user edited comment on space
  case editCommentOnSpace
  /// The user deleted comment from space
  case deleteCommentFromSpace
  /// The user added a public acl to a space
  case addSpacePublicAcl
  /// The user deleted a public acl from a space
  case deleteSpacePublicAcl
  /// The user previewed it
  case preview
  /// The user navigated left on a preview
  case previewNavLeft
  /// The user navigated right on a preview
  case previewNavRight
  /// The user exited a preview
  case previewClose
  /// User scrolled carousel left
  case leftScrollCarousel
  /// User scrolled carousel right
  case rightScrollCarousel
  /// The user clicked on search Suggest
  case suggestClick
  /// The user filled from the search Suggest
  case suggestFill
  /// The user focused on the suggestion
  case suggestFocus
  /// The user viewed the suggestion
  case suggestView
  /// Typed query matches suggestion
  case suggestMatchedTyped
  /// User clicked to DuckDuckGo search
  case duckDuckGoClick
  /// User clicked to Google search
  case googleSearchClick
  /// User clicked to Bing search
  case bingSearchClick
  /// User clicked on corpus filter
  case corpusFilterClick
  /// User clicked on show more/less to see more/less results
  case oneBoxClick
  /// Click on result group.
  case resultGroupClick
  /// Click on universal results like image, video
  case universalClick
  /// The user clicks on follow
  case follow
  /// The user clicks on unfollow
  case unfollow
  /// The user clicks on the geolocation prompt
  case geolocationClick
  /// Page view interaction type
  case pageView
  /// Open all links contained in Space
  case spaceOpenAllLinksClick
  /// Click to start reorder operation in Space
  case spaceStartReorderClick
  /// The user click on item that is on RHS
  case rhsClick
  /// The User clicked on show more/less on RHS item to see more/less results
  case rhsOneBoxClick
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "View": self = .view
      case "LongView": self = .longView
      case "Hover": self = .hover
      case "Click": self = .click
      case "Like": self = .like
      case "UndoLike": self = .undoLike
      case "Hide": self = .hide
      case "UndoHide": self = .undoHide
      case "HideAlways": self = .hideAlways
      case "CreateSpace": self = .createSpace
      case "AddToSpace": self = .addToSpace
      case "CopyToSpace": self = .copyToSpace
      case "RemoveFromSpace": self = .removeFromSpace
      case "DeleteSnapshotFromSpaceEntity": self = .deleteSnapshotFromSpaceEntity
      case "EditSpaceEntity": self = .editSpaceEntity
      case "RenameSpaceEntity": self = .renameSpaceEntity
      case "ShareSpace": self = .shareSpace
      case "RenameSpace": self = .renameSpace
      case "EditSpace": self = .editSpace
      case "DeleteSpace": self = .deleteSpace
      case "LeaveSpace": self = .leaveSpace
      case "AcceptSpaceInvite": self = .acceptSpaceInvite
      case "DeclineSpaceInvite": self = .declineSpaceInvite
      case "ViewOriginalSnapshotPage": self = .viewOriginalSnapshotPage
      case "AddCommentToSpace": self = .addCommentToSpace
      case "EditCommentOnSpace": self = .editCommentOnSpace
      case "DeleteCommentFromSpace": self = .deleteCommentFromSpace
      case "AddSpacePublicAcl": self = .addSpacePublicAcl
      case "DeleteSpacePublicAcl": self = .deleteSpacePublicAcl
      case "Preview": self = .preview
      case "PreviewNavLeft": self = .previewNavLeft
      case "PreviewNavRight": self = .previewNavRight
      case "PreviewClose": self = .previewClose
      case "LeftScrollCarousel": self = .leftScrollCarousel
      case "RightScrollCarousel": self = .rightScrollCarousel
      case "SuggestClick": self = .suggestClick
      case "SuggestFill": self = .suggestFill
      case "SuggestFocus": self = .suggestFocus
      case "SuggestView": self = .suggestView
      case "SuggestMatchedTyped": self = .suggestMatchedTyped
      case "DuckDuckGoClick": self = .duckDuckGoClick
      case "GoogleSearchClick": self = .googleSearchClick
      case "BingSearchClick": self = .bingSearchClick
      case "CorpusFilterClick": self = .corpusFilterClick
      case "OneBoxClick": self = .oneBoxClick
      case "ResultGroupClick": self = .resultGroupClick
      case "UniversalClick": self = .universalClick
      case "Follow": self = .follow
      case "Unfollow": self = .unfollow
      case "GeolocationClick": self = .geolocationClick
      case "PageView": self = .pageView
      case "SpaceOpenAllLinksClick": self = .spaceOpenAllLinksClick
      case "SpaceStartReorderClick": self = .spaceStartReorderClick
      case "RhsClick": self = .rhsClick
      case "RhsOneBoxClick": self = .rhsOneBoxClick
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .view: return "View"
      case .longView: return "LongView"
      case .hover: return "Hover"
      case .click: return "Click"
      case .like: return "Like"
      case .undoLike: return "UndoLike"
      case .hide: return "Hide"
      case .undoHide: return "UndoHide"
      case .hideAlways: return "HideAlways"
      case .createSpace: return "CreateSpace"
      case .addToSpace: return "AddToSpace"
      case .copyToSpace: return "CopyToSpace"
      case .removeFromSpace: return "RemoveFromSpace"
      case .deleteSnapshotFromSpaceEntity: return "DeleteSnapshotFromSpaceEntity"
      case .editSpaceEntity: return "EditSpaceEntity"
      case .renameSpaceEntity: return "RenameSpaceEntity"
      case .shareSpace: return "ShareSpace"
      case .renameSpace: return "RenameSpace"
      case .editSpace: return "EditSpace"
      case .deleteSpace: return "DeleteSpace"
      case .leaveSpace: return "LeaveSpace"
      case .acceptSpaceInvite: return "AcceptSpaceInvite"
      case .declineSpaceInvite: return "DeclineSpaceInvite"
      case .viewOriginalSnapshotPage: return "ViewOriginalSnapshotPage"
      case .addCommentToSpace: return "AddCommentToSpace"
      case .editCommentOnSpace: return "EditCommentOnSpace"
      case .deleteCommentFromSpace: return "DeleteCommentFromSpace"
      case .addSpacePublicAcl: return "AddSpacePublicAcl"
      case .deleteSpacePublicAcl: return "DeleteSpacePublicAcl"
      case .preview: return "Preview"
      case .previewNavLeft: return "PreviewNavLeft"
      case .previewNavRight: return "PreviewNavRight"
      case .previewClose: return "PreviewClose"
      case .leftScrollCarousel: return "LeftScrollCarousel"
      case .rightScrollCarousel: return "RightScrollCarousel"
      case .suggestClick: return "SuggestClick"
      case .suggestFill: return "SuggestFill"
      case .suggestFocus: return "SuggestFocus"
      case .suggestView: return "SuggestView"
      case .suggestMatchedTyped: return "SuggestMatchedTyped"
      case .duckDuckGoClick: return "DuckDuckGoClick"
      case .googleSearchClick: return "GoogleSearchClick"
      case .bingSearchClick: return "BingSearchClick"
      case .corpusFilterClick: return "CorpusFilterClick"
      case .oneBoxClick: return "OneBoxClick"
      case .resultGroupClick: return "ResultGroupClick"
      case .universalClick: return "UniversalClick"
      case .follow: return "Follow"
      case .unfollow: return "Unfollow"
      case .geolocationClick: return "GeolocationClick"
      case .pageView: return "PageView"
      case .spaceOpenAllLinksClick: return "SpaceOpenAllLinksClick"
      case .spaceStartReorderClick: return "SpaceStartReorderClick"
      case .rhsClick: return "RhsClick"
      case .rhsOneBoxClick: return "RhsOneBoxClick"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: InteractionType, rhs: InteractionType) -> Bool {
    switch (lhs, rhs) {
      case (.view, .view): return true
      case (.longView, .longView): return true
      case (.hover, .hover): return true
      case (.click, .click): return true
      case (.like, .like): return true
      case (.undoLike, .undoLike): return true
      case (.hide, .hide): return true
      case (.undoHide, .undoHide): return true
      case (.hideAlways, .hideAlways): return true
      case (.createSpace, .createSpace): return true
      case (.addToSpace, .addToSpace): return true
      case (.copyToSpace, .copyToSpace): return true
      case (.removeFromSpace, .removeFromSpace): return true
      case (.deleteSnapshotFromSpaceEntity, .deleteSnapshotFromSpaceEntity): return true
      case (.editSpaceEntity, .editSpaceEntity): return true
      case (.renameSpaceEntity, .renameSpaceEntity): return true
      case (.shareSpace, .shareSpace): return true
      case (.renameSpace, .renameSpace): return true
      case (.editSpace, .editSpace): return true
      case (.deleteSpace, .deleteSpace): return true
      case (.leaveSpace, .leaveSpace): return true
      case (.acceptSpaceInvite, .acceptSpaceInvite): return true
      case (.declineSpaceInvite, .declineSpaceInvite): return true
      case (.viewOriginalSnapshotPage, .viewOriginalSnapshotPage): return true
      case (.addCommentToSpace, .addCommentToSpace): return true
      case (.editCommentOnSpace, .editCommentOnSpace): return true
      case (.deleteCommentFromSpace, .deleteCommentFromSpace): return true
      case (.addSpacePublicAcl, .addSpacePublicAcl): return true
      case (.deleteSpacePublicAcl, .deleteSpacePublicAcl): return true
      case (.preview, .preview): return true
      case (.previewNavLeft, .previewNavLeft): return true
      case (.previewNavRight, .previewNavRight): return true
      case (.previewClose, .previewClose): return true
      case (.leftScrollCarousel, .leftScrollCarousel): return true
      case (.rightScrollCarousel, .rightScrollCarousel): return true
      case (.suggestClick, .suggestClick): return true
      case (.suggestFill, .suggestFill): return true
      case (.suggestFocus, .suggestFocus): return true
      case (.suggestView, .suggestView): return true
      case (.suggestMatchedTyped, .suggestMatchedTyped): return true
      case (.duckDuckGoClick, .duckDuckGoClick): return true
      case (.googleSearchClick, .googleSearchClick): return true
      case (.bingSearchClick, .bingSearchClick): return true
      case (.corpusFilterClick, .corpusFilterClick): return true
      case (.oneBoxClick, .oneBoxClick): return true
      case (.resultGroupClick, .resultGroupClick): return true
      case (.universalClick, .universalClick): return true
      case (.follow, .follow): return true
      case (.unfollow, .unfollow): return true
      case (.geolocationClick, .geolocationClick): return true
      case (.pageView, .pageView): return true
      case (.spaceOpenAllLinksClick, .spaceOpenAllLinksClick): return true
      case (.spaceStartReorderClick, .spaceStartReorderClick): return true
      case (.rhsClick, .rhsClick): return true
      case (.rhsOneBoxClick, .rhsOneBoxClick): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [InteractionType] {
    return [
      .view,
      .longView,
      .hover,
      .click,
      .like,
      .undoLike,
      .hide,
      .undoHide,
      .hideAlways,
      .createSpace,
      .addToSpace,
      .copyToSpace,
      .removeFromSpace,
      .deleteSnapshotFromSpaceEntity,
      .editSpaceEntity,
      .renameSpaceEntity,
      .shareSpace,
      .renameSpace,
      .editSpace,
      .deleteSpace,
      .leaveSpace,
      .acceptSpaceInvite,
      .declineSpaceInvite,
      .viewOriginalSnapshotPage,
      .addCommentToSpace,
      .editCommentOnSpace,
      .deleteCommentFromSpace,
      .addSpacePublicAcl,
      .deleteSpacePublicAcl,
      .preview,
      .previewNavLeft,
      .previewNavRight,
      .previewClose,
      .leftScrollCarousel,
      .rightScrollCarousel,
      .suggestClick,
      .suggestFill,
      .suggestFocus,
      .suggestView,
      .suggestMatchedTyped,
      .duckDuckGoClick,
      .googleSearchClick,
      .bingSearchClick,
      .corpusFilterClick,
      .oneBoxClick,
      .resultGroupClick,
      .universalClick,
      .follow,
      .unfollow,
      .geolocationClick,
      .pageView,
      .spaceOpenAllLinksClick,
      .spaceStartReorderClick,
      .rhsClick,
      .rhsOneBoxClick,
    ]
  }
}

/// Page attributes
public struct PageEventAttributes: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - pageId
  ///   - previousPageId
  ///   - corpusFilter
  ///   - corpusCount
  ///   - suggestClickMetadata
  ///   - corpusType
  public init(pageId: Swift.Optional<String?> = nil, previousPageId: Swift.Optional<String?> = nil, corpusFilter: Swift.Optional<CorpusFilterTransition?> = nil, corpusCount: Swift.Optional<Int?> = nil, suggestClickMetadata: Swift.Optional<SuggestClickMetadata?> = nil, corpusType: Swift.Optional<CorpusType?> = nil) {
    graphQLMap = ["pageID": pageId, "previousPageID": previousPageId, "corpusFilter": corpusFilter, "corpusCount": corpusCount, "suggestClickMetadata": suggestClickMetadata, "corpusType": corpusType]
  }

  public var pageId: Swift.Optional<String?> {
    get {
      return graphQLMap["pageID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "pageID")
    }
  }

  public var previousPageId: Swift.Optional<String?> {
    get {
      return graphQLMap["previousPageID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "previousPageID")
    }
  }

  public var corpusFilter: Swift.Optional<CorpusFilterTransition?> {
    get {
      return graphQLMap["corpusFilter"] as? Swift.Optional<CorpusFilterTransition?> ?? Swift.Optional<CorpusFilterTransition?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "corpusFilter")
    }
  }

  public var corpusCount: Swift.Optional<Int?> {
    get {
      return graphQLMap["corpusCount"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "corpusCount")
    }
  }

  public var suggestClickMetadata: Swift.Optional<SuggestClickMetadata?> {
    get {
      return graphQLMap["suggestClickMetadata"] as? Swift.Optional<SuggestClickMetadata?> ?? Swift.Optional<SuggestClickMetadata?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "suggestClickMetadata")
    }
  }

  public var corpusType: Swift.Optional<CorpusType?> {
    get {
      return graphQLMap["corpusType"] as? Swift.Optional<CorpusType?> ?? Swift.Optional<CorpusType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "corpusType")
    }
  }
}

public struct CorpusFilterTransition: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - to
  ///   - from
  public init(to: Swift.Optional<String?> = nil, from: Swift.Optional<String?> = nil) {
    graphQLMap = ["to": to, "from": from]
  }

  public var to: Swift.Optional<String?> {
    get {
      return graphQLMap["to"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "to")
    }
  }

  public var from: Swift.Optional<String?> {
    get {
      return graphQLMap["from"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "from")
    }
  }
}

public struct SuggestClickMetadata: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - clickedSuggestion
  ///   - shownSuggestions
  ///   - suggestionEventId
  public init(clickedSuggestion: Swift.Optional<SuggestionMetadata?> = nil, shownSuggestions: Swift.Optional<[SuggestionMetadata]?> = nil, suggestionEventId: Swift.Optional<String?> = nil) {
    graphQLMap = ["clickedSuggestion": clickedSuggestion, "shownSuggestions": shownSuggestions, "suggestionEventID": suggestionEventId]
  }

  public var clickedSuggestion: Swift.Optional<SuggestionMetadata?> {
    get {
      return graphQLMap["clickedSuggestion"] as? Swift.Optional<SuggestionMetadata?> ?? Swift.Optional<SuggestionMetadata?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "clickedSuggestion")
    }
  }

  public var shownSuggestions: Swift.Optional<[SuggestionMetadata]?> {
    get {
      return graphQLMap["shownSuggestions"] as? Swift.Optional<[SuggestionMetadata]?> ?? Swift.Optional<[SuggestionMetadata]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "shownSuggestions")
    }
  }

  public var suggestionEventId: Swift.Optional<String?> {
    get {
      return graphQLMap["suggestionEventID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "suggestionEventID")
    }
  }
}

public struct SuggestionMetadata: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - suggestionTitle
  ///   - docId
  ///   - rank
  ///   - source
  ///   - type
  public init(suggestionTitle: Swift.Optional<String?> = nil, docId: Swift.Optional<String?> = nil, rank: Swift.Optional<Int?> = nil, source: Swift.Optional<String?> = nil, type: Swift.Optional<String?> = nil) {
    graphQLMap = ["suggestionTitle": suggestionTitle, "docID": docId, "rank": rank, "source": source, "type": type]
  }

  public var suggestionTitle: Swift.Optional<String?> {
    get {
      return graphQLMap["suggestionTitle"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "suggestionTitle")
    }
  }

  public var docId: Swift.Optional<String?> {
    get {
      return graphQLMap["docID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "docID")
    }
  }

  public var rank: Swift.Optional<Int?> {
    get {
      return graphQLMap["rank"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "rank")
    }
  }

  public var source: Swift.Optional<String?> {
    get {
      return graphQLMap["source"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "source")
    }
  }

  public var type: Swift.Optional<String?> {
    get {
      return graphQLMap["type"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }
}

public enum CorpusType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case personal
  case `public`
  case image
  case news
  case maps
  case recipes
  case shopping
  case video
  case all
  case web3
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Personal": self = .personal
      case "Public": self = .public
      case "Image": self = .image
      case "News": self = .news
      case "Maps": self = .maps
      case "Recipes": self = .recipes
      case "Shopping": self = .shopping
      case "Video": self = .video
      case "All": self = .all
      case "Web3": self = .web3
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .personal: return "Personal"
      case .public: return "Public"
      case .image: return "Image"
      case .news: return "News"
      case .maps: return "Maps"
      case .recipes: return "Recipes"
      case .shopping: return "Shopping"
      case .video: return "Video"
      case .all: return "All"
      case .web3: return "Web3"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: CorpusType, rhs: CorpusType) -> Bool {
    switch (lhs, rhs) {
      case (.personal, .personal): return true
      case (.public, .public): return true
      case (.image, .image): return true
      case (.news, .news): return true
      case (.maps, .maps): return true
      case (.recipes, .recipes): return true
      case (.shopping, .shopping): return true
      case (.video, .video): return true
      case (.all, .all): return true
      case (.web3, .web3): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [CorpusType] {
    return [
      .personal,
      .public,
      .image,
      .news,
      .maps,
      .recipes,
      .shopping,
      .video,
      .all,
      .web3,
    ]
  }
}

/// Result Group attributes
/// TODO: Move this to logging context
public struct ResultGroupAttributes: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - resultGroupAction
  public init(resultGroupAction: Swift.Optional<ResultGroupActionType?> = nil) {
    graphQLMap = ["resultGroupAction": resultGroupAction]
  }

  public var resultGroupAction: Swift.Optional<ResultGroupActionType?> {
    get {
      return graphQLMap["resultGroupAction"] as? Swift.Optional<ResultGroupActionType?> ?? Swift.Optional<ResultGroupActionType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultGroupAction")
    }
  }
}

/// Input type for v3 ClientLog.interactionV3Event mutation.
///
/// This is the preferred mechanism for logging an interaction that happens in a
/// search results page (SRP) context. The concepts and design behind how
/// interactions are recorded in the design doc:
///
/// https://paper.dropbox.com/doc/Logging-V3-Page-structure--A7Q0Gpx7oVh1vflhuaIBsHQfAg-4RsxGgmgnFiaM5Rg72YjO
public struct InteractionV3EventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - loggingContexts: Array of all logging contexts
  ///   - action: The action the user took.
  ///   - requestEventId: DocId of the request for which the event being recorded
  public init(loggingContexts: Swift.Optional<[LoggingContext]?> = nil, action: Swift.Optional<InteractionV3ActionInput?> = nil, requestEventId: Swift.Optional<String?> = nil) {
    graphQLMap = ["loggingContexts": loggingContexts, "action": action, "requestEventID": requestEventId]
  }

  /// Array of all logging contexts
  public var loggingContexts: Swift.Optional<[LoggingContext]?> {
    get {
      return graphQLMap["loggingContexts"] as? Swift.Optional<[LoggingContext]?> ?? Swift.Optional<[LoggingContext]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "loggingContexts")
    }
  }

  /// The action the user took.
  public var action: Swift.Optional<InteractionV3ActionInput?> {
    get {
      return graphQLMap["action"] as? Swift.Optional<InteractionV3ActionInput?> ?? Swift.Optional<InteractionV3ActionInput?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "action")
    }
  }

  /// DocId of the request for which the event being recorded
  public var requestEventId: Swift.Optional<String?> {
    get {
      return graphQLMap["requestEventID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "requestEventID")
    }
  }
}

/// This defines the structure of an action for the interactions v3.
public struct InteractionV3ActionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - actionType: The type of the action.
  ///   - category: The target category of the action. This should have the same taxonomy as
  /// the category for LoggingContext.
  ///   - element: What element within the group/result/etc. that the action took place. For
  /// example, this may be an ExpertReview or Retailer within a shopping result.
  ///
  /// This is a relatively free-form field. Please add the things that make the most
  /// sense for _your particular_ use case.
  ///   - elementAction: Optional. The action taken on the Element. If the Element is Carousel, then
  /// the ElementAction may be 'ScrollLeft' or 'ScrollRight'
  ///
  /// Only used in cases when you have multiple actions that can happen on the
  /// same Element.
  public init(actionType: Swift.Optional<InteractionV3Type?> = nil, category: Swift.Optional<InteractionV3Category?> = nil, element: Swift.Optional<String?> = nil, elementAction: Swift.Optional<String?> = nil) {
    graphQLMap = ["actionType": actionType, "category": category, "element": element, "elementAction": elementAction]
  }

  /// The type of the action.
  public var actionType: Swift.Optional<InteractionV3Type?> {
    get {
      return graphQLMap["actionType"] as? Swift.Optional<InteractionV3Type?> ?? Swift.Optional<InteractionV3Type?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "actionType")
    }
  }

  /// The target category of the action. This should have the same taxonomy as
  /// the category for LoggingContext.
  public var category: Swift.Optional<InteractionV3Category?> {
    get {
      return graphQLMap["category"] as? Swift.Optional<InteractionV3Category?> ?? Swift.Optional<InteractionV3Category?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "category")
    }
  }

  /// What element within the group/result/etc. that the action took place. For
  /// example, this may be an ExpertReview or Retailer within a shopping result.
  ///
  /// This is a relatively free-form field. Please add the things that make the most
  /// sense for _your particular_ use case.
  public var element: Swift.Optional<String?> {
    get {
      return graphQLMap["element"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "element")
    }
  }

  /// Optional. The action taken on the Element. If the Element is Carousel, then
  /// the ElementAction may be 'ScrollLeft' or 'ScrollRight'
  ///
  /// Only used in cases when you have multiple actions that can happen on the
  /// same Element.
  public var elementAction: Swift.Optional<String?> {
    get {
      return graphQLMap["elementAction"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "elementAction")
    }
  }
}

/// The collection of action types for the v3 interactions table.
///
/// Be VERY CAREFUL about extending the action types here. In general, we want
/// to have a very limited number of action types. If you need more information
/// about the context of an action, consider using Element, ElementAction, or
/// the Attributes table.
///
/// PLEASE KEEP IN SYNC with //schemas/constants/interaction_type.go.
public enum InteractionV3Type: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Click covers all outbound clicks, i.e. anything that takes you outside of
  /// neeva.
  case click
  /// View represents a view, according to the definition we've set (e.g. may or
  /// may not be delayed).
  case view
  /// InternalClick represents a non-outbound click, and involves
  /// the user interacting with some semantically meaningful part of a widget that
  /// does not cause the user to leave the search context. Usually this is
  /// something like navigating a carousel, showing more information, or seeing a
  /// preview. Excludes MetaClicks.
  case internalClick
  /// MetaClick represents a non-outbound click, and involves the
  /// user interacting with a search element that changes the user’s relationship
  /// to that element. This can be hide, follow, add to space, etc. Unlike an
  /// InternalClick, a MetaClick does not involve the user interacting with the
  /// element in a way that provides more information to the user.
  case metaClick
  /// Refinement is an interaction that initiates another, related search context,
  /// i.e. by applying a corpus filter or opening a related search.
  case refinement
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Click": self = .click
      case "View": self = .view
      case "InternalClick": self = .internalClick
      case "MetaClick": self = .metaClick
      case "Refinement": self = .refinement
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .click: return "Click"
      case .view: return "View"
      case .internalClick: return "InternalClick"
      case .metaClick: return "MetaClick"
      case .refinement: return "Refinement"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: InteractionV3Type, rhs: InteractionV3Type) -> Bool {
    switch (lhs, rhs) {
      case (.click, .click): return true
      case (.view, .view): return true
      case (.internalClick, .internalClick): return true
      case (.metaClick, .metaClick): return true
      case (.refinement, .refinement): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [InteractionV3Type] {
    return [
      .click,
      .view,
      .internalClick,
      .metaClick,
      .refinement,
    ]
  }
}

/// InteractionV3Category specifies the type of the item in the log tree hierarchy.
/// The log tree can have have N number of entries, but these are the ones
/// that have IDs associated.
///
/// PLEASE KEEP IN SYNC with //schemas/constants/category.go
public enum InteractionV3Category: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Represents a page, such as a search results page or a space page.
  case page
  /// Represents a group of results or containers. This is synonymous with "result
  /// group".
  case group
  /// Represents a container of results, such as a news list or video carousel.
  case container
  /// Represents a single result. The result can be simple (a web link) or complex
  /// (a rich entity), but this is the terminal category to which an action can
  /// belong.
  case result
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "page": self = .page
      case "group": self = .group
      case "container": self = .container
      case "result": self = .result
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .page: return "page"
      case .group: return "group"
      case .container: return "container"
      case .result: return "result"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: InteractionV3Category, rhs: InteractionV3Category) -> Bool {
    switch (lhs, rhs) {
      case (.page, .page): return true
      case (.group, .group): return true
      case (.container, .container): return true
      case (.result, .result): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [InteractionV3Category] {
    return [
      .page,
      .group,
      .container,
      .result,
    ]
  }
}

/// Search Perf related data collected from client
public struct SearchPerfEventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - parentEventId: Parent event ID of the page.
  /// This is a event of graphqql request fied to render the measured view
  ///   - appState: State of the app at the time of the event
  ///   - effectiveNetworkType: Type of network predicted by browser based (supported in chrome)
  ///
  /// Doc: https://developer.mozilla.org/en-US/docs/Web/API/NetworkInformation
  ///   - rttMs: RTT of the recent connection
  ///   - userActionTimeMs: Use action time in ms since start of the document
  /// This is valid only when inAppTransition is true
  ///   - queryRequestTimeMs: Query start time, since start of the document
  ///   - queryResponseTimeMs: Query response received, since start of the document
  ///   - resultRenderTimeMs: Result is rendered on the browser, since start of the document
  ///   - criticalPathResourcePerfEntries: Detailed critical path resources of critical path resources as JSON
  ///   - appBootstrapTimeMs: App bootstrapped, just before react render
  ///   - appLoadingTimeMs: App marked as loading time in Ms
  ///   - loggedInTimeMs: App logged in time
  ///   - customMarkers: Custom markers added by neeva app sent as JSON
  public init(parentEventId: Swift.Optional<String?> = nil, appState: Swift.Optional<AppState?> = nil, effectiveNetworkType: Swift.Optional<String?> = nil, rttMs: Swift.Optional<Int?> = nil, userActionTimeMs: Swift.Optional<Double?> = nil, queryRequestTimeMs: Swift.Optional<Double?> = nil, queryResponseTimeMs: Swift.Optional<Double?> = nil, resultRenderTimeMs: Swift.Optional<Double?> = nil, criticalPathResourcePerfEntries: Swift.Optional<String?> = nil, appBootstrapTimeMs: Swift.Optional<Double?> = nil, appLoadingTimeMs: Swift.Optional<Double?> = nil, loggedInTimeMs: Swift.Optional<Double?> = nil, customMarkers: Swift.Optional<String?> = nil) {
    graphQLMap = ["parentEventID": parentEventId, "appState": appState, "effectiveNetworkType": effectiveNetworkType, "rttMs": rttMs, "userActionTimeMs": userActionTimeMs, "queryRequestTimeMs": queryRequestTimeMs, "queryResponseTimeMs": queryResponseTimeMs, "resultRenderTimeMs": resultRenderTimeMs, "criticalPathResourcePerfEntries": criticalPathResourcePerfEntries, "appBootstrapTimeMs": appBootstrapTimeMs, "appLoadingTimeMs": appLoadingTimeMs, "loggedInTimeMs": loggedInTimeMs, "customMarkers": customMarkers]
  }

  /// Parent event ID of the page.
  /// This is a event of graphqql request fied to render the measured view
  public var parentEventId: Swift.Optional<String?> {
    get {
      return graphQLMap["parentEventID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "parentEventID")
    }
  }

  /// State of the app at the time of the event
  public var appState: Swift.Optional<AppState?> {
    get {
      return graphQLMap["appState"] as? Swift.Optional<AppState?> ?? Swift.Optional<AppState?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "appState")
    }
  }

  /// Type of network predicted by browser based (supported in chrome)
  ///
  /// Doc: https://developer.mozilla.org/en-US/docs/Web/API/NetworkInformation
  public var effectiveNetworkType: Swift.Optional<String?> {
    get {
      return graphQLMap["effectiveNetworkType"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "effectiveNetworkType")
    }
  }

  /// RTT of the recent connection
  public var rttMs: Swift.Optional<Int?> {
    get {
      return graphQLMap["rttMs"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "rttMs")
    }
  }

  /// Use action time in ms since start of the document
  /// This is valid only when inAppTransition is true
  public var userActionTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["userActionTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userActionTimeMs")
    }
  }

  /// Query start time, since start of the document
  public var queryRequestTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["queryRequestTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "queryRequestTimeMs")
    }
  }

  /// Query response received, since start of the document
  public var queryResponseTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["queryResponseTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "queryResponseTimeMs")
    }
  }

  /// Result is rendered on the browser, since start of the document
  public var resultRenderTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["resultRenderTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultRenderTimeMs")
    }
  }

  /// Detailed critical path resources of critical path resources as JSON
  public var criticalPathResourcePerfEntries: Swift.Optional<String?> {
    get {
      return graphQLMap["criticalPathResourcePerfEntries"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "criticalPathResourcePerfEntries")
    }
  }

  /// App bootstrapped, just before react render
  public var appBootstrapTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["appBootstrapTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "appBootstrapTimeMs")
    }
  }

  /// App marked as loading time in Ms
  public var appLoadingTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["appLoadingTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "appLoadingTimeMs")
    }
  }

  /// App logged in time
  public var loggedInTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["loggedInTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "loggedInTimeMs")
    }
  }

  /// Custom markers added by neeva app sent as JSON
  public var customMarkers: Swift.Optional<String?> {
    get {
      return graphQLMap["customMarkers"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "customMarkers")
    }
  }
}

public enum AppState: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Main app.js was not in cache
  case coldStart
  /// Opposite of ColdStart
  case warmStart
  /// InApp transition
  case inApp
  /// Request is rendered with SSR
  case ssr
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ColdStart": self = .coldStart
      case "WarmStart": self = .warmStart
      case "InApp": self = .inApp
      case "Ssr": self = .ssr
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .coldStart: return "ColdStart"
      case .warmStart: return "WarmStart"
      case .inApp: return "InApp"
      case .ssr: return "Ssr"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: AppState, rhs: AppState) -> Bool {
    switch (lhs, rhs) {
      case (.coldStart, .coldStart): return true
      case (.warmStart, .warmStart): return true
      case (.inApp, .inApp): return true
      case (.ssr, .ssr): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [AppState] {
    return [
      .coldStart,
      .warmStart,
      .inApp,
      .ssr,
    ]
  }
}

/// Suggest latency logs,
/// all times are origin of the page (instance at which page was initiated)
public struct SuggestPerfEventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - eventId: event of suggest request
  ///   - requestResourceTiming: JSON blob of suggest request from browser
  ///   - requestStartTimeMs: Suggest request start
  ///   - responseStartTimeMs: Suggest response start receiving
  ///   - responseEndTimeMs: Suggest response received, last byte
  ///   - renderTimeMs: Suggest response render time
  public init(eventId: Swift.Optional<String?> = nil, requestResourceTiming: Swift.Optional<String?> = nil, requestStartTimeMs: Swift.Optional<Double?> = nil, responseStartTimeMs: Swift.Optional<Double?> = nil, responseEndTimeMs: Swift.Optional<Double?> = nil, renderTimeMs: Swift.Optional<Double?> = nil) {
    graphQLMap = ["eventID": eventId, "requestResourceTiming": requestResourceTiming, "requestStartTimeMs": requestStartTimeMs, "responseStartTimeMs": responseStartTimeMs, "responseEndTimeMs": responseEndTimeMs, "renderTimeMs": renderTimeMs]
  }

  /// event of suggest request
  public var eventId: Swift.Optional<String?> {
    get {
      return graphQLMap["eventID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eventID")
    }
  }

  /// JSON blob of suggest request from browser
  public var requestResourceTiming: Swift.Optional<String?> {
    get {
      return graphQLMap["requestResourceTiming"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "requestResourceTiming")
    }
  }

  /// Suggest request start
  public var requestStartTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["requestStartTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "requestStartTimeMs")
    }
  }

  /// Suggest response start receiving
  public var responseStartTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["responseStartTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "responseStartTimeMs")
    }
  }

  /// Suggest response received, last byte
  public var responseEndTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["responseEndTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "responseEndTimeMs")
    }
  }

  /// Suggest response render time
  public var renderTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["renderTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "renderTimeMs")
    }
  }
}

/// Apple mapkit resource latency logs,
/// all times are origin of the page (instance at which page was initiated)
public struct AppleMapkitResourcePerfEventInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - requestUrl: url of request
  ///   - durationTimeMs: Apple Mapkit resource request to response duration
  ///   - fetchStartTimeMs: Apple Mapkit resource fetch start
  ///   - requestStartTimeMs: Apple Mapkit resource request start
  ///   - responseStartTimeMs: Apple Mapkit resource response start receiving
  ///   - responseEndTimeMs: Apple Mapkit resource response received, last byte
  ///   - numberOfTilesLoaded: Apple Mapkit number of resources loaded
  public init(requestUrl: Swift.Optional<String?> = nil, durationTimeMs: Swift.Optional<Double?> = nil, fetchStartTimeMs: Swift.Optional<Double?> = nil, requestStartTimeMs: Swift.Optional<Double?> = nil, responseStartTimeMs: Swift.Optional<Double?> = nil, responseEndTimeMs: Swift.Optional<Double?> = nil, numberOfTilesLoaded: Swift.Optional<Int?> = nil) {
    graphQLMap = ["requestURL": requestUrl, "durationTimeMs": durationTimeMs, "fetchStartTimeMs": fetchStartTimeMs, "requestStartTimeMs": requestStartTimeMs, "responseStartTimeMs": responseStartTimeMs, "responseEndTimeMs": responseEndTimeMs, "numberOfTilesLoaded": numberOfTilesLoaded]
  }

  /// url of request
  public var requestUrl: Swift.Optional<String?> {
    get {
      return graphQLMap["requestURL"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "requestURL")
    }
  }

  /// Apple Mapkit resource request to response duration
  public var durationTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["durationTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "durationTimeMs")
    }
  }

  /// Apple Mapkit resource fetch start
  public var fetchStartTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["fetchStartTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "fetchStartTimeMs")
    }
  }

  /// Apple Mapkit resource request start
  public var requestStartTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["requestStartTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "requestStartTimeMs")
    }
  }

  /// Apple Mapkit resource response start receiving
  public var responseStartTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["responseStartTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "responseStartTimeMs")
    }
  }

  /// Apple Mapkit resource response received, last byte
  public var responseEndTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["responseEndTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "responseEndTimeMs")
    }
  }

  /// Apple Mapkit number of resources loaded
  public var numberOfTilesLoaded: Swift.Optional<Int?> {
    get {
      return graphQLMap["numberOfTilesLoaded"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "numberOfTilesLoaded")
    }
  }
}

public struct PerfTraceInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - traceGroupId: The group ID of the trace. This can be used to join multiple, interacting
  /// traces that may track things happening in parallel.
  ///   - type: The type of the perf trace. This is an identifier like 'search' or
  /// 'bootstrap'. We are specifically not providing an exact contract for trace
  /// types, since we want to allow flexibility on the client.
  ///   - traceStartTimeMs: The wallclock start time of the trace, as measured by the client.
  ///   - requestEventId: Request event ID of the page.
  /// This is a event of graphqql request fired to render the measured view.
  ///   - appState: State of the app at the time of the event
  ///   - effectiveNetworkType: Type of network predicted by browser based (supported in chrome and in
  /// React Native).
  ///
  /// Doc: https://developer.mozilla.org/en-US/docs/Web/API/NetworkInformation
  ///   - events: The events in the trace. A trace is an ordered collection of perf events
  /// that are all related in some way. A single action (such as loading the app)
  /// may result in multiple traces, some with shared events, depending on what
  /// view of the trace you're looking for.
  ///   - status: The status of the perf trace.
  public init(traceGroupId: Swift.Optional<String?> = nil, type: Swift.Optional<String?> = nil, traceStartTimeMs: Swift.Optional<Double?> = nil, requestEventId: Swift.Optional<String?> = nil, appState: Swift.Optional<AppState?> = nil, effectiveNetworkType: Swift.Optional<String?> = nil, events: Swift.Optional<[PerfEvent]?> = nil, status: Swift.Optional<PerfTraceStatus?> = nil) {
    graphQLMap = ["traceGroupID": traceGroupId, "type": type, "traceStartTimeMs": traceStartTimeMs, "requestEventID": requestEventId, "appState": appState, "effectiveNetworkType": effectiveNetworkType, "events": events, "status": status]
  }

  /// The group ID of the trace. This can be used to join multiple, interacting
  /// traces that may track things happening in parallel.
  public var traceGroupId: Swift.Optional<String?> {
    get {
      return graphQLMap["traceGroupID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "traceGroupID")
    }
  }

  /// The type of the perf trace. This is an identifier like 'search' or
  /// 'bootstrap'. We are specifically not providing an exact contract for trace
  /// types, since we want to allow flexibility on the client.
  public var type: Swift.Optional<String?> {
    get {
      return graphQLMap["type"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  /// The wallclock start time of the trace, as measured by the client.
  public var traceStartTimeMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["traceStartTimeMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "traceStartTimeMs")
    }
  }

  /// Request event ID of the page.
  /// This is a event of graphqql request fired to render the measured view.
  public var requestEventId: Swift.Optional<String?> {
    get {
      return graphQLMap["requestEventID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "requestEventID")
    }
  }

  /// State of the app at the time of the event
  public var appState: Swift.Optional<AppState?> {
    get {
      return graphQLMap["appState"] as? Swift.Optional<AppState?> ?? Swift.Optional<AppState?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "appState")
    }
  }

  /// Type of network predicted by browser based (supported in chrome and in
  /// React Native).
  ///
  /// Doc: https://developer.mozilla.org/en-US/docs/Web/API/NetworkInformation
  public var effectiveNetworkType: Swift.Optional<String?> {
    get {
      return graphQLMap["effectiveNetworkType"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "effectiveNetworkType")
    }
  }

  /// The events in the trace. A trace is an ordered collection of perf events
  /// that are all related in some way. A single action (such as loading the app)
  /// may result in multiple traces, some with shared events, depending on what
  /// view of the trace you're looking for.
  public var events: Swift.Optional<[PerfEvent]?> {
    get {
      return graphQLMap["events"] as? Swift.Optional<[PerfEvent]?> ?? Swift.Optional<[PerfEvent]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "events")
    }
  }

  /// The status of the perf trace.
  public var status: Swift.Optional<PerfTraceStatus?> {
    get {
      return graphQLMap["status"] as? Swift.Optional<PerfTraceStatus?> ?? Swift.Optional<PerfTraceStatus?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "status")
    }
  }
}

public struct PerfEvent: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - type: The name of perf event type. Perf event types are defined in the client code.
  ///   - elapsedTotalMs: The elapsed time since the beginning of the perf trace. Note that this is
  /// not the absolute timestamp, which can be computed by adding the trace
  /// timestamp to the elapsedMs.
  ///   - elapsedMs: DEPRECATED 2020-04-24
  ///
  /// Versions:
  /// - iOS: 0.3.6
  /// - web: never used
  ///
  /// Not using on the BE since it can be derived from elapsedTotalMs.
  public init(type: Swift.Optional<String?> = nil, elapsedTotalMs: Swift.Optional<Double?> = nil, elapsedMs: Swift.Optional<Double?> = nil) {
    graphQLMap = ["type": type, "elapsedTotalMs": elapsedTotalMs, "elapsedMs": elapsedMs]
  }

  /// The name of perf event type. Perf event types are defined in the client code.
  public var type: Swift.Optional<String?> {
    get {
      return graphQLMap["type"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }

  /// The elapsed time since the beginning of the perf trace. Note that this is
  /// not the absolute timestamp, which can be computed by adding the trace
  /// timestamp to the elapsedMs.
  public var elapsedTotalMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["elapsedTotalMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "elapsedTotalMs")
    }
  }

  /// DEPRECATED 2020-04-24
  ///
  /// Versions:
  /// - iOS: 0.3.6
  /// - web: never used
  ///
  /// Not using on the BE since it can be derived from elapsedTotalMs.
  public var elapsedMs: Swift.Optional<Double?> {
    get {
      return graphQLMap["elapsedMs"] as? Swift.Optional<Double?> ?? Swift.Optional<Double?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "elapsedMs")
    }
  }
}

/// The status of a perf trace.
public enum PerfTraceStatus: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// The trace did not complete in either a success or a failure state. This can
  /// mean that the perf event is in progress, or that the perf event failed
  /// silently.
  case incomplete
  /// The trace has completed in a success condition; i.e. the query was rendered.
  case complete
  /// The trace has completed in a failed condition; that is, there was some kind
  /// of error.
  case failed
  /// The trace was canceled; that is, some event was triggered that made this
  /// trace invalid.
  case canceled
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Incomplete": self = .incomplete
      case "Complete": self = .complete
      case "Failed": self = .failed
      case "Canceled": self = .canceled
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .incomplete: return "Incomplete"
      case .complete: return "Complete"
      case .failed: return "Failed"
      case .canceled: return "Canceled"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: PerfTraceStatus, rhs: PerfTraceStatus) -> Bool {
    switch (lhs, rhs) {
      case (.incomplete, .incomplete): return true
      case (.complete, .complete): return true
      case (.failed, .failed): return true
      case (.canceled, .canceled): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [PerfTraceStatus] {
    return [
      .incomplete,
      .complete,
      .failed,
      .canceled,
    ]
  }
}

public enum SubscriptionType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case basic
  case premium
  case lifetime
  case unknown
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Basic": self = .basic
      case "Premium": self = .premium
      case "Lifetime": self = .lifetime
      case "Unknown": self = .unknown
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .basic: return "Basic"
      case .premium: return "Premium"
      case .lifetime: return "Lifetime"
      case .unknown: return "Unknown"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: SubscriptionType, rhs: SubscriptionType) -> Bool {
    switch (lhs, rhs) {
      case (.basic, .basic): return true
      case (.premium, .premium): return true
      case (.lifetime, .lifetime): return true
      case (.unknown, .unknown): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [SubscriptionType] {
    return [
      .basic,
      .premium,
      .lifetime,
      .unknown,
    ]
  }
}

public enum UserPreference: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case notSupported
  case noPreference
  case prioritized
  case deprioritized
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "NotSupported": self = .notSupported
      case "NoPreference": self = .noPreference
      case "Prioritized": self = .prioritized
      case "Deprioritized": self = .deprioritized
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .notSupported: return "NotSupported"
      case .noPreference: return "NoPreference"
      case .prioritized: return "Prioritized"
      case .deprioritized: return "Deprioritized"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: UserPreference, rhs: UserPreference) -> Bool {
    switch (lhs, rhs) {
      case (.notSupported, .notSupported): return true
      case (.noPreference, .noPreference): return true
      case (.prioritized, .prioritized): return true
      case (.deprioritized, .deprioritized): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [UserPreference] {
    return [
      .notSupported,
      .noPreference,
      .prioritized,
      .deprioritized,
    ]
  }
}

public struct PublicEmailLookupInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - email
  public init(email: Swift.Optional<String?> = nil) {
    graphQLMap = ["email": email]
  }

  public var email: Swift.Optional<String?> {
    get {
      return graphQLMap["email"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "email")
    }
  }
}

/// Data sent back from client representing user feedback response (V2)
public struct SendFeedbackV2Input: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - feedback
  ///   - shareResults
  ///   - requestId
  ///   - geoLocationStatus
  ///   - source
  ///   - inviteToken
  ///   - screenshot
  ///   - userProvidedEmail
  ///   - errorCode
  public init(feedback: Swift.Optional<String?> = nil, shareResults: Swift.Optional<Bool?> = nil, requestId: Swift.Optional<String?> = nil, geoLocationStatus: Swift.Optional<String?> = nil, source: Swift.Optional<FeedbackSource?> = nil, inviteToken: Swift.Optional<String?> = nil, screenshot: Swift.Optional<String?> = nil, userProvidedEmail: Swift.Optional<String?> = nil, errorCode: Swift.Optional<String?> = nil) {
    graphQLMap = ["feedback": feedback, "shareResults": shareResults, "requestID": requestId, "geoLocationStatus": geoLocationStatus, "source": source, "inviteToken": inviteToken, "screenshot": screenshot, "userProvidedEmail": userProvidedEmail, "errorCode": errorCode]
  }

  public var feedback: Swift.Optional<String?> {
    get {
      return graphQLMap["feedback"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "feedback")
    }
  }

  public var shareResults: Swift.Optional<Bool?> {
    get {
      return graphQLMap["shareResults"] as? Swift.Optional<Bool?> ?? Swift.Optional<Bool?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "shareResults")
    }
  }

  public var requestId: Swift.Optional<String?> {
    get {
      return graphQLMap["requestID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "requestID")
    }
  }

  public var geoLocationStatus: Swift.Optional<String?> {
    get {
      return graphQLMap["geoLocationStatus"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "geoLocationStatus")
    }
  }

  public var source: Swift.Optional<FeedbackSource?> {
    get {
      return graphQLMap["source"] as? Swift.Optional<FeedbackSource?> ?? Swift.Optional<FeedbackSource?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "source")
    }
  }

  public var inviteToken: Swift.Optional<String?> {
    get {
      return graphQLMap["inviteToken"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "inviteToken")
    }
  }

  public var screenshot: Swift.Optional<String?> {
    get {
      return graphQLMap["screenshot"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "screenshot")
    }
  }

  public var userProvidedEmail: Swift.Optional<String?> {
    get {
      return graphQLMap["userProvidedEmail"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userProvidedEmail")
    }
  }

  public var errorCode: Swift.Optional<String?> {
    get {
      return graphQLMap["errorCode"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "errorCode")
    }
  }
}

/// Context in which user provided the feedback
public enum FeedbackSource: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case app
  case standalonePage
  case extensionUninstall
  case appRegistration
  case appOnboarding
  case appLogin
  case appAccountDeletion
  case iosApp
  case iosAppLoggedOut
  case iosWeb3App
  case preview
  case premiumSurvey
  case protectExtension
  case hardBenefitsRedemption
  case androidApp
  case androidAppLoggedOut
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "App": self = .app
      case "StandalonePage": self = .standalonePage
      case "ExtensionUninstall": self = .extensionUninstall
      case "AppRegistration": self = .appRegistration
      case "AppOnboarding": self = .appOnboarding
      case "AppLogin": self = .appLogin
      case "AppAccountDeletion": self = .appAccountDeletion
      case "IOSApp": self = .iosApp
      case "IOSAppLoggedOut": self = .iosAppLoggedOut
      case "IOSWeb3App": self = .iosWeb3App
      case "Preview": self = .preview
      case "PremiumSurvey": self = .premiumSurvey
      case "ProtectExtension": self = .protectExtension
      case "HardBenefitsRedemption": self = .hardBenefitsRedemption
      case "AndroidApp": self = .androidApp
      case "AndroidAppLoggedOut": self = .androidAppLoggedOut
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .app: return "App"
      case .standalonePage: return "StandalonePage"
      case .extensionUninstall: return "ExtensionUninstall"
      case .appRegistration: return "AppRegistration"
      case .appOnboarding: return "AppOnboarding"
      case .appLogin: return "AppLogin"
      case .appAccountDeletion: return "AppAccountDeletion"
      case .iosApp: return "IOSApp"
      case .iosAppLoggedOut: return "IOSAppLoggedOut"
      case .iosWeb3App: return "IOSWeb3App"
      case .preview: return "Preview"
      case .premiumSurvey: return "PremiumSurvey"
      case .protectExtension: return "ProtectExtension"
      case .hardBenefitsRedemption: return "HardBenefitsRedemption"
      case .androidApp: return "AndroidApp"
      case .androidAppLoggedOut: return "AndroidAppLoggedOut"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: FeedbackSource, rhs: FeedbackSource) -> Bool {
    switch (lhs, rhs) {
      case (.app, .app): return true
      case (.standalonePage, .standalonePage): return true
      case (.extensionUninstall, .extensionUninstall): return true
      case (.appRegistration, .appRegistration): return true
      case (.appOnboarding, .appOnboarding): return true
      case (.appLogin, .appLogin): return true
      case (.appAccountDeletion, .appAccountDeletion): return true
      case (.iosApp, .iosApp): return true
      case (.iosAppLoggedOut, .iosAppLoggedOut): return true
      case (.iosWeb3App, .iosWeb3App): return true
      case (.preview, .preview): return true
      case (.premiumSurvey, .premiumSurvey): return true
      case (.protectExtension, .protectExtension): return true
      case (.hardBenefitsRedemption, .hardBenefitsRedemption): return true
      case (.androidApp, .androidApp): return true
      case (.androidAppLoggedOut, .androidAppLoggedOut): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [FeedbackSource] {
    return [
      .app,
      .standalonePage,
      .extensionUninstall,
      .appRegistration,
      .appOnboarding,
      .appLogin,
      .appAccountDeletion,
      .iosApp,
      .iosAppLoggedOut,
      .iosWeb3App,
      .preview,
      .premiumSurvey,
      .protectExtension,
      .hardBenefitsRedemption,
      .androidApp,
      .androidAppLoggedOut,
    ]
  }
}

/// Input type for user flag mutations
public struct FlagInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - flagId
  ///   - flagValue
  public init(flagId: String, flagValue: Bool) {
    graphQLMap = ["flagID": flagId, "flagValue": flagValue]
  }

  public var flagId: String {
    get {
      return graphQLMap["flagID"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "flagID")
    }
  }

  public var flagValue: Bool {
    get {
      return graphQLMap["flagValue"] as! Bool
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "flagValue")
    }
  }
}

/// Input type for preferred provider mutations.
///
/// We support three mutations:
/// - set
/// - add
/// - delete
public struct PreferredProviderInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - domain
  ///   - preference
  ///   - providerCategory
  public init(domain: Swift.Optional<String?> = nil, preference: Swift.Optional<UserPreference?> = nil, providerCategory: Swift.Optional<ProviderCategory?> = nil) {
    graphQLMap = ["domain": domain, "preference": preference, "providerCategory": providerCategory]
  }

  public var domain: Swift.Optional<String?> {
    get {
      return graphQLMap["domain"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "domain")
    }
  }

  public var preference: Swift.Optional<UserPreference?> {
    get {
      return graphQLMap["preference"] as? Swift.Optional<UserPreference?> ?? Swift.Optional<UserPreference?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "preference")
    }
  }

  public var providerCategory: Swift.Optional<ProviderCategory?> {
    get {
      return graphQLMap["providerCategory"] as? Swift.Optional<ProviderCategory?> ?? Swift.Optional<ProviderCategory?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "providerCategory")
    }
  }
}

public enum ProviderCategory: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case unknown
  case news
  case recipes
  case web
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Unknown": self = .unknown
      case "News": self = .news
      case "Recipes": self = .recipes
      case "Web": self = .web
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .unknown: return "Unknown"
      case .news: return "News"
      case .recipes: return "Recipes"
      case .web: return "Web"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ProviderCategory, rhs: ProviderCategory) -> Bool {
    switch (lhs, rhs) {
      case (.unknown, .unknown): return true
      case (.news, .news): return true
      case (.recipes, .recipes): return true
      case (.web, .web): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ProviderCategory] {
    return [
      .unknown,
      .news,
      .recipes,
      .web,
    ]
  }
}

public struct DeviceTokenInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - deviceToken
  ///   - deviceId
  ///   - environment
  public init(deviceToken: Swift.Optional<String?> = nil, deviceId: Swift.Optional<String?> = nil, environment: Swift.Optional<String?> = nil) {
    graphQLMap = ["deviceToken": deviceToken, "deviceID": deviceId, "environment": environment]
  }

  public var deviceToken: Swift.Optional<String?> {
    get {
      return graphQLMap["deviceToken"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "deviceToken")
    }
  }

  public var deviceId: Swift.Optional<String?> {
    get {
      return graphQLMap["deviceID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "deviceID")
    }
  }

  public var environment: Swift.Optional<String?> {
    get {
      return graphQLMap["environment"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "environment")
    }
  }
}

public struct DeleteDeviceTokenInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - deviceId
  public init(deviceId: Swift.Optional<String?> = nil) {
    graphQLMap = ["deviceID": deviceId]
  }

  public var deviceId: Swift.Optional<String?> {
    get {
      return graphQLMap["deviceID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "deviceID")
    }
  }
}

public struct UpdateUserProfileInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - firstName
  ///   - lastName
  public init(firstName: Swift.Optional<String?> = nil, lastName: Swift.Optional<String?> = nil) {
    graphQLMap = ["firstName": firstName, "lastName": lastName]
  }

  public var firstName: Swift.Optional<String?> {
    get {
      return graphQLMap["firstName"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "firstName")
    }
  }

  public var lastName: Swift.Optional<String?> {
    get {
      return graphQLMap["lastName"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lastName")
    }
  }
}

public enum ResendVerificationEmailResult: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case emailSent
  case alreadyVerified
  case unknown
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "EmailSent": self = .emailSent
      case "AlreadyVerified": self = .alreadyVerified
      case "Unknown": self = .unknown
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .emailSent: return "EmailSent"
      case .alreadyVerified: return "AlreadyVerified"
      case .unknown: return "Unknown"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ResendVerificationEmailResult, rhs: ResendVerificationEmailResult) -> Bool {
    switch (lhs, rhs) {
      case (.emailSent, .emailSent): return true
      case (.alreadyVerified, .alreadyVerified): return true
      case (.unknown, .unknown): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ResendVerificationEmailResult] {
    return [
      .emailSent,
      .alreadyVerified,
      .unknown,
    ]
  }
}

/// Input for reportDomainTrustSignal mutation type
public struct ReportDomainTrustSignalInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - domain
  ///   - signal
  public init(domain: Swift.Optional<String?> = nil, signal: Swift.Optional<TrustSignal?> = nil) {
    graphQLMap = ["domain": domain, "signal": signal]
  }

  public var domain: Swift.Optional<String?> {
    get {
      return graphQLMap["domain"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "domain")
    }
  }

  public var signal: Swift.Optional<TrustSignal?> {
    get {
      return graphQLMap["signal"] as? Swift.Optional<TrustSignal?> ?? Swift.Optional<TrustSignal?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "signal")
    }
  }
}

/// Trust signal
public enum TrustSignal: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Trust signal is unknown
  case unknown
  /// Domain is trusted
  case trusted
  /// Domain is not yet trusted
  case notTrusted
  /// Domain has been marked as having spammy, malicious content
  case malicious
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Unknown": self = .unknown
      case "Trusted": self = .trusted
      case "NotTrusted": self = .notTrusted
      case "Malicious": self = .malicious
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .unknown: return "Unknown"
      case .trusted: return "Trusted"
      case .notTrusted: return "NotTrusted"
      case .malicious: return "Malicious"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: TrustSignal, rhs: TrustSignal) -> Bool {
    switch (lhs, rhs) {
      case (.unknown, .unknown): return true
      case (.trusted, .trusted): return true
      case (.notTrusted, .notTrusted): return true
      case (.malicious, .malicious): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [TrustSignal] {
    return [
      .unknown,
      .trusted,
      .notTrusted,
      .malicious,
    ]
  }
}

/// Input for domainTrustSignals query type
public struct DomainTrustSignalsInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - domains
  public init(domains: Swift.Optional<[String]?> = nil) {
    graphQLMap = ["domains": domains]
  }

  public var domains: Swift.Optional<[String]?> {
    get {
      return graphQLMap["domains"] as? Swift.Optional<[String]?> ?? Swift.Optional<[String]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "domains")
    }
  }
}

public enum SubResultsDisplayType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case `default`
  case carousel
  case grid
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Default": self = .default
      case "Carousel": self = .carousel
      case "Grid": self = .grid
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .default: return "Default"
      case .carousel: return "Carousel"
      case .grid: return "Grid"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: SubResultsDisplayType, rhs: SubResultsDisplayType) -> Bool {
    switch (lhs, rhs) {
      case (.default, .default): return true
      case (.carousel, .carousel): return true
      case (.grid, .grid): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [SubResultsDisplayType] {
    return [
      .default,
      .carousel,
      .grid,
    ]
  }
}

public enum SubResultsSemantics: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case unspecified
  case maybeDupe
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Unspecified": self = .unspecified
      case "MaybeDupe": self = .maybeDupe
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .unspecified: return "Unspecified"
      case .maybeDupe: return "MaybeDupe"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: SubResultsSemantics, rhs: SubResultsSemantics) -> Bool {
    switch (lhs, rhs) {
      case (.unspecified, .unspecified): return true
      case (.maybeDupe, .maybeDupe): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [SubResultsSemantics] {
    return [
      .unspecified,
      .maybeDupe,
    ]
  }
}

public enum PlaceSubType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case unknown
  case placeList
  case map
  case singlePlace
  case address
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Unknown": self = .unknown
      case "PlaceList": self = .placeList
      case "Map": self = .map
      case "SinglePlace": self = .singlePlace
      case "Address": self = .address
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .unknown: return "Unknown"
      case .placeList: return "PlaceList"
      case .map: return "Map"
      case .singlePlace: return "SinglePlace"
      case .address: return "Address"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: PlaceSubType, rhs: PlaceSubType) -> Bool {
    switch (lhs, rhs) {
      case (.unknown, .unknown): return true
      case (.placeList, .placeList): return true
      case (.map, .map): return true
      case (.singlePlace, .singlePlace): return true
      case (.address, .address): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [PlaceSubType] {
    return [
      .unknown,
      .placeList,
      .map,
      .singlePlace,
      .address,
    ]
  }
}

public enum ListSpacesKind: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case all
  case visited
  case invited
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "All": self = .all
      case "Visited": self = .visited
      case "Invited": self = .invited
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .all: return "All"
      case .visited: return "Visited"
      case .invited: return "Invited"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ListSpacesKind, rhs: ListSpacesKind) -> Bool {
    switch (lhs, rhs) {
      case (.all, .all): return true
      case (.visited, .visited): return true
      case (.invited, .invited): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ListSpacesKind] {
    return [
      .all,
      .visited,
      .invited,
    ]
  }
}

public enum NotificationType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case spaceSharedWithYou
  case spaceEntitiesAdded
  case spaceCommentsAdded
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "SpaceSharedWithYou": self = .spaceSharedWithYou
      case "SpaceEntitiesAdded": self = .spaceEntitiesAdded
      case "SpaceCommentsAdded": self = .spaceCommentsAdded
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .spaceSharedWithYou: return "SpaceSharedWithYou"
      case .spaceEntitiesAdded: return "SpaceEntitiesAdded"
      case .spaceCommentsAdded: return "SpaceCommentsAdded"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: NotificationType, rhs: NotificationType) -> Bool {
    switch (lhs, rhs) {
      case (.spaceSharedWithYou, .spaceSharedWithYou): return true
      case (.spaceEntitiesAdded, .spaceEntitiesAdded): return true
      case (.spaceCommentsAdded, .spaceCommentsAdded): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [NotificationType] {
    return [
      .spaceSharedWithYou,
      .spaceEntitiesAdded,
      .spaceCommentsAdded,
    ]
  }
}

public enum SpaceACLLevel: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case owner
  case edit
  case comment
  case view
  case publicView
  case publicIndexed
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Owner": self = .owner
      case "Edit": self = .edit
      case "Comment": self = .comment
      case "View": self = .view
      case "PublicView": self = .publicView
      case "PublicIndexed": self = .publicIndexed
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .owner: return "Owner"
      case .edit: return "Edit"
      case .comment: return "Comment"
      case .view: return "View"
      case .publicView: return "PublicView"
      case .publicIndexed: return "PublicIndexed"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: SpaceACLLevel, rhs: SpaceACLLevel) -> Bool {
    switch (lhs, rhs) {
      case (.owner, .owner): return true
      case (.edit, .edit): return true
      case (.comment, .comment): return true
      case (.view, .view): return true
      case (.publicView, .publicView): return true
      case (.publicIndexed, .publicIndexed): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [SpaceACLLevel] {
    return [
      .owner,
      .edit,
      .comment,
      .view,
      .publicView,
      .publicIndexed,
    ]
  }
}

public struct AddSpaceResultByURLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - spaceId
  ///   - url
  ///   - title
  ///   - thumbnail
  ///   - comment
  ///   - data: Raw data for page being added. Could be HTML from DOM or byte stream if PDF etc
  ///   - mediaType: Type of content, eg text/html
  ///   - contentType: Type of the content obtained from the http response
  ///   - isBase64: Defaults to false
  public init(spaceId: String, url: String, title: String, thumbnail: Swift.Optional<String?> = nil, comment: Swift.Optional<String?> = nil, data: Swift.Optional<String?> = nil, mediaType: Swift.Optional<String?> = nil, contentType: Swift.Optional<String?> = nil, isBase64: Swift.Optional<Bool?> = nil) {
    graphQLMap = ["spaceID": spaceId, "url": url, "title": title, "thumbnail": thumbnail, "comment": comment, "data": data, "mediaType": mediaType, "contentType": contentType, "isBase64": isBase64]
  }

  public var spaceId: String {
    get {
      return graphQLMap["spaceID"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "spaceID")
    }
  }

  public var url: String {
    get {
      return graphQLMap["url"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "url")
    }
  }

  public var title: String {
    get {
      return graphQLMap["title"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var thumbnail: Swift.Optional<String?> {
    get {
      return graphQLMap["thumbnail"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "thumbnail")
    }
  }

  public var comment: Swift.Optional<String?> {
    get {
      return graphQLMap["comment"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "comment")
    }
  }

  /// Raw data for page being added. Could be HTML from DOM or byte stream if PDF etc
  public var data: Swift.Optional<String?> {
    get {
      return graphQLMap["data"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "data")
    }
  }

  /// Type of content, eg text/html
  public var mediaType: Swift.Optional<String?> {
    get {
      return graphQLMap["mediaType"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "mediaType")
    }
  }

  /// Type of the content obtained from the http response
  public var contentType: Swift.Optional<String?> {
    get {
      return graphQLMap["contentType"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contentType")
    }
  }

  /// Defaults to false
  public var isBase64: Swift.Optional<Bool?> {
    get {
      return graphQLMap["isBase64"] as? Swift.Optional<Bool?> ?? Swift.Optional<Bool?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isBase64")
    }
  }
}

public struct UpdateSpaceInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - id
  ///   - name
  ///   - description
  ///   - thumbnail
  public init(id: String, name: Swift.Optional<String?> = nil, description: Swift.Optional<String?> = nil, thumbnail: Swift.Optional<String?> = nil) {
    graphQLMap = ["id": id, "name": name, "description": description, "thumbnail": thumbnail]
  }

  public var id: String {
    get {
      return graphQLMap["id"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var name: Swift.Optional<String?> {
    get {
      return graphQLMap["name"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var description: Swift.Optional<String?> {
    get {
      return graphQLMap["description"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var thumbnail: Swift.Optional<String?> {
    get {
      return graphQLMap["thumbnail"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "thumbnail")
    }
  }
}

public struct LeaveSpaceInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - id
  public init(id: String) {
    graphQLMap = ["id": id]
  }

  public var id: String {
    get {
      return graphQLMap["id"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct DeleteSpaceInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - id
  public init(id: String) {
    graphQLMap = ["id": id]
  }

  public var id: String {
    get {
      return graphQLMap["id"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct DeleteSpaceResultByURLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - spaceId
  ///   - url
  public init(spaceId: String, url: String) {
    graphQLMap = ["spaceID": spaceId, "url": url]
  }

  public var spaceId: String {
    get {
      return graphQLMap["spaceID"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "spaceID")
    }
  }

  public var url: String {
    get {
      return graphQLMap["url"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "url")
    }
  }
}

public struct BatchDeleteSpaceResultInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - spaceId
  ///   - resultIDs
  public init(spaceId: String, resultIDs: [String]) {
    graphQLMap = ["spaceID": spaceId, "resultIDs": resultIDs]
  }

  public var spaceId: String {
    get {
      return graphQLMap["spaceID"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "spaceID")
    }
  }

  public var resultIDs: [String] {
    get {
      return graphQLMap["resultIDs"] as! [String]
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultIDs")
    }
  }
}

public struct UpdateSpaceEntityDisplayDataInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - spaceId
  ///   - resultId
  ///   - title
  ///   - snippet
  ///   - thumbnail
  public init(spaceId: Swift.Optional<String?> = nil, resultId: Swift.Optional<String?> = nil, title: Swift.Optional<String?> = nil, snippet: Swift.Optional<String?> = nil, thumbnail: Swift.Optional<String?> = nil) {
    graphQLMap = ["spaceID": spaceId, "resultID": resultId, "title": title, "snippet": snippet, "thumbnail": thumbnail]
  }

  public var spaceId: Swift.Optional<String?> {
    get {
      return graphQLMap["spaceID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "spaceID")
    }
  }

  public var resultId: Swift.Optional<String?> {
    get {
      return graphQLMap["resultID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultID")
    }
  }

  public var title: Swift.Optional<String?> {
    get {
      return graphQLMap["title"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "title")
    }
  }

  public var snippet: Swift.Optional<String?> {
    get {
      return graphQLMap["snippet"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "snippet")
    }
  }

  public var thumbnail: Swift.Optional<String?> {
    get {
      return graphQLMap["thumbnail"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "thumbnail")
    }
  }
}

public struct SetSpaceDetailPageSortOrderInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - spaceId
  ///   - attribute
  ///   - sortOrderType
  ///   - customSortOrder
  public init(spaceId: Swift.Optional<String?> = nil, attribute: Swift.Optional<String?> = nil, sortOrderType: Swift.Optional<SortOrderType?> = nil, customSortOrder: Swift.Optional<CustomSortOrderInput?> = nil) {
    graphQLMap = ["spaceID": spaceId, "attribute": attribute, "sortOrderType": sortOrderType, "customSortOrder": customSortOrder]
  }

  public var spaceId: Swift.Optional<String?> {
    get {
      return graphQLMap["spaceID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "spaceID")
    }
  }

  public var attribute: Swift.Optional<String?> {
    get {
      return graphQLMap["attribute"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "attribute")
    }
  }

  public var sortOrderType: Swift.Optional<SortOrderType?> {
    get {
      return graphQLMap["sortOrderType"] as? Swift.Optional<SortOrderType?> ?? Swift.Optional<SortOrderType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "sortOrderType")
    }
  }

  public var customSortOrder: Swift.Optional<CustomSortOrderInput?> {
    get {
      return graphQLMap["customSortOrder"] as? Swift.Optional<CustomSortOrderInput?> ?? Swift.Optional<CustomSortOrderInput?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "customSortOrder")
    }
  }
}

public enum SortOrderType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case unspecified
  case ascending
  case descending
  case custom
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Unspecified": self = .unspecified
      case "Ascending": self = .ascending
      case "Descending": self = .descending
      case "Custom": self = .custom
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .unspecified: return "Unspecified"
      case .ascending: return "Ascending"
      case .descending: return "Descending"
      case .custom: return "Custom"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: SortOrderType, rhs: SortOrderType) -> Bool {
    switch (lhs, rhs) {
      case (.unspecified, .unspecified): return true
      case (.ascending, .ascending): return true
      case (.descending, .descending): return true
      case (.custom, .custom): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [SortOrderType] {
    return [
      .unspecified,
      .ascending,
      .descending,
      .custom,
    ]
  }
}

public struct CustomSortOrderInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - resultIDs
  public init(resultIDs: Swift.Optional<[String]?> = nil) {
    graphQLMap = ["resultIDs": resultIDs]
  }

  public var resultIDs: Swift.Optional<[String]?> {
    get {
      return graphQLMap["resultIDs"] as? Swift.Optional<[String]?> ?? Swift.Optional<[String]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultIDs")
    }
  }
}

public struct AddSpacePublicACLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - id
  public init(id: Swift.Optional<String?> = nil) {
    graphQLMap = ["id": id]
  }

  public var id: Swift.Optional<String?> {
    get {
      return graphQLMap["id"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct DeleteSpacePublicACLInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - id
  public init(id: Swift.Optional<String?> = nil) {
    graphQLMap = ["id": id]
  }

  public var id: Swift.Optional<String?> {
    get {
      return graphQLMap["id"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct DeleteSpaceGeneratorInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - spaceId
  ///   - generatorId
  public init(spaceId: Swift.Optional<String?> = nil, generatorId: Swift.Optional<String?> = nil) {
    graphQLMap = ["spaceID": spaceId, "generatorID": generatorId]
  }

  public var spaceId: Swift.Optional<String?> {
    get {
      return graphQLMap["spaceID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "spaceID")
    }
  }

  public var generatorId: Swift.Optional<String?> {
    get {
      return graphQLMap["generatorID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "generatorID")
    }
  }
}

public struct AddSpaceCommentInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - spaceId
  ///   - comment
  public init(spaceId: Swift.Optional<String?> = nil, comment: Swift.Optional<String?> = nil) {
    graphQLMap = ["spaceID": spaceId, "comment": comment]
  }

  public var spaceId: Swift.Optional<String?> {
    get {
      return graphQLMap["spaceID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "spaceID")
    }
  }

  public var comment: Swift.Optional<String?> {
    get {
      return graphQLMap["comment"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "comment")
    }
  }
}

public struct AddSpaceSoloACLsInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - id
  ///   - shareWith
  ///   - note
  public init(id: Swift.Optional<String?> = nil, shareWith: Swift.Optional<[SpaceEmailACL]?> = nil, note: Swift.Optional<String?> = nil) {
    graphQLMap = ["id": id, "shareWith": shareWith, "note": note]
  }

  public var id: Swift.Optional<String?> {
    get {
      return graphQLMap["id"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var shareWith: Swift.Optional<[SpaceEmailACL]?> {
    get {
      return graphQLMap["shareWith"] as? Swift.Optional<[SpaceEmailACL]?> ?? Swift.Optional<[SpaceEmailACL]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "shareWith")
    }
  }

  public var note: Swift.Optional<String?> {
    get {
      return graphQLMap["note"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "note")
    }
  }
}

public struct SpaceEmailACL: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - email
  ///   - acl
  public init(email: String, acl: SpaceACLLevel) {
    graphQLMap = ["email": email, "acl": acl]
  }

  public var email: String {
    get {
      return graphQLMap["email"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "email")
    }
  }

  public var acl: SpaceACLLevel {
    get {
      return graphQLMap["acl"] as! SpaceACLLevel
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "acl")
    }
  }
}

public struct ClaimGeneratedItemInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - spaceId
  ///   - resultId
  public init(spaceId: Swift.Optional<String?> = nil, resultId: Swift.Optional<String?> = nil) {
    graphQLMap = ["spaceID": spaceId, "resultID": resultId]
  }

  public var spaceId: Swift.Optional<String?> {
    get {
      return graphQLMap["spaceID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "spaceID")
    }
  }

  public var resultId: Swift.Optional<String?> {
    get {
      return graphQLMap["resultID"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "resultID")
    }
  }
}

public enum QuerySuggestionType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case standard
  case `operator`
  case searchHistory
  case space
  case unknown
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Standard": self = .standard
      case "Operator": self = .operator
      case "SearchHistory": self = .searchHistory
      case "Space": self = .space
      case "Unknown": self = .unknown
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .standard: return "Standard"
      case .operator: return "Operator"
      case .searchHistory: return "SearchHistory"
      case .space: return "Space"
      case .unknown: return "Unknown"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: QuerySuggestionType, rhs: QuerySuggestionType) -> Bool {
    switch (lhs, rhs) {
      case (.standard, .standard): return true
      case (.operator, .operator): return true
      case (.searchHistory, .searchHistory): return true
      case (.space, .space): return true
      case (.unknown, .unknown): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [QuerySuggestionType] {
    return [
      .standard,
      .operator,
      .searchHistory,
      .space,
      .unknown,
    ]
  }
}

public enum QuerySuggestionSource: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case bing
  case publicNav
  case searchHistory
  case privateCorpus
  case elastic
  case calculator
  case stock
  case unknown
  case clipboard
  case `public`
  case dictionary
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Bing": self = .bing
      case "PublicNav": self = .publicNav
      case "SearchHistory": self = .searchHistory
      case "PrivateCorpus": self = .privateCorpus
      case "Elastic": self = .elastic
      case "Calculator": self = .calculator
      case "Stock": self = .stock
      case "Unknown": self = .unknown
      case "Clipboard": self = .clipboard
      case "Public": self = .public
      case "Dictionary": self = .dictionary
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .bing: return "Bing"
      case .publicNav: return "PublicNav"
      case .searchHistory: return "SearchHistory"
      case .privateCorpus: return "PrivateCorpus"
      case .elastic: return "Elastic"
      case .calculator: return "Calculator"
      case .stock: return "Stock"
      case .unknown: return "Unknown"
      case .clipboard: return "Clipboard"
      case .public: return "Public"
      case .dictionary: return "Dictionary"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: QuerySuggestionSource, rhs: QuerySuggestionSource) -> Bool {
    switch (lhs, rhs) {
      case (.bing, .bing): return true
      case (.publicNav, .publicNav): return true
      case (.searchHistory, .searchHistory): return true
      case (.privateCorpus, .privateCorpus): return true
      case (.elastic, .elastic): return true
      case (.calculator, .calculator): return true
      case (.stock, .stock): return true
      case (.unknown, .unknown): return true
      case (.clipboard, .clipboard): return true
      case (.public, .public): return true
      case (.dictionary, .dictionary): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [QuerySuggestionSource] {
    return [
      .bing,
      .publicNav,
      .searchHistory,
      .privateCorpus,
      .elastic,
      .calculator,
      .stock,
      .unknown,
      .clipboard,
      .public,
      .dictionary,
    ]
  }
}

public enum ActiveLensBangType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case unknown
  case lens
  case bang
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "Unknown": self = .unknown
      case "Lens": self = .lens
      case "Bang": self = .bang
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .unknown: return "Unknown"
      case .lens: return "Lens"
      case .bang: return "Bang"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ActiveLensBangType, rhs: ActiveLensBangType) -> Bool {
    switch (lhs, rhs) {
      case (.unknown, .unknown): return true
      case (.lens, .lens): return true
      case (.bang, .bang): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ActiveLensBangType] {
    return [
      .unknown,
      .lens,
      .bang,
    ]
  }
}

public final class LogMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation Log($input: ClientLogInput!) {
      log(input: $input)
    }
    """

  public let operationName: String = "Log"

  public let operationIdentifier: String? = "c7cb9ba8d413a3eef416d5daea86742c333d88018f775e607b2feb001faf9a6b"

  public var input: ClientLogInput

  public init(input: ClientLogInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("log", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(log: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "log": log])
    }

    /// Send a log message from the client.
    public var log: Bool {
      get {
        return resultMap["log"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "log")
      }
    }
  }
}

public final class UserInfoQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query UserInfo {
      user {
        __typename
        id
        profile {
          __typename
          displayName
          email
          pictureURL
        }
        flags
        isVerified
        featureFlags {
          __typename
          id
          value
          intValue
          floatValue
          stringValue
        }
        authProvider
        subscriptionType
      }
    }
    """

  public let operationName: String = "UserInfo"

  public let operationIdentifier: String? = "8cf56e9c3248d91180131675507fb3c06a45f613d81f08a51501e9bd004638bd"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("user", type: .object(User.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(user: User? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "user": user.flatMap { (value: User) -> ResultMap in value.resultMap }])
    }

    /// The logged-in user making the request.
    public var user: User? {
      get {
        return (resultMap["user"] as? ResultMap).flatMap { User(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "user")
      }
    }

    public struct User: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["User"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("profile", type: .nonNull(.object(Profile.selections))),
          GraphQLField("flags", type: .nonNull(.list(.nonNull(.scalar(String.self))))),
          GraphQLField("isVerified", type: .scalar(Bool.self)),
          GraphQLField("featureFlags", type: .nonNull(.list(.nonNull(.object(FeatureFlag.selections))))),
          GraphQLField("authProvider", type: .scalar(String.self)),
          GraphQLField("subscriptionType", type: .scalar(SubscriptionType.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, profile: Profile, flags: [String], isVerified: Bool? = nil, featureFlags: [FeatureFlag], authProvider: String? = nil, subscriptionType: SubscriptionType? = nil) {
        self.init(unsafeResultMap: ["__typename": "User", "id": id, "profile": profile.resultMap, "flags": flags, "isVerified": isVerified, "featureFlags": featureFlags.map { (value: FeatureFlag) -> ResultMap in value.resultMap }, "authProvider": authProvider, "subscriptionType": subscriptionType])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// User's Neeva ID.
      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      /// User's profile/display information.
      public var profile: Profile {
        get {
          return Profile(unsafeResultMap: resultMap["profile"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "profile")
        }
      }

      /// List of all user flags that exist for a user (these are used to store UI preferences)
      public var flags: [String] {
        get {
          return resultMap["flags"]! as! [String]
        }
        set {
          resultMap.updateValue(newValue, forKey: "flags")
        }
      }

      /// User's account verification status
      public var isVerified: Bool? {
        get {
          return resultMap["isVerified"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "isVerified")
        }
      }

      /// List of feature flags
      public var featureFlags: [FeatureFlag] {
        get {
          return (resultMap["featureFlags"] as! [ResultMap]).map { (value: ResultMap) -> FeatureFlag in FeatureFlag(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: FeatureFlag) -> ResultMap in value.resultMap }, forKey: "featureFlags")
        }
      }

      /// Name of the authenticator provider the user used to authenticate.
      public var authProvider: String? {
        get {
          return resultMap["authProvider"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "authProvider")
        }
      }

      /// Type of a user subscription (modulates subscription behavior)
      public var subscriptionType: SubscriptionType? {
        get {
          return resultMap["subscriptionType"] as? SubscriptionType
        }
        set {
          resultMap.updateValue(newValue, forKey: "subscriptionType")
        }
      }

      public struct Profile: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Profile"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("displayName", type: .nonNull(.scalar(String.self))),
            GraphQLField("email", type: .nonNull(.scalar(String.self))),
            GraphQLField("pictureURL", type: .nonNull(.scalar(String.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(displayName: String, email: String, pictureUrl: String) {
          self.init(unsafeResultMap: ["__typename": "Profile", "displayName": displayName, "email": email, "pictureURL": pictureUrl])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var displayName: String {
          get {
            return resultMap["displayName"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "displayName")
          }
        }

        public var email: String {
          get {
            return resultMap["email"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "email")
          }
        }

        public var pictureUrl: String {
          get {
            return resultMap["pictureURL"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "pictureURL")
          }
        }
      }

      public struct FeatureFlag: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["FeatureFlag"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(Int.self))),
            GraphQLField("value", type: .scalar(Bool.self)),
            GraphQLField("intValue", type: .scalar(Int.self)),
            GraphQLField("floatValue", type: .scalar(Double.self)),
            GraphQLField("stringValue", type: .scalar(String.self)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: Int, value: Bool? = nil, intValue: Int? = nil, floatValue: Double? = nil, stringValue: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "FeatureFlag", "id": id, "value": value, "intValue": intValue, "floatValue": floatValue, "stringValue": stringValue])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The numeric ID of the feature flag.
        public var id: Int {
          get {
            return resultMap["id"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        /// The boolean value of the feature flag, to be populated if the flag is of
        /// type Boolean.
        public var value: Bool? {
          get {
            return resultMap["value"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "value")
          }
        }

        /// The integer value of the feature flag, to be populated if the flag is of
        /// type Integer.
        public var intValue: Int? {
          get {
            return resultMap["intValue"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "intValue")
          }
        }

        /// The float value of the feature flag, to be populated if the flag is of
        /// type Float.
        public var floatValue: Double? {
          get {
            return resultMap["floatValue"] as? Double
          }
          set {
            resultMap.updateValue(newValue, forKey: "floatValue")
          }
        }

        /// The string value of the feature flag, to be populated if the flag is of
        /// type String.
        public var stringValue: String? {
          get {
            return resultMap["stringValue"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "stringValue")
          }
        }
      }
    }
  }
}

public final class CheatsheetInfoQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query CheatsheetInfo($input: String!) {
      getCheatsheetInfo(input: $input) {
        __typename
        ReviewURL
        PriceHistory {
          __typename
          InStock
          Max {
            __typename
            Date
            PriceUSD
          }
          Min {
            __typename
            Date
            PriceUSD
          }
          Current {
            __typename
            Date
            PriceUSD
          }
          Average {
            __typename
            Date
            PriceUSD
          }
        }
        MemorizedQuery
        Recipe {
          __typename
          title
          preference
          imageURL
          totalTime
          prepTime
          yield
          ingredients {
            __typename
            text
          }
          instructions {
            __typename
            text
          }
          recipeRating {
            __typename
            maxStars
            recipeStars
            numReviews
          }
          reviews {
            __typename
            reviewerName
            body
            rating {
              __typename
              maxStars
              actualStars
            }
          }
        }
      }
    }
    """

  public let operationName: String = "CheatsheetInfo"

  public let operationIdentifier: String? = "de04f6a5f3780f8256c08ab333608050744f2aa80f4cec1af52659f4bb19fc35"

  public var input: String

  public init(input: String) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("getCheatsheetInfo", arguments: ["input": GraphQLVariable("input")], type: .object(GetCheatsheetInfo.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(getCheatsheetInfo: GetCheatsheetInfo? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "getCheatsheetInfo": getCheatsheetInfo.flatMap { (value: GetCheatsheetInfo) -> ResultMap in value.resultMap }])
    }

    /// Get cheatsheet info for a url
    public var getCheatsheetInfo: GetCheatsheetInfo? {
      get {
        return (resultMap["getCheatsheetInfo"] as? ResultMap).flatMap { GetCheatsheetInfo(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "getCheatsheetInfo")
      }
    }

    public struct GetCheatsheetInfo: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["CheatsheetAnnotationData"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("ReviewURL", type: .list(.nonNull(.scalar(String.self)))),
          GraphQLField("PriceHistory", type: .object(PriceHistory.selections)),
          GraphQLField("MemorizedQuery", type: .list(.nonNull(.scalar(String.self)))),
          GraphQLField("Recipe", type: .object(Recipe.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(reviewUrl: [String]? = nil, priceHistory: PriceHistory? = nil, memorizedQuery: [String]? = nil, recipe: Recipe? = nil) {
        self.init(unsafeResultMap: ["__typename": "CheatsheetAnnotationData", "ReviewURL": reviewUrl, "PriceHistory": priceHistory.flatMap { (value: PriceHistory) -> ResultMap in value.resultMap }, "MemorizedQuery": memorizedQuery, "Recipe": recipe.flatMap { (value: Recipe) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var reviewUrl: [String]? {
        get {
          return resultMap["ReviewURL"] as? [String]
        }
        set {
          resultMap.updateValue(newValue, forKey: "ReviewURL")
        }
      }

      public var priceHistory: PriceHistory? {
        get {
          return (resultMap["PriceHistory"] as? ResultMap).flatMap { PriceHistory(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "PriceHistory")
        }
      }

      public var memorizedQuery: [String]? {
        get {
          return resultMap["MemorizedQuery"] as? [String]
        }
        set {
          resultMap.updateValue(newValue, forKey: "MemorizedQuery")
        }
      }

      public var recipe: Recipe? {
        get {
          return (resultMap["Recipe"] as? ResultMap).flatMap { Recipe(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "Recipe")
        }
      }

      public struct PriceHistory: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["ProviderPriceHistory"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("InStock", type: .scalar(Bool.self)),
            GraphQLField("Max", type: .object(Max.selections)),
            GraphQLField("Min", type: .object(Min.selections)),
            GraphQLField("Current", type: .object(Current.selections)),
            GraphQLField("Average", type: .object(Average.selections)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(inStock: Bool? = nil, max: Max? = nil, min: Min? = nil, current: Current? = nil, average: Average? = nil) {
          self.init(unsafeResultMap: ["__typename": "ProviderPriceHistory", "InStock": inStock, "Max": max.flatMap { (value: Max) -> ResultMap in value.resultMap }, "Min": min.flatMap { (value: Min) -> ResultMap in value.resultMap }, "Current": current.flatMap { (value: Current) -> ResultMap in value.resultMap }, "Average": average.flatMap { (value: Average) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var inStock: Bool? {
          get {
            return resultMap["InStock"] as? Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "InStock")
          }
        }

        public var max: Max? {
          get {
            return (resultMap["Max"] as? ResultMap).flatMap { Max(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "Max")
          }
        }

        public var min: Min? {
          get {
            return (resultMap["Min"] as? ResultMap).flatMap { Min(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "Min")
          }
        }

        public var current: Current? {
          get {
            return (resultMap["Current"] as? ResultMap).flatMap { Current(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "Current")
          }
        }

        public var average: Average? {
          get {
            return (resultMap["Average"] as? ResultMap).flatMap { Average(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "Average")
          }
        }

        public struct Max: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["PriceDate"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("Date", type: .scalar(String.self)),
              GraphQLField("PriceUSD", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(date: String? = nil, priceUsd: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "PriceDate", "Date": date, "PriceUSD": priceUsd])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var date: String? {
            get {
              return resultMap["Date"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "Date")
            }
          }

          public var priceUsd: String? {
            get {
              return resultMap["PriceUSD"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "PriceUSD")
            }
          }
        }

        public struct Min: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["PriceDate"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("Date", type: .scalar(String.self)),
              GraphQLField("PriceUSD", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(date: String? = nil, priceUsd: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "PriceDate", "Date": date, "PriceUSD": priceUsd])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var date: String? {
            get {
              return resultMap["Date"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "Date")
            }
          }

          public var priceUsd: String? {
            get {
              return resultMap["PriceUSD"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "PriceUSD")
            }
          }
        }

        public struct Current: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["PriceDate"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("Date", type: .scalar(String.self)),
              GraphQLField("PriceUSD", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(date: String? = nil, priceUsd: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "PriceDate", "Date": date, "PriceUSD": priceUsd])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var date: String? {
            get {
              return resultMap["Date"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "Date")
            }
          }

          public var priceUsd: String? {
            get {
              return resultMap["PriceUSD"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "PriceUSD")
            }
          }
        }

        public struct Average: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["PriceDate"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("Date", type: .scalar(String.self)),
              GraphQLField("PriceUSD", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(date: String? = nil, priceUsd: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "PriceDate", "Date": date, "PriceUSD": priceUsd])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var date: String? {
            get {
              return resultMap["Date"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "Date")
            }
          }

          public var priceUsd: String? {
            get {
              return resultMap["PriceUSD"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "PriceUSD")
            }
          }
        }
      }

      public struct Recipe: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Recipe"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("title", type: .scalar(String.self)),
            GraphQLField("preference", type: .scalar(UserPreference.self)),
            GraphQLField("imageURL", type: .scalar(String.self)),
            GraphQLField("totalTime", type: .scalar(String.self)),
            GraphQLField("prepTime", type: .scalar(String.self)),
            GraphQLField("yield", type: .scalar(String.self)),
            GraphQLField("ingredients", type: .list(.nonNull(.object(Ingredient.selections)))),
            GraphQLField("instructions", type: .list(.nonNull(.object(Instruction.selections)))),
            GraphQLField("recipeRating", type: .object(RecipeRating.selections)),
            GraphQLField("reviews", type: .list(.nonNull(.object(Review.selections)))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(title: String? = nil, preference: UserPreference? = nil, imageUrl: String? = nil, totalTime: String? = nil, prepTime: String? = nil, yield: String? = nil, ingredients: [Ingredient]? = nil, instructions: [Instruction]? = nil, recipeRating: RecipeRating? = nil, reviews: [Review]? = nil) {
          self.init(unsafeResultMap: ["__typename": "Recipe", "title": title, "preference": preference, "imageURL": imageUrl, "totalTime": totalTime, "prepTime": prepTime, "yield": yield, "ingredients": ingredients.flatMap { (value: [Ingredient]) -> [ResultMap] in value.map { (value: Ingredient) -> ResultMap in value.resultMap } }, "instructions": instructions.flatMap { (value: [Instruction]) -> [ResultMap] in value.map { (value: Instruction) -> ResultMap in value.resultMap } }, "recipeRating": recipeRating.flatMap { (value: RecipeRating) -> ResultMap in value.resultMap }, "reviews": reviews.flatMap { (value: [Review]) -> [ResultMap] in value.map { (value: Review) -> ResultMap in value.resultMap } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var title: String? {
          get {
            return resultMap["title"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "title")
          }
        }

        public var preference: UserPreference? {
          get {
            return resultMap["preference"] as? UserPreference
          }
          set {
            resultMap.updateValue(newValue, forKey: "preference")
          }
        }

        public var imageUrl: String? {
          get {
            return resultMap["imageURL"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "imageURL")
          }
        }

        public var totalTime: String? {
          get {
            return resultMap["totalTime"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "totalTime")
          }
        }

        public var prepTime: String? {
          get {
            return resultMap["prepTime"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "prepTime")
          }
        }

        public var yield: String? {
          get {
            return resultMap["yield"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "yield")
          }
        }

        public var ingredients: [Ingredient]? {
          get {
            return (resultMap["ingredients"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Ingredient] in value.map { (value: ResultMap) -> Ingredient in Ingredient(unsafeResultMap: value) } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Ingredient]) -> [ResultMap] in value.map { (value: Ingredient) -> ResultMap in value.resultMap } }, forKey: "ingredients")
          }
        }

        public var instructions: [Instruction]? {
          get {
            return (resultMap["instructions"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Instruction] in value.map { (value: ResultMap) -> Instruction in Instruction(unsafeResultMap: value) } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Instruction]) -> [ResultMap] in value.map { (value: Instruction) -> ResultMap in value.resultMap } }, forKey: "instructions")
          }
        }

        public var recipeRating: RecipeRating? {
          get {
            return (resultMap["recipeRating"] as? ResultMap).flatMap { RecipeRating(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "recipeRating")
          }
        }

        public var reviews: [Review]? {
          get {
            return (resultMap["reviews"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Review] in value.map { (value: ResultMap) -> Review in Review(unsafeResultMap: value) } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Review]) -> [ResultMap] in value.map { (value: Review) -> ResultMap in value.resultMap } }, forKey: "reviews")
          }
        }

        public struct Ingredient: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["RecipeIngredient"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("text", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(text: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "RecipeIngredient", "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var text: String? {
            get {
              return resultMap["text"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }
        }

        public struct Instruction: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["RecipeInstruction"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("text", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(text: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "RecipeInstruction", "text": text])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var text: String? {
            get {
              return resultMap["text"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }
        }

        public struct RecipeRating: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["RecipeRating"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("maxStars", type: .scalar(Double.self)),
              GraphQLField("recipeStars", type: .scalar(Double.self)),
              GraphQLField("numReviews", type: .scalar(Int.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(maxStars: Double? = nil, recipeStars: Double? = nil, numReviews: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "RecipeRating", "maxStars": maxStars, "recipeStars": recipeStars, "numReviews": numReviews])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var maxStars: Double? {
            get {
              return resultMap["maxStars"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "maxStars")
            }
          }

          public var recipeStars: Double? {
            get {
              return resultMap["recipeStars"] as? Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "recipeStars")
            }
          }

          public var numReviews: Int? {
            get {
              return resultMap["numReviews"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "numReviews")
            }
          }
        }

        public struct Review: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["RHSWebDisplayBlockReview"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("reviewerName", type: .scalar(String.self)),
              GraphQLField("body", type: .scalar(String.self)),
              GraphQLField("rating", type: .object(Rating.selections)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(reviewerName: String? = nil, body: String? = nil, rating: Rating? = nil) {
            self.init(unsafeResultMap: ["__typename": "RHSWebDisplayBlockReview", "reviewerName": reviewerName, "body": body, "rating": rating.flatMap { (value: Rating) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var reviewerName: String? {
            get {
              return resultMap["reviewerName"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "reviewerName")
            }
          }

          public var body: String? {
            get {
              return resultMap["body"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "body")
            }
          }

          public var rating: Rating? {
            get {
              return (resultMap["rating"] as? ResultMap).flatMap { Rating(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "rating")
            }
          }

          public struct Rating: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["RHSWebDisplayRating"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("maxStars", type: .scalar(Double.self)),
                GraphQLField("actualStars", type: .scalar(Double.self)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(maxStars: Double? = nil, actualStars: Double? = nil) {
              self.init(unsafeResultMap: ["__typename": "RHSWebDisplayRating", "maxStars": maxStars, "actualStars": actualStars])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var maxStars: Double? {
              get {
                return resultMap["maxStars"] as? Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "maxStars")
              }
            }

            public var actualStars: Double? {
              get {
                return resultMap["actualStars"] as? Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "actualStars")
              }
            }
          }
        }
      }
    }
  }
}

public final class GetContactSuggestionsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query GetContactSuggestions($q: String!, $count: Int, $onlyNeevaUsers: Boolean) {
      suggestContacts(q: $q, count: $count, onlyNeevaUsers: $onlyNeevaUsers) {
        __typename
        requestID
        contactSuggestions {
          __typename
          profile {
            __typename
            displayName
            email
            pictureURL
          }
        }
      }
    }
    """

  public let operationName: String = "GetContactSuggestions"

  public let operationIdentifier: String? = "b7c4438e46da456873602ff047a2693ad52e93b8344aacdcf6554f20ab10306f"

  public var q: String
  public var count: Int?
  public var onlyNeevaUsers: Bool?

  public init(q: String, count: Int? = nil, onlyNeevaUsers: Bool? = nil) {
    self.q = q
    self.count = count
    self.onlyNeevaUsers = onlyNeevaUsers
  }

  public var variables: GraphQLMap? {
    return ["q": q, "count": count, "onlyNeevaUsers": onlyNeevaUsers]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("suggestContacts", arguments: ["q": GraphQLVariable("q"), "count": GraphQLVariable("count"), "onlyNeevaUsers": GraphQLVariable("onlyNeevaUsers")], type: .object(SuggestContact.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(suggestContacts: SuggestContact? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "suggestContacts": suggestContacts.flatMap { (value: SuggestContact) -> ResultMap in value.resultMap }])
    }

    /// Suggestions for contacts (i.e. people).
    public var suggestContacts: SuggestContact? {
      get {
        return (resultMap["suggestContacts"] as? ResultMap).flatMap { SuggestContact(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "suggestContacts")
      }
    }

    public struct SuggestContact: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["SuggestContacts"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("requestID", type: .scalar(String.self)),
          GraphQLField("contactSuggestions", type: .list(.nonNull(.object(ContactSuggestion.selections)))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(requestId: String? = nil, contactSuggestions: [ContactSuggestion]? = nil) {
        self.init(unsafeResultMap: ["__typename": "SuggestContacts", "requestID": requestId, "contactSuggestions": contactSuggestions.flatMap { (value: [ContactSuggestion]) -> [ResultMap] in value.map { (value: ContactSuggestion) -> ResultMap in value.resultMap } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// requestID for suggest contacts request
      public var requestId: String? {
        get {
          return resultMap["requestID"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "requestID")
        }
      }

      /// List of suggested contacts based on query
      public var contactSuggestions: [ContactSuggestion]? {
        get {
          return (resultMap["contactSuggestions"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [ContactSuggestion] in value.map { (value: ResultMap) -> ContactSuggestion in ContactSuggestion(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [ContactSuggestion]) -> [ResultMap] in value.map { (value: ContactSuggestion) -> ResultMap in value.resultMap } }, forKey: "contactSuggestions")
        }
      }

      public struct ContactSuggestion: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["ContactSuggestion"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("profile", type: .object(Profile.selections)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(profile: Profile? = nil) {
          self.init(unsafeResultMap: ["__typename": "ContactSuggestion", "profile": profile.flatMap { (value: Profile) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var profile: Profile? {
          get {
            return (resultMap["profile"] as? ResultMap).flatMap { Profile(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "profile")
          }
        }

        public struct Profile: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Profile"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("displayName", type: .nonNull(.scalar(String.self))),
              GraphQLField("email", type: .nonNull(.scalar(String.self))),
              GraphQLField("pictureURL", type: .nonNull(.scalar(String.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(displayName: String, email: String, pictureUrl: String) {
            self.init(unsafeResultMap: ["__typename": "Profile", "displayName": displayName, "email": email, "pictureURL": pictureUrl])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var displayName: String {
            get {
              return resultMap["displayName"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "displayName")
            }
          }

          public var email: String {
            get {
              return resultMap["email"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "email")
            }
          }

          public var pictureUrl: String {
            get {
              return resultMap["pictureURL"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "pictureURL")
            }
          }
        }
      }
    }
  }
}

public final class EmailLookupQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query EmailLookup($input: PublicEmailLookupInput!) {
      publicEmailLookup(input: $input) {
        __typename
        authProvider
      }
    }
    """

  public let operationName: String = "EmailLookup"

  public let operationIdentifier: String? = "9cf649cadb09403ec1a58d08a6f0e3a0f432bca6f1525af473df7672b38f6aa2"

  public var input: PublicEmailLookupInput

  public init(input: PublicEmailLookupInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("publicEmailLookup", arguments: ["input": GraphQLVariable("input")], type: .object(PublicEmailLookup.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(publicEmailLookup: PublicEmailLookup? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "publicEmailLookup": publicEmailLookup.flatMap { (value: PublicEmailLookup) -> ResultMap in value.resultMap }])
    }

    public var publicEmailLookup: PublicEmailLookup? {
      get {
        return (resultMap["publicEmailLookup"] as? ResultMap).flatMap { PublicEmailLookup(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "publicEmailLookup")
      }
    }

    public struct PublicEmailLookup: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["PublicEmailLookupResponse"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("authProvider", type: .scalar(String.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(authProvider: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "PublicEmailLookupResponse", "authProvider": authProvider])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var authProvider: String? {
        get {
          return resultMap["authProvider"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "authProvider")
        }
      }
    }
  }
}

public final class SendFeedbackMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation SendFeedback($input: SendFeedbackV2Input!) {
      sendFeedbackV2(input: $input)
    }
    """

  public let operationName: String = "SendFeedback"

  public let operationIdentifier: String? = "dc843ee8dfc6f5fc8ba43bba8cf907e6fcd24fe785b37a9be97a8cde14512eb1"

  public var input: SendFeedbackV2Input

  public init(input: SendFeedbackV2Input) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("sendFeedbackV2", arguments: ["input": GraphQLVariable("input")], type: .scalar(Bool.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(sendFeedbackV2: Bool? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "sendFeedbackV2": sendFeedbackV2])
    }

    /// Save a free form feedback from user (v2)
    public var sendFeedbackV2: Bool? {
      get {
        return resultMap["sendFeedbackV2"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "sendFeedbackV2")
      }
    }
  }
}

public final class StartIncognitoMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation StartIncognito($redirect: String!) {
      startIncognito(input: {redirect: $redirect})
    }
    """

  public let operationName: String = "StartIncognito"

  public let operationIdentifier: String? = "c56f3d8704d94836640f41e28c4cde4140c3ac7c32e9994e0fcc2c12ec4e98dd"

  public var redirect: String

  public init(redirect: String) {
    self.redirect = redirect
  }

  public var variables: GraphQLMap? {
    return ["redirect": redirect]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("startIncognito", arguments: ["input": ["redirect": GraphQLVariable("redirect")]], type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(startIncognito: String) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "startIncognito": startIncognito])
    }

    /// Initialize an incognito access token for this user.
    public var startIncognito: String {
      get {
        return resultMap["startIncognito"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "startIncognito")
      }
    }
  }
}

public final class UpdateUserFlagMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation UpdateUserFlag($input: FlagInput!) {
      updateFlag(input: $input)
    }
    """

  public let operationName: String = "UpdateUserFlag"

  public let operationIdentifier: String? = "1fc376082d3952ef7344f937ab000d85bee8223c086b7c753e51bc194661dd39"

  public var input: FlagInput

  public init(input: FlagInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("updateFlag", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateFlag: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateFlag": updateFlag])
    }

    /// Add or remove a flag for a user
    public var updateFlag: Bool {
      get {
        return resultMap["updateFlag"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "updateFlag")
      }
    }
  }
}

public final class SetProviderPreferenceMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation SetProviderPreference($input: PreferredProviderInput!) {
      setProviderPreference(input: $input)
    }
    """

  public let operationName: String = "SetProviderPreference"

  public let operationIdentifier: String? = "685e0633b7ac8c511f953817f425bc973d653d08e20737f34db31236af7ebc4a"

  public var input: PreferredProviderInput

  public init(input: PreferredProviderInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("setProviderPreference", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(setProviderPreference: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "setProviderPreference": setProviderPreference])
    }

    /// Set a single provider preference.
    public var setProviderPreference: Bool {
      get {
        return resultMap["setProviderPreference"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "setProviderPreference")
      }
    }
  }
}

public final class AddDeviceTokenIosMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation addDeviceTokenIOS($input: DeviceTokenInput!) {
      addDeviceTokenIOS(input: $input) {
        __typename
        success
      }
    }
    """

  public let operationName: String = "addDeviceTokenIOS"

  public let operationIdentifier: String? = "eec975bc778bc9d2c7e481fdb0d940f49acb05f994708f0d43155bb3ad67f556"

  public var input: DeviceTokenInput

  public init(input: DeviceTokenInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("addDeviceTokenIOS", arguments: ["input": GraphQLVariable("input")], type: .object(AddDeviceTokenIo.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(addDeviceTokenIos: AddDeviceTokenIo? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "addDeviceTokenIOS": addDeviceTokenIos.flatMap { (value: AddDeviceTokenIo) -> ResultMap in value.resultMap }])
    }

    public var addDeviceTokenIos: AddDeviceTokenIo? {
      get {
        return (resultMap["addDeviceTokenIOS"] as? ResultMap).flatMap { AddDeviceTokenIo(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "addDeviceTokenIOS")
      }
    }

    public struct AddDeviceTokenIo: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["AddDeviceTokenResponse"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("success", type: .scalar(Bool.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(success: Bool? = nil) {
        self.init(unsafeResultMap: ["__typename": "AddDeviceTokenResponse", "success": success])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var success: Bool? {
        get {
          return resultMap["success"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "success")
        }
      }
    }
  }
}

public final class DeleteDeviceTokenIosMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation deleteDeviceTokenIOS($input: DeleteDeviceTokenInput!) {
      deleteDeviceTokenIOS(input: $input) {
        __typename
        success
      }
    }
    """

  public let operationName: String = "deleteDeviceTokenIOS"

  public let operationIdentifier: String? = "4c2a5f4acbfb7bf0a21310331f2f98d66ad01cf80a2ca7ae067ff01ae370aa91"

  public var input: DeleteDeviceTokenInput

  public init(input: DeleteDeviceTokenInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("deleteDeviceTokenIOS", arguments: ["input": GraphQLVariable("input")], type: .object(DeleteDeviceTokenIo.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(deleteDeviceTokenIos: DeleteDeviceTokenIo? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "deleteDeviceTokenIOS": deleteDeviceTokenIos.flatMap { (value: DeleteDeviceTokenIo) -> ResultMap in value.resultMap }])
    }

    public var deleteDeviceTokenIos: DeleteDeviceTokenIo? {
      get {
        return (resultMap["deleteDeviceTokenIOS"] as? ResultMap).flatMap { DeleteDeviceTokenIo(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "deleteDeviceTokenIOS")
      }
    }

    public struct DeleteDeviceTokenIo: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["DeleteDeviceTokenResponse"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("success", type: .scalar(Bool.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(success: Bool? = nil) {
        self.init(unsafeResultMap: ["__typename": "DeleteDeviceTokenResponse", "success": success])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var success: Bool? {
        get {
          return resultMap["success"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "success")
        }
      }
    }
  }
}

public final class UpdateUserProfileMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation UpdateUserProfile($input: UpdateUserProfileInput!) {
      updateUserProfile(input: $input) {
        __typename
        success
      }
    }
    """

  public let operationName: String = "UpdateUserProfile"

  public let operationIdentifier: String? = "f48db7858c3f67d2faf8c0a8dffc7abb38c37d7ce70b1b4a1129aff134ec8a9b"

  public var input: UpdateUserProfileInput

  public init(input: UpdateUserProfileInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("updateUserProfile", arguments: ["input": GraphQLVariable("input")], type: .object(UpdateUserProfile.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateUserProfile: UpdateUserProfile? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateUserProfile": updateUserProfile.flatMap { (value: UpdateUserProfile) -> ResultMap in value.resultMap }])
    }

    /// Updates the displayed first and last name of the user
    public var updateUserProfile: UpdateUserProfile? {
      get {
        return (resultMap["updateUserProfile"] as? ResultMap).flatMap { UpdateUserProfile(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "updateUserProfile")
      }
    }

    public struct UpdateUserProfile: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["UpdateUserProfileResponse"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("success", type: .scalar(Bool.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(success: Bool? = nil) {
        self.init(unsafeResultMap: ["__typename": "UpdateUserProfileResponse", "success": success])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var success: Bool? {
        get {
          return resultMap["success"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "success")
        }
      }
    }
  }
}

public final class ResendVerificationEmailMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation ResendVerificationEmail {
      resendVerificationEmail {
        __typename
        result
      }
    }
    """

  public let operationName: String = "ResendVerificationEmail"

  public let operationIdentifier: String? = "0211e7a852db584c8fb85dd9c8984941c9dadbfbb9cfddce30cd18b0c7c31fd0"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("resendVerificationEmail", type: .object(ResendVerificationEmail.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(resendVerificationEmail: ResendVerificationEmail? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "resendVerificationEmail": resendVerificationEmail.flatMap { (value: ResendVerificationEmail) -> ResultMap in value.resultMap }])
    }

    /// Resend account verification email
    public var resendVerificationEmail: ResendVerificationEmail? {
      get {
        return (resultMap["resendVerificationEmail"] as? ResultMap).flatMap { ResendVerificationEmail(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "resendVerificationEmail")
      }
    }

    public struct ResendVerificationEmail: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["ResendVerificationEmailResponse"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("result", type: .scalar(ResendVerificationEmailResult.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(result: ResendVerificationEmailResult? = nil) {
        self.init(unsafeResultMap: ["__typename": "ResendVerificationEmailResponse", "result": result])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var result: ResendVerificationEmailResult? {
        get {
          return resultMap["result"] as? ResendVerificationEmailResult
        }
        set {
          resultMap.updateValue(newValue, forKey: "result")
        }
      }
    }
  }
}

public final class ReportDomainTrustSignalMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation ReportDomainTrustSignal($input: ReportDomainTrustSignalInput!) {
      xyzReportDomainTrustSignal(input: $input) {
        __typename
        success
      }
    }
    """

  public let operationName: String = "ReportDomainTrustSignal"

  public let operationIdentifier: String? = "04a134b9efa4f74e9d39587a7fcc88cef1de531c84a46e89a8f4d3e8354bbd5e"

  public var input: ReportDomainTrustSignalInput

  public init(input: ReportDomainTrustSignalInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("xyzReportDomainTrustSignal", arguments: ["input": GraphQLVariable("input")], type: .object(XyzReportDomainTrustSignal.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(xyzReportDomainTrustSignal: XyzReportDomainTrustSignal? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "xyzReportDomainTrustSignal": xyzReportDomainTrustSignal.flatMap { (value: XyzReportDomainTrustSignal) -> ResultMap in value.resultMap }])
    }

    /// Same as reportDomainTrustSignal but for the xyz browser; doesn't require auth'd users
    public var xyzReportDomainTrustSignal: XyzReportDomainTrustSignal? {
      get {
        return (resultMap["xyzReportDomainTrustSignal"] as? ResultMap).flatMap { XyzReportDomainTrustSignal(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "xyzReportDomainTrustSignal")
      }
    }

    public struct XyzReportDomainTrustSignal: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["ReportDomainTrustSignalResponse"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("success", type: .scalar(Bool.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(success: Bool? = nil) {
        self.init(unsafeResultMap: ["__typename": "ReportDomainTrustSignalResponse", "success": success])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var success: Bool? {
        get {
          return resultMap["success"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "success")
        }
      }
    }
  }
}

public final class GetDomainTrustSignalsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query getDomainTrustSignals($input: DomainTrustSignalsInput!) {
      xyzDomainTrustSignals(input: $input) {
        __typename
        domain
        signal
      }
    }
    """

  public let operationName: String = "getDomainTrustSignals"

  public let operationIdentifier: String? = "d624526d21db75a28ed96c70a79cbdffa4c504a58c96e67603359b5b9f6eac56"

  public var input: DomainTrustSignalsInput

  public init(input: DomainTrustSignalsInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("xyzDomainTrustSignals", arguments: ["input": GraphQLVariable("input")], type: .list(.nonNull(.object(XyzDomainTrustSignal.selections)))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(xyzDomainTrustSignals: [XyzDomainTrustSignal]? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "xyzDomainTrustSignals": xyzDomainTrustSignals.flatMap { (value: [XyzDomainTrustSignal]) -> [ResultMap] in value.map { (value: XyzDomainTrustSignal) -> ResultMap in value.resultMap } }])
    }

    /// Same as domainTrustSignals but for the xyz browser; doesn't require auth'd users
    public var xyzDomainTrustSignals: [XyzDomainTrustSignal]? {
      get {
        return (resultMap["xyzDomainTrustSignals"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [XyzDomainTrustSignal] in value.map { (value: ResultMap) -> XyzDomainTrustSignal in XyzDomainTrustSignal(unsafeResultMap: value) } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [XyzDomainTrustSignal]) -> [ResultMap] in value.map { (value: XyzDomainTrustSignal) -> ResultMap in value.resultMap } }, forKey: "xyzDomainTrustSignals")
      }
    }

    public struct XyzDomainTrustSignal: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["DomainTrustSignal"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("domain", type: .scalar(String.self)),
          GraphQLField("signal", type: .scalar(TrustSignal.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(domain: String? = nil, signal: TrustSignal? = nil) {
        self.init(unsafeResultMap: ["__typename": "DomainTrustSignal", "domain": domain, "signal": signal])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var domain: String? {
        get {
          return resultMap["domain"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "domain")
        }
      }

      public var signal: TrustSignal? {
        get {
          return resultMap["signal"] as? TrustSignal
        }
        set {
          resultMap.updateValue(newValue, forKey: "signal")
        }
      }
    }
  }
}

public final class SearchQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Search($query: String!) {
      search(q: $query, source: NeevaScope) {
        __typename
        resultGroup {
          __typename
          result {
            __typename
            subResultsDisplayType
            subResultsSemantics
            subResults {
              __typename
              ... on News {
                __typename
                news {
                  __typename
                  title
                  snippet
                  url
                  thumbnailImage {
                    __typename
                    url
                    width
                    height
                  }
                  providerName
                  datePublished
                  favIconURL
                  preference
                  domain
                  provider {
                    __typename
                    name
                    site
                  }
                }
              }
            }
            title
            appIcon {
              __typename
              labels
            }
            actionURL
            snippet
            typeSpecific {
              __typename
              ... on Place {
                __typename
                place {
                  __typename
                  id
                  placeSubType
                  name
                  address {
                    __typename
                    streetAddress
                    fullAddress
                  }
                  position {
                    __typename
                    lat
                    lon
                  }
                  telephone
                  telephonePretty
                  websiteURL
                  yelpURL
                  mapsURL
                  googleMapsURL
                  price
                  rating
                  reviewCount
                  reviews {
                    __typename
                    id
                  }
                  articulatedOperatingStatus
                  articulatedHour
                  specialHours {
                    __typename
                    isOvernight
                    start
                    end
                    date
                    isClosed
                  }
                  hours {
                    __typename
                    open {
                      __typename
                      isOvernight
                      start
                      end
                      day
                    }
                  }
                  isClosed
                  isOpenNow
                  categories
                  imageURL
                  mapImage {
                    __typename
                    url
                    darkUrl
                    height
                    width
                  }
                }
              }
              ... on PlaceList {
                __typename
                placeList {
                  __typename
                  places {
                    __typename
                    place {
                      __typename
                      id
                      type
                      name
                      address {
                        __typename
                        streetAddress
                        fullAddress
                      }
                      telephone
                      telephonePretty
                      websiteURL
                      yelpURL
                      bingWebSearchURL
                      position {
                        __typename
                        lat
                        lon
                      }
                      placeSubType
                      isAddress
                      rating
                      price
                      reviews {
                        __typename
                        id
                        text
                        rating
                        timeCreated
                        url
                      }
                      specialHours {
                        __typename
                        isOvernight
                        start
                        end
                        date
                        isClosed
                      }
                      hours {
                        __typename
                        open {
                          __typename
                          isOvernight
                          start
                          end
                          day
                        }
                      }
                      reviewCount
                      imageURL
                      imageURLs
                      isClosed
                      isOpenNow
                      categories
                      mapImage {
                        __typename
                        url
                        darkUrl
                        width
                        height
                      }
                      mapImageLarge {
                        __typename
                        url
                        darkUrl
                        width
                        height
                      }
                      googleMapsURL
                      subTitle
                      useHighVisuals
                      articulatedOperatingStatus
                      articulatedHour
                      mapsURL
                      neevaMapsQuery {
                        __typename
                        query
                        latitude
                        longitude
                        radius
                        isLocationShift
                        placeID
                        zoom
                      }
                      placeSuggestions {
                        __typename
                        address {
                          __typename
                          country
                          locality
                          region
                          neighborhood
                          postalCode
                          streetName
                          streetNumber
                          streetAddress
                          fullAddress
                        }
                        mapImage {
                          __typename
                          url
                          darkUrl
                          width
                          height
                        }
                        mapImageLarge {
                          __typename
                          url
                          darkUrl
                          width
                          height
                        }
                        googleMapsURL
                      }
                    }
                  }
                }
              }
              ... on Web {
                __typename
                web {
                  __typename
                  favIconURL
                  displayUrl
                  publicationDate
                  structuredUrl {
                    __typename
                    paths
                    hostname
                  }
                  highlightedSnippet {
                    __typename
                    segments {
                      __typename
                      text
                      isHighlighted
                    }
                  }
                  buyingGuideProducts {
                    __typename
                    reviewTitle
                    reviewType
                    productName
                    reviewHighlights
                    reviewSummary
                    reviewURL
                    priceLow
                    thumbnailURL
                  }
                  inlineSearchProducts {
                    __typename
                    productName
                    priceLow
                    thumbnailURL
                    actionURL
                  }
                }
              }
              ... on ProductClusters {
                __typename
                productClusters {
                  __typename
                  filterLabels {
                    __typename
                    min
                    max
                    label
                  }
                  products {
                    __typename
                    productName
                    thumbnailURL
                    buyingGuideReviews {
                      __typename
                      source
                      reviewURL
                      price
                      header {
                        __typename
                        title
                        summary
                      }
                      proCon {
                        __typename
                        pros
                        cons
                      }
                    }
                    sellers {
                      __typename
                      url
                      price
                      displayName
                      providerCode
                    }
                    priceLow
                    priceHigh
                    priceLabel
                    rating
                    maxRating
                    ratingProvider
                    retailerReviews {
                      __typename
                      allReviewsURL
                      provider {
                        __typename
                        displayName
                        providerCode
                      }
                      reviews {
                        __typename
                        author
                        title
                        body
                        highlights {
                          __typename
                          begin
                          end
                        }
                        rating {
                          __typename
                          maxStars
                          productStars
                        }
                      }
                      criticalReviews {
                        __typename
                        author
                        title
                        body
                        highlights {
                          __typename
                          begin
                          end
                        }
                        rating {
                          __typename
                          maxStars
                          productStars
                        }
                      }
                      ratingSummary {
                        __typename
                        rating {
                          __typename
                          maxStars
                          productStars
                        }
                        numReviews
                        price
                      }
                    }
                  }
                }
              }
              ... on RecipeBlock {
                __typename
                recipeBlock {
                  __typename
                  recipes {
                    __typename
                    title
                    url
                    imageURL
                    preference
                    totalTime
                    prepTime
                    yield
                    ingredients {
                      __typename
                      text
                    }
                    instructions {
                      __typename
                      text
                    }
                    recipeRating {
                      __typename
                      maxStars
                      recipeStars
                      numReviews
                    }
                    reviews {
                      __typename
                      reviewerName
                      body
                      rating {
                        __typename
                        maxStars
                        actualStars
                      }
                    }
                  }
                }
              }
              ... on RelatedSearches {
                __typename
                relatedSearches {
                  __typename
                  entries {
                    __typename
                    searchText
                    displayText {
                      __typename
                      segments {
                        __typename
                        isHighlighted
                        text
                      }
                    }
                  }
                }
              }
              ... on TechDoc {
                __typename
                techDoc {
                  __typename
                  name
                  actionURL
                  isCollapsed
                  languageID
                  useFixedWidth
                  poweredBy
                  domain
                  favIconURL
                  visualSpec
                  snippet {
                    __typename
                    name
                    body
                    url
                  }
                  sections {
                    __typename
                    name
                    rhsTitle
                    body
                    url
                    votes
                    subsections {
                      __typename
                      name
                      body
                      url
                      metadata {
                        __typename
                        text
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    """

  public let operationName: String = "Search"

  public let operationIdentifier: String? = "6ebbd1cee60e8e0567665900a9fdd73d920e4c3ad23c8e932813afbbf267df18"

  public var query: String

  public init(query: String) {
    self.query = query
  }

  public var variables: GraphQLMap? {
    return ["query": query]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("search", arguments: ["q": GraphQLVariable("query"), "source": "NeevaScope"], type: .object(Search.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(search: Search? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "search": search.flatMap { (value: Search) -> ResultMap in value.resultMap }])
    }

    /// The main search query. Note that latitude and longitude are deprecated parameters as of 2020/03/05 but kept for iOS app compatibility.
    public var search: Search? {
      get {
        return (resultMap["search"] as? ResultMap).flatMap { Search(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "search")
      }
    }

    public struct Search: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Search"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("resultGroup", type: .list(.object(ResultGroup.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(resultGroup: [ResultGroup?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Search", "resultGroup": resultGroup.flatMap { (value: [ResultGroup?]) -> [ResultMap?] in value.map { (value: ResultGroup?) -> ResultMap? in value.flatMap { (value: ResultGroup) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Results are grouped into 0 or more result groups according to criteria
      /// decided by the backend.
      public var resultGroup: [ResultGroup?]? {
        get {
          return (resultMap["resultGroup"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [ResultGroup?] in value.map { (value: ResultMap?) -> ResultGroup? in value.flatMap { (value: ResultMap) -> ResultGroup in ResultGroup(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [ResultGroup?]) -> [ResultMap?] in value.map { (value: ResultGroup?) -> ResultMap? in value.flatMap { (value: ResultGroup) -> ResultMap in value.resultMap } } }, forKey: "resultGroup")
        }
      }

      public struct ResultGroup: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["ResultGroup"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("result", type: .list(.object(Result.selections))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(result: [Result?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "ResultGroup", "result": result.flatMap { (value: [Result?]) -> [ResultMap?] in value.map { (value: Result?) -> ResultMap? in value.flatMap { (value: Result) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// An ordered list of all the results.
        public var result: [Result?]? {
          get {
            return (resultMap["result"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Result?] in value.map { (value: ResultMap?) -> Result? in value.flatMap { (value: ResultMap) -> Result in Result(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Result?]) -> [ResultMap?] in value.map { (value: Result?) -> ResultMap? in value.flatMap { (value: Result) -> ResultMap in value.resultMap } } }, forKey: "result")
          }
        }

        public struct Result: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Result"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("subResultsDisplayType", type: .nonNull(.scalar(SubResultsDisplayType.self))),
              GraphQLField("subResultsSemantics", type: .nonNull(.scalar(SubResultsSemantics.self))),
              GraphQLField("subResults", type: .list(.nonNull(.object(SubResult.selections)))),
              GraphQLField("title", type: .scalar(String.self)),
              GraphQLField("appIcon", type: .nonNull(.object(AppIcon.selections))),
              GraphQLField("actionURL", type: .nonNull(.scalar(String.self))),
              GraphQLField("snippet", type: .scalar(String.self)),
              GraphQLField("typeSpecific", type: .object(TypeSpecific.selections)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(subResultsDisplayType: SubResultsDisplayType, subResultsSemantics: SubResultsSemantics, subResults: [SubResult]? = nil, title: String? = nil, appIcon: AppIcon, actionUrl: String, snippet: String? = nil, typeSpecific: TypeSpecific? = nil) {
            self.init(unsafeResultMap: ["__typename": "Result", "subResultsDisplayType": subResultsDisplayType, "subResultsSemantics": subResultsSemantics, "subResults": subResults.flatMap { (value: [SubResult]) -> [ResultMap] in value.map { (value: SubResult) -> ResultMap in value.resultMap } }, "title": title, "appIcon": appIcon.resultMap, "actionURL": actionUrl, "snippet": snippet, "typeSpecific": typeSpecific.flatMap { (value: TypeSpecific) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Client hint for how to visually arrange sub-results
          public var subResultsDisplayType: SubResultsDisplayType {
            get {
              return resultMap["subResultsDisplayType"]! as! SubResultsDisplayType
            }
            set {
              resultMap.updateValue(newValue, forKey: "subResultsDisplayType")
            }
          }

          /// Client hint for semantic meaning of sub-results
          public var subResultsSemantics: SubResultsSemantics {
            get {
              return resultMap["subResultsSemantics"]! as! SubResultsSemantics
            }
            set {
              resultMap.updateValue(newValue, forKey: "subResultsSemantics")
            }
          }

          /// This is an array of sub-results. they can be any type. the UI
          /// renders them as it sees fit, optionally taking a hint from renderAs
          public var subResults: [SubResult]? {
            get {
              return (resultMap["subResults"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [SubResult] in value.map { (value: ResultMap) -> SubResult in SubResult(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [SubResult]) -> [ResultMap] in value.map { (value: SubResult) -> ResultMap in value.resultMap } }, forKey: "subResults")
            }
          }

          /// Result title. Used if no type-specific data is used for the title.
          public var title: String? {
            get {
              return resultMap["title"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "title")
            }
          }

          /// Icon of the application to show with the result.
          public var appIcon: AppIcon {
            get {
              return AppIcon(unsafeResultMap: resultMap["appIcon"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "appIcon")
            }
          }

          /// The primary url to navigate to when the user clicks on a result.
          public var actionUrl: String {
            get {
              return resultMap["actionURL"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "actionURL")
            }
          }

          /// Snippet string. HTML format.
          public var snippet: String? {
            get {
              return resultMap["snippet"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "snippet")
            }
          }

          /// Information specific to the result type. For example, this may be the
          /// 'to' and 'from' fields for an email, or 'mime type' for a file.
          public var typeSpecific: TypeSpecific? {
            get {
              return (resultMap["typeSpecific"] as? ResultMap).flatMap { TypeSpecific(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "typeSpecific")
            }
          }

          public struct SubResult: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["AgendaView", "BillsView", "Computation", "Contact", "Currency", "Dictionary", "Doc", "DocView", "Email", "EmailActivity", "Entity", "Event", "EventView", "ExternalSearchProvider", "Flight", "FeedDocsView", "FeedGHView", "Image", "IpAddress", "Issue", "Journey", "KnowledgeGraphAnswer", "Lyrics", "Message", "MovieList", "MovieShowtimes", "NeevaDefinition", "News", "NewsItem", "NewsletterView", "NoAdsBanner", "PackageTracking", "PersonView", "Place", "PlaceList", "PreviewModeCTA", "PriceFollow", "ProductCategoryOverview", "ProductQNA", "ProductReviews", "ProductClusters", "ProductBrowse", "ProgrammingDoc", "Promo", "ReceiptView", "RecipeResult", "RecipeBlock", "FeaturedRecipeBlock", "FeaturedVideoRecipeBlock", "Redirect", "RelatedSearches", "RelatedQnA", "RichEntity", "PPRanking", "ShippingView", "Social", "SpaceView", "SpaceBlock", "SportsCard", "Stock", "TechDoc", "TechQNA", "TimeCalculation", "Timezone", "TimezoneDifference", "Token", "Translation", "TravelView", "Tweet", "Vanity", "Video", "WalletTS", "Weather", "Web"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLTypeCase(
                  variants: ["News": AsNews.selections],
                  default: [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  ]
                )
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public static func makeAgendaView() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "AgendaView"])
            }

            public static func makeBillsView() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "BillsView"])
            }

            public static func makeComputation() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Computation"])
            }

            public static func makeContact() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Contact"])
            }

            public static func makeCurrency() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Currency"])
            }

            public static func makeDictionary() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Dictionary"])
            }

            public static func makeDoc() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Doc"])
            }

            public static func makeDocView() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "DocView"])
            }

            public static func makeEmail() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Email"])
            }

            public static func makeEmailActivity() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "EmailActivity"])
            }

            public static func makeEntity() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Entity"])
            }

            public static func makeEvent() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Event"])
            }

            public static func makeEventView() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "EventView"])
            }

            public static func makeExternalSearchProvider() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "ExternalSearchProvider"])
            }

            public static func makeFlight() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Flight"])
            }

            public static func makeFeedDocsView() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "FeedDocsView"])
            }

            public static func makeFeedGHView() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "FeedGHView"])
            }

            public static func makeImage() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Image"])
            }

            public static func makeIpAddress() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "IpAddress"])
            }

            public static func makeIssue() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Issue"])
            }

            public static func makeJourney() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Journey"])
            }

            public static func makeKnowledgeGraphAnswer() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "KnowledgeGraphAnswer"])
            }

            public static func makeLyrics() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Lyrics"])
            }

            public static func makeMessage() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Message"])
            }

            public static func makeMovieList() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "MovieList"])
            }

            public static func makeMovieShowtimes() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "MovieShowtimes"])
            }

            public static func makeNeevaDefinition() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "NeevaDefinition"])
            }

            public static func makeNewsItem() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "NewsItem"])
            }

            public static func makeNewsletterView() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "NewsletterView"])
            }

            public static func makeNoAdsBanner() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "NoAdsBanner"])
            }

            public static func makePackageTracking() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "PackageTracking"])
            }

            public static func makePersonView() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "PersonView"])
            }

            public static func makePlace() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Place"])
            }

            public static func makePlaceList() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "PlaceList"])
            }

            public static func makePreviewModeCTA() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "PreviewModeCTA"])
            }

            public static func makePriceFollow() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "PriceFollow"])
            }

            public static func makeProductCategoryOverview() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "ProductCategoryOverview"])
            }

            public static func makeProductQNA() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "ProductQNA"])
            }

            public static func makeProductReviews() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "ProductReviews"])
            }

            public static func makeProductClusters() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "ProductClusters"])
            }

            public static func makeProductBrowse() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "ProductBrowse"])
            }

            public static func makeProgrammingDoc() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "ProgrammingDoc"])
            }

            public static func makePromo() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Promo"])
            }

            public static func makeReceiptView() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "ReceiptView"])
            }

            public static func makeRecipeResult() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "RecipeResult"])
            }

            public static func makeRecipeBlock() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "RecipeBlock"])
            }

            public static func makeFeaturedRecipeBlock() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "FeaturedRecipeBlock"])
            }

            public static func makeFeaturedVideoRecipeBlock() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "FeaturedVideoRecipeBlock"])
            }

            public static func makeRedirect() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Redirect"])
            }

            public static func makeRelatedSearches() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "RelatedSearches"])
            }

            public static func makeRelatedQnA() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "RelatedQnA"])
            }

            public static func makeRichEntity() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "RichEntity"])
            }

            public static func makePPRanking() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "PPRanking"])
            }

            public static func makeShippingView() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "ShippingView"])
            }

            public static func makeSocial() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Social"])
            }

            public static func makeSpaceView() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "SpaceView"])
            }

            public static func makeSpaceBlock() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "SpaceBlock"])
            }

            public static func makeSportsCard() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "SportsCard"])
            }

            public static func makeStock() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Stock"])
            }

            public static func makeTechDoc() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "TechDoc"])
            }

            public static func makeTechQNA() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "TechQNA"])
            }

            public static func makeTimeCalculation() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "TimeCalculation"])
            }

            public static func makeTimezone() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Timezone"])
            }

            public static func makeTimezoneDifference() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "TimezoneDifference"])
            }

            public static func makeToken() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Token"])
            }

            public static func makeTranslation() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Translation"])
            }

            public static func makeTravelView() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "TravelView"])
            }

            public static func makeTweet() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Tweet"])
            }

            public static func makeVanity() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Vanity"])
            }

            public static func makeVideo() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Video"])
            }

            public static func makeWalletTS() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "WalletTS"])
            }

            public static func makeWeather() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Weather"])
            }

            public static func makeWeb() -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "Web"])
            }

            public static func makeNews(news: AsNews.News? = nil) -> SubResult {
              return SubResult(unsafeResultMap: ["__typename": "News", "news": news.flatMap { (value: AsNews.News) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var asNews: AsNews? {
              get {
                if !AsNews.possibleTypes.contains(__typename) { return nil }
                return AsNews(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsNews: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["News"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("news", type: .object(News.selections)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(news: News? = nil) {
                self.init(unsafeResultMap: ["__typename": "News", "news": news.flatMap { (value: News) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var news: News? {
                get {
                  return (resultMap["news"] as? ResultMap).flatMap { News(unsafeResultMap: $0) }
                }
                set {
                  resultMap.updateValue(newValue?.resultMap, forKey: "news")
                }
              }

              public struct News: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["NewsData"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("title", type: .nonNull(.scalar(String.self))),
                    GraphQLField("snippet", type: .nonNull(.scalar(String.self))),
                    GraphQLField("url", type: .nonNull(.scalar(String.self))),
                    GraphQLField("thumbnailImage", type: .nonNull(.object(ThumbnailImage.selections))),
                    GraphQLField("providerName", type: .nonNull(.scalar(String.self))),
                    GraphQLField("datePublished", type: .nonNull(.scalar(String.self))),
                    GraphQLField("favIconURL", type: .scalar(String.self)),
                    GraphQLField("preference", type: .scalar(UserPreference.self)),
                    GraphQLField("domain", type: .scalar(String.self)),
                    GraphQLField("provider", type: .object(Provider.selections)),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(title: String, snippet: String, url: String, thumbnailImage: ThumbnailImage, providerName: String, datePublished: String, favIconUrl: String? = nil, preference: UserPreference? = nil, domain: String? = nil, provider: Provider? = nil) {
                  self.init(unsafeResultMap: ["__typename": "NewsData", "title": title, "snippet": snippet, "url": url, "thumbnailImage": thumbnailImage.resultMap, "providerName": providerName, "datePublished": datePublished, "favIconURL": favIconUrl, "preference": preference, "domain": domain, "provider": provider.flatMap { (value: Provider) -> ResultMap in value.resultMap }])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var title: String {
                  get {
                    return resultMap["title"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "title")
                  }
                }

                public var snippet: String {
                  get {
                    return resultMap["snippet"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "snippet")
                  }
                }

                public var url: String {
                  get {
                    return resultMap["url"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "url")
                  }
                }

                public var thumbnailImage: ThumbnailImage {
                  get {
                    return ThumbnailImage(unsafeResultMap: resultMap["thumbnailImage"]! as! ResultMap)
                  }
                  set {
                    resultMap.updateValue(newValue.resultMap, forKey: "thumbnailImage")
                  }
                }

                public var providerName: String {
                  get {
                    return resultMap["providerName"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "providerName")
                  }
                }

                public var datePublished: String {
                  get {
                    return resultMap["datePublished"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "datePublished")
                  }
                }

                public var favIconUrl: String? {
                  get {
                    return resultMap["favIconURL"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "favIconURL")
                  }
                }

                public var preference: UserPreference? {
                  get {
                    return resultMap["preference"] as? UserPreference
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "preference")
                  }
                }

                public var domain: String? {
                  get {
                    return resultMap["domain"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "domain")
                  }
                }

                public var provider: Provider? {
                  get {
                    return (resultMap["provider"] as? ResultMap).flatMap { Provider(unsafeResultMap: $0) }
                  }
                  set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "provider")
                  }
                }

                public struct ThumbnailImage: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["ThumbnailImage"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("url", type: .nonNull(.scalar(String.self))),
                      GraphQLField("width", type: .nonNull(.scalar(Int.self))),
                      GraphQLField("height", type: .nonNull(.scalar(Int.self))),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(url: String, width: Int, height: Int) {
                    self.init(unsafeResultMap: ["__typename": "ThumbnailImage", "url": url, "width": width, "height": height])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var url: String {
                    get {
                      return resultMap["url"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "url")
                    }
                  }

                  public var width: Int {
                    get {
                      return resultMap["width"]! as! Int
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "width")
                    }
                  }

                  public var height: Int {
                    get {
                      return resultMap["height"]! as! Int
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "height")
                    }
                  }
                }

                public struct Provider: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["Provider"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("name", type: .scalar(String.self)),
                      GraphQLField("site", type: .scalar(String.self)),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(name: String? = nil, site: String? = nil) {
                    self.init(unsafeResultMap: ["__typename": "Provider", "name": name, "site": site])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var name: String? {
                    get {
                      return resultMap["name"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "name")
                    }
                  }

                  public var site: String? {
                    get {
                      return resultMap["site"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "site")
                    }
                  }
                }
              }
            }
          }

          public struct AppIcon: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Icon"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("labels", type: .list(.nonNull(.scalar(String.self)))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(labels: [String]? = nil) {
              self.init(unsafeResultMap: ["__typename": "Icon", "labels": labels])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// A list of labels to use. The labels are looked up in order, and the
            /// client will use the first found label. If no icons are found matching the
            /// given labels, then it's up to the client to determine whether to
            /// use a default icon or no icon.
            public var labels: [String]? {
              get {
                return resultMap["labels"] as? [String]
              }
              set {
                resultMap.updateValue(newValue, forKey: "labels")
              }
            }
          }

          public struct TypeSpecific: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["AgendaView", "BillsView", "Computation", "Contact", "Currency", "Dictionary", "Doc", "DocView", "Email", "EmailActivity", "Entity", "Event", "EventView", "ExternalSearchProvider", "Flight", "FeedDocsView", "FeedGHView", "Image", "IpAddress", "Issue", "Journey", "KnowledgeGraphAnswer", "Lyrics", "Message", "MovieList", "MovieShowtimes", "NeevaDefinition", "News", "NewsItem", "NewsletterView", "NoAdsBanner", "PackageTracking", "PersonView", "Place", "PlaceList", "PreviewModeCTA", "PriceFollow", "ProductCategoryOverview", "ProductQNA", "ProductReviews", "ProductClusters", "ProductBrowse", "ProgrammingDoc", "Promo", "ReceiptView", "RecipeResult", "RecipeBlock", "FeaturedRecipeBlock", "FeaturedVideoRecipeBlock", "Redirect", "RelatedSearches", "RelatedQnA", "RichEntity", "PPRanking", "ShippingView", "Social", "SpaceView", "SpaceBlock", "SportsCard", "Stock", "TechDoc", "TechQNA", "TimeCalculation", "Timezone", "TimezoneDifference", "Token", "Translation", "TravelView", "Tweet", "Vanity", "Video", "WalletTS", "Weather", "Web"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLTypeCase(
                  variants: ["Place": AsPlace.selections, "PlaceList": AsPlaceList.selections, "Web": AsWeb.selections, "ProductClusters": AsProductClusters.selections, "RecipeBlock": AsRecipeBlock.selections, "RelatedSearches": AsRelatedSearches.selections, "TechDoc": AsTechDoc.selections],
                  default: [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  ]
                )
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public static func makeAgendaView() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "AgendaView"])
            }

            public static func makeBillsView() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "BillsView"])
            }

            public static func makeComputation() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Computation"])
            }

            public static func makeContact() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Contact"])
            }

            public static func makeCurrency() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Currency"])
            }

            public static func makeDictionary() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Dictionary"])
            }

            public static func makeDoc() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Doc"])
            }

            public static func makeDocView() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "DocView"])
            }

            public static func makeEmail() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Email"])
            }

            public static func makeEmailActivity() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "EmailActivity"])
            }

            public static func makeEntity() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Entity"])
            }

            public static func makeEvent() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Event"])
            }

            public static func makeEventView() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "EventView"])
            }

            public static func makeExternalSearchProvider() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "ExternalSearchProvider"])
            }

            public static func makeFlight() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Flight"])
            }

            public static func makeFeedDocsView() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "FeedDocsView"])
            }

            public static func makeFeedGHView() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "FeedGHView"])
            }

            public static func makeImage() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Image"])
            }

            public static func makeIpAddress() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "IpAddress"])
            }

            public static func makeIssue() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Issue"])
            }

            public static func makeJourney() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Journey"])
            }

            public static func makeKnowledgeGraphAnswer() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "KnowledgeGraphAnswer"])
            }

            public static func makeLyrics() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Lyrics"])
            }

            public static func makeMessage() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Message"])
            }

            public static func makeMovieList() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "MovieList"])
            }

            public static func makeMovieShowtimes() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "MovieShowtimes"])
            }

            public static func makeNeevaDefinition() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "NeevaDefinition"])
            }

            public static func makeNews() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "News"])
            }

            public static func makeNewsItem() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "NewsItem"])
            }

            public static func makeNewsletterView() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "NewsletterView"])
            }

            public static func makeNoAdsBanner() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "NoAdsBanner"])
            }

            public static func makePackageTracking() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "PackageTracking"])
            }

            public static func makePersonView() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "PersonView"])
            }

            public static func makePreviewModeCTA() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "PreviewModeCTA"])
            }

            public static func makePriceFollow() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "PriceFollow"])
            }

            public static func makeProductCategoryOverview() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "ProductCategoryOverview"])
            }

            public static func makeProductQNA() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "ProductQNA"])
            }

            public static func makeProductReviews() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "ProductReviews"])
            }

            public static func makeProductBrowse() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "ProductBrowse"])
            }

            public static func makeProgrammingDoc() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "ProgrammingDoc"])
            }

            public static func makePromo() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Promo"])
            }

            public static func makeReceiptView() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "ReceiptView"])
            }

            public static func makeRecipeResult() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "RecipeResult"])
            }

            public static func makeFeaturedRecipeBlock() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "FeaturedRecipeBlock"])
            }

            public static func makeFeaturedVideoRecipeBlock() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "FeaturedVideoRecipeBlock"])
            }

            public static func makeRedirect() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Redirect"])
            }

            public static func makeRelatedQnA() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "RelatedQnA"])
            }

            public static func makeRichEntity() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "RichEntity"])
            }

            public static func makePPRanking() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "PPRanking"])
            }

            public static func makeShippingView() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "ShippingView"])
            }

            public static func makeSocial() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Social"])
            }

            public static func makeSpaceView() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "SpaceView"])
            }

            public static func makeSpaceBlock() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "SpaceBlock"])
            }

            public static func makeSportsCard() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "SportsCard"])
            }

            public static func makeStock() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Stock"])
            }

            public static func makeTechQNA() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "TechQNA"])
            }

            public static func makeTimeCalculation() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "TimeCalculation"])
            }

            public static func makeTimezone() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Timezone"])
            }

            public static func makeTimezoneDifference() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "TimezoneDifference"])
            }

            public static func makeToken() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Token"])
            }

            public static func makeTranslation() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Translation"])
            }

            public static func makeTravelView() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "TravelView"])
            }

            public static func makeTweet() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Tweet"])
            }

            public static func makeVanity() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Vanity"])
            }

            public static func makeVideo() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Video"])
            }

            public static func makeWalletTS() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "WalletTS"])
            }

            public static func makeWeather() -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Weather"])
            }

            public static func makePlace(place: AsPlace.Place) -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Place", "place": place.resultMap])
            }

            public static func makePlaceList(placeList: AsPlaceList.PlaceList? = nil) -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "PlaceList", "placeList": placeList.flatMap { (value: AsPlaceList.PlaceList) -> ResultMap in value.resultMap }])
            }

            public static func makeWeb(web: AsWeb.Web? = nil) -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "Web", "web": web.flatMap { (value: AsWeb.Web) -> ResultMap in value.resultMap }])
            }

            public static func makeProductClusters(productClusters: AsProductClusters.ProductCluster? = nil) -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "ProductClusters", "productClusters": productClusters.flatMap { (value: AsProductClusters.ProductCluster) -> ResultMap in value.resultMap }])
            }

            public static func makeRecipeBlock(recipeBlock: AsRecipeBlock.RecipeBlock? = nil) -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "RecipeBlock", "recipeBlock": recipeBlock.flatMap { (value: AsRecipeBlock.RecipeBlock) -> ResultMap in value.resultMap }])
            }

            public static func makeRelatedSearches(relatedSearches: AsRelatedSearches.RelatedSearch? = nil) -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "RelatedSearches", "relatedSearches": relatedSearches.flatMap { (value: AsRelatedSearches.RelatedSearch) -> ResultMap in value.resultMap }])
            }

            public static func makeTechDoc(techDoc: AsTechDoc.TechDoc? = nil) -> TypeSpecific {
              return TypeSpecific(unsafeResultMap: ["__typename": "TechDoc", "techDoc": techDoc.flatMap { (value: AsTechDoc.TechDoc) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var asPlace: AsPlace? {
              get {
                if !AsPlace.possibleTypes.contains(__typename) { return nil }
                return AsPlace(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsPlace: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["Place"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("place", type: .nonNull(.object(Place.selections))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(place: Place) {
                self.init(unsafeResultMap: ["__typename": "Place", "place": place.resultMap])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var place: Place {
                get {
                  return Place(unsafeResultMap: resultMap["place"]! as! ResultMap)
                }
                set {
                  resultMap.updateValue(newValue.resultMap, forKey: "place")
                }
              }

              public struct Place: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["PlaceData"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("id", type: .scalar(String.self)),
                    GraphQLField("placeSubType", type: .scalar(PlaceSubType.self)),
                    GraphQLField("name", type: .nonNull(.scalar(String.self))),
                    GraphQLField("address", type: .nonNull(.object(Address.selections))),
                    GraphQLField("position", type: .nonNull(.object(Position.selections))),
                    GraphQLField("telephone", type: .nonNull(.scalar(String.self))),
                    GraphQLField("telephonePretty", type: .nonNull(.scalar(String.self))),
                    GraphQLField("websiteURL", type: .nonNull(.scalar(String.self))),
                    GraphQLField("yelpURL", type: .nonNull(.scalar(String.self))),
                    GraphQLField("mapsURL", type: .scalar(String.self)),
                    GraphQLField("googleMapsURL", type: .scalar(String.self)),
                    GraphQLField("price", type: .nonNull(.scalar(String.self))),
                    GraphQLField("rating", type: .nonNull(.scalar(Double.self))),
                    GraphQLField("reviewCount", type: .nonNull(.scalar(Int.self))),
                    GraphQLField("reviews", type: .list(.nonNull(.object(Review.selections)))),
                    GraphQLField("articulatedOperatingStatus", type: .scalar(String.self)),
                    GraphQLField("articulatedHour", type: .scalar(String.self)),
                    GraphQLField("specialHours", type: .list(.nonNull(.object(SpecialHour.selections)))),
                    GraphQLField("hours", type: .object(Hour.selections)),
                    GraphQLField("isClosed", type: .nonNull(.scalar(Bool.self))),
                    GraphQLField("isOpenNow", type: .scalar(Bool.self)),
                    GraphQLField("categories", type: .nonNull(.list(.nonNull(.scalar(String.self))))),
                    GraphQLField("imageURL", type: .nonNull(.scalar(String.self))),
                    GraphQLField("mapImage", type: .object(MapImage.selections)),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(id: String? = nil, placeSubType: PlaceSubType? = nil, name: String, address: Address, position: Position, telephone: String, telephonePretty: String, websiteUrl: String, yelpUrl: String, mapsUrl: String? = nil, googleMapsUrl: String? = nil, price: String, rating: Double, reviewCount: Int, reviews: [Review]? = nil, articulatedOperatingStatus: String? = nil, articulatedHour: String? = nil, specialHours: [SpecialHour]? = nil, hours: Hour? = nil, isClosed: Bool, isOpenNow: Bool? = nil, categories: [String], imageUrl: String, mapImage: MapImage? = nil) {
                  self.init(unsafeResultMap: ["__typename": "PlaceData", "id": id, "placeSubType": placeSubType, "name": name, "address": address.resultMap, "position": position.resultMap, "telephone": telephone, "telephonePretty": telephonePretty, "websiteURL": websiteUrl, "yelpURL": yelpUrl, "mapsURL": mapsUrl, "googleMapsURL": googleMapsUrl, "price": price, "rating": rating, "reviewCount": reviewCount, "reviews": reviews.flatMap { (value: [Review]) -> [ResultMap] in value.map { (value: Review) -> ResultMap in value.resultMap } }, "articulatedOperatingStatus": articulatedOperatingStatus, "articulatedHour": articulatedHour, "specialHours": specialHours.flatMap { (value: [SpecialHour]) -> [ResultMap] in value.map { (value: SpecialHour) -> ResultMap in value.resultMap } }, "hours": hours.flatMap { (value: Hour) -> ResultMap in value.resultMap }, "isClosed": isClosed, "isOpenNow": isOpenNow, "categories": categories, "imageURL": imageUrl, "mapImage": mapImage.flatMap { (value: MapImage) -> ResultMap in value.resultMap }])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var id: String? {
                  get {
                    return resultMap["id"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "id")
                  }
                }

                public var placeSubType: PlaceSubType? {
                  get {
                    return resultMap["placeSubType"] as? PlaceSubType
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "placeSubType")
                  }
                }

                public var name: String {
                  get {
                    return resultMap["name"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "name")
                  }
                }

                public var address: Address {
                  get {
                    return Address(unsafeResultMap: resultMap["address"]! as! ResultMap)
                  }
                  set {
                    resultMap.updateValue(newValue.resultMap, forKey: "address")
                  }
                }

                public var position: Position {
                  get {
                    return Position(unsafeResultMap: resultMap["position"]! as! ResultMap)
                  }
                  set {
                    resultMap.updateValue(newValue.resultMap, forKey: "position")
                  }
                }

                public var telephone: String {
                  get {
                    return resultMap["telephone"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "telephone")
                  }
                }

                public var telephonePretty: String {
                  get {
                    return resultMap["telephonePretty"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "telephonePretty")
                  }
                }

                public var websiteUrl: String {
                  get {
                    return resultMap["websiteURL"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "websiteURL")
                  }
                }

                public var yelpUrl: String {
                  get {
                    return resultMap["yelpURL"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "yelpURL")
                  }
                }

                @available(*, deprecated, message: "No longer supported")
                public var mapsUrl: String? {
                  get {
                    return resultMap["mapsURL"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "mapsURL")
                  }
                }

                public var googleMapsUrl: String? {
                  get {
                    return resultMap["googleMapsURL"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "googleMapsURL")
                  }
                }

                public var price: String {
                  get {
                    return resultMap["price"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "price")
                  }
                }

                public var rating: Double {
                  get {
                    return resultMap["rating"]! as! Double
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "rating")
                  }
                }

                public var reviewCount: Int {
                  get {
                    return resultMap["reviewCount"]! as! Int
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "reviewCount")
                  }
                }

                public var reviews: [Review]? {
                  get {
                    return (resultMap["reviews"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Review] in value.map { (value: ResultMap) -> Review in Review(unsafeResultMap: value) } }
                  }
                  set {
                    resultMap.updateValue(newValue.flatMap { (value: [Review]) -> [ResultMap] in value.map { (value: Review) -> ResultMap in value.resultMap } }, forKey: "reviews")
                  }
                }

                public var articulatedOperatingStatus: String? {
                  get {
                    return resultMap["articulatedOperatingStatus"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "articulatedOperatingStatus")
                  }
                }

                public var articulatedHour: String? {
                  get {
                    return resultMap["articulatedHour"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "articulatedHour")
                  }
                }

                public var specialHours: [SpecialHour]? {
                  get {
                    return (resultMap["specialHours"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [SpecialHour] in value.map { (value: ResultMap) -> SpecialHour in SpecialHour(unsafeResultMap: value) } }
                  }
                  set {
                    resultMap.updateValue(newValue.flatMap { (value: [SpecialHour]) -> [ResultMap] in value.map { (value: SpecialHour) -> ResultMap in value.resultMap } }, forKey: "specialHours")
                  }
                }

                public var hours: Hour? {
                  get {
                    return (resultMap["hours"] as? ResultMap).flatMap { Hour(unsafeResultMap: $0) }
                  }
                  set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "hours")
                  }
                }

                public var isClosed: Bool {
                  get {
                    return resultMap["isClosed"]! as! Bool
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "isClosed")
                  }
                }

                public var isOpenNow: Bool? {
                  get {
                    return resultMap["isOpenNow"] as? Bool
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "isOpenNow")
                  }
                }

                public var categories: [String] {
                  get {
                    return resultMap["categories"]! as! [String]
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "categories")
                  }
                }

                /// DEPRECATED in favor of imageURLs
                public var imageUrl: String {
                  get {
                    return resultMap["imageURL"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "imageURL")
                  }
                }

                public var mapImage: MapImage? {
                  get {
                    return (resultMap["mapImage"] as? ResultMap).flatMap { MapImage(unsafeResultMap: $0) }
                  }
                  set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "mapImage")
                  }
                }

                public struct Address: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["PlaceAddress"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("streetAddress", type: .scalar(String.self)),
                      GraphQLField("fullAddress", type: .scalar(String.self)),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(streetAddress: String? = nil, fullAddress: String? = nil) {
                    self.init(unsafeResultMap: ["__typename": "PlaceAddress", "streetAddress": streetAddress, "fullAddress": fullAddress])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var streetAddress: String? {
                    get {
                      return resultMap["streetAddress"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "streetAddress")
                    }
                  }

                  public var fullAddress: String? {
                    get {
                      return resultMap["fullAddress"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "fullAddress")
                    }
                  }
                }

                public struct Position: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["LatLon"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("lat", type: .nonNull(.scalar(Double.self))),
                      GraphQLField("lon", type: .nonNull(.scalar(Double.self))),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(lat: Double, lon: Double) {
                    self.init(unsafeResultMap: ["__typename": "LatLon", "lat": lat, "lon": lon])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var lat: Double {
                    get {
                      return resultMap["lat"]! as! Double
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "lat")
                    }
                  }

                  public var lon: Double {
                    get {
                      return resultMap["lon"]! as! Double
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "lon")
                    }
                  }
                }

                public struct Review: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["PlaceReview"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("id", type: .nonNull(.scalar(String.self))),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(id: String) {
                    self.init(unsafeResultMap: ["__typename": "PlaceReview", "id": id])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var id: String {
                    get {
                      return resultMap["id"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "id")
                    }
                  }
                }

                public struct SpecialHour: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["PlaceSpecialHours"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("isOvernight", type: .nonNull(.scalar(Bool.self))),
                      GraphQLField("start", type: .nonNull(.scalar(String.self))),
                      GraphQLField("end", type: .nonNull(.scalar(String.self))),
                      GraphQLField("date", type: .nonNull(.scalar(String.self))),
                      GraphQLField("isClosed", type: .nonNull(.scalar(Bool.self))),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(isOvernight: Bool, start: String, end: String, date: String, isClosed: Bool) {
                    self.init(unsafeResultMap: ["__typename": "PlaceSpecialHours", "isOvernight": isOvernight, "start": start, "end": end, "date": date, "isClosed": isClosed])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var isOvernight: Bool {
                    get {
                      return resultMap["isOvernight"]! as! Bool
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "isOvernight")
                    }
                  }

                  public var start: String {
                    get {
                      return resultMap["start"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "start")
                    }
                  }

                  public var end: String {
                    get {
                      return resultMap["end"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "end")
                    }
                  }

                  public var date: String {
                    get {
                      return resultMap["date"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "date")
                    }
                  }

                  public var isClosed: Bool {
                    get {
                      return resultMap["isClosed"]! as! Bool
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "isClosed")
                    }
                  }
                }

                public struct Hour: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["PlaceHours"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("open", type: .nonNull(.list(.nonNull(.object(Open.selections))))),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(`open`: [Open]) {
                    self.init(unsafeResultMap: ["__typename": "PlaceHours", "open": `open`.map { (value: Open) -> ResultMap in value.resultMap }])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var `open`: [Open] {
                    get {
                      return (resultMap["open"] as! [ResultMap]).map { (value: ResultMap) -> Open in Open(unsafeResultMap: value) }
                    }
                    set {
                      resultMap.updateValue(newValue.map { (value: Open) -> ResultMap in value.resultMap }, forKey: "open")
                    }
                  }

                  public struct Open: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["PlaceDayHours"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("isOvernight", type: .nonNull(.scalar(Bool.self))),
                        GraphQLField("start", type: .nonNull(.scalar(String.self))),
                        GraphQLField("end", type: .nonNull(.scalar(String.self))),
                        GraphQLField("day", type: .nonNull(.scalar(Int.self))),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(isOvernight: Bool, start: String, end: String, day: Int) {
                      self.init(unsafeResultMap: ["__typename": "PlaceDayHours", "isOvernight": isOvernight, "start": start, "end": end, "day": day])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var isOvernight: Bool {
                      get {
                        return resultMap["isOvernight"]! as! Bool
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "isOvernight")
                      }
                    }

                    public var start: String {
                      get {
                        return resultMap["start"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "start")
                      }
                    }

                    public var end: String {
                      get {
                        return resultMap["end"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "end")
                      }
                    }

                    public var day: Int {
                      get {
                        return resultMap["day"]! as! Int
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "day")
                      }
                    }
                  }
                }

                public struct MapImage: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["MapImage"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("url", type: .scalar(String.self)),
                      GraphQLField("darkUrl", type: .scalar(String.self)),
                      GraphQLField("height", type: .scalar(Int.self)),
                      GraphQLField("width", type: .scalar(Int.self)),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(url: String? = nil, darkUrl: String? = nil, height: Int? = nil, width: Int? = nil) {
                    self.init(unsafeResultMap: ["__typename": "MapImage", "url": url, "darkUrl": darkUrl, "height": height, "width": width])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var url: String? {
                    get {
                      return resultMap["url"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "url")
                    }
                  }

                  public var darkUrl: String? {
                    get {
                      return resultMap["darkUrl"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "darkUrl")
                    }
                  }

                  public var height: Int? {
                    get {
                      return resultMap["height"] as? Int
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "height")
                    }
                  }

                  public var width: Int? {
                    get {
                      return resultMap["width"] as? Int
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "width")
                    }
                  }
                }
              }
            }

            public var asPlaceList: AsPlaceList? {
              get {
                if !AsPlaceList.possibleTypes.contains(__typename) { return nil }
                return AsPlaceList(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsPlaceList: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["PlaceList"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("placeList", type: .object(PlaceList.selections)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(placeList: PlaceList? = nil) {
                self.init(unsafeResultMap: ["__typename": "PlaceList", "placeList": placeList.flatMap { (value: PlaceList) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var placeList: PlaceList? {
                get {
                  return (resultMap["placeList"] as? ResultMap).flatMap { PlaceList(unsafeResultMap: $0) }
                }
                set {
                  resultMap.updateValue(newValue?.resultMap, forKey: "placeList")
                }
              }

              public struct PlaceList: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["PlaceListData"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("places", type: .nonNull(.list(.nonNull(.object(Place.selections))))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(places: [Place]) {
                  self.init(unsafeResultMap: ["__typename": "PlaceListData", "places": places.map { (value: Place) -> ResultMap in value.resultMap }])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var places: [Place] {
                  get {
                    return (resultMap["places"] as! [ResultMap]).map { (value: ResultMap) -> Place in Place(unsafeResultMap: value) }
                  }
                  set {
                    resultMap.updateValue(newValue.map { (value: Place) -> ResultMap in value.resultMap }, forKey: "places")
                  }
                }

                public struct Place: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["Place"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("place", type: .nonNull(.object(Place.selections))),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(place: Place) {
                    self.init(unsafeResultMap: ["__typename": "Place", "place": place.resultMap])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var place: Place {
                    get {
                      return Place(unsafeResultMap: resultMap["place"]! as! ResultMap)
                    }
                    set {
                      resultMap.updateValue(newValue.resultMap, forKey: "place")
                    }
                  }

                  public struct Place: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["PlaceData"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("id", type: .scalar(String.self)),
                        GraphQLField("type", type: .nonNull(.scalar(String.self))),
                        GraphQLField("name", type: .nonNull(.scalar(String.self))),
                        GraphQLField("address", type: .nonNull(.object(Address.selections))),
                        GraphQLField("telephone", type: .nonNull(.scalar(String.self))),
                        GraphQLField("telephonePretty", type: .nonNull(.scalar(String.self))),
                        GraphQLField("websiteURL", type: .nonNull(.scalar(String.self))),
                        GraphQLField("yelpURL", type: .nonNull(.scalar(String.self))),
                        GraphQLField("bingWebSearchURL", type: .nonNull(.scalar(String.self))),
                        GraphQLField("position", type: .nonNull(.object(Position.selections))),
                        GraphQLField("placeSubType", type: .scalar(PlaceSubType.self)),
                        GraphQLField("isAddress", type: .scalar(Bool.self)),
                        GraphQLField("rating", type: .nonNull(.scalar(Double.self))),
                        GraphQLField("price", type: .nonNull(.scalar(String.self))),
                        GraphQLField("reviews", type: .list(.nonNull(.object(Review.selections)))),
                        GraphQLField("specialHours", type: .list(.nonNull(.object(SpecialHour.selections)))),
                        GraphQLField("hours", type: .object(Hour.selections)),
                        GraphQLField("reviewCount", type: .nonNull(.scalar(Int.self))),
                        GraphQLField("imageURL", type: .nonNull(.scalar(String.self))),
                        GraphQLField("imageURLs", type: .list(.nonNull(.scalar(String.self)))),
                        GraphQLField("isClosed", type: .nonNull(.scalar(Bool.self))),
                        GraphQLField("isOpenNow", type: .scalar(Bool.self)),
                        GraphQLField("categories", type: .nonNull(.list(.nonNull(.scalar(String.self))))),
                        GraphQLField("mapImage", type: .object(MapImage.selections)),
                        GraphQLField("mapImageLarge", type: .object(MapImageLarge.selections)),
                        GraphQLField("googleMapsURL", type: .scalar(String.self)),
                        GraphQLField("subTitle", type: .scalar(String.self)),
                        GraphQLField("useHighVisuals", type: .scalar(Bool.self)),
                        GraphQLField("articulatedOperatingStatus", type: .scalar(String.self)),
                        GraphQLField("articulatedHour", type: .scalar(String.self)),
                        GraphQLField("mapsURL", type: .scalar(String.self)),
                        GraphQLField("neevaMapsQuery", type: .object(NeevaMapsQuery.selections)),
                        GraphQLField("placeSuggestions", type: .list(.nonNull(.object(PlaceSuggestion.selections)))),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(id: String? = nil, type: String, name: String, address: Address, telephone: String, telephonePretty: String, websiteUrl: String, yelpUrl: String, bingWebSearchUrl: String, position: Position, placeSubType: PlaceSubType? = nil, isAddress: Bool? = nil, rating: Double, price: String, reviews: [Review]? = nil, specialHours: [SpecialHour]? = nil, hours: Hour? = nil, reviewCount: Int, imageUrl: String, imageUrLs: [String]? = nil, isClosed: Bool, isOpenNow: Bool? = nil, categories: [String], mapImage: MapImage? = nil, mapImageLarge: MapImageLarge? = nil, googleMapsUrl: String? = nil, subTitle: String? = nil, useHighVisuals: Bool? = nil, articulatedOperatingStatus: String? = nil, articulatedHour: String? = nil, mapsUrl: String? = nil, neevaMapsQuery: NeevaMapsQuery? = nil, placeSuggestions: [PlaceSuggestion]? = nil) {
                      self.init(unsafeResultMap: ["__typename": "PlaceData", "id": id, "type": type, "name": name, "address": address.resultMap, "telephone": telephone, "telephonePretty": telephonePretty, "websiteURL": websiteUrl, "yelpURL": yelpUrl, "bingWebSearchURL": bingWebSearchUrl, "position": position.resultMap, "placeSubType": placeSubType, "isAddress": isAddress, "rating": rating, "price": price, "reviews": reviews.flatMap { (value: [Review]) -> [ResultMap] in value.map { (value: Review) -> ResultMap in value.resultMap } }, "specialHours": specialHours.flatMap { (value: [SpecialHour]) -> [ResultMap] in value.map { (value: SpecialHour) -> ResultMap in value.resultMap } }, "hours": hours.flatMap { (value: Hour) -> ResultMap in value.resultMap }, "reviewCount": reviewCount, "imageURL": imageUrl, "imageURLs": imageUrLs, "isClosed": isClosed, "isOpenNow": isOpenNow, "categories": categories, "mapImage": mapImage.flatMap { (value: MapImage) -> ResultMap in value.resultMap }, "mapImageLarge": mapImageLarge.flatMap { (value: MapImageLarge) -> ResultMap in value.resultMap }, "googleMapsURL": googleMapsUrl, "subTitle": subTitle, "useHighVisuals": useHighVisuals, "articulatedOperatingStatus": articulatedOperatingStatus, "articulatedHour": articulatedHour, "mapsURL": mapsUrl, "neevaMapsQuery": neevaMapsQuery.flatMap { (value: NeevaMapsQuery) -> ResultMap in value.resultMap }, "placeSuggestions": placeSuggestions.flatMap { (value: [PlaceSuggestion]) -> [ResultMap] in value.map { (value: PlaceSuggestion) -> ResultMap in value.resultMap } }])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var id: String? {
                      get {
                        return resultMap["id"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "id")
                      }
                    }

                    public var type: String {
                      get {
                        return resultMap["type"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "type")
                      }
                    }

                    public var name: String {
                      get {
                        return resultMap["name"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "name")
                      }
                    }

                    public var address: Address {
                      get {
                        return Address(unsafeResultMap: resultMap["address"]! as! ResultMap)
                      }
                      set {
                        resultMap.updateValue(newValue.resultMap, forKey: "address")
                      }
                    }

                    public var telephone: String {
                      get {
                        return resultMap["telephone"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "telephone")
                      }
                    }

                    public var telephonePretty: String {
                      get {
                        return resultMap["telephonePretty"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "telephonePretty")
                      }
                    }

                    public var websiteUrl: String {
                      get {
                        return resultMap["websiteURL"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "websiteURL")
                      }
                    }

                    public var yelpUrl: String {
                      get {
                        return resultMap["yelpURL"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "yelpURL")
                      }
                    }

                    public var bingWebSearchUrl: String {
                      get {
                        return resultMap["bingWebSearchURL"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "bingWebSearchURL")
                      }
                    }

                    public var position: Position {
                      get {
                        return Position(unsafeResultMap: resultMap["position"]! as! ResultMap)
                      }
                      set {
                        resultMap.updateValue(newValue.resultMap, forKey: "position")
                      }
                    }

                    public var placeSubType: PlaceSubType? {
                      get {
                        return resultMap["placeSubType"] as? PlaceSubType
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "placeSubType")
                      }
                    }

                    public var isAddress: Bool? {
                      get {
                        return resultMap["isAddress"] as? Bool
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "isAddress")
                      }
                    }

                    public var rating: Double {
                      get {
                        return resultMap["rating"]! as! Double
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "rating")
                      }
                    }

                    public var price: String {
                      get {
                        return resultMap["price"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "price")
                      }
                    }

                    public var reviews: [Review]? {
                      get {
                        return (resultMap["reviews"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Review] in value.map { (value: ResultMap) -> Review in Review(unsafeResultMap: value) } }
                      }
                      set {
                        resultMap.updateValue(newValue.flatMap { (value: [Review]) -> [ResultMap] in value.map { (value: Review) -> ResultMap in value.resultMap } }, forKey: "reviews")
                      }
                    }

                    public var specialHours: [SpecialHour]? {
                      get {
                        return (resultMap["specialHours"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [SpecialHour] in value.map { (value: ResultMap) -> SpecialHour in SpecialHour(unsafeResultMap: value) } }
                      }
                      set {
                        resultMap.updateValue(newValue.flatMap { (value: [SpecialHour]) -> [ResultMap] in value.map { (value: SpecialHour) -> ResultMap in value.resultMap } }, forKey: "specialHours")
                      }
                    }

                    public var hours: Hour? {
                      get {
                        return (resultMap["hours"] as? ResultMap).flatMap { Hour(unsafeResultMap: $0) }
                      }
                      set {
                        resultMap.updateValue(newValue?.resultMap, forKey: "hours")
                      }
                    }

                    public var reviewCount: Int {
                      get {
                        return resultMap["reviewCount"]! as! Int
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "reviewCount")
                      }
                    }

                    /// DEPRECATED in favor of imageURLs
                    public var imageUrl: String {
                      get {
                        return resultMap["imageURL"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "imageURL")
                      }
                    }

                    public var imageUrLs: [String]? {
                      get {
                        return resultMap["imageURLs"] as? [String]
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "imageURLs")
                      }
                    }

                    public var isClosed: Bool {
                      get {
                        return resultMap["isClosed"]! as! Bool
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "isClosed")
                      }
                    }

                    public var isOpenNow: Bool? {
                      get {
                        return resultMap["isOpenNow"] as? Bool
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "isOpenNow")
                      }
                    }

                    public var categories: [String] {
                      get {
                        return resultMap["categories"]! as! [String]
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "categories")
                      }
                    }

                    public var mapImage: MapImage? {
                      get {
                        return (resultMap["mapImage"] as? ResultMap).flatMap { MapImage(unsafeResultMap: $0) }
                      }
                      set {
                        resultMap.updateValue(newValue?.resultMap, forKey: "mapImage")
                      }
                    }

                    public var mapImageLarge: MapImageLarge? {
                      get {
                        return (resultMap["mapImageLarge"] as? ResultMap).flatMap { MapImageLarge(unsafeResultMap: $0) }
                      }
                      set {
                        resultMap.updateValue(newValue?.resultMap, forKey: "mapImageLarge")
                      }
                    }

                    public var googleMapsUrl: String? {
                      get {
                        return resultMap["googleMapsURL"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "googleMapsURL")
                      }
                    }

                    public var subTitle: String? {
                      get {
                        return resultMap["subTitle"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "subTitle")
                      }
                    }

                    public var useHighVisuals: Bool? {
                      get {
                        return resultMap["useHighVisuals"] as? Bool
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "useHighVisuals")
                      }
                    }

                    public var articulatedOperatingStatus: String? {
                      get {
                        return resultMap["articulatedOperatingStatus"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "articulatedOperatingStatus")
                      }
                    }

                    public var articulatedHour: String? {
                      get {
                        return resultMap["articulatedHour"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "articulatedHour")
                      }
                    }

                    @available(*, deprecated, message: "No longer supported")
                    public var mapsUrl: String? {
                      get {
                        return resultMap["mapsURL"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "mapsURL")
                      }
                    }

                    public var neevaMapsQuery: NeevaMapsQuery? {
                      get {
                        return (resultMap["neevaMapsQuery"] as? ResultMap).flatMap { NeevaMapsQuery(unsafeResultMap: $0) }
                      }
                      set {
                        resultMap.updateValue(newValue?.resultMap, forKey: "neevaMapsQuery")
                      }
                    }

                    public var placeSuggestions: [PlaceSuggestion]? {
                      get {
                        return (resultMap["placeSuggestions"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [PlaceSuggestion] in value.map { (value: ResultMap) -> PlaceSuggestion in PlaceSuggestion(unsafeResultMap: value) } }
                      }
                      set {
                        resultMap.updateValue(newValue.flatMap { (value: [PlaceSuggestion]) -> [ResultMap] in value.map { (value: PlaceSuggestion) -> ResultMap in value.resultMap } }, forKey: "placeSuggestions")
                      }
                    }

                    public struct Address: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["PlaceAddress"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("streetAddress", type: .scalar(String.self)),
                          GraphQLField("fullAddress", type: .scalar(String.self)),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(streetAddress: String? = nil, fullAddress: String? = nil) {
                        self.init(unsafeResultMap: ["__typename": "PlaceAddress", "streetAddress": streetAddress, "fullAddress": fullAddress])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var streetAddress: String? {
                        get {
                          return resultMap["streetAddress"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "streetAddress")
                        }
                      }

                      public var fullAddress: String? {
                        get {
                          return resultMap["fullAddress"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "fullAddress")
                        }
                      }
                    }

                    public struct Position: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["LatLon"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("lat", type: .nonNull(.scalar(Double.self))),
                          GraphQLField("lon", type: .nonNull(.scalar(Double.self))),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(lat: Double, lon: Double) {
                        self.init(unsafeResultMap: ["__typename": "LatLon", "lat": lat, "lon": lon])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var lat: Double {
                        get {
                          return resultMap["lat"]! as! Double
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "lat")
                        }
                      }

                      public var lon: Double {
                        get {
                          return resultMap["lon"]! as! Double
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "lon")
                        }
                      }
                    }

                    public struct Review: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["PlaceReview"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("id", type: .nonNull(.scalar(String.self))),
                          GraphQLField("text", type: .nonNull(.scalar(String.self))),
                          GraphQLField("rating", type: .nonNull(.scalar(Int.self))),
                          GraphQLField("timeCreated", type: .nonNull(.scalar(String.self))),
                          GraphQLField("url", type: .nonNull(.scalar(String.self))),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(id: String, text: String, rating: Int, timeCreated: String, url: String) {
                        self.init(unsafeResultMap: ["__typename": "PlaceReview", "id": id, "text": text, "rating": rating, "timeCreated": timeCreated, "url": url])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var id: String {
                        get {
                          return resultMap["id"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "id")
                        }
                      }

                      public var text: String {
                        get {
                          return resultMap["text"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "text")
                        }
                      }

                      public var rating: Int {
                        get {
                          return resultMap["rating"]! as! Int
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "rating")
                        }
                      }

                      public var timeCreated: String {
                        get {
                          return resultMap["timeCreated"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "timeCreated")
                        }
                      }

                      public var url: String {
                        get {
                          return resultMap["url"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "url")
                        }
                      }
                    }

                    public struct SpecialHour: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["PlaceSpecialHours"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("isOvernight", type: .nonNull(.scalar(Bool.self))),
                          GraphQLField("start", type: .nonNull(.scalar(String.self))),
                          GraphQLField("end", type: .nonNull(.scalar(String.self))),
                          GraphQLField("date", type: .nonNull(.scalar(String.self))),
                          GraphQLField("isClosed", type: .nonNull(.scalar(Bool.self))),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(isOvernight: Bool, start: String, end: String, date: String, isClosed: Bool) {
                        self.init(unsafeResultMap: ["__typename": "PlaceSpecialHours", "isOvernight": isOvernight, "start": start, "end": end, "date": date, "isClosed": isClosed])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var isOvernight: Bool {
                        get {
                          return resultMap["isOvernight"]! as! Bool
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "isOvernight")
                        }
                      }

                      public var start: String {
                        get {
                          return resultMap["start"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "start")
                        }
                      }

                      public var end: String {
                        get {
                          return resultMap["end"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "end")
                        }
                      }

                      public var date: String {
                        get {
                          return resultMap["date"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "date")
                        }
                      }

                      public var isClosed: Bool {
                        get {
                          return resultMap["isClosed"]! as! Bool
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "isClosed")
                        }
                      }
                    }

                    public struct Hour: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["PlaceHours"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("open", type: .nonNull(.list(.nonNull(.object(Open.selections))))),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(`open`: [Open]) {
                        self.init(unsafeResultMap: ["__typename": "PlaceHours", "open": `open`.map { (value: Open) -> ResultMap in value.resultMap }])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var `open`: [Open] {
                        get {
                          return (resultMap["open"] as! [ResultMap]).map { (value: ResultMap) -> Open in Open(unsafeResultMap: value) }
                        }
                        set {
                          resultMap.updateValue(newValue.map { (value: Open) -> ResultMap in value.resultMap }, forKey: "open")
                        }
                      }

                      public struct Open: GraphQLSelectionSet {
                        public static let possibleTypes: [String] = ["PlaceDayHours"]

                        public static var selections: [GraphQLSelection] {
                          return [
                            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                            GraphQLField("isOvernight", type: .nonNull(.scalar(Bool.self))),
                            GraphQLField("start", type: .nonNull(.scalar(String.self))),
                            GraphQLField("end", type: .nonNull(.scalar(String.self))),
                            GraphQLField("day", type: .nonNull(.scalar(Int.self))),
                          ]
                        }

                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                          self.resultMap = unsafeResultMap
                        }

                        public init(isOvernight: Bool, start: String, end: String, day: Int) {
                          self.init(unsafeResultMap: ["__typename": "PlaceDayHours", "isOvernight": isOvernight, "start": start, "end": end, "day": day])
                        }

                        public var __typename: String {
                          get {
                            return resultMap["__typename"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "__typename")
                          }
                        }

                        public var isOvernight: Bool {
                          get {
                            return resultMap["isOvernight"]! as! Bool
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "isOvernight")
                          }
                        }

                        public var start: String {
                          get {
                            return resultMap["start"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "start")
                          }
                        }

                        public var end: String {
                          get {
                            return resultMap["end"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "end")
                          }
                        }

                        public var day: Int {
                          get {
                            return resultMap["day"]! as! Int
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "day")
                          }
                        }
                      }
                    }

                    public struct MapImage: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["MapImage"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("url", type: .scalar(String.self)),
                          GraphQLField("darkUrl", type: .scalar(String.self)),
                          GraphQLField("width", type: .scalar(Int.self)),
                          GraphQLField("height", type: .scalar(Int.self)),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(url: String? = nil, darkUrl: String? = nil, width: Int? = nil, height: Int? = nil) {
                        self.init(unsafeResultMap: ["__typename": "MapImage", "url": url, "darkUrl": darkUrl, "width": width, "height": height])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var url: String? {
                        get {
                          return resultMap["url"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "url")
                        }
                      }

                      public var darkUrl: String? {
                        get {
                          return resultMap["darkUrl"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "darkUrl")
                        }
                      }

                      public var width: Int? {
                        get {
                          return resultMap["width"] as? Int
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "width")
                        }
                      }

                      public var height: Int? {
                        get {
                          return resultMap["height"] as? Int
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "height")
                        }
                      }
                    }

                    public struct MapImageLarge: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["MapImage"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("url", type: .scalar(String.self)),
                          GraphQLField("darkUrl", type: .scalar(String.self)),
                          GraphQLField("width", type: .scalar(Int.self)),
                          GraphQLField("height", type: .scalar(Int.self)),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(url: String? = nil, darkUrl: String? = nil, width: Int? = nil, height: Int? = nil) {
                        self.init(unsafeResultMap: ["__typename": "MapImage", "url": url, "darkUrl": darkUrl, "width": width, "height": height])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var url: String? {
                        get {
                          return resultMap["url"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "url")
                        }
                      }

                      public var darkUrl: String? {
                        get {
                          return resultMap["darkUrl"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "darkUrl")
                        }
                      }

                      public var width: Int? {
                        get {
                          return resultMap["width"] as? Int
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "width")
                        }
                      }

                      public var height: Int? {
                        get {
                          return resultMap["height"] as? Int
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "height")
                        }
                      }
                    }

                    public struct NeevaMapsQuery: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["NeevaMapsQuery"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("query", type: .scalar(String.self)),
                          GraphQLField("latitude", type: .scalar(Double.self)),
                          GraphQLField("longitude", type: .scalar(Double.self)),
                          GraphQLField("radius", type: .scalar(Int.self)),
                          GraphQLField("isLocationShift", type: .scalar(Bool.self)),
                          GraphQLField("placeID", type: .scalar(String.self)),
                          GraphQLField("zoom", type: .scalar(Int.self)),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(query: String? = nil, latitude: Double? = nil, longitude: Double? = nil, radius: Int? = nil, isLocationShift: Bool? = nil, placeId: String? = nil, zoom: Int? = nil) {
                        self.init(unsafeResultMap: ["__typename": "NeevaMapsQuery", "query": query, "latitude": latitude, "longitude": longitude, "radius": radius, "isLocationShift": isLocationShift, "placeID": placeId, "zoom": zoom])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var query: String? {
                        get {
                          return resultMap["query"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "query")
                        }
                      }

                      public var latitude: Double? {
                        get {
                          return resultMap["latitude"] as? Double
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "latitude")
                        }
                      }

                      public var longitude: Double? {
                        get {
                          return resultMap["longitude"] as? Double
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "longitude")
                        }
                      }

                      public var radius: Int? {
                        get {
                          return resultMap["radius"] as? Int
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "radius")
                        }
                      }

                      public var isLocationShift: Bool? {
                        get {
                          return resultMap["isLocationShift"] as? Bool
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "isLocationShift")
                        }
                      }

                      public var placeId: String? {
                        get {
                          return resultMap["placeID"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "placeID")
                        }
                      }

                      public var zoom: Int? {
                        get {
                          return resultMap["zoom"] as? Int
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "zoom")
                        }
                      }
                    }

                    public struct PlaceSuggestion: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["PlaceSuggestion"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("address", type: .object(Address.selections)),
                          GraphQLField("mapImage", type: .object(MapImage.selections)),
                          GraphQLField("mapImageLarge", type: .object(MapImageLarge.selections)),
                          GraphQLField("googleMapsURL", type: .scalar(String.self)),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(address: Address? = nil, mapImage: MapImage? = nil, mapImageLarge: MapImageLarge? = nil, googleMapsUrl: String? = nil) {
                        self.init(unsafeResultMap: ["__typename": "PlaceSuggestion", "address": address.flatMap { (value: Address) -> ResultMap in value.resultMap }, "mapImage": mapImage.flatMap { (value: MapImage) -> ResultMap in value.resultMap }, "mapImageLarge": mapImageLarge.flatMap { (value: MapImageLarge) -> ResultMap in value.resultMap }, "googleMapsURL": googleMapsUrl])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var address: Address? {
                        get {
                          return (resultMap["address"] as? ResultMap).flatMap { Address(unsafeResultMap: $0) }
                        }
                        set {
                          resultMap.updateValue(newValue?.resultMap, forKey: "address")
                        }
                      }

                      public var mapImage: MapImage? {
                        get {
                          return (resultMap["mapImage"] as? ResultMap).flatMap { MapImage(unsafeResultMap: $0) }
                        }
                        set {
                          resultMap.updateValue(newValue?.resultMap, forKey: "mapImage")
                        }
                      }

                      public var mapImageLarge: MapImageLarge? {
                        get {
                          return (resultMap["mapImageLarge"] as? ResultMap).flatMap { MapImageLarge(unsafeResultMap: $0) }
                        }
                        set {
                          resultMap.updateValue(newValue?.resultMap, forKey: "mapImageLarge")
                        }
                      }

                      public var googleMapsUrl: String? {
                        get {
                          return resultMap["googleMapsURL"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "googleMapsURL")
                        }
                      }

                      public struct Address: GraphQLSelectionSet {
                        public static let possibleTypes: [String] = ["PlaceAddress"]

                        public static var selections: [GraphQLSelection] {
                          return [
                            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                            GraphQLField("country", type: .nonNull(.scalar(String.self))),
                            GraphQLField("locality", type: .nonNull(.scalar(String.self))),
                            GraphQLField("region", type: .nonNull(.scalar(String.self))),
                            GraphQLField("neighborhood", type: .nonNull(.scalar(String.self))),
                            GraphQLField("postalCode", type: .nonNull(.scalar(String.self))),
                            GraphQLField("streetName", type: .nonNull(.scalar(String.self))),
                            GraphQLField("streetNumber", type: .nonNull(.scalar(String.self))),
                            GraphQLField("streetAddress", type: .scalar(String.self)),
                            GraphQLField("fullAddress", type: .scalar(String.self)),
                          ]
                        }

                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                          self.resultMap = unsafeResultMap
                        }

                        public init(country: String, locality: String, region: String, neighborhood: String, postalCode: String, streetName: String, streetNumber: String, streetAddress: String? = nil, fullAddress: String? = nil) {
                          self.init(unsafeResultMap: ["__typename": "PlaceAddress", "country": country, "locality": locality, "region": region, "neighborhood": neighborhood, "postalCode": postalCode, "streetName": streetName, "streetNumber": streetNumber, "streetAddress": streetAddress, "fullAddress": fullAddress])
                        }

                        public var __typename: String {
                          get {
                            return resultMap["__typename"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "__typename")
                          }
                        }

                        public var country: String {
                          get {
                            return resultMap["country"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "country")
                          }
                        }

                        public var locality: String {
                          get {
                            return resultMap["locality"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "locality")
                          }
                        }

                        public var region: String {
                          get {
                            return resultMap["region"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "region")
                          }
                        }

                        public var neighborhood: String {
                          get {
                            return resultMap["neighborhood"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "neighborhood")
                          }
                        }

                        public var postalCode: String {
                          get {
                            return resultMap["postalCode"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "postalCode")
                          }
                        }

                        public var streetName: String {
                          get {
                            return resultMap["streetName"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "streetName")
                          }
                        }

                        public var streetNumber: String {
                          get {
                            return resultMap["streetNumber"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "streetNumber")
                          }
                        }

                        public var streetAddress: String? {
                          get {
                            return resultMap["streetAddress"] as? String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "streetAddress")
                          }
                        }

                        public var fullAddress: String? {
                          get {
                            return resultMap["fullAddress"] as? String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "fullAddress")
                          }
                        }
                      }

                      public struct MapImage: GraphQLSelectionSet {
                        public static let possibleTypes: [String] = ["MapImage"]

                        public static var selections: [GraphQLSelection] {
                          return [
                            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                            GraphQLField("url", type: .scalar(String.self)),
                            GraphQLField("darkUrl", type: .scalar(String.self)),
                            GraphQLField("width", type: .scalar(Int.self)),
                            GraphQLField("height", type: .scalar(Int.self)),
                          ]
                        }

                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                          self.resultMap = unsafeResultMap
                        }

                        public init(url: String? = nil, darkUrl: String? = nil, width: Int? = nil, height: Int? = nil) {
                          self.init(unsafeResultMap: ["__typename": "MapImage", "url": url, "darkUrl": darkUrl, "width": width, "height": height])
                        }

                        public var __typename: String {
                          get {
                            return resultMap["__typename"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "__typename")
                          }
                        }

                        public var url: String? {
                          get {
                            return resultMap["url"] as? String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "url")
                          }
                        }

                        public var darkUrl: String? {
                          get {
                            return resultMap["darkUrl"] as? String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "darkUrl")
                          }
                        }

                        public var width: Int? {
                          get {
                            return resultMap["width"] as? Int
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "width")
                          }
                        }

                        public var height: Int? {
                          get {
                            return resultMap["height"] as? Int
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "height")
                          }
                        }
                      }

                      public struct MapImageLarge: GraphQLSelectionSet {
                        public static let possibleTypes: [String] = ["MapImage"]

                        public static var selections: [GraphQLSelection] {
                          return [
                            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                            GraphQLField("url", type: .scalar(String.self)),
                            GraphQLField("darkUrl", type: .scalar(String.self)),
                            GraphQLField("width", type: .scalar(Int.self)),
                            GraphQLField("height", type: .scalar(Int.self)),
                          ]
                        }

                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                          self.resultMap = unsafeResultMap
                        }

                        public init(url: String? = nil, darkUrl: String? = nil, width: Int? = nil, height: Int? = nil) {
                          self.init(unsafeResultMap: ["__typename": "MapImage", "url": url, "darkUrl": darkUrl, "width": width, "height": height])
                        }

                        public var __typename: String {
                          get {
                            return resultMap["__typename"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "__typename")
                          }
                        }

                        public var url: String? {
                          get {
                            return resultMap["url"] as? String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "url")
                          }
                        }

                        public var darkUrl: String? {
                          get {
                            return resultMap["darkUrl"] as? String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "darkUrl")
                          }
                        }

                        public var width: Int? {
                          get {
                            return resultMap["width"] as? Int
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "width")
                          }
                        }

                        public var height: Int? {
                          get {
                            return resultMap["height"] as? Int
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "height")
                          }
                        }
                      }
                    }
                  }
                }
              }
            }

            public var asWeb: AsWeb? {
              get {
                if !AsWeb.possibleTypes.contains(__typename) { return nil }
                return AsWeb(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsWeb: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["Web"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("web", type: .object(Web.selections)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(web: Web? = nil) {
                self.init(unsafeResultMap: ["__typename": "Web", "web": web.flatMap { (value: Web) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var web: Web? {
                get {
                  return (resultMap["web"] as? ResultMap).flatMap { Web(unsafeResultMap: $0) }
                }
                set {
                  resultMap.updateValue(newValue?.resultMap, forKey: "web")
                }
              }

              public struct Web: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["WebData"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("favIconURL", type: .scalar(String.self)),
                    GraphQLField("displayUrl", type: .nonNull(.scalar(String.self))),
                    GraphQLField("publicationDate", type: .scalar(String.self)),
                    GraphQLField("structuredUrl", type: .object(StructuredUrl.selections)),
                    GraphQLField("highlightedSnippet", type: .object(HighlightedSnippet.selections)),
                    GraphQLField("buyingGuideProducts", type: .list(.nonNull(.object(BuyingGuideProduct.selections)))),
                    GraphQLField("inlineSearchProducts", type: .list(.nonNull(.object(InlineSearchProduct.selections)))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(favIconUrl: String? = nil, displayUrl: String, publicationDate: String? = nil, structuredUrl: StructuredUrl? = nil, highlightedSnippet: HighlightedSnippet? = nil, buyingGuideProducts: [BuyingGuideProduct]? = nil, inlineSearchProducts: [InlineSearchProduct]? = nil) {
                  self.init(unsafeResultMap: ["__typename": "WebData", "favIconURL": favIconUrl, "displayUrl": displayUrl, "publicationDate": publicationDate, "structuredUrl": structuredUrl.flatMap { (value: StructuredUrl) -> ResultMap in value.resultMap }, "highlightedSnippet": highlightedSnippet.flatMap { (value: HighlightedSnippet) -> ResultMap in value.resultMap }, "buyingGuideProducts": buyingGuideProducts.flatMap { (value: [BuyingGuideProduct]) -> [ResultMap] in value.map { (value: BuyingGuideProduct) -> ResultMap in value.resultMap } }, "inlineSearchProducts": inlineSearchProducts.flatMap { (value: [InlineSearchProduct]) -> [ResultMap] in value.map { (value: InlineSearchProduct) -> ResultMap in value.resultMap } }])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var favIconUrl: String? {
                  get {
                    return resultMap["favIconURL"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "favIconURL")
                  }
                }

                public var displayUrl: String {
                  get {
                    return resultMap["displayUrl"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "displayUrl")
                  }
                }

                public var publicationDate: String? {
                  get {
                    return resultMap["publicationDate"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "publicationDate")
                  }
                }

                public var structuredUrl: StructuredUrl? {
                  get {
                    return (resultMap["structuredUrl"] as? ResultMap).flatMap { StructuredUrl(unsafeResultMap: $0) }
                  }
                  set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "structuredUrl")
                  }
                }

                public var highlightedSnippet: HighlightedSnippet? {
                  get {
                    return (resultMap["highlightedSnippet"] as? ResultMap).flatMap { HighlightedSnippet(unsafeResultMap: $0) }
                  }
                  set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "highlightedSnippet")
                  }
                }

                public var buyingGuideProducts: [BuyingGuideProduct]? {
                  get {
                    return (resultMap["buyingGuideProducts"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [BuyingGuideProduct] in value.map { (value: ResultMap) -> BuyingGuideProduct in BuyingGuideProduct(unsafeResultMap: value) } }
                  }
                  set {
                    resultMap.updateValue(newValue.flatMap { (value: [BuyingGuideProduct]) -> [ResultMap] in value.map { (value: BuyingGuideProduct) -> ResultMap in value.resultMap } }, forKey: "buyingGuideProducts")
                  }
                }

                public var inlineSearchProducts: [InlineSearchProduct]? {
                  get {
                    return (resultMap["inlineSearchProducts"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [InlineSearchProduct] in value.map { (value: ResultMap) -> InlineSearchProduct in InlineSearchProduct(unsafeResultMap: value) } }
                  }
                  set {
                    resultMap.updateValue(newValue.flatMap { (value: [InlineSearchProduct]) -> [ResultMap] in value.map { (value: InlineSearchProduct) -> ResultMap in value.resultMap } }, forKey: "inlineSearchProducts")
                  }
                }

                public struct StructuredUrl: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["StructuredUrl"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("paths", type: .list(.nonNull(.scalar(String.self)))),
                      GraphQLField("hostname", type: .nonNull(.scalar(String.self))),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(paths: [String]? = nil, hostname: String) {
                    self.init(unsafeResultMap: ["__typename": "StructuredUrl", "paths": paths, "hostname": hostname])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var paths: [String]? {
                    get {
                      return resultMap["paths"] as? [String]
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "paths")
                    }
                  }

                  public var hostname: String {
                    get {
                      return resultMap["hostname"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "hostname")
                    }
                  }
                }

                public struct HighlightedSnippet: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["HighlightedText"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("segments", type: .list(.nonNull(.object(Segment.selections)))),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(segments: [Segment]? = nil) {
                    self.init(unsafeResultMap: ["__typename": "HighlightedText", "segments": segments.flatMap { (value: [Segment]) -> [ResultMap] in value.map { (value: Segment) -> ResultMap in value.resultMap } }])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var segments: [Segment]? {
                    get {
                      return (resultMap["segments"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Segment] in value.map { (value: ResultMap) -> Segment in Segment(unsafeResultMap: value) } }
                    }
                    set {
                      resultMap.updateValue(newValue.flatMap { (value: [Segment]) -> [ResultMap] in value.map { (value: Segment) -> ResultMap in value.resultMap } }, forKey: "segments")
                    }
                  }

                  public struct Segment: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["HighlightedTextSegment"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("text", type: .scalar(String.self)),
                        GraphQLField("isHighlighted", type: .scalar(Bool.self)),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(text: String? = nil, isHighlighted: Bool? = nil) {
                      self.init(unsafeResultMap: ["__typename": "HighlightedTextSegment", "text": text, "isHighlighted": isHighlighted])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var text: String? {
                      get {
                        return resultMap["text"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "text")
                      }
                    }

                    public var isHighlighted: Bool? {
                      get {
                        return resultMap["isHighlighted"] as? Bool
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "isHighlighted")
                      }
                    }
                  }
                }

                public struct BuyingGuideProduct: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["Product"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("reviewTitle", type: .scalar(String.self)),
                      GraphQLField("reviewType", type: .scalar(String.self)),
                      GraphQLField("productName", type: .scalar(String.self)),
                      GraphQLField("reviewHighlights", type: .scalar(String.self)),
                      GraphQLField("reviewSummary", type: .scalar(String.self)),
                      GraphQLField("reviewURL", type: .scalar(String.self)),
                      GraphQLField("priceLow", type: .scalar(String.self)),
                      GraphQLField("thumbnailURL", type: .scalar(String.self)),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(reviewTitle: String? = nil, reviewType: String? = nil, productName: String? = nil, reviewHighlights: String? = nil, reviewSummary: String? = nil, reviewUrl: String? = nil, priceLow: String? = nil, thumbnailUrl: String? = nil) {
                    self.init(unsafeResultMap: ["__typename": "Product", "reviewTitle": reviewTitle, "reviewType": reviewType, "productName": productName, "reviewHighlights": reviewHighlights, "reviewSummary": reviewSummary, "reviewURL": reviewUrl, "priceLow": priceLow, "thumbnailURL": thumbnailUrl])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var reviewTitle: String? {
                    get {
                      return resultMap["reviewTitle"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "reviewTitle")
                    }
                  }

                  public var reviewType: String? {
                    get {
                      return resultMap["reviewType"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "reviewType")
                    }
                  }

                  public var productName: String? {
                    get {
                      return resultMap["productName"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "productName")
                    }
                  }

                  public var reviewHighlights: String? {
                    get {
                      return resultMap["reviewHighlights"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "reviewHighlights")
                    }
                  }

                  public var reviewSummary: String? {
                    get {
                      return resultMap["reviewSummary"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "reviewSummary")
                    }
                  }

                  public var reviewUrl: String? {
                    get {
                      return resultMap["reviewURL"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "reviewURL")
                    }
                  }

                  public var priceLow: String? {
                    get {
                      return resultMap["priceLow"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "priceLow")
                    }
                  }

                  public var thumbnailUrl: String? {
                    get {
                      return resultMap["thumbnailURL"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "thumbnailURL")
                    }
                  }
                }

                public struct InlineSearchProduct: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["Product"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("productName", type: .scalar(String.self)),
                      GraphQLField("priceLow", type: .scalar(String.self)),
                      GraphQLField("thumbnailURL", type: .scalar(String.self)),
                      GraphQLField("actionURL", type: .scalar(String.self)),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(productName: String? = nil, priceLow: String? = nil, thumbnailUrl: String? = nil, actionUrl: String? = nil) {
                    self.init(unsafeResultMap: ["__typename": "Product", "productName": productName, "priceLow": priceLow, "thumbnailURL": thumbnailUrl, "actionURL": actionUrl])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var productName: String? {
                    get {
                      return resultMap["productName"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "productName")
                    }
                  }

                  public var priceLow: String? {
                    get {
                      return resultMap["priceLow"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "priceLow")
                    }
                  }

                  public var thumbnailUrl: String? {
                    get {
                      return resultMap["thumbnailURL"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "thumbnailURL")
                    }
                  }

                  public var actionUrl: String? {
                    get {
                      return resultMap["actionURL"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "actionURL")
                    }
                  }
                }
              }
            }

            public var asProductClusters: AsProductClusters? {
              get {
                if !AsProductClusters.possibleTypes.contains(__typename) { return nil }
                return AsProductClusters(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsProductClusters: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["ProductClusters"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("productClusters", type: .object(ProductCluster.selections)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(productClusters: ProductCluster? = nil) {
                self.init(unsafeResultMap: ["__typename": "ProductClusters", "productClusters": productClusters.flatMap { (value: ProductCluster) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var productClusters: ProductCluster? {
                get {
                  return (resultMap["productClusters"] as? ResultMap).flatMap { ProductCluster(unsafeResultMap: $0) }
                }
                set {
                  resultMap.updateValue(newValue?.resultMap, forKey: "productClusters")
                }
              }

              public struct ProductCluster: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["ProductClustersData"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("filterLabels", type: .list(.nonNull(.object(FilterLabel.selections)))),
                    GraphQLField("products", type: .list(.nonNull(.object(Product.selections)))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(filterLabels: [FilterLabel]? = nil, products: [Product]? = nil) {
                  self.init(unsafeResultMap: ["__typename": "ProductClustersData", "filterLabels": filterLabels.flatMap { (value: [FilterLabel]) -> [ResultMap] in value.map { (value: FilterLabel) -> ResultMap in value.resultMap } }, "products": products.flatMap { (value: [Product]) -> [ResultMap] in value.map { (value: Product) -> ResultMap in value.resultMap } }])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var filterLabels: [FilterLabel]? {
                  get {
                    return (resultMap["filterLabels"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [FilterLabel] in value.map { (value: ResultMap) -> FilterLabel in FilterLabel(unsafeResultMap: value) } }
                  }
                  set {
                    resultMap.updateValue(newValue.flatMap { (value: [FilterLabel]) -> [ResultMap] in value.map { (value: FilterLabel) -> ResultMap in value.resultMap } }, forKey: "filterLabels")
                  }
                }

                public var products: [Product]? {
                  get {
                    return (resultMap["products"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Product] in value.map { (value: ResultMap) -> Product in Product(unsafeResultMap: value) } }
                  }
                  set {
                    resultMap.updateValue(newValue.flatMap { (value: [Product]) -> [ResultMap] in value.map { (value: Product) -> ResultMap in value.resultMap } }, forKey: "products")
                  }
                }

                public struct FilterLabel: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["PriceLabelsInfo"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("min", type: .scalar(Double.self)),
                      GraphQLField("max", type: .scalar(Double.self)),
                      GraphQLField("label", type: .scalar(String.self)),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(min: Double? = nil, max: Double? = nil, label: String? = nil) {
                    self.init(unsafeResultMap: ["__typename": "PriceLabelsInfo", "min": min, "max": max, "label": label])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var min: Double? {
                    get {
                      return resultMap["min"] as? Double
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "min")
                    }
                  }

                  public var max: Double? {
                    get {
                      return resultMap["max"] as? Double
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "max")
                    }
                  }

                  public var label: String? {
                    get {
                      return resultMap["label"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "label")
                    }
                  }
                }

                public struct Product: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["ProductClusteredInfo"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("productName", type: .scalar(String.self)),
                      GraphQLField("thumbnailURL", type: .scalar(String.self)),
                      GraphQLField("buyingGuideReviews", type: .list(.nonNull(.object(BuyingGuideReview.selections)))),
                      GraphQLField("sellers", type: .list(.nonNull(.object(Seller.selections)))),
                      GraphQLField("priceLow", type: .scalar(Double.self)),
                      GraphQLField("priceHigh", type: .scalar(Double.self)),
                      GraphQLField("priceLabel", type: .scalar(String.self)),
                      GraphQLField("rating", type: .scalar(Double.self)),
                      GraphQLField("maxRating", type: .scalar(Double.self)),
                      GraphQLField("ratingProvider", type: .scalar(String.self)),
                      GraphQLField("retailerReviews", type: .list(.nonNull(.object(RetailerReview.selections)))),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(productName: String? = nil, thumbnailUrl: String? = nil, buyingGuideReviews: [BuyingGuideReview]? = nil, sellers: [Seller]? = nil, priceLow: Double? = nil, priceHigh: Double? = nil, priceLabel: String? = nil, rating: Double? = nil, maxRating: Double? = nil, ratingProvider: String? = nil, retailerReviews: [RetailerReview]? = nil) {
                    self.init(unsafeResultMap: ["__typename": "ProductClusteredInfo", "productName": productName, "thumbnailURL": thumbnailUrl, "buyingGuideReviews": buyingGuideReviews.flatMap { (value: [BuyingGuideReview]) -> [ResultMap] in value.map { (value: BuyingGuideReview) -> ResultMap in value.resultMap } }, "sellers": sellers.flatMap { (value: [Seller]) -> [ResultMap] in value.map { (value: Seller) -> ResultMap in value.resultMap } }, "priceLow": priceLow, "priceHigh": priceHigh, "priceLabel": priceLabel, "rating": rating, "maxRating": maxRating, "ratingProvider": ratingProvider, "retailerReviews": retailerReviews.flatMap { (value: [RetailerReview]) -> [ResultMap] in value.map { (value: RetailerReview) -> ResultMap in value.resultMap } }])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var productName: String? {
                    get {
                      return resultMap["productName"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "productName")
                    }
                  }

                  public var thumbnailUrl: String? {
                    get {
                      return resultMap["thumbnailURL"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "thumbnailURL")
                    }
                  }

                  public var buyingGuideReviews: [BuyingGuideReview]? {
                    get {
                      return (resultMap["buyingGuideReviews"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [BuyingGuideReview] in value.map { (value: ResultMap) -> BuyingGuideReview in BuyingGuideReview(unsafeResultMap: value) } }
                    }
                    set {
                      resultMap.updateValue(newValue.flatMap { (value: [BuyingGuideReview]) -> [ResultMap] in value.map { (value: BuyingGuideReview) -> ResultMap in value.resultMap } }, forKey: "buyingGuideReviews")
                    }
                  }

                  public var sellers: [Seller]? {
                    get {
                      return (resultMap["sellers"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Seller] in value.map { (value: ResultMap) -> Seller in Seller(unsafeResultMap: value) } }
                    }
                    set {
                      resultMap.updateValue(newValue.flatMap { (value: [Seller]) -> [ResultMap] in value.map { (value: Seller) -> ResultMap in value.resultMap } }, forKey: "sellers")
                    }
                  }

                  public var priceLow: Double? {
                    get {
                      return resultMap["priceLow"] as? Double
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "priceLow")
                    }
                  }

                  public var priceHigh: Double? {
                    get {
                      return resultMap["priceHigh"] as? Double
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "priceHigh")
                    }
                  }

                  public var priceLabel: String? {
                    get {
                      return resultMap["priceLabel"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "priceLabel")
                    }
                  }

                  public var rating: Double? {
                    get {
                      return resultMap["rating"] as? Double
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "rating")
                    }
                  }

                  public var maxRating: Double? {
                    get {
                      return resultMap["maxRating"] as? Double
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "maxRating")
                    }
                  }

                  public var ratingProvider: String? {
                    get {
                      return resultMap["ratingProvider"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "ratingProvider")
                    }
                  }

                  public var retailerReviews: [RetailerReview]? {
                    get {
                      return (resultMap["retailerReviews"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [RetailerReview] in value.map { (value: ResultMap) -> RetailerReview in RetailerReview(unsafeResultMap: value) } }
                    }
                    set {
                      resultMap.updateValue(newValue.flatMap { (value: [RetailerReview]) -> [ResultMap] in value.map { (value: RetailerReview) -> ResultMap in value.resultMap } }, forKey: "retailerReviews")
                    }
                  }

                  public struct BuyingGuideReview: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["WebProductExpertReview"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("source", type: .scalar(String.self)),
                        GraphQLField("reviewURL", type: .scalar(String.self)),
                        GraphQLField("price", type: .scalar(Double.self)),
                        GraphQLField("header", type: .object(Header.selections)),
                        GraphQLField("proCon", type: .object(ProCon.selections)),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(source: String? = nil, reviewUrl: String? = nil, price: Double? = nil, header: Header? = nil, proCon: ProCon? = nil) {
                      self.init(unsafeResultMap: ["__typename": "WebProductExpertReview", "source": source, "reviewURL": reviewUrl, "price": price, "header": header.flatMap { (value: Header) -> ResultMap in value.resultMap }, "proCon": proCon.flatMap { (value: ProCon) -> ResultMap in value.resultMap }])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var source: String? {
                      get {
                        return resultMap["source"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "source")
                      }
                    }

                    public var reviewUrl: String? {
                      get {
                        return resultMap["reviewURL"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "reviewURL")
                      }
                    }

                    public var price: Double? {
                      get {
                        return resultMap["price"] as? Double
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "price")
                      }
                    }

                    public var header: Header? {
                      get {
                        return (resultMap["header"] as? ResultMap).flatMap { Header(unsafeResultMap: $0) }
                      }
                      set {
                        resultMap.updateValue(newValue?.resultMap, forKey: "header")
                      }
                    }

                    public var proCon: ProCon? {
                      get {
                        return (resultMap["proCon"] as? ResultMap).flatMap { ProCon(unsafeResultMap: $0) }
                      }
                      set {
                        resultMap.updateValue(newValue?.resultMap, forKey: "proCon")
                      }
                    }

                    public struct Header: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["WebProductExpertReviewHeader"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("title", type: .scalar(String.self)),
                          GraphQLField("summary", type: .scalar(String.self)),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(title: String? = nil, summary: String? = nil) {
                        self.init(unsafeResultMap: ["__typename": "WebProductExpertReviewHeader", "title": title, "summary": summary])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var title: String? {
                        get {
                          return resultMap["title"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "title")
                        }
                      }

                      public var summary: String? {
                        get {
                          return resultMap["summary"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "summary")
                        }
                      }
                    }

                    public struct ProCon: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["WebProductExpertReviewProCon"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("pros", type: .list(.nonNull(.scalar(String.self)))),
                          GraphQLField("cons", type: .list(.nonNull(.scalar(String.self)))),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(pros: [String]? = nil, cons: [String]? = nil) {
                        self.init(unsafeResultMap: ["__typename": "WebProductExpertReviewProCon", "pros": pros, "cons": cons])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var pros: [String]? {
                        get {
                          return resultMap["pros"] as? [String]
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "pros")
                        }
                      }

                      public var cons: [String]? {
                        get {
                          return resultMap["cons"] as? [String]
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "cons")
                        }
                      }
                    }
                  }

                  public struct Seller: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["SellerInfo"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("url", type: .scalar(String.self)),
                        GraphQLField("price", type: .scalar(Double.self)),
                        GraphQLField("displayName", type: .scalar(String.self)),
                        GraphQLField("providerCode", type: .scalar(String.self)),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(url: String? = nil, price: Double? = nil, displayName: String? = nil, providerCode: String? = nil) {
                      self.init(unsafeResultMap: ["__typename": "SellerInfo", "url": url, "price": price, "displayName": displayName, "providerCode": providerCode])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var url: String? {
                      get {
                        return resultMap["url"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "url")
                      }
                    }

                    public var price: Double? {
                      get {
                        return resultMap["price"] as? Double
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "price")
                      }
                    }

                    public var displayName: String? {
                      get {
                        return resultMap["displayName"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "displayName")
                      }
                    }

                    public var providerCode: String? {
                      get {
                        return resultMap["providerCode"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "providerCode")
                      }
                    }
                  }

                  public struct RetailerReview: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["WebProductReviews"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("allReviewsURL", type: .scalar(String.self)),
                        GraphQLField("provider", type: .object(Provider.selections)),
                        GraphQLField("reviews", type: .list(.nonNull(.object(Review.selections)))),
                        GraphQLField("criticalReviews", type: .list(.nonNull(.object(CriticalReview.selections)))),
                        GraphQLField("ratingSummary", type: .object(RatingSummary.selections)),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(allReviewsUrl: String? = nil, provider: Provider? = nil, reviews: [Review]? = nil, criticalReviews: [CriticalReview]? = nil, ratingSummary: RatingSummary? = nil) {
                      self.init(unsafeResultMap: ["__typename": "WebProductReviews", "allReviewsURL": allReviewsUrl, "provider": provider.flatMap { (value: Provider) -> ResultMap in value.resultMap }, "reviews": reviews.flatMap { (value: [Review]) -> [ResultMap] in value.map { (value: Review) -> ResultMap in value.resultMap } }, "criticalReviews": criticalReviews.flatMap { (value: [CriticalReview]) -> [ResultMap] in value.map { (value: CriticalReview) -> ResultMap in value.resultMap } }, "ratingSummary": ratingSummary.flatMap { (value: RatingSummary) -> ResultMap in value.resultMap }])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var allReviewsUrl: String? {
                      get {
                        return resultMap["allReviewsURL"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "allReviewsURL")
                      }
                    }

                    public var provider: Provider? {
                      get {
                        return (resultMap["provider"] as? ResultMap).flatMap { Provider(unsafeResultMap: $0) }
                      }
                      set {
                        resultMap.updateValue(newValue?.resultMap, forKey: "provider")
                      }
                    }

                    public var reviews: [Review]? {
                      get {
                        return (resultMap["reviews"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Review] in value.map { (value: ResultMap) -> Review in Review(unsafeResultMap: value) } }
                      }
                      set {
                        resultMap.updateValue(newValue.flatMap { (value: [Review]) -> [ResultMap] in value.map { (value: Review) -> ResultMap in value.resultMap } }, forKey: "reviews")
                      }
                    }

                    public var criticalReviews: [CriticalReview]? {
                      get {
                        return (resultMap["criticalReviews"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [CriticalReview] in value.map { (value: ResultMap) -> CriticalReview in CriticalReview(unsafeResultMap: value) } }
                      }
                      set {
                        resultMap.updateValue(newValue.flatMap { (value: [CriticalReview]) -> [ResultMap] in value.map { (value: CriticalReview) -> ResultMap in value.resultMap } }, forKey: "criticalReviews")
                      }
                    }

                    public var ratingSummary: RatingSummary? {
                      get {
                        return (resultMap["ratingSummary"] as? ResultMap).flatMap { RatingSummary(unsafeResultMap: $0) }
                      }
                      set {
                        resultMap.updateValue(newValue?.resultMap, forKey: "ratingSummary")
                      }
                    }

                    public struct Provider: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["ProductProvider"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("displayName", type: .scalar(String.self)),
                          GraphQLField("providerCode", type: .scalar(String.self)),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(displayName: String? = nil, providerCode: String? = nil) {
                        self.init(unsafeResultMap: ["__typename": "ProductProvider", "displayName": displayName, "providerCode": providerCode])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var displayName: String? {
                        get {
                          return resultMap["displayName"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "displayName")
                        }
                      }

                      public var providerCode: String? {
                        get {
                          return resultMap["providerCode"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "providerCode")
                        }
                      }
                    }

                    public struct Review: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["ProductReview"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("author", type: .scalar(String.self)),
                          GraphQLField("title", type: .scalar(String.self)),
                          GraphQLField("body", type: .scalar(String.self)),
                          GraphQLField("highlights", type: .list(.nonNull(.object(Highlight.selections)))),
                          GraphQLField("rating", type: .object(Rating.selections)),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(author: String? = nil, title: String? = nil, body: String? = nil, highlights: [Highlight]? = nil, rating: Rating? = nil) {
                        self.init(unsafeResultMap: ["__typename": "ProductReview", "author": author, "title": title, "body": body, "highlights": highlights.flatMap { (value: [Highlight]) -> [ResultMap] in value.map { (value: Highlight) -> ResultMap in value.resultMap } }, "rating": rating.flatMap { (value: Rating) -> ResultMap in value.resultMap }])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var author: String? {
                        get {
                          return resultMap["author"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "author")
                        }
                      }

                      public var title: String? {
                        get {
                          return resultMap["title"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "title")
                        }
                      }

                      public var body: String? {
                        get {
                          return resultMap["body"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "body")
                        }
                      }

                      public var highlights: [Highlight]? {
                        get {
                          return (resultMap["highlights"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Highlight] in value.map { (value: ResultMap) -> Highlight in Highlight(unsafeResultMap: value) } }
                        }
                        set {
                          resultMap.updateValue(newValue.flatMap { (value: [Highlight]) -> [ResultMap] in value.map { (value: Highlight) -> ResultMap in value.resultMap } }, forKey: "highlights")
                        }
                      }

                      public var rating: Rating? {
                        get {
                          return (resultMap["rating"] as? ResultMap).flatMap { Rating(unsafeResultMap: $0) }
                        }
                        set {
                          resultMap.updateValue(newValue?.resultMap, forKey: "rating")
                        }
                      }

                      public struct Highlight: GraphQLSelectionSet {
                        public static let possibleTypes: [String] = ["Snippet"]

                        public static var selections: [GraphQLSelection] {
                          return [
                            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                            GraphQLField("begin", type: .scalar(Int.self)),
                            GraphQLField("end", type: .scalar(Int.self)),
                          ]
                        }

                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                          self.resultMap = unsafeResultMap
                        }

                        public init(begin: Int? = nil, end: Int? = nil) {
                          self.init(unsafeResultMap: ["__typename": "Snippet", "begin": begin, "end": end])
                        }

                        public var __typename: String {
                          get {
                            return resultMap["__typename"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "__typename")
                          }
                        }

                        public var begin: Int? {
                          get {
                            return resultMap["begin"] as? Int
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "begin")
                          }
                        }

                        public var end: Int? {
                          get {
                            return resultMap["end"] as? Int
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "end")
                          }
                        }
                      }

                      public struct Rating: GraphQLSelectionSet {
                        public static let possibleTypes: [String] = ["ProductRating"]

                        public static var selections: [GraphQLSelection] {
                          return [
                            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                            GraphQLField("maxStars", type: .scalar(Double.self)),
                            GraphQLField("productStars", type: .scalar(Double.self)),
                          ]
                        }

                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                          self.resultMap = unsafeResultMap
                        }

                        public init(maxStars: Double? = nil, productStars: Double? = nil) {
                          self.init(unsafeResultMap: ["__typename": "ProductRating", "maxStars": maxStars, "productStars": productStars])
                        }

                        public var __typename: String {
                          get {
                            return resultMap["__typename"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "__typename")
                          }
                        }

                        public var maxStars: Double? {
                          get {
                            return resultMap["maxStars"] as? Double
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "maxStars")
                          }
                        }

                        public var productStars: Double? {
                          get {
                            return resultMap["productStars"] as? Double
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "productStars")
                          }
                        }
                      }
                    }

                    public struct CriticalReview: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["ProductReview"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("author", type: .scalar(String.self)),
                          GraphQLField("title", type: .scalar(String.self)),
                          GraphQLField("body", type: .scalar(String.self)),
                          GraphQLField("highlights", type: .list(.nonNull(.object(Highlight.selections)))),
                          GraphQLField("rating", type: .object(Rating.selections)),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(author: String? = nil, title: String? = nil, body: String? = nil, highlights: [Highlight]? = nil, rating: Rating? = nil) {
                        self.init(unsafeResultMap: ["__typename": "ProductReview", "author": author, "title": title, "body": body, "highlights": highlights.flatMap { (value: [Highlight]) -> [ResultMap] in value.map { (value: Highlight) -> ResultMap in value.resultMap } }, "rating": rating.flatMap { (value: Rating) -> ResultMap in value.resultMap }])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var author: String? {
                        get {
                          return resultMap["author"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "author")
                        }
                      }

                      public var title: String? {
                        get {
                          return resultMap["title"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "title")
                        }
                      }

                      public var body: String? {
                        get {
                          return resultMap["body"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "body")
                        }
                      }

                      public var highlights: [Highlight]? {
                        get {
                          return (resultMap["highlights"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Highlight] in value.map { (value: ResultMap) -> Highlight in Highlight(unsafeResultMap: value) } }
                        }
                        set {
                          resultMap.updateValue(newValue.flatMap { (value: [Highlight]) -> [ResultMap] in value.map { (value: Highlight) -> ResultMap in value.resultMap } }, forKey: "highlights")
                        }
                      }

                      public var rating: Rating? {
                        get {
                          return (resultMap["rating"] as? ResultMap).flatMap { Rating(unsafeResultMap: $0) }
                        }
                        set {
                          resultMap.updateValue(newValue?.resultMap, forKey: "rating")
                        }
                      }

                      public struct Highlight: GraphQLSelectionSet {
                        public static let possibleTypes: [String] = ["Snippet"]

                        public static var selections: [GraphQLSelection] {
                          return [
                            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                            GraphQLField("begin", type: .scalar(Int.self)),
                            GraphQLField("end", type: .scalar(Int.self)),
                          ]
                        }

                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                          self.resultMap = unsafeResultMap
                        }

                        public init(begin: Int? = nil, end: Int? = nil) {
                          self.init(unsafeResultMap: ["__typename": "Snippet", "begin": begin, "end": end])
                        }

                        public var __typename: String {
                          get {
                            return resultMap["__typename"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "__typename")
                          }
                        }

                        public var begin: Int? {
                          get {
                            return resultMap["begin"] as? Int
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "begin")
                          }
                        }

                        public var end: Int? {
                          get {
                            return resultMap["end"] as? Int
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "end")
                          }
                        }
                      }

                      public struct Rating: GraphQLSelectionSet {
                        public static let possibleTypes: [String] = ["ProductRating"]

                        public static var selections: [GraphQLSelection] {
                          return [
                            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                            GraphQLField("maxStars", type: .scalar(Double.self)),
                            GraphQLField("productStars", type: .scalar(Double.self)),
                          ]
                        }

                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                          self.resultMap = unsafeResultMap
                        }

                        public init(maxStars: Double? = nil, productStars: Double? = nil) {
                          self.init(unsafeResultMap: ["__typename": "ProductRating", "maxStars": maxStars, "productStars": productStars])
                        }

                        public var __typename: String {
                          get {
                            return resultMap["__typename"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "__typename")
                          }
                        }

                        public var maxStars: Double? {
                          get {
                            return resultMap["maxStars"] as? Double
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "maxStars")
                          }
                        }

                        public var productStars: Double? {
                          get {
                            return resultMap["productStars"] as? Double
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "productStars")
                          }
                        }
                      }
                    }

                    public struct RatingSummary: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["WebProductRating"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("rating", type: .object(Rating.selections)),
                          GraphQLField("numReviews", type: .scalar(Int.self)),
                          GraphQLField("price", type: .scalar(Double.self)),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(rating: Rating? = nil, numReviews: Int? = nil, price: Double? = nil) {
                        self.init(unsafeResultMap: ["__typename": "WebProductRating", "rating": rating.flatMap { (value: Rating) -> ResultMap in value.resultMap }, "numReviews": numReviews, "price": price])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var rating: Rating? {
                        get {
                          return (resultMap["rating"] as? ResultMap).flatMap { Rating(unsafeResultMap: $0) }
                        }
                        set {
                          resultMap.updateValue(newValue?.resultMap, forKey: "rating")
                        }
                      }

                      public var numReviews: Int? {
                        get {
                          return resultMap["numReviews"] as? Int
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "numReviews")
                        }
                      }

                      public var price: Double? {
                        get {
                          return resultMap["price"] as? Double
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "price")
                        }
                      }

                      public struct Rating: GraphQLSelectionSet {
                        public static let possibleTypes: [String] = ["ProductRating"]

                        public static var selections: [GraphQLSelection] {
                          return [
                            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                            GraphQLField("maxStars", type: .scalar(Double.self)),
                            GraphQLField("productStars", type: .scalar(Double.self)),
                          ]
                        }

                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                          self.resultMap = unsafeResultMap
                        }

                        public init(maxStars: Double? = nil, productStars: Double? = nil) {
                          self.init(unsafeResultMap: ["__typename": "ProductRating", "maxStars": maxStars, "productStars": productStars])
                        }

                        public var __typename: String {
                          get {
                            return resultMap["__typename"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "__typename")
                          }
                        }

                        public var maxStars: Double? {
                          get {
                            return resultMap["maxStars"] as? Double
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "maxStars")
                          }
                        }

                        public var productStars: Double? {
                          get {
                            return resultMap["productStars"] as? Double
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "productStars")
                          }
                        }
                      }
                    }
                  }
                }
              }
            }

            public var asRecipeBlock: AsRecipeBlock? {
              get {
                if !AsRecipeBlock.possibleTypes.contains(__typename) { return nil }
                return AsRecipeBlock(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsRecipeBlock: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["RecipeBlock"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("recipeBlock", type: .object(RecipeBlock.selections)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(recipeBlock: RecipeBlock? = nil) {
                self.init(unsafeResultMap: ["__typename": "RecipeBlock", "recipeBlock": recipeBlock.flatMap { (value: RecipeBlock) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var recipeBlock: RecipeBlock? {
                get {
                  return (resultMap["recipeBlock"] as? ResultMap).flatMap { RecipeBlock(unsafeResultMap: $0) }
                }
                set {
                  resultMap.updateValue(newValue?.resultMap, forKey: "recipeBlock")
                }
              }

              public struct RecipeBlock: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["RecipeBlockData"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("recipes", type: .list(.nonNull(.object(Recipe.selections)))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(recipes: [Recipe]? = nil) {
                  self.init(unsafeResultMap: ["__typename": "RecipeBlockData", "recipes": recipes.flatMap { (value: [Recipe]) -> [ResultMap] in value.map { (value: Recipe) -> ResultMap in value.resultMap } }])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var recipes: [Recipe]? {
                  get {
                    return (resultMap["recipes"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Recipe] in value.map { (value: ResultMap) -> Recipe in Recipe(unsafeResultMap: value) } }
                  }
                  set {
                    resultMap.updateValue(newValue.flatMap { (value: [Recipe]) -> [ResultMap] in value.map { (value: Recipe) -> ResultMap in value.resultMap } }, forKey: "recipes")
                  }
                }

                public struct Recipe: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["Recipe"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("title", type: .scalar(String.self)),
                      GraphQLField("url", type: .scalar(String.self)),
                      GraphQLField("imageURL", type: .scalar(String.self)),
                      GraphQLField("preference", type: .scalar(UserPreference.self)),
                      GraphQLField("totalTime", type: .scalar(String.self)),
                      GraphQLField("prepTime", type: .scalar(String.self)),
                      GraphQLField("yield", type: .scalar(String.self)),
                      GraphQLField("ingredients", type: .list(.nonNull(.object(Ingredient.selections)))),
                      GraphQLField("instructions", type: .list(.nonNull(.object(Instruction.selections)))),
                      GraphQLField("recipeRating", type: .object(RecipeRating.selections)),
                      GraphQLField("reviews", type: .list(.nonNull(.object(Review.selections)))),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(title: String? = nil, url: String? = nil, imageUrl: String? = nil, preference: UserPreference? = nil, totalTime: String? = nil, prepTime: String? = nil, yield: String? = nil, ingredients: [Ingredient]? = nil, instructions: [Instruction]? = nil, recipeRating: RecipeRating? = nil, reviews: [Review]? = nil) {
                    self.init(unsafeResultMap: ["__typename": "Recipe", "title": title, "url": url, "imageURL": imageUrl, "preference": preference, "totalTime": totalTime, "prepTime": prepTime, "yield": yield, "ingredients": ingredients.flatMap { (value: [Ingredient]) -> [ResultMap] in value.map { (value: Ingredient) -> ResultMap in value.resultMap } }, "instructions": instructions.flatMap { (value: [Instruction]) -> [ResultMap] in value.map { (value: Instruction) -> ResultMap in value.resultMap } }, "recipeRating": recipeRating.flatMap { (value: RecipeRating) -> ResultMap in value.resultMap }, "reviews": reviews.flatMap { (value: [Review]) -> [ResultMap] in value.map { (value: Review) -> ResultMap in value.resultMap } }])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var title: String? {
                    get {
                      return resultMap["title"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "title")
                    }
                  }

                  public var url: String? {
                    get {
                      return resultMap["url"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "url")
                    }
                  }

                  public var imageUrl: String? {
                    get {
                      return resultMap["imageURL"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "imageURL")
                    }
                  }

                  public var preference: UserPreference? {
                    get {
                      return resultMap["preference"] as? UserPreference
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "preference")
                    }
                  }

                  public var totalTime: String? {
                    get {
                      return resultMap["totalTime"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "totalTime")
                    }
                  }

                  public var prepTime: String? {
                    get {
                      return resultMap["prepTime"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "prepTime")
                    }
                  }

                  public var yield: String? {
                    get {
                      return resultMap["yield"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "yield")
                    }
                  }

                  public var ingredients: [Ingredient]? {
                    get {
                      return (resultMap["ingredients"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Ingredient] in value.map { (value: ResultMap) -> Ingredient in Ingredient(unsafeResultMap: value) } }
                    }
                    set {
                      resultMap.updateValue(newValue.flatMap { (value: [Ingredient]) -> [ResultMap] in value.map { (value: Ingredient) -> ResultMap in value.resultMap } }, forKey: "ingredients")
                    }
                  }

                  public var instructions: [Instruction]? {
                    get {
                      return (resultMap["instructions"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Instruction] in value.map { (value: ResultMap) -> Instruction in Instruction(unsafeResultMap: value) } }
                    }
                    set {
                      resultMap.updateValue(newValue.flatMap { (value: [Instruction]) -> [ResultMap] in value.map { (value: Instruction) -> ResultMap in value.resultMap } }, forKey: "instructions")
                    }
                  }

                  public var recipeRating: RecipeRating? {
                    get {
                      return (resultMap["recipeRating"] as? ResultMap).flatMap { RecipeRating(unsafeResultMap: $0) }
                    }
                    set {
                      resultMap.updateValue(newValue?.resultMap, forKey: "recipeRating")
                    }
                  }

                  public var reviews: [Review]? {
                    get {
                      return (resultMap["reviews"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Review] in value.map { (value: ResultMap) -> Review in Review(unsafeResultMap: value) } }
                    }
                    set {
                      resultMap.updateValue(newValue.flatMap { (value: [Review]) -> [ResultMap] in value.map { (value: Review) -> ResultMap in value.resultMap } }, forKey: "reviews")
                    }
                  }

                  public struct Ingredient: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["RecipeIngredient"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("text", type: .scalar(String.self)),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(text: String? = nil) {
                      self.init(unsafeResultMap: ["__typename": "RecipeIngredient", "text": text])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var text: String? {
                      get {
                        return resultMap["text"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "text")
                      }
                    }
                  }

                  public struct Instruction: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["RecipeInstruction"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("text", type: .scalar(String.self)),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(text: String? = nil) {
                      self.init(unsafeResultMap: ["__typename": "RecipeInstruction", "text": text])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var text: String? {
                      get {
                        return resultMap["text"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "text")
                      }
                    }
                  }

                  public struct RecipeRating: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["RecipeRating"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("maxStars", type: .scalar(Double.self)),
                        GraphQLField("recipeStars", type: .scalar(Double.self)),
                        GraphQLField("numReviews", type: .scalar(Int.self)),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(maxStars: Double? = nil, recipeStars: Double? = nil, numReviews: Int? = nil) {
                      self.init(unsafeResultMap: ["__typename": "RecipeRating", "maxStars": maxStars, "recipeStars": recipeStars, "numReviews": numReviews])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var maxStars: Double? {
                      get {
                        return resultMap["maxStars"] as? Double
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "maxStars")
                      }
                    }

                    public var recipeStars: Double? {
                      get {
                        return resultMap["recipeStars"] as? Double
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "recipeStars")
                      }
                    }

                    public var numReviews: Int? {
                      get {
                        return resultMap["numReviews"] as? Int
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "numReviews")
                      }
                    }
                  }

                  public struct Review: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["RHSWebDisplayBlockReview"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("reviewerName", type: .scalar(String.self)),
                        GraphQLField("body", type: .scalar(String.self)),
                        GraphQLField("rating", type: .object(Rating.selections)),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(reviewerName: String? = nil, body: String? = nil, rating: Rating? = nil) {
                      self.init(unsafeResultMap: ["__typename": "RHSWebDisplayBlockReview", "reviewerName": reviewerName, "body": body, "rating": rating.flatMap { (value: Rating) -> ResultMap in value.resultMap }])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var reviewerName: String? {
                      get {
                        return resultMap["reviewerName"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "reviewerName")
                      }
                    }

                    public var body: String? {
                      get {
                        return resultMap["body"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "body")
                      }
                    }

                    public var rating: Rating? {
                      get {
                        return (resultMap["rating"] as? ResultMap).flatMap { Rating(unsafeResultMap: $0) }
                      }
                      set {
                        resultMap.updateValue(newValue?.resultMap, forKey: "rating")
                      }
                    }

                    public struct Rating: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["RHSWebDisplayRating"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("maxStars", type: .scalar(Double.self)),
                          GraphQLField("actualStars", type: .scalar(Double.self)),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(maxStars: Double? = nil, actualStars: Double? = nil) {
                        self.init(unsafeResultMap: ["__typename": "RHSWebDisplayRating", "maxStars": maxStars, "actualStars": actualStars])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var maxStars: Double? {
                        get {
                          return resultMap["maxStars"] as? Double
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "maxStars")
                        }
                      }

                      public var actualStars: Double? {
                        get {
                          return resultMap["actualStars"] as? Double
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "actualStars")
                        }
                      }
                    }
                  }
                }
              }
            }

            public var asRelatedSearches: AsRelatedSearches? {
              get {
                if !AsRelatedSearches.possibleTypes.contains(__typename) { return nil }
                return AsRelatedSearches(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsRelatedSearches: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["RelatedSearches"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("relatedSearches", type: .object(RelatedSearch.selections)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(relatedSearches: RelatedSearch? = nil) {
                self.init(unsafeResultMap: ["__typename": "RelatedSearches", "relatedSearches": relatedSearches.flatMap { (value: RelatedSearch) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var relatedSearches: RelatedSearch? {
                get {
                  return (resultMap["relatedSearches"] as? ResultMap).flatMap { RelatedSearch(unsafeResultMap: $0) }
                }
                set {
                  resultMap.updateValue(newValue?.resultMap, forKey: "relatedSearches")
                }
              }

              public struct RelatedSearch: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["RelatedSearchesData"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("entries", type: .list(.nonNull(.object(Entry.selections)))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(entries: [Entry]? = nil) {
                  self.init(unsafeResultMap: ["__typename": "RelatedSearchesData", "entries": entries.flatMap { (value: [Entry]) -> [ResultMap] in value.map { (value: Entry) -> ResultMap in value.resultMap } }])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var entries: [Entry]? {
                  get {
                    return (resultMap["entries"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Entry] in value.map { (value: ResultMap) -> Entry in Entry(unsafeResultMap: value) } }
                  }
                  set {
                    resultMap.updateValue(newValue.flatMap { (value: [Entry]) -> [ResultMap] in value.map { (value: Entry) -> ResultMap in value.resultMap } }, forKey: "entries")
                  }
                }

                public struct Entry: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["RelatedSearchEntry"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("searchText", type: .scalar(String.self)),
                      GraphQLField("displayText", type: .object(DisplayText.selections)),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(searchText: String? = nil, displayText: DisplayText? = nil) {
                    self.init(unsafeResultMap: ["__typename": "RelatedSearchEntry", "searchText": searchText, "displayText": displayText.flatMap { (value: DisplayText) -> ResultMap in value.resultMap }])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var searchText: String? {
                    get {
                      return resultMap["searchText"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "searchText")
                    }
                  }

                  public var displayText: DisplayText? {
                    get {
                      return (resultMap["displayText"] as? ResultMap).flatMap { DisplayText(unsafeResultMap: $0) }
                    }
                    set {
                      resultMap.updateValue(newValue?.resultMap, forKey: "displayText")
                    }
                  }

                  public struct DisplayText: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["HighlightedText"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("segments", type: .list(.nonNull(.object(Segment.selections)))),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(segments: [Segment]? = nil) {
                      self.init(unsafeResultMap: ["__typename": "HighlightedText", "segments": segments.flatMap { (value: [Segment]) -> [ResultMap] in value.map { (value: Segment) -> ResultMap in value.resultMap } }])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var segments: [Segment]? {
                      get {
                        return (resultMap["segments"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Segment] in value.map { (value: ResultMap) -> Segment in Segment(unsafeResultMap: value) } }
                      }
                      set {
                        resultMap.updateValue(newValue.flatMap { (value: [Segment]) -> [ResultMap] in value.map { (value: Segment) -> ResultMap in value.resultMap } }, forKey: "segments")
                      }
                    }

                    public struct Segment: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["HighlightedTextSegment"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("isHighlighted", type: .scalar(Bool.self)),
                          GraphQLField("text", type: .scalar(String.self)),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(isHighlighted: Bool? = nil, text: String? = nil) {
                        self.init(unsafeResultMap: ["__typename": "HighlightedTextSegment", "isHighlighted": isHighlighted, "text": text])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var isHighlighted: Bool? {
                        get {
                          return resultMap["isHighlighted"] as? Bool
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "isHighlighted")
                        }
                      }

                      public var text: String? {
                        get {
                          return resultMap["text"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "text")
                        }
                      }
                    }
                  }
                }
              }
            }

            public var asTechDoc: AsTechDoc? {
              get {
                if !AsTechDoc.possibleTypes.contains(__typename) { return nil }
                return AsTechDoc(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsTechDoc: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["TechDoc"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("techDoc", type: .object(TechDoc.selections)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(techDoc: TechDoc? = nil) {
                self.init(unsafeResultMap: ["__typename": "TechDoc", "techDoc": techDoc.flatMap { (value: TechDoc) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var techDoc: TechDoc? {
                get {
                  return (resultMap["techDoc"] as? ResultMap).flatMap { TechDoc(unsafeResultMap: $0) }
                }
                set {
                  resultMap.updateValue(newValue?.resultMap, forKey: "techDoc")
                }
              }

              public struct TechDoc: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["TechDocData"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("name", type: .scalar(String.self)),
                    GraphQLField("actionURL", type: .scalar(String.self)),
                    GraphQLField("isCollapsed", type: .scalar(Bool.self)),
                    GraphQLField("languageID", type: .scalar(String.self)),
                    GraphQLField("useFixedWidth", type: .scalar(Bool.self)),
                    GraphQLField("poweredBy", type: .scalar(String.self)),
                    GraphQLField("domain", type: .scalar(String.self)),
                    GraphQLField("favIconURL", type: .scalar(String.self)),
                    GraphQLField("visualSpec", type: .scalar(String.self)),
                    GraphQLField("snippet", type: .object(Snippet.selections)),
                    GraphQLField("sections", type: .list(.nonNull(.object(Section.selections)))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(name: String? = nil, actionUrl: String? = nil, isCollapsed: Bool? = nil, languageId: String? = nil, useFixedWidth: Bool? = nil, poweredBy: String? = nil, domain: String? = nil, favIconUrl: String? = nil, visualSpec: String? = nil, snippet: Snippet? = nil, sections: [Section]? = nil) {
                  self.init(unsafeResultMap: ["__typename": "TechDocData", "name": name, "actionURL": actionUrl, "isCollapsed": isCollapsed, "languageID": languageId, "useFixedWidth": useFixedWidth, "poweredBy": poweredBy, "domain": domain, "favIconURL": favIconUrl, "visualSpec": visualSpec, "snippet": snippet.flatMap { (value: Snippet) -> ResultMap in value.resultMap }, "sections": sections.flatMap { (value: [Section]) -> [ResultMap] in value.map { (value: Section) -> ResultMap in value.resultMap } }])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var name: String? {
                  get {
                    return resultMap["name"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "name")
                  }
                }

                public var actionUrl: String? {
                  get {
                    return resultMap["actionURL"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "actionURL")
                  }
                }

                public var isCollapsed: Bool? {
                  get {
                    return resultMap["isCollapsed"] as? Bool
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "isCollapsed")
                  }
                }

                public var languageId: String? {
                  get {
                    return resultMap["languageID"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "languageID")
                  }
                }

                public var useFixedWidth: Bool? {
                  get {
                    return resultMap["useFixedWidth"] as? Bool
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "useFixedWidth")
                  }
                }

                public var poweredBy: String? {
                  get {
                    return resultMap["poweredBy"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "poweredBy")
                  }
                }

                public var domain: String? {
                  get {
                    return resultMap["domain"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "domain")
                  }
                }

                public var favIconUrl: String? {
                  get {
                    return resultMap["favIconURL"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "favIconURL")
                  }
                }

                public var visualSpec: String? {
                  get {
                    return resultMap["visualSpec"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "visualSpec")
                  }
                }

                public var snippet: Snippet? {
                  get {
                    return (resultMap["snippet"] as? ResultMap).flatMap { Snippet(unsafeResultMap: $0) }
                  }
                  set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "snippet")
                  }
                }

                public var sections: [Section]? {
                  get {
                    return (resultMap["sections"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Section] in value.map { (value: ResultMap) -> Section in Section(unsafeResultMap: value) } }
                  }
                  set {
                    resultMap.updateValue(newValue.flatMap { (value: [Section]) -> [ResultMap] in value.map { (value: Section) -> ResultMap in value.resultMap } }, forKey: "sections")
                  }
                }

                public struct Snippet: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["TechDocSection"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("name", type: .scalar(String.self)),
                      GraphQLField("body", type: .scalar(String.self)),
                      GraphQLField("url", type: .scalar(String.self)),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(name: String? = nil, body: String? = nil, url: String? = nil) {
                    self.init(unsafeResultMap: ["__typename": "TechDocSection", "name": name, "body": body, "url": url])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var name: String? {
                    get {
                      return resultMap["name"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "name")
                    }
                  }

                  public var body: String? {
                    get {
                      return resultMap["body"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "body")
                    }
                  }

                  public var url: String? {
                    get {
                      return resultMap["url"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "url")
                    }
                  }
                }

                public struct Section: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["TechDocSection"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("name", type: .scalar(String.self)),
                      GraphQLField("rhsTitle", type: .scalar(String.self)),
                      GraphQLField("body", type: .scalar(String.self)),
                      GraphQLField("url", type: .scalar(String.self)),
                      GraphQLField("votes", type: .scalar(Double.self)),
                      GraphQLField("subsections", type: .list(.nonNull(.object(Subsection.selections)))),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(name: String? = nil, rhsTitle: String? = nil, body: String? = nil, url: String? = nil, votes: Double? = nil, subsections: [Subsection]? = nil) {
                    self.init(unsafeResultMap: ["__typename": "TechDocSection", "name": name, "rhsTitle": rhsTitle, "body": body, "url": url, "votes": votes, "subsections": subsections.flatMap { (value: [Subsection]) -> [ResultMap] in value.map { (value: Subsection) -> ResultMap in value.resultMap } }])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var name: String? {
                    get {
                      return resultMap["name"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "name")
                    }
                  }

                  public var rhsTitle: String? {
                    get {
                      return resultMap["rhsTitle"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "rhsTitle")
                    }
                  }

                  public var body: String? {
                    get {
                      return resultMap["body"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "body")
                    }
                  }

                  public var url: String? {
                    get {
                      return resultMap["url"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "url")
                    }
                  }

                  public var votes: Double? {
                    get {
                      return resultMap["votes"] as? Double
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "votes")
                    }
                  }

                  public var subsections: [Subsection]? {
                    get {
                      return (resultMap["subsections"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Subsection] in value.map { (value: ResultMap) -> Subsection in Subsection(unsafeResultMap: value) } }
                    }
                    set {
                      resultMap.updateValue(newValue.flatMap { (value: [Subsection]) -> [ResultMap] in value.map { (value: Subsection) -> ResultMap in value.resultMap } }, forKey: "subsections")
                    }
                  }

                  public struct Subsection: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["TechDocSubsection"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("name", type: .scalar(String.self)),
                        GraphQLField("body", type: .scalar(String.self)),
                        GraphQLField("url", type: .scalar(String.self)),
                        GraphQLField("metadata", type: .list(.nonNull(.object(Metadatum.selections)))),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(name: String? = nil, body: String? = nil, url: String? = nil, metadata: [Metadatum]? = nil) {
                      self.init(unsafeResultMap: ["__typename": "TechDocSubsection", "name": name, "body": body, "url": url, "metadata": metadata.flatMap { (value: [Metadatum]) -> [ResultMap] in value.map { (value: Metadatum) -> ResultMap in value.resultMap } }])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var name: String? {
                      get {
                        return resultMap["name"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "name")
                      }
                    }

                    public var body: String? {
                      get {
                        return resultMap["body"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "body")
                      }
                    }

                    public var url: String? {
                      get {
                        return resultMap["url"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "url")
                      }
                    }

                    public var metadata: [Metadatum]? {
                      get {
                        return (resultMap["metadata"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Metadatum] in value.map { (value: ResultMap) -> Metadatum in Metadatum(unsafeResultMap: value) } }
                      }
                      set {
                        resultMap.updateValue(newValue.flatMap { (value: [Metadatum]) -> [ResultMap] in value.map { (value: Metadatum) -> ResultMap in value.resultMap } }, forKey: "metadata")
                      }
                    }

                    public struct Metadatum: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["TechDocMetadata"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("text", type: .scalar(String.self)),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(text: String? = nil) {
                        self.init(unsafeResultMap: ["__typename": "TechDocMetadata", "text": text])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var text: String? {
                        get {
                          return resultMap["text"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "text")
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

public final class ListSpacesQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query ListSpaces($kind: ListSpacesKind = All) {
      listSpaces(input: {kind: $kind}) {
        __typename
        requestID
        space {
          __typename
          pageMetadata {
            __typename
            pageID
          }
          space {
            __typename
            name
            lastModifiedTs
            notifications(input: {kind: HomeFeed}) {
              __typename
              type
              timestamp
              data {
                __typename
                ... on NotificationSpaceSharedWithYou {
                  __typename
                  sharedBy {
                    __typename
                    displayName
                    email
                    pictureURL
                  }
                }
                ... on NotificationSpaceEntitiesAdded {
                  __typename
                  addedBy {
                    __typename
                    displayName
                    email
                    pictureURL
                  }
                  itemID
                }
                ... on NotificationSpaceCommentsAdded {
                  __typename
                  addedBy {
                    __typename
                    displayName
                    email
                    pictureURL
                  }
                }
              }
            }
            userACL {
              __typename
              acl
            }
            acl {
              __typename
              userID
              profile {
                __typename
                displayName
                email
                pictureURL
              }
              acl
            }
            hasPublicACL
            thumbnail
            thumbnailSize {
              __typename
              height
              width
            }
            resultCount
            isDefaultSpace
          }
        }
      }
    }
    """

  public let operationName: String = "ListSpaces"

  public let operationIdentifier: String? = "6fb0d3b619a8b5e35dc213af1a0daf03fe7a20c3580f352e11f8b6aff2e5d2f3"

  public var kind: ListSpacesKind?

  public init(kind: ListSpacesKind? = nil) {
    self.kind = kind
  }

  public var variables: GraphQLMap? {
    return ["kind": kind]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("listSpaces", arguments: ["input": ["kind": GraphQLVariable("kind")]], type: .object(ListSpace.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(listSpaces: ListSpace? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "listSpaces": listSpaces.flatMap { (value: ListSpace) -> ResultMap in value.resultMap }])
    }

    /// List spaces accessible to the user of the given kind.
    /// Entites and comments are elided from the returned space list.
    public var listSpaces: ListSpace? {
      get {
        return (resultMap["listSpaces"] as? ResultMap).flatMap { ListSpace(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "listSpaces")
      }
    }

    public struct ListSpace: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["SpaceList"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("requestID", type: .nonNull(.scalar(String.self))),
          GraphQLField("space", type: .nonNull(.list(.nonNull(.object(Space.selections))))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(requestId: String, space: [Space]) {
        self.init(unsafeResultMap: ["__typename": "SpaceList", "requestID": requestId, "space": space.map { (value: Space) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var requestId: String {
        get {
          return resultMap["requestID"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "requestID")
        }
      }

      public var space: [Space] {
        get {
          return (resultMap["space"] as! [ResultMap]).map { (value: ResultMap) -> Space in Space(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Space) -> ResultMap in value.resultMap }, forKey: "space")
        }
      }

      public struct Space: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Space"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("pageMetadata", type: .object(PageMetadatum.selections)),
            GraphQLField("space", type: .object(Space.selections)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(pageMetadata: PageMetadatum? = nil, space: Space? = nil) {
          self.init(unsafeResultMap: ["__typename": "Space", "pageMetadata": pageMetadata.flatMap { (value: PageMetadatum) -> ResultMap in value.resultMap }, "space": space.flatMap { (value: Space) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var pageMetadata: PageMetadatum? {
          get {
            return (resultMap["pageMetadata"] as? ResultMap).flatMap { PageMetadatum(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "pageMetadata")
          }
        }

        public var space: Space? {
          get {
            return (resultMap["space"] as? ResultMap).flatMap { Space(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "space")
          }
        }

        public struct PageMetadatum: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["PageMetadata"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("pageID", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(pageId: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "PageMetadata", "pageID": pageId])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// An optional identifier for the page.
          public var pageId: String? {
            get {
              return resultMap["pageID"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "pageID")
            }
          }
        }

        public struct Space: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["SpaceData"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("lastModifiedTs", type: .scalar(String.self)),
              GraphQLField("notifications", arguments: ["input": ["kind": "HomeFeed"]], type: .list(.nonNull(.object(Notification.selections)))),
              GraphQLField("userACL", type: .object(UserAcl.selections)),
              GraphQLField("acl", type: .list(.nonNull(.object(Acl.selections)))),
              GraphQLField("hasPublicACL", type: .scalar(Bool.self)),
              GraphQLField("thumbnail", type: .scalar(String.self)),
              GraphQLField("thumbnailSize", type: .object(ThumbnailSize.selections)),
              GraphQLField("resultCount", type: .scalar(Int.self)),
              GraphQLField("isDefaultSpace", type: .scalar(Bool.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(name: String? = nil, lastModifiedTs: String? = nil, notifications: [Notification]? = nil, userAcl: UserAcl? = nil, acl: [Acl]? = nil, hasPublicAcl: Bool? = nil, thumbnail: String? = nil, thumbnailSize: ThumbnailSize? = nil, resultCount: Int? = nil, isDefaultSpace: Bool? = nil) {
            self.init(unsafeResultMap: ["__typename": "SpaceData", "name": name, "lastModifiedTs": lastModifiedTs, "notifications": notifications.flatMap { (value: [Notification]) -> [ResultMap] in value.map { (value: Notification) -> ResultMap in value.resultMap } }, "userACL": userAcl.flatMap { (value: UserAcl) -> ResultMap in value.resultMap }, "acl": acl.flatMap { (value: [Acl]) -> [ResultMap] in value.map { (value: Acl) -> ResultMap in value.resultMap } }, "hasPublicACL": hasPublicAcl, "thumbnail": thumbnail, "thumbnailSize": thumbnailSize.flatMap { (value: ThumbnailSize) -> ResultMap in value.resultMap }, "resultCount": resultCount, "isDefaultSpace": isDefaultSpace])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }

          public var lastModifiedTs: String? {
            get {
              return resultMap["lastModifiedTs"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "lastModifiedTs")
            }
          }

          public var notifications: [Notification]? {
            get {
              return (resultMap["notifications"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Notification] in value.map { (value: ResultMap) -> Notification in Notification(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Notification]) -> [ResultMap] in value.map { (value: Notification) -> ResultMap in value.resultMap } }, forKey: "notifications")
            }
          }

          public var userAcl: UserAcl? {
            get {
              return (resultMap["userACL"] as? ResultMap).flatMap { UserAcl(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "userACL")
            }
          }

          public var acl: [Acl]? {
            get {
              return (resultMap["acl"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Acl] in value.map { (value: ResultMap) -> Acl in Acl(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Acl]) -> [ResultMap] in value.map { (value: Acl) -> ResultMap in value.resultMap } }, forKey: "acl")
            }
          }

          public var hasPublicAcl: Bool? {
            get {
              return resultMap["hasPublicACL"] as? Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "hasPublicACL")
            }
          }

          public var thumbnail: String? {
            get {
              return resultMap["thumbnail"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "thumbnail")
            }
          }

          public var thumbnailSize: ThumbnailSize? {
            get {
              return (resultMap["thumbnailSize"] as? ResultMap).flatMap { ThumbnailSize(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "thumbnailSize")
            }
          }

          public var resultCount: Int? {
            get {
              return resultMap["resultCount"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "resultCount")
            }
          }

          public var isDefaultSpace: Bool? {
            get {
              return resultMap["isDefaultSpace"] as? Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "isDefaultSpace")
            }
          }

          public struct Notification: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Notification"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("type", type: .scalar(NotificationType.self)),
                GraphQLField("timestamp", type: .scalar(String.self)),
                GraphQLField("data", type: .object(Datum.selections)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(type: NotificationType? = nil, timestamp: String? = nil, data: Datum? = nil) {
              self.init(unsafeResultMap: ["__typename": "Notification", "type": type, "timestamp": timestamp, "data": data.flatMap { (value: Datum) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// The type of activity corresponding to the notification.
            public var type: NotificationType? {
              get {
                return resultMap["type"] as? NotificationType
              }
              set {
                resultMap.updateValue(newValue, forKey: "type")
              }
            }

            /// Typically corresponds to the time of the underlying activity which triggered
            /// the notification. Formatted as RFC 3339 date/time.
            public var timestamp: String? {
              get {
                return resultMap["timestamp"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "timestamp")
              }
            }

            /// Additional type-specific data corresponding to the notification.
            public var data: Datum? {
              get {
                return (resultMap["data"] as? ResultMap).flatMap { Datum(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "data")
              }
            }

            public struct Datum: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["NotificationSpaceSharedWithYou", "NotificationSpaceEntitiesAdded", "NotificationSpaceCommentsAdded"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLTypeCase(
                    variants: ["NotificationSpaceSharedWithYou": AsNotificationSpaceSharedWithYou.selections, "NotificationSpaceEntitiesAdded": AsNotificationSpaceEntitiesAdded.selections, "NotificationSpaceCommentsAdded": AsNotificationSpaceCommentsAdded.selections],
                    default: [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    ]
                  )
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public static func makeNotificationSpaceSharedWithYou(sharedBy: AsNotificationSpaceSharedWithYou.SharedBy? = nil) -> Datum {
                return Datum(unsafeResultMap: ["__typename": "NotificationSpaceSharedWithYou", "sharedBy": sharedBy.flatMap { (value: AsNotificationSpaceSharedWithYou.SharedBy) -> ResultMap in value.resultMap }])
              }

              public static func makeNotificationSpaceEntitiesAdded(addedBy: AsNotificationSpaceEntitiesAdded.AddedBy? = nil, itemId: String? = nil) -> Datum {
                return Datum(unsafeResultMap: ["__typename": "NotificationSpaceEntitiesAdded", "addedBy": addedBy.flatMap { (value: AsNotificationSpaceEntitiesAdded.AddedBy) -> ResultMap in value.resultMap }, "itemID": itemId])
              }

              public static func makeNotificationSpaceCommentsAdded(addedBy: AsNotificationSpaceCommentsAdded.AddedBy? = nil) -> Datum {
                return Datum(unsafeResultMap: ["__typename": "NotificationSpaceCommentsAdded", "addedBy": addedBy.flatMap { (value: AsNotificationSpaceCommentsAdded.AddedBy) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var asNotificationSpaceSharedWithYou: AsNotificationSpaceSharedWithYou? {
                get {
                  if !AsNotificationSpaceSharedWithYou.possibleTypes.contains(__typename) { return nil }
                  return AsNotificationSpaceSharedWithYou(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsNotificationSpaceSharedWithYou: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["NotificationSpaceSharedWithYou"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("sharedBy", type: .object(SharedBy.selections)),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(sharedBy: SharedBy? = nil) {
                  self.init(unsafeResultMap: ["__typename": "NotificationSpaceSharedWithYou", "sharedBy": sharedBy.flatMap { (value: SharedBy) -> ResultMap in value.resultMap }])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var sharedBy: SharedBy? {
                  get {
                    return (resultMap["sharedBy"] as? ResultMap).flatMap { SharedBy(unsafeResultMap: $0) }
                  }
                  set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "sharedBy")
                  }
                }

                public struct SharedBy: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["Profile"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("displayName", type: .nonNull(.scalar(String.self))),
                      GraphQLField("email", type: .nonNull(.scalar(String.self))),
                      GraphQLField("pictureURL", type: .nonNull(.scalar(String.self))),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(displayName: String, email: String, pictureUrl: String) {
                    self.init(unsafeResultMap: ["__typename": "Profile", "displayName": displayName, "email": email, "pictureURL": pictureUrl])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var displayName: String {
                    get {
                      return resultMap["displayName"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "displayName")
                    }
                  }

                  public var email: String {
                    get {
                      return resultMap["email"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "email")
                    }
                  }

                  public var pictureUrl: String {
                    get {
                      return resultMap["pictureURL"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "pictureURL")
                    }
                  }
                }
              }

              public var asNotificationSpaceEntitiesAdded: AsNotificationSpaceEntitiesAdded? {
                get {
                  if !AsNotificationSpaceEntitiesAdded.possibleTypes.contains(__typename) { return nil }
                  return AsNotificationSpaceEntitiesAdded(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsNotificationSpaceEntitiesAdded: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["NotificationSpaceEntitiesAdded"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("addedBy", type: .object(AddedBy.selections)),
                    GraphQLField("itemID", type: .scalar(String.self)),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(addedBy: AddedBy? = nil, itemId: String? = nil) {
                  self.init(unsafeResultMap: ["__typename": "NotificationSpaceEntitiesAdded", "addedBy": addedBy.flatMap { (value: AddedBy) -> ResultMap in value.resultMap }, "itemID": itemId])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var addedBy: AddedBy? {
                  get {
                    return (resultMap["addedBy"] as? ResultMap).flatMap { AddedBy(unsafeResultMap: $0) }
                  }
                  set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "addedBy")
                  }
                }

                public var itemId: String? {
                  get {
                    return resultMap["itemID"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "itemID")
                  }
                }

                public struct AddedBy: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["Profile"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("displayName", type: .nonNull(.scalar(String.self))),
                      GraphQLField("email", type: .nonNull(.scalar(String.self))),
                      GraphQLField("pictureURL", type: .nonNull(.scalar(String.self))),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(displayName: String, email: String, pictureUrl: String) {
                    self.init(unsafeResultMap: ["__typename": "Profile", "displayName": displayName, "email": email, "pictureURL": pictureUrl])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var displayName: String {
                    get {
                      return resultMap["displayName"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "displayName")
                    }
                  }

                  public var email: String {
                    get {
                      return resultMap["email"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "email")
                    }
                  }

                  public var pictureUrl: String {
                    get {
                      return resultMap["pictureURL"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "pictureURL")
                    }
                  }
                }
              }

              public var asNotificationSpaceCommentsAdded: AsNotificationSpaceCommentsAdded? {
                get {
                  if !AsNotificationSpaceCommentsAdded.possibleTypes.contains(__typename) { return nil }
                  return AsNotificationSpaceCommentsAdded(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsNotificationSpaceCommentsAdded: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["NotificationSpaceCommentsAdded"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("addedBy", type: .object(AddedBy.selections)),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(addedBy: AddedBy? = nil) {
                  self.init(unsafeResultMap: ["__typename": "NotificationSpaceCommentsAdded", "addedBy": addedBy.flatMap { (value: AddedBy) -> ResultMap in value.resultMap }])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var addedBy: AddedBy? {
                  get {
                    return (resultMap["addedBy"] as? ResultMap).flatMap { AddedBy(unsafeResultMap: $0) }
                  }
                  set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "addedBy")
                  }
                }

                public struct AddedBy: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["Profile"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("displayName", type: .nonNull(.scalar(String.self))),
                      GraphQLField("email", type: .nonNull(.scalar(String.self))),
                      GraphQLField("pictureURL", type: .nonNull(.scalar(String.self))),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(displayName: String, email: String, pictureUrl: String) {
                    self.init(unsafeResultMap: ["__typename": "Profile", "displayName": displayName, "email": email, "pictureURL": pictureUrl])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var displayName: String {
                    get {
                      return resultMap["displayName"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "displayName")
                    }
                  }

                  public var email: String {
                    get {
                      return resultMap["email"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "email")
                    }
                  }

                  public var pictureUrl: String {
                    get {
                      return resultMap["pictureURL"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "pictureURL")
                    }
                  }
                }
              }
            }
          }

          public struct UserAcl: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["SpaceACL"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("acl", type: .nonNull(.scalar(SpaceACLLevel.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(acl: SpaceACLLevel) {
              self.init(unsafeResultMap: ["__typename": "SpaceACL", "acl": acl])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var acl: SpaceACLLevel {
              get {
                return resultMap["acl"]! as! SpaceACLLevel
              }
              set {
                resultMap.updateValue(newValue, forKey: "acl")
              }
            }
          }

          public struct Acl: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["SpaceACL"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("userID", type: .nonNull(.scalar(String.self))),
                GraphQLField("profile", type: .nonNull(.object(Profile.selections))),
                GraphQLField("acl", type: .nonNull(.scalar(SpaceACLLevel.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(userId: String, profile: Profile, acl: SpaceACLLevel) {
              self.init(unsafeResultMap: ["__typename": "SpaceACL", "userID": userId, "profile": profile.resultMap, "acl": acl])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var userId: String {
              get {
                return resultMap["userID"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "userID")
              }
            }

            public var profile: Profile {
              get {
                return Profile(unsafeResultMap: resultMap["profile"]! as! ResultMap)
              }
              set {
                resultMap.updateValue(newValue.resultMap, forKey: "profile")
              }
            }

            public var acl: SpaceACLLevel {
              get {
                return resultMap["acl"]! as! SpaceACLLevel
              }
              set {
                resultMap.updateValue(newValue, forKey: "acl")
              }
            }

            public struct Profile: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["Profile"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("displayName", type: .nonNull(.scalar(String.self))),
                  GraphQLField("email", type: .nonNull(.scalar(String.self))),
                  GraphQLField("pictureURL", type: .nonNull(.scalar(String.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(displayName: String, email: String, pictureUrl: String) {
                self.init(unsafeResultMap: ["__typename": "Profile", "displayName": displayName, "email": email, "pictureURL": pictureUrl])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var displayName: String {
                get {
                  return resultMap["displayName"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "displayName")
                }
              }

              public var email: String {
                get {
                  return resultMap["email"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "email")
                }
              }

              public var pictureUrl: String {
                get {
                  return resultMap["pictureURL"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "pictureURL")
                }
              }
            }
          }

          public struct ThumbnailSize: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["ThumbnailSize"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("height", type: .nonNull(.scalar(Int.self))),
                GraphQLField("width", type: .nonNull(.scalar(Int.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(height: Int, width: Int) {
              self.init(unsafeResultMap: ["__typename": "ThumbnailSize", "height": height, "width": width])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var height: Int {
              get {
                return resultMap["height"]! as! Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "height")
              }
            }

            public var width: Int {
              get {
                return resultMap["width"]! as! Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "width")
              }
            }
          }
        }
      }
    }
  }
}

public final class GetSpacesTitleInfoQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query GetSpacesTitleInfo($ids: [String!]) {
      getSpace(input: {ids: $ids}) {
        __typename
        space {
          __typename
          pageMetadata {
            __typename
            pageID
          }
          space {
            __typename
            name
            thumbnail
          }
        }
      }
    }
    """

  public let operationName: String = "GetSpacesTitleInfo"

  public let operationIdentifier: String? = "9896da35094ebeef83c08e0f589fe4c74b45ba292c2e98c6afa3161cad842f63"

  public var ids: [String]?

  public init(ids: [String]?) {
    self.ids = ids
  }

  public var variables: GraphQLMap? {
    return ["ids": ids]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("getSpace", arguments: ["input": ["ids": GraphQLVariable("ids")]], type: .object(GetSpace.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(getSpace: GetSpace? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "getSpace": getSpace.flatMap { (value: GetSpace) -> ResultMap in value.resultMap }])
    }

    /// Get full details for specific space.
    /// This returns a space list in case we support getting multiple spaces in the future.
    public var getSpace: GetSpace? {
      get {
        return (resultMap["getSpace"] as? ResultMap).flatMap { GetSpace(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "getSpace")
      }
    }

    public struct GetSpace: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["SpaceList"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("space", type: .nonNull(.list(.nonNull(.object(Space.selections))))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(space: [Space]) {
        self.init(unsafeResultMap: ["__typename": "SpaceList", "space": space.map { (value: Space) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var space: [Space] {
        get {
          return (resultMap["space"] as! [ResultMap]).map { (value: ResultMap) -> Space in Space(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Space) -> ResultMap in value.resultMap }, forKey: "space")
        }
      }

      public struct Space: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Space"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("pageMetadata", type: .object(PageMetadatum.selections)),
            GraphQLField("space", type: .object(Space.selections)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(pageMetadata: PageMetadatum? = nil, space: Space? = nil) {
          self.init(unsafeResultMap: ["__typename": "Space", "pageMetadata": pageMetadata.flatMap { (value: PageMetadatum) -> ResultMap in value.resultMap }, "space": space.flatMap { (value: Space) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var pageMetadata: PageMetadatum? {
          get {
            return (resultMap["pageMetadata"] as? ResultMap).flatMap { PageMetadatum(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "pageMetadata")
          }
        }

        public var space: Space? {
          get {
            return (resultMap["space"] as? ResultMap).flatMap { Space(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "space")
          }
        }

        public struct PageMetadatum: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["PageMetadata"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("pageID", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(pageId: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "PageMetadata", "pageID": pageId])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// An optional identifier for the page.
          public var pageId: String? {
            get {
              return resultMap["pageID"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "pageID")
            }
          }
        }

        public struct Space: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["SpaceData"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("thumbnail", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(name: String? = nil, thumbnail: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "SpaceData", "name": name, "thumbnail": thumbnail])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }

          public var thumbnail: String? {
            get {
              return resultMap["thumbnail"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "thumbnail")
            }
          }
        }
      }
    }
  }
}

public final class GetSpacesDataQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query GetSpacesData($ids: [String!]) {
      getSpace(input: {ids: $ids}) {
        __typename
        space {
          __typename
          stats {
            __typename
            followers
            views
          }
          pageMetadata {
            __typename
            pageID
          }
          space {
            __typename
            name
            description
            generators {
              __typename
              id
              params
            }
            comments {
              __typename
              id
              profile {
                __typename
                displayName
                pictureURL
              }
              createdTs
              comment
            }
            entities {
              __typename
              metadata {
                __typename
                docID
              }
              spaceEntity {
                __typename
                url
                title
                snippet
                thumbnail
                generator {
                  __typename
                  id
                }
                content {
                  __typename
                  id
                  title
                  snippet
                  typeSpecific {
                    __typename
                    ... on TechDoc {
                      __typename
                      techDoc {
                        __typename
                        name
                        sections {
                          __typename
                          body
                        }
                      }
                    }
                    ... on NewsItem {
                      __typename
                      newsItem {
                        __typename
                        title
                        snippet
                        url
                        thumbnailImage {
                          __typename
                          url
                        }
                        providerName
                        datePublished
                        favIconURL
                        preference
                        domain
                      }
                    }
                    ... on Web {
                      __typename
                      web {
                        __typename
                        retailerProduct {
                          __typename
                          url
                          name
                          description
                          priceHistory {
                            __typename
                            currentPrice
                          }
                          reviews {
                            __typename
                            ratingSummary {
                              __typename
                              numReviews
                              rating {
                                __typename
                                productStars
                              }
                            }
                          }
                        }
                        recipes {
                          __typename
                          title
                          imageURL
                          source
                          totalTime
                          recipeRating {
                            __typename
                            recipeStars
                            numReviews
                          }
                        }
                      }
                    }
                    ... on RichEntity {
                      __typename
                      richEntity {
                        __typename
                        images {
                          __typename
                          thumbnailURL
                        }
                        title
                        subTitle
                      }
                    }
                  }
                  actionURL
                }
              }
            }
          }
        }
      }
    }
    """

  public let operationName: String = "GetSpacesData"

  public let operationIdentifier: String? = "d724476184f95e68a1c3a97e11a29bf7b29151147d63823279932c1462b2100a"

  public var ids: [String]?

  public init(ids: [String]?) {
    self.ids = ids
  }

  public var variables: GraphQLMap? {
    return ["ids": ids]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("getSpace", arguments: ["input": ["ids": GraphQLVariable("ids")]], type: .object(GetSpace.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(getSpace: GetSpace? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "getSpace": getSpace.flatMap { (value: GetSpace) -> ResultMap in value.resultMap }])
    }

    /// Get full details for specific space.
    /// This returns a space list in case we support getting multiple spaces in the future.
    public var getSpace: GetSpace? {
      get {
        return (resultMap["getSpace"] as? ResultMap).flatMap { GetSpace(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "getSpace")
      }
    }

    public struct GetSpace: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["SpaceList"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("space", type: .nonNull(.list(.nonNull(.object(Space.selections))))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(space: [Space]) {
        self.init(unsafeResultMap: ["__typename": "SpaceList", "space": space.map { (value: Space) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var space: [Space] {
        get {
          return (resultMap["space"] as! [ResultMap]).map { (value: ResultMap) -> Space in Space(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Space) -> ResultMap in value.resultMap }, forKey: "space")
        }
      }

      public struct Space: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Space"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("stats", type: .object(Stat.selections)),
            GraphQLField("pageMetadata", type: .object(PageMetadatum.selections)),
            GraphQLField("space", type: .object(Space.selections)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(stats: Stat? = nil, pageMetadata: PageMetadatum? = nil, space: Space? = nil) {
          self.init(unsafeResultMap: ["__typename": "Space", "stats": stats.flatMap { (value: Stat) -> ResultMap in value.resultMap }, "pageMetadata": pageMetadata.flatMap { (value: PageMetadatum) -> ResultMap in value.resultMap }, "space": space.flatMap { (value: Space) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var stats: Stat? {
          get {
            return (resultMap["stats"] as? ResultMap).flatMap { Stat(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "stats")
          }
        }

        public var pageMetadata: PageMetadatum? {
          get {
            return (resultMap["pageMetadata"] as? ResultMap).flatMap { PageMetadatum(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "pageMetadata")
          }
        }

        public var space: Space? {
          get {
            return (resultMap["space"] as? ResultMap).flatMap { Space(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "space")
          }
        }

        public struct Stat: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["SpaceStats"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("followers", type: .scalar(Int.self)),
              GraphQLField("views", type: .scalar(Int.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(followers: Int? = nil, views: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "SpaceStats", "followers": followers, "views": views])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var followers: Int? {
            get {
              return resultMap["followers"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "followers")
            }
          }

          public var views: Int? {
            get {
              return resultMap["views"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "views")
            }
          }
        }

        public struct PageMetadatum: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["PageMetadata"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("pageID", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(pageId: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "PageMetadata", "pageID": pageId])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// An optional identifier for the page.
          public var pageId: String? {
            get {
              return resultMap["pageID"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "pageID")
            }
          }
        }

        public struct Space: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["SpaceData"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("name", type: .scalar(String.self)),
              GraphQLField("description", type: .scalar(String.self)),
              GraphQLField("generators", type: .list(.nonNull(.object(Generator.selections)))),
              GraphQLField("comments", type: .list(.nonNull(.object(Comment.selections)))),
              GraphQLField("entities", type: .list(.nonNull(.object(Entity.selections)))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(name: String? = nil, description: String? = nil, generators: [Generator]? = nil, comments: [Comment]? = nil, entities: [Entity]? = nil) {
            self.init(unsafeResultMap: ["__typename": "SpaceData", "name": name, "description": description, "generators": generators.flatMap { (value: [Generator]) -> [ResultMap] in value.map { (value: Generator) -> ResultMap in value.resultMap } }, "comments": comments.flatMap { (value: [Comment]) -> [ResultMap] in value.map { (value: Comment) -> ResultMap in value.resultMap } }, "entities": entities.flatMap { (value: [Entity]) -> [ResultMap] in value.map { (value: Entity) -> ResultMap in value.resultMap } }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var name: String? {
            get {
              return resultMap["name"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }

          public var description: String? {
            get {
              return resultMap["description"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "description")
            }
          }

          public var generators: [Generator]? {
            get {
              return (resultMap["generators"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Generator] in value.map { (value: ResultMap) -> Generator in Generator(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Generator]) -> [ResultMap] in value.map { (value: Generator) -> ResultMap in value.resultMap } }, forKey: "generators")
            }
          }

          public var comments: [Comment]? {
            get {
              return (resultMap["comments"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Comment] in value.map { (value: ResultMap) -> Comment in Comment(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Comment]) -> [ResultMap] in value.map { (value: Comment) -> ResultMap in value.resultMap } }, forKey: "comments")
            }
          }

          public var entities: [Entity]? {
            get {
              return (resultMap["entities"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Entity] in value.map { (value: ResultMap) -> Entity in Entity(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Entity]) -> [ResultMap] in value.map { (value: Entity) -> ResultMap in value.resultMap } }, forKey: "entities")
            }
          }

          public struct Generator: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["SpaceGenerator"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("id", type: .nonNull(.scalar(String.self))),
                GraphQLField("params", type: .scalar(String.self)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: String, params: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "SpaceGenerator", "id": id, "params": params])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: String {
              get {
                return resultMap["id"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "id")
              }
            }

            public var params: String? {
              get {
                return resultMap["params"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "params")
              }
            }
          }

          public struct Comment: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["SpaceCommentData"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("id", type: .scalar(String.self)),
                GraphQLField("profile", type: .object(Profile.selections)),
                GraphQLField("createdTs", type: .scalar(String.self)),
                GraphQLField("comment", type: .scalar(String.self)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: String? = nil, profile: Profile? = nil, createdTs: String? = nil, comment: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "SpaceCommentData", "id": id, "profile": profile.flatMap { (value: Profile) -> ResultMap in value.resultMap }, "createdTs": createdTs, "comment": comment])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: String? {
              get {
                return resultMap["id"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "id")
              }
            }

            public var profile: Profile? {
              get {
                return (resultMap["profile"] as? ResultMap).flatMap { Profile(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "profile")
              }
            }

            public var createdTs: String? {
              get {
                return resultMap["createdTs"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "createdTs")
              }
            }

            public var comment: String? {
              get {
                return resultMap["comment"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "comment")
              }
            }

            public struct Profile: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["Profile"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("displayName", type: .nonNull(.scalar(String.self))),
                  GraphQLField("pictureURL", type: .nonNull(.scalar(String.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(displayName: String, pictureUrl: String) {
                self.init(unsafeResultMap: ["__typename": "Profile", "displayName": displayName, "pictureURL": pictureUrl])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var displayName: String {
                get {
                  return resultMap["displayName"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "displayName")
                }
              }

              public var pictureUrl: String {
                get {
                  return resultMap["pictureURL"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "pictureURL")
                }
              }
            }
          }

          public struct Entity: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["SpaceEntity"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("metadata", type: .object(Metadatum.selections)),
                GraphQLField("spaceEntity", type: .object(SpaceEntity.selections)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(metadata: Metadatum? = nil, spaceEntity: SpaceEntity? = nil) {
              self.init(unsafeResultMap: ["__typename": "SpaceEntity", "metadata": metadata.flatMap { (value: Metadatum) -> ResultMap in value.resultMap }, "spaceEntity": spaceEntity.flatMap { (value: SpaceEntity) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var metadata: Metadatum? {
              get {
                return (resultMap["metadata"] as? ResultMap).flatMap { Metadatum(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "metadata")
              }
            }

            public var spaceEntity: SpaceEntity? {
              get {
                return (resultMap["spaceEntity"] as? ResultMap).flatMap { SpaceEntity(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "spaceEntity")
              }
            }

            public struct Metadatum: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["ResultMetadata"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("docID", type: .scalar(String.self)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(docId: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "ResultMetadata", "docID": docId])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// The DocID for this item
              /// See: https://github.com/neevaco/neeva/blob/41e1f138129605b106dc88d456ed50f1b9da4578/docs/doc.go#L18-L26
              public var docId: String? {
                get {
                  return resultMap["docID"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "docID")
                }
              }
            }

            public struct SpaceEntity: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["SpaceEntityData"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("url", type: .scalar(String.self)),
                  GraphQLField("title", type: .scalar(String.self)),
                  GraphQLField("snippet", type: .scalar(String.self)),
                  GraphQLField("thumbnail", type: .scalar(String.self)),
                  GraphQLField("generator", type: .object(Generator.selections)),
                  GraphQLField("content", type: .object(Content.selections)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(url: String? = nil, title: String? = nil, snippet: String? = nil, thumbnail: String? = nil, generator: Generator? = nil, content: Content? = nil) {
                self.init(unsafeResultMap: ["__typename": "SpaceEntityData", "url": url, "title": title, "snippet": snippet, "thumbnail": thumbnail, "generator": generator.flatMap { (value: Generator) -> ResultMap in value.resultMap }, "content": content.flatMap { (value: Content) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var url: String? {
                get {
                  return resultMap["url"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "url")
                }
              }

              public var title: String? {
                get {
                  return resultMap["title"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "title")
                }
              }

              public var snippet: String? {
                get {
                  return resultMap["snippet"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "snippet")
                }
              }

              public var thumbnail: String? {
                get {
                  return resultMap["thumbnail"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "thumbnail")
                }
              }

              public var generator: Generator? {
                get {
                  return (resultMap["generator"] as? ResultMap).flatMap { Generator(unsafeResultMap: $0) }
                }
                set {
                  resultMap.updateValue(newValue?.resultMap, forKey: "generator")
                }
              }

              public var content: Content? {
                get {
                  return (resultMap["content"] as? ResultMap).flatMap { Content(unsafeResultMap: $0) }
                }
                set {
                  resultMap.updateValue(newValue?.resultMap, forKey: "content")
                }
              }

              public struct Generator: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["SpaceGenerator"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("id", type: .nonNull(.scalar(String.self))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(id: String) {
                  self.init(unsafeResultMap: ["__typename": "SpaceGenerator", "id": id])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var id: String {
                  get {
                    return resultMap["id"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "id")
                  }
                }
              }

              public struct Content: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["Result"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("id", type: .nonNull(.scalar(String.self))),
                    GraphQLField("title", type: .scalar(String.self)),
                    GraphQLField("snippet", type: .scalar(String.self)),
                    GraphQLField("typeSpecific", type: .object(TypeSpecific.selections)),
                    GraphQLField("actionURL", type: .nonNull(.scalar(String.self))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(id: String, title: String? = nil, snippet: String? = nil, typeSpecific: TypeSpecific? = nil, actionUrl: String) {
                  self.init(unsafeResultMap: ["__typename": "Result", "id": id, "title": title, "snippet": snippet, "typeSpecific": typeSpecific.flatMap { (value: TypeSpecific) -> ResultMap in value.resultMap }, "actionURL": actionUrl])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// ID of the result that is being retrieved.
                public var id: String {
                  get {
                    return resultMap["id"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "id")
                  }
                }

                /// Result title. Used if no type-specific data is used for the title.
                public var title: String? {
                  get {
                    return resultMap["title"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "title")
                  }
                }

                /// Snippet string. HTML format.
                public var snippet: String? {
                  get {
                    return resultMap["snippet"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "snippet")
                  }
                }

                /// Information specific to the result type. For example, this may be the
                /// 'to' and 'from' fields for an email, or 'mime type' for a file.
                public var typeSpecific: TypeSpecific? {
                  get {
                    return (resultMap["typeSpecific"] as? ResultMap).flatMap { TypeSpecific(unsafeResultMap: $0) }
                  }
                  set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "typeSpecific")
                  }
                }

                /// The primary url to navigate to when the user clicks on a result.
                public var actionUrl: String {
                  get {
                    return resultMap["actionURL"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "actionURL")
                  }
                }

                public struct TypeSpecific: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["AgendaView", "BillsView", "Computation", "Contact", "Currency", "Dictionary", "Doc", "DocView", "Email", "EmailActivity", "Entity", "Event", "EventView", "ExternalSearchProvider", "Flight", "FeedDocsView", "FeedGHView", "Image", "IpAddress", "Issue", "Journey", "KnowledgeGraphAnswer", "Lyrics", "Message", "MovieList", "MovieShowtimes", "NeevaDefinition", "News", "NewsItem", "NewsletterView", "NoAdsBanner", "PackageTracking", "PersonView", "Place", "PlaceList", "PreviewModeCTA", "PriceFollow", "ProductCategoryOverview", "ProductQNA", "ProductReviews", "ProductClusters", "ProductBrowse", "ProgrammingDoc", "Promo", "ReceiptView", "RecipeResult", "RecipeBlock", "FeaturedRecipeBlock", "FeaturedVideoRecipeBlock", "Redirect", "RelatedSearches", "RelatedQnA", "RichEntity", "PPRanking", "ShippingView", "Social", "SpaceView", "SpaceBlock", "SportsCard", "Stock", "TechDoc", "TechQNA", "TimeCalculation", "Timezone", "TimezoneDifference", "Token", "Translation", "TravelView", "Tweet", "Vanity", "Video", "WalletTS", "Weather", "Web"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLTypeCase(
                        variants: ["TechDoc": AsTechDoc.selections, "NewsItem": AsNewsItem.selections, "Web": AsWeb.selections, "RichEntity": AsRichEntity.selections],
                        default: [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        ]
                      )
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public static func makeAgendaView() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "AgendaView"])
                  }

                  public static func makeBillsView() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "BillsView"])
                  }

                  public static func makeComputation() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Computation"])
                  }

                  public static func makeContact() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Contact"])
                  }

                  public static func makeCurrency() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Currency"])
                  }

                  public static func makeDictionary() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Dictionary"])
                  }

                  public static func makeDoc() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Doc"])
                  }

                  public static func makeDocView() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "DocView"])
                  }

                  public static func makeEmail() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Email"])
                  }

                  public static func makeEmailActivity() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "EmailActivity"])
                  }

                  public static func makeEntity() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Entity"])
                  }

                  public static func makeEvent() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Event"])
                  }

                  public static func makeEventView() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "EventView"])
                  }

                  public static func makeExternalSearchProvider() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "ExternalSearchProvider"])
                  }

                  public static func makeFlight() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Flight"])
                  }

                  public static func makeFeedDocsView() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "FeedDocsView"])
                  }

                  public static func makeFeedGHView() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "FeedGHView"])
                  }

                  public static func makeImage() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Image"])
                  }

                  public static func makeIpAddress() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "IpAddress"])
                  }

                  public static func makeIssue() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Issue"])
                  }

                  public static func makeJourney() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Journey"])
                  }

                  public static func makeKnowledgeGraphAnswer() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "KnowledgeGraphAnswer"])
                  }

                  public static func makeLyrics() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Lyrics"])
                  }

                  public static func makeMessage() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Message"])
                  }

                  public static func makeMovieList() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "MovieList"])
                  }

                  public static func makeMovieShowtimes() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "MovieShowtimes"])
                  }

                  public static func makeNeevaDefinition() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "NeevaDefinition"])
                  }

                  public static func makeNews() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "News"])
                  }

                  public static func makeNewsletterView() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "NewsletterView"])
                  }

                  public static func makeNoAdsBanner() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "NoAdsBanner"])
                  }

                  public static func makePackageTracking() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "PackageTracking"])
                  }

                  public static func makePersonView() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "PersonView"])
                  }

                  public static func makePlace() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Place"])
                  }

                  public static func makePlaceList() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "PlaceList"])
                  }

                  public static func makePreviewModeCTA() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "PreviewModeCTA"])
                  }

                  public static func makePriceFollow() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "PriceFollow"])
                  }

                  public static func makeProductCategoryOverview() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "ProductCategoryOverview"])
                  }

                  public static func makeProductQNA() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "ProductQNA"])
                  }

                  public static func makeProductReviews() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "ProductReviews"])
                  }

                  public static func makeProductClusters() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "ProductClusters"])
                  }

                  public static func makeProductBrowse() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "ProductBrowse"])
                  }

                  public static func makeProgrammingDoc() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "ProgrammingDoc"])
                  }

                  public static func makePromo() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Promo"])
                  }

                  public static func makeReceiptView() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "ReceiptView"])
                  }

                  public static func makeRecipeResult() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "RecipeResult"])
                  }

                  public static func makeRecipeBlock() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "RecipeBlock"])
                  }

                  public static func makeFeaturedRecipeBlock() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "FeaturedRecipeBlock"])
                  }

                  public static func makeFeaturedVideoRecipeBlock() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "FeaturedVideoRecipeBlock"])
                  }

                  public static func makeRedirect() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Redirect"])
                  }

                  public static func makeRelatedSearches() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "RelatedSearches"])
                  }

                  public static func makeRelatedQnA() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "RelatedQnA"])
                  }

                  public static func makePPRanking() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "PPRanking"])
                  }

                  public static func makeShippingView() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "ShippingView"])
                  }

                  public static func makeSocial() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Social"])
                  }

                  public static func makeSpaceView() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "SpaceView"])
                  }

                  public static func makeSpaceBlock() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "SpaceBlock"])
                  }

                  public static func makeSportsCard() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "SportsCard"])
                  }

                  public static func makeStock() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Stock"])
                  }

                  public static func makeTechQNA() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "TechQNA"])
                  }

                  public static func makeTimeCalculation() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "TimeCalculation"])
                  }

                  public static func makeTimezone() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Timezone"])
                  }

                  public static func makeTimezoneDifference() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "TimezoneDifference"])
                  }

                  public static func makeToken() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Token"])
                  }

                  public static func makeTranslation() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Translation"])
                  }

                  public static func makeTravelView() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "TravelView"])
                  }

                  public static func makeTweet() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Tweet"])
                  }

                  public static func makeVanity() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Vanity"])
                  }

                  public static func makeVideo() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Video"])
                  }

                  public static func makeWalletTS() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "WalletTS"])
                  }

                  public static func makeWeather() -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Weather"])
                  }

                  public static func makeTechDoc(techDoc: AsTechDoc.TechDoc? = nil) -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "TechDoc", "techDoc": techDoc.flatMap { (value: AsTechDoc.TechDoc) -> ResultMap in value.resultMap }])
                  }

                  public static func makeNewsItem(newsItem: AsNewsItem.NewsItem? = nil) -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "NewsItem", "newsItem": newsItem.flatMap { (value: AsNewsItem.NewsItem) -> ResultMap in value.resultMap }])
                  }

                  public static func makeWeb(web: AsWeb.Web? = nil) -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "Web", "web": web.flatMap { (value: AsWeb.Web) -> ResultMap in value.resultMap }])
                  }

                  public static func makeRichEntity(richEntity: AsRichEntity.RichEntity? = nil) -> TypeSpecific {
                    return TypeSpecific(unsafeResultMap: ["__typename": "RichEntity", "richEntity": richEntity.flatMap { (value: AsRichEntity.RichEntity) -> ResultMap in value.resultMap }])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  public var asTechDoc: AsTechDoc? {
                    get {
                      if !AsTechDoc.possibleTypes.contains(__typename) { return nil }
                      return AsTechDoc(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap = newValue.resultMap
                    }
                  }

                  public struct AsTechDoc: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["TechDoc"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("techDoc", type: .object(TechDoc.selections)),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(techDoc: TechDoc? = nil) {
                      self.init(unsafeResultMap: ["__typename": "TechDoc", "techDoc": techDoc.flatMap { (value: TechDoc) -> ResultMap in value.resultMap }])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var techDoc: TechDoc? {
                      get {
                        return (resultMap["techDoc"] as? ResultMap).flatMap { TechDoc(unsafeResultMap: $0) }
                      }
                      set {
                        resultMap.updateValue(newValue?.resultMap, forKey: "techDoc")
                      }
                    }

                    public struct TechDoc: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["TechDocData"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("name", type: .scalar(String.self)),
                          GraphQLField("sections", type: .list(.nonNull(.object(Section.selections)))),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(name: String? = nil, sections: [Section]? = nil) {
                        self.init(unsafeResultMap: ["__typename": "TechDocData", "name": name, "sections": sections.flatMap { (value: [Section]) -> [ResultMap] in value.map { (value: Section) -> ResultMap in value.resultMap } }])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var name: String? {
                        get {
                          return resultMap["name"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "name")
                        }
                      }

                      public var sections: [Section]? {
                        get {
                          return (resultMap["sections"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Section] in value.map { (value: ResultMap) -> Section in Section(unsafeResultMap: value) } }
                        }
                        set {
                          resultMap.updateValue(newValue.flatMap { (value: [Section]) -> [ResultMap] in value.map { (value: Section) -> ResultMap in value.resultMap } }, forKey: "sections")
                        }
                      }

                      public struct Section: GraphQLSelectionSet {
                        public static let possibleTypes: [String] = ["TechDocSection"]

                        public static var selections: [GraphQLSelection] {
                          return [
                            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                            GraphQLField("body", type: .scalar(String.self)),
                          ]
                        }

                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                          self.resultMap = unsafeResultMap
                        }

                        public init(body: String? = nil) {
                          self.init(unsafeResultMap: ["__typename": "TechDocSection", "body": body])
                        }

                        public var __typename: String {
                          get {
                            return resultMap["__typename"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "__typename")
                          }
                        }

                        public var body: String? {
                          get {
                            return resultMap["body"] as? String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "body")
                          }
                        }
                      }
                    }
                  }

                  public var asNewsItem: AsNewsItem? {
                    get {
                      if !AsNewsItem.possibleTypes.contains(__typename) { return nil }
                      return AsNewsItem(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap = newValue.resultMap
                    }
                  }

                  public struct AsNewsItem: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["NewsItem"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("newsItem", type: .object(NewsItem.selections)),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(newsItem: NewsItem? = nil) {
                      self.init(unsafeResultMap: ["__typename": "NewsItem", "newsItem": newsItem.flatMap { (value: NewsItem) -> ResultMap in value.resultMap }])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var newsItem: NewsItem? {
                      get {
                        return (resultMap["newsItem"] as? ResultMap).flatMap { NewsItem(unsafeResultMap: $0) }
                      }
                      set {
                        resultMap.updateValue(newValue?.resultMap, forKey: "newsItem")
                      }
                    }

                    public struct NewsItem: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["NewsData"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("title", type: .nonNull(.scalar(String.self))),
                          GraphQLField("snippet", type: .nonNull(.scalar(String.self))),
                          GraphQLField("url", type: .nonNull(.scalar(String.self))),
                          GraphQLField("thumbnailImage", type: .nonNull(.object(ThumbnailImage.selections))),
                          GraphQLField("providerName", type: .nonNull(.scalar(String.self))),
                          GraphQLField("datePublished", type: .nonNull(.scalar(String.self))),
                          GraphQLField("favIconURL", type: .scalar(String.self)),
                          GraphQLField("preference", type: .scalar(UserPreference.self)),
                          GraphQLField("domain", type: .scalar(String.self)),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(title: String, snippet: String, url: String, thumbnailImage: ThumbnailImage, providerName: String, datePublished: String, favIconUrl: String? = nil, preference: UserPreference? = nil, domain: String? = nil) {
                        self.init(unsafeResultMap: ["__typename": "NewsData", "title": title, "snippet": snippet, "url": url, "thumbnailImage": thumbnailImage.resultMap, "providerName": providerName, "datePublished": datePublished, "favIconURL": favIconUrl, "preference": preference, "domain": domain])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var title: String {
                        get {
                          return resultMap["title"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "title")
                        }
                      }

                      public var snippet: String {
                        get {
                          return resultMap["snippet"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "snippet")
                        }
                      }

                      public var url: String {
                        get {
                          return resultMap["url"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "url")
                        }
                      }

                      public var thumbnailImage: ThumbnailImage {
                        get {
                          return ThumbnailImage(unsafeResultMap: resultMap["thumbnailImage"]! as! ResultMap)
                        }
                        set {
                          resultMap.updateValue(newValue.resultMap, forKey: "thumbnailImage")
                        }
                      }

                      public var providerName: String {
                        get {
                          return resultMap["providerName"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "providerName")
                        }
                      }

                      public var datePublished: String {
                        get {
                          return resultMap["datePublished"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "datePublished")
                        }
                      }

                      public var favIconUrl: String? {
                        get {
                          return resultMap["favIconURL"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "favIconURL")
                        }
                      }

                      public var preference: UserPreference? {
                        get {
                          return resultMap["preference"] as? UserPreference
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "preference")
                        }
                      }

                      public var domain: String? {
                        get {
                          return resultMap["domain"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "domain")
                        }
                      }

                      public struct ThumbnailImage: GraphQLSelectionSet {
                        public static let possibleTypes: [String] = ["ThumbnailImage"]

                        public static var selections: [GraphQLSelection] {
                          return [
                            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                            GraphQLField("url", type: .nonNull(.scalar(String.self))),
                          ]
                        }

                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                          self.resultMap = unsafeResultMap
                        }

                        public init(url: String) {
                          self.init(unsafeResultMap: ["__typename": "ThumbnailImage", "url": url])
                        }

                        public var __typename: String {
                          get {
                            return resultMap["__typename"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "__typename")
                          }
                        }

                        public var url: String {
                          get {
                            return resultMap["url"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "url")
                          }
                        }
                      }
                    }
                  }

                  public var asWeb: AsWeb? {
                    get {
                      if !AsWeb.possibleTypes.contains(__typename) { return nil }
                      return AsWeb(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap = newValue.resultMap
                    }
                  }

                  public struct AsWeb: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["Web"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("web", type: .object(Web.selections)),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(web: Web? = nil) {
                      self.init(unsafeResultMap: ["__typename": "Web", "web": web.flatMap { (value: Web) -> ResultMap in value.resultMap }])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var web: Web? {
                      get {
                        return (resultMap["web"] as? ResultMap).flatMap { Web(unsafeResultMap: $0) }
                      }
                      set {
                        resultMap.updateValue(newValue?.resultMap, forKey: "web")
                      }
                    }

                    public struct Web: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["WebData"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("retailerProduct", type: .object(RetailerProduct.selections)),
                          GraphQLField("recipes", type: .list(.nonNull(.object(Recipe.selections)))),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(retailerProduct: RetailerProduct? = nil, recipes: [Recipe]? = nil) {
                        self.init(unsafeResultMap: ["__typename": "WebData", "retailerProduct": retailerProduct.flatMap { (value: RetailerProduct) -> ResultMap in value.resultMap }, "recipes": recipes.flatMap { (value: [Recipe]) -> [ResultMap] in value.map { (value: Recipe) -> ResultMap in value.resultMap } }])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var retailerProduct: RetailerProduct? {
                        get {
                          return (resultMap["retailerProduct"] as? ResultMap).flatMap { RetailerProduct(unsafeResultMap: $0) }
                        }
                        set {
                          resultMap.updateValue(newValue?.resultMap, forKey: "retailerProduct")
                        }
                      }

                      public var recipes: [Recipe]? {
                        get {
                          return (resultMap["recipes"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Recipe] in value.map { (value: ResultMap) -> Recipe in Recipe(unsafeResultMap: value) } }
                        }
                        set {
                          resultMap.updateValue(newValue.flatMap { (value: [Recipe]) -> [ResultMap] in value.map { (value: Recipe) -> ResultMap in value.resultMap } }, forKey: "recipes")
                        }
                      }

                      public struct RetailerProduct: GraphQLSelectionSet {
                        public static let possibleTypes: [String] = ["RetailerProduct"]

                        public static var selections: [GraphQLSelection] {
                          return [
                            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                            GraphQLField("url", type: .scalar(String.self)),
                            GraphQLField("name", type: .scalar(String.self)),
                            GraphQLField("description", type: .list(.nonNull(.scalar(String.self)))),
                            GraphQLField("priceHistory", type: .object(PriceHistory.selections)),
                            GraphQLField("reviews", type: .object(Review.selections)),
                          ]
                        }

                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                          self.resultMap = unsafeResultMap
                        }

                        public init(url: String? = nil, name: String? = nil, description: [String]? = nil, priceHistory: PriceHistory? = nil, reviews: Review? = nil) {
                          self.init(unsafeResultMap: ["__typename": "RetailerProduct", "url": url, "name": name, "description": description, "priceHistory": priceHistory.flatMap { (value: PriceHistory) -> ResultMap in value.resultMap }, "reviews": reviews.flatMap { (value: Review) -> ResultMap in value.resultMap }])
                        }

                        public var __typename: String {
                          get {
                            return resultMap["__typename"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "__typename")
                          }
                        }

                        public var url: String? {
                          get {
                            return resultMap["url"] as? String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "url")
                          }
                        }

                        public var name: String? {
                          get {
                            return resultMap["name"] as? String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "name")
                          }
                        }

                        public var description: [String]? {
                          get {
                            return resultMap["description"] as? [String]
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "description")
                          }
                        }

                        public var priceHistory: PriceHistory? {
                          get {
                            return (resultMap["priceHistory"] as? ResultMap).flatMap { PriceHistory(unsafeResultMap: $0) }
                          }
                          set {
                            resultMap.updateValue(newValue?.resultMap, forKey: "priceHistory")
                          }
                        }

                        public var reviews: Review? {
                          get {
                            return (resultMap["reviews"] as? ResultMap).flatMap { Review(unsafeResultMap: $0) }
                          }
                          set {
                            resultMap.updateValue(newValue?.resultMap, forKey: "reviews")
                          }
                        }

                        public struct PriceHistory: GraphQLSelectionSet {
                          public static let possibleTypes: [String] = ["ProductPriceHistory"]

                          public static var selections: [GraphQLSelection] {
                            return [
                              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                              GraphQLField("currentPrice", type: .scalar(Double.self)),
                            ]
                          }

                          public private(set) var resultMap: ResultMap

                          public init(unsafeResultMap: ResultMap) {
                            self.resultMap = unsafeResultMap
                          }

                          public init(currentPrice: Double? = nil) {
                            self.init(unsafeResultMap: ["__typename": "ProductPriceHistory", "currentPrice": currentPrice])
                          }

                          public var __typename: String {
                            get {
                              return resultMap["__typename"]! as! String
                            }
                            set {
                              resultMap.updateValue(newValue, forKey: "__typename")
                            }
                          }

                          public var currentPrice: Double? {
                            get {
                              return resultMap["currentPrice"] as? Double
                            }
                            set {
                              resultMap.updateValue(newValue, forKey: "currentPrice")
                            }
                          }
                        }

                        public struct Review: GraphQLSelectionSet {
                          public static let possibleTypes: [String] = ["WebProductReviews"]

                          public static var selections: [GraphQLSelection] {
                            return [
                              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                              GraphQLField("ratingSummary", type: .object(RatingSummary.selections)),
                            ]
                          }

                          public private(set) var resultMap: ResultMap

                          public init(unsafeResultMap: ResultMap) {
                            self.resultMap = unsafeResultMap
                          }

                          public init(ratingSummary: RatingSummary? = nil) {
                            self.init(unsafeResultMap: ["__typename": "WebProductReviews", "ratingSummary": ratingSummary.flatMap { (value: RatingSummary) -> ResultMap in value.resultMap }])
                          }

                          public var __typename: String {
                            get {
                              return resultMap["__typename"]! as! String
                            }
                            set {
                              resultMap.updateValue(newValue, forKey: "__typename")
                            }
                          }

                          public var ratingSummary: RatingSummary? {
                            get {
                              return (resultMap["ratingSummary"] as? ResultMap).flatMap { RatingSummary(unsafeResultMap: $0) }
                            }
                            set {
                              resultMap.updateValue(newValue?.resultMap, forKey: "ratingSummary")
                            }
                          }

                          public struct RatingSummary: GraphQLSelectionSet {
                            public static let possibleTypes: [String] = ["WebProductRating"]

                            public static var selections: [GraphQLSelection] {
                              return [
                                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                                GraphQLField("numReviews", type: .scalar(Int.self)),
                                GraphQLField("rating", type: .object(Rating.selections)),
                              ]
                            }

                            public private(set) var resultMap: ResultMap

                            public init(unsafeResultMap: ResultMap) {
                              self.resultMap = unsafeResultMap
                            }

                            public init(numReviews: Int? = nil, rating: Rating? = nil) {
                              self.init(unsafeResultMap: ["__typename": "WebProductRating", "numReviews": numReviews, "rating": rating.flatMap { (value: Rating) -> ResultMap in value.resultMap }])
                            }

                            public var __typename: String {
                              get {
                                return resultMap["__typename"]! as! String
                              }
                              set {
                                resultMap.updateValue(newValue, forKey: "__typename")
                              }
                            }

                            public var numReviews: Int? {
                              get {
                                return resultMap["numReviews"] as? Int
                              }
                              set {
                                resultMap.updateValue(newValue, forKey: "numReviews")
                              }
                            }

                            public var rating: Rating? {
                              get {
                                return (resultMap["rating"] as? ResultMap).flatMap { Rating(unsafeResultMap: $0) }
                              }
                              set {
                                resultMap.updateValue(newValue?.resultMap, forKey: "rating")
                              }
                            }

                            public struct Rating: GraphQLSelectionSet {
                              public static let possibleTypes: [String] = ["ProductRating"]

                              public static var selections: [GraphQLSelection] {
                                return [
                                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                                  GraphQLField("productStars", type: .scalar(Double.self)),
                                ]
                              }

                              public private(set) var resultMap: ResultMap

                              public init(unsafeResultMap: ResultMap) {
                                self.resultMap = unsafeResultMap
                              }

                              public init(productStars: Double? = nil) {
                                self.init(unsafeResultMap: ["__typename": "ProductRating", "productStars": productStars])
                              }

                              public var __typename: String {
                                get {
                                  return resultMap["__typename"]! as! String
                                }
                                set {
                                  resultMap.updateValue(newValue, forKey: "__typename")
                                }
                              }

                              public var productStars: Double? {
                                get {
                                  return resultMap["productStars"] as? Double
                                }
                                set {
                                  resultMap.updateValue(newValue, forKey: "productStars")
                                }
                              }
                            }
                          }
                        }
                      }

                      public struct Recipe: GraphQLSelectionSet {
                        public static let possibleTypes: [String] = ["Recipe"]

                        public static var selections: [GraphQLSelection] {
                          return [
                            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                            GraphQLField("title", type: .scalar(String.self)),
                            GraphQLField("imageURL", type: .scalar(String.self)),
                            GraphQLField("source", type: .scalar(String.self)),
                            GraphQLField("totalTime", type: .scalar(String.self)),
                            GraphQLField("recipeRating", type: .object(RecipeRating.selections)),
                          ]
                        }

                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                          self.resultMap = unsafeResultMap
                        }

                        public init(title: String? = nil, imageUrl: String? = nil, source: String? = nil, totalTime: String? = nil, recipeRating: RecipeRating? = nil) {
                          self.init(unsafeResultMap: ["__typename": "Recipe", "title": title, "imageURL": imageUrl, "source": source, "totalTime": totalTime, "recipeRating": recipeRating.flatMap { (value: RecipeRating) -> ResultMap in value.resultMap }])
                        }

                        public var __typename: String {
                          get {
                            return resultMap["__typename"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "__typename")
                          }
                        }

                        public var title: String? {
                          get {
                            return resultMap["title"] as? String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "title")
                          }
                        }

                        public var imageUrl: String? {
                          get {
                            return resultMap["imageURL"] as? String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "imageURL")
                          }
                        }

                        public var source: String? {
                          get {
                            return resultMap["source"] as? String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "source")
                          }
                        }

                        public var totalTime: String? {
                          get {
                            return resultMap["totalTime"] as? String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "totalTime")
                          }
                        }

                        public var recipeRating: RecipeRating? {
                          get {
                            return (resultMap["recipeRating"] as? ResultMap).flatMap { RecipeRating(unsafeResultMap: $0) }
                          }
                          set {
                            resultMap.updateValue(newValue?.resultMap, forKey: "recipeRating")
                          }
                        }

                        public struct RecipeRating: GraphQLSelectionSet {
                          public static let possibleTypes: [String] = ["RecipeRating"]

                          public static var selections: [GraphQLSelection] {
                            return [
                              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                              GraphQLField("recipeStars", type: .scalar(Double.self)),
                              GraphQLField("numReviews", type: .scalar(Int.self)),
                            ]
                          }

                          public private(set) var resultMap: ResultMap

                          public init(unsafeResultMap: ResultMap) {
                            self.resultMap = unsafeResultMap
                          }

                          public init(recipeStars: Double? = nil, numReviews: Int? = nil) {
                            self.init(unsafeResultMap: ["__typename": "RecipeRating", "recipeStars": recipeStars, "numReviews": numReviews])
                          }

                          public var __typename: String {
                            get {
                              return resultMap["__typename"]! as! String
                            }
                            set {
                              resultMap.updateValue(newValue, forKey: "__typename")
                            }
                          }

                          public var recipeStars: Double? {
                            get {
                              return resultMap["recipeStars"] as? Double
                            }
                            set {
                              resultMap.updateValue(newValue, forKey: "recipeStars")
                            }
                          }

                          public var numReviews: Int? {
                            get {
                              return resultMap["numReviews"] as? Int
                            }
                            set {
                              resultMap.updateValue(newValue, forKey: "numReviews")
                            }
                          }
                        }
                      }
                    }
                  }

                  public var asRichEntity: AsRichEntity? {
                    get {
                      if !AsRichEntity.possibleTypes.contains(__typename) { return nil }
                      return AsRichEntity(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap = newValue.resultMap
                    }
                  }

                  public struct AsRichEntity: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["RichEntity"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("richEntity", type: .object(RichEntity.selections)),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(richEntity: RichEntity? = nil) {
                      self.init(unsafeResultMap: ["__typename": "RichEntity", "richEntity": richEntity.flatMap { (value: RichEntity) -> ResultMap in value.resultMap }])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var richEntity: RichEntity? {
                      get {
                        return (resultMap["richEntity"] as? ResultMap).flatMap { RichEntity(unsafeResultMap: $0) }
                      }
                      set {
                        resultMap.updateValue(newValue?.resultMap, forKey: "richEntity")
                      }
                    }

                    public struct RichEntity: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["RichEntityData"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("images", type: .list(.nonNull(.object(Image.selections)))),
                          GraphQLField("title", type: .scalar(String.self)),
                          GraphQLField("subTitle", type: .scalar(String.self)),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(images: [Image]? = nil, title: String? = nil, subTitle: String? = nil) {
                        self.init(unsafeResultMap: ["__typename": "RichEntityData", "images": images.flatMap { (value: [Image]) -> [ResultMap] in value.map { (value: Image) -> ResultMap in value.resultMap } }, "title": title, "subTitle": subTitle])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      public var images: [Image]? {
                        get {
                          return (resultMap["images"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Image] in value.map { (value: ResultMap) -> Image in Image(unsafeResultMap: value) } }
                        }
                        set {
                          resultMap.updateValue(newValue.flatMap { (value: [Image]) -> [ResultMap] in value.map { (value: Image) -> ResultMap in value.resultMap } }, forKey: "images")
                        }
                      }

                      public var title: String? {
                        get {
                          return resultMap["title"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "title")
                        }
                      }

                      public var subTitle: String? {
                        get {
                          return resultMap["subTitle"] as? String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "subTitle")
                        }
                      }

                      public struct Image: GraphQLSelectionSet {
                        public static let possibleTypes: [String] = ["EntityImage"]

                        public static var selections: [GraphQLSelection] {
                          return [
                            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                            GraphQLField("thumbnailURL", type: .scalar(String.self)),
                          ]
                        }

                        public private(set) var resultMap: ResultMap

                        public init(unsafeResultMap: ResultMap) {
                          self.resultMap = unsafeResultMap
                        }

                        public init(thumbnailUrl: String? = nil) {
                          self.init(unsafeResultMap: ["__typename": "EntityImage", "thumbnailURL": thumbnailUrl])
                        }

                        public var __typename: String {
                          get {
                            return resultMap["__typename"]! as! String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "__typename")
                          }
                        }

                        public var thumbnailUrl: String? {
                          get {
                            return resultMap["thumbnailURL"] as? String
                          }
                          set {
                            resultMap.updateValue(newValue, forKey: "thumbnailURL")
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

public final class AddToSpaceMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation AddToSpace($input: AddSpaceResultByURLInput!) {
      entityId: addSpaceResultByURL(input: $input)
    }
    """

  public let operationName: String = "AddToSpace"

  public let operationIdentifier: String? = "661b239d7f9d0fb8c802fb37f45b25bed49f15d80995582321cb88380ac51653"

  public var input: AddSpaceResultByURLInput

  public init(input: AddSpaceResultByURLInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("addSpaceResultByURL", alias: "entityId", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(entityId: String) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "entityId": entityId])
    }

    /// Add a URL to a space, and return the ID of the space result.
    public var entityId: String {
      get {
        return resultMap["entityId"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "entityId")
      }
    }
  }
}

public final class CreateSpaceMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation CreateSpace($name: String!) {
      createSpace(input: {name: $name})
    }
    """

  public let operationName: String = "CreateSpace"

  public let operationIdentifier: String? = "3a1c8dcb01cc11a6109d79f8ef46bd768ec7e6c25d734aef479bf9f994a41c21"

  public var name: String

  public init(name: String) {
    self.name = name
  }

  public var variables: GraphQLMap? {
    return ["name": name]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("createSpace", arguments: ["input": ["name": GraphQLVariable("name")]], type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createSpace: String) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createSpace": createSpace])
    }

    /// API to create a space.
    public var createSpace: String {
      get {
        return resultMap["createSpace"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "createSpace")
      }
    }
  }
}

public final class UpdateSpaceMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation UpdateSpace($input: UpdateSpaceInput!) {
      updateSpace(input: $input)
    }
    """

  public let operationName: String = "UpdateSpace"

  public let operationIdentifier: String? = "088045e16c6d36719441ffe31e587aa6062705ebde5b38e12d1e00396ac60e34"

  public var input: UpdateSpaceInput

  public init(input: UpdateSpaceInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("updateSpace", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateSpace: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateSpace": updateSpace])
    }

    /// API to update a space.
    public var updateSpace: Bool {
      get {
        return resultMap["updateSpace"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "updateSpace")
      }
    }
  }
}

public final class LeaveSpaceMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation LeaveSpace($input: LeaveSpaceInput!) {
      leaveSpace(input: $input)
    }
    """

  public let operationName: String = "LeaveSpace"

  public let operationIdentifier: String? = "5250d08a797df48e0e39df49c31151f4970cf355257c46180fcedfe76d530ee9"

  public var input: LeaveSpaceInput

  public init(input: LeaveSpaceInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("leaveSpace", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(leaveSpace: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "leaveSpace": leaveSpace])
    }

    /// Leave a space, meaning a non-owner is removing themselves from the ACL
    public var leaveSpace: Bool {
      get {
        return resultMap["leaveSpace"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "leaveSpace")
      }
    }
  }
}

public final class DeleteSpaceMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation DeleteSpace($input: DeleteSpaceInput!) {
      deleteSpace(input: $input)
    }
    """

  public let operationName: String = "DeleteSpace"

  public let operationIdentifier: String? = "d1565076557135baf018125228903ebddedbb2aaac0fb6548027073aca93cf3b"

  public var input: DeleteSpaceInput

  public init(input: DeleteSpaceInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("deleteSpace", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(deleteSpace: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "deleteSpace": deleteSpace])
    }

    /// API to delete a space.
    public var deleteSpace: Bool {
      get {
        return resultMap["deleteSpace"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "deleteSpace")
      }
    }
  }
}

public final class DeleteSpaceResultByUrlMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation DeleteSpaceResultByURL($input: DeleteSpaceResultByURLInput!) {
      deleteSpaceResultByURL(input: $input)
    }
    """

  public let operationName: String = "DeleteSpaceResultByURL"

  public let operationIdentifier: String? = "34c776b14ec3ba076ce8dbbb3bb1eaf87b51a101d777cf22b6b1f2437a897732"

  public var input: DeleteSpaceResultByURLInput

  public init(input: DeleteSpaceResultByURLInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("deleteSpaceResultByURL", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(deleteSpaceResultByUrl: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "deleteSpaceResultByURL": deleteSpaceResultByUrl])
    }

    /// API to delete entity from a space by URL.
    public var deleteSpaceResultByUrl: Bool {
      get {
        return resultMap["deleteSpaceResultByURL"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "deleteSpaceResultByURL")
      }
    }
  }
}

public final class BatchDeleteSpaceResultMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation BatchDeleteSpaceResult($input: BatchDeleteSpaceResultInput!) {
      batchDeleteSpaceResult(input: $input)
    }
    """

  public let operationName: String = "BatchDeleteSpaceResult"

  public let operationIdentifier: String? = "430484f13a7348f1881725708333e97e169063d9fbb345e06a15e73cbf34f262"

  public var input: BatchDeleteSpaceResultInput

  public init(input: BatchDeleteSpaceResultInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("batchDeleteSpaceResult", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(Bool.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(batchDeleteSpaceResult: Bool) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "batchDeleteSpaceResult": batchDeleteSpaceResult])
    }

    /// API to delete entity from a space.
    public var batchDeleteSpaceResult: Bool {
      get {
        return resultMap["batchDeleteSpaceResult"]! as! Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "batchDeleteSpaceResult")
      }
    }
  }
}

public final class UpdateSpaceEntityDisplayDataMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation UpdateSpaceEntityDisplayData($input: UpdateSpaceEntityDisplayDataInput!) {
      updateSpaceEntityDisplayData(input: $input)
    }
    """

  public let operationName: String = "UpdateSpaceEntityDisplayData"

  public let operationIdentifier: String? = "53f90f349a5b9e5a1f0cae8b0c2e3167fb926cffa082d53ee85c76946f4a38a2"

  public var input: UpdateSpaceEntityDisplayDataInput

  public init(input: UpdateSpaceEntityDisplayDataInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("updateSpaceEntityDisplayData", arguments: ["input": GraphQLVariable("input")], type: .scalar(Bool.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateSpaceEntityDisplayData: Bool? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateSpaceEntityDisplayData": updateSpaceEntityDisplayData])
    }

    /// API to update the display data for space entities.
    public var updateSpaceEntityDisplayData: Bool? {
      get {
        return resultMap["updateSpaceEntityDisplayData"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "updateSpaceEntityDisplayData")
      }
    }
  }
}

public final class SetSpaceDetailPageSortOrderMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation SetSpaceDetailPageSortOrder($input: SetSpaceDetailPageSortOrderInput!) {
      setSpaceDetailPageSortOrder(input: $input)
    }
    """

  public let operationName: String = "SetSpaceDetailPageSortOrder"

  public let operationIdentifier: String? = "502700fc85c24dbffab26f782fa7cbe0c059f08c9683fa8b4642113d8fdc8104"

  public var input: SetSpaceDetailPageSortOrderInput

  public init(input: SetSpaceDetailPageSortOrderInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("setSpaceDetailPageSortOrder", arguments: ["input": GraphQLVariable("input")], type: .scalar(Bool.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(setSpaceDetailPageSortOrder: Bool? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "setSpaceDetailPageSortOrder": setSpaceDetailPageSortOrder])
    }

    /// API to set the sort order in the space detail page.
    public var setSpaceDetailPageSortOrder: Bool? {
      get {
        return resultMap["setSpaceDetailPageSortOrder"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "setSpaceDetailPageSortOrder")
      }
    }
  }
}

public final class AddSpacePublicAclMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation AddSpacePublicACL($input: AddSpacePublicACLInput!) {
      addSpacePublicACL(input: $input)
    }
    """

  public let operationName: String = "AddSpacePublicACL"

  public let operationIdentifier: String? = "7e14e3c762d112f24a2aad5e2935c128016f1fdd4c55e172d45c8235d4d3d1e4"

  public var input: AddSpacePublicACLInput

  public init(input: AddSpacePublicACLInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("addSpacePublicACL", arguments: ["input": GraphQLVariable("input")], type: .scalar(Bool.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(addSpacePublicAcl: Bool? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "addSpacePublicACL": addSpacePublicAcl])
    }

    /// Add public ACL to a space.
    public var addSpacePublicAcl: Bool? {
      get {
        return resultMap["addSpacePublicACL"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "addSpacePublicACL")
      }
    }
  }
}

public final class DeleteSpacePublicAclMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation DeleteSpacePublicACL($input: DeleteSpacePublicACLInput!) {
      deleteSpacePublicACL(input: $input)
    }
    """

  public let operationName: String = "DeleteSpacePublicACL"

  public let operationIdentifier: String? = "4730b43e599a2e2183cbf928de2b59267fc8a40122c45c700775343f8371f8f4"

  public var input: DeleteSpacePublicACLInput

  public init(input: DeleteSpacePublicACLInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("deleteSpacePublicACL", arguments: ["input": GraphQLVariable("input")], type: .scalar(Bool.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(deleteSpacePublicAcl: Bool? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "deleteSpacePublicACL": deleteSpacePublicAcl])
    }

    /// Delete public ACL from a space.
    public var deleteSpacePublicAcl: Bool? {
      get {
        return resultMap["deleteSpacePublicACL"] as? Bool
      }
      set {
        resultMap.updateValue(newValue, forKey: "deleteSpacePublicACL")
      }
    }
  }
}

public final class DeleteSpaceGeneratorMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation DeleteSpaceGenerator($input: DeleteSpaceGeneratorInput!) {
      deleteSpaceGenerator(input: $input) {
        __typename
        applied
      }
    }
    """

  public let operationName: String = "DeleteSpaceGenerator"

  public let operationIdentifier: String? = "6fff312db30ee2b63f2e7c572e7a97904d99d983f962f32e665907014fcf58ee"

  public var input: DeleteSpaceGeneratorInput

  public init(input: DeleteSpaceGeneratorInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("deleteSpaceGenerator", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(DeleteSpaceGenerator.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(deleteSpaceGenerator: DeleteSpaceGenerator) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "deleteSpaceGenerator": deleteSpaceGenerator.resultMap])
    }

    /// API to delete space generators from a space
    public var deleteSpaceGenerator: DeleteSpaceGenerator {
      get {
        return DeleteSpaceGenerator(unsafeResultMap: resultMap["deleteSpaceGenerator"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "deleteSpaceGenerator")
      }
    }

    public struct DeleteSpaceGenerator: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["DeleteSpaceGeneratorResponse"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("applied", type: .scalar(Bool.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(applied: Bool? = nil) {
        self.init(unsafeResultMap: ["__typename": "DeleteSpaceGeneratorResponse", "applied": applied])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var applied: Bool? {
        get {
          return resultMap["applied"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "applied")
        }
      }
    }
  }
}

public final class AddSpaceCommentMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation AddSpaceComment($input: AddSpaceCommentInput!) {
      addSpaceComment(input: $input)
    }
    """

  public let operationName: String = "AddSpaceComment"

  public let operationIdentifier: String? = "c8ad8fcefd2bd190eb66b9f6cd6cf824a90ce3e48f44005163e8bb9fb6117a48"

  public var input: AddSpaceCommentInput

  public init(input: AddSpaceCommentInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("addSpaceComment", arguments: ["input": GraphQLVariable("input")], type: .scalar(String.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(addSpaceComment: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "addSpaceComment": addSpaceComment])
    }

    /// API to add a comment to a space.
    public var addSpaceComment: String? {
      get {
        return resultMap["addSpaceComment"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "addSpaceComment")
      }
    }
  }
}

public final class AddSpaceSoloAcLsMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation AddSpaceSoloACLs($input: AddSpaceSoloACLsInput!) {
      addSpaceSoloACLs(input: $input) {
        __typename
        nonNeevanEmails
        changedACLCount
      }
    }
    """

  public let operationName: String = "AddSpaceSoloACLs"

  public let operationIdentifier: String? = "48811ea28522d0331e0b7d4540aa5076fc784faadacec0b53b8dcc4b51a05f00"

  public var input: AddSpaceSoloACLsInput

  public init(input: AddSpaceSoloACLsInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("addSpaceSoloACLs", arguments: ["input": GraphQLVariable("input")], type: .object(AddSpaceSoloAcl.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(addSpaceSoloAcLs: AddSpaceSoloAcl? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "addSpaceSoloACLs": addSpaceSoloAcLs.flatMap { (value: AddSpaceSoloAcl) -> ResultMap in value.resultMap }])
    }

    /// Add a list of emails to a space.
    public var addSpaceSoloAcLs: AddSpaceSoloAcl? {
      get {
        return (resultMap["addSpaceSoloACLs"] as? ResultMap).flatMap { AddSpaceSoloAcl(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "addSpaceSoloACLs")
      }
    }

    public struct AddSpaceSoloAcl: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["AddSpaceSoloACLsResponse"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nonNeevanEmails", type: .list(.nonNull(.scalar(String.self)))),
          GraphQLField("changedACLCount", type: .scalar(Int.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(nonNeevanEmails: [String]? = nil, changedAclCount: Int? = nil) {
        self.init(unsafeResultMap: ["__typename": "AddSpaceSoloACLsResponse", "nonNeevanEmails": nonNeevanEmails, "changedACLCount": changedAclCount])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var nonNeevanEmails: [String]? {
        get {
          return resultMap["nonNeevanEmails"] as? [String]
        }
        set {
          resultMap.updateValue(newValue, forKey: "nonNeevanEmails")
        }
      }

      public var changedAclCount: Int? {
        get {
          return resultMap["changedACLCount"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "changedACLCount")
        }
      }
    }
  }
}

public final class ClaimGeneratedItemMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation ClaimGeneratedItem($input: ClaimGeneratedItemInput!) {
      claimGeneratedItem(input: $input) {
        __typename
        applied
      }
    }
    """

  public let operationName: String = "ClaimGeneratedItem"

  public let operationIdentifier: String? = "35be16a3b923e68614d1e99da6f14ea77e675432620950e284fc96da8c229803"

  public var input: ClaimGeneratedItemInput

  public init(input: ClaimGeneratedItemInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("claimGeneratedItem", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(ClaimGeneratedItem.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(claimGeneratedItem: ClaimGeneratedItem) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "claimGeneratedItem": claimGeneratedItem.resultMap])
    }

    /// API to permanently add a generated item to a space
    public var claimGeneratedItem: ClaimGeneratedItem {
      get {
        return ClaimGeneratedItem(unsafeResultMap: resultMap["claimGeneratedItem"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "claimGeneratedItem")
      }
    }

    public struct ClaimGeneratedItem: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["ClaimGeneratedItemResponse"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("applied", type: .scalar(Bool.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(applied: Bool? = nil) {
        self.init(unsafeResultMap: ["__typename": "ClaimGeneratedItemResponse", "applied": applied])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var applied: Bool? {
        get {
          return resultMap["applied"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "applied")
        }
      }
    }
  }
}

public final class SuggestionsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Suggestions($query: String!) {
      suggest(q: $query) {
        __typename
        querySuggestion {
          __typename
          type
          suggestedQuery
          boldSpan {
            __typename
            startInclusive
            endExclusive
          }
          source
          annotation {
            __typename
            annotationType
            description
            imageURL
            stockInfo {
              __typename
              companyName
              ticker
              currentPrice
              changeFromPreviousClose
              percentChangeFromPreviousClose
              fetchedAtTime
            }
            dictionaryInfo {
              __typename
              shortDefinition
              phoneticSpelling
              lexicalCategory
              word
            }
          }
        }
        urlSuggestion {
          __typename
          icon {
            __typename
            labels
          }
          suggestedURL
          title
          author
          timestamp
          subtitle
          sourceQueryIndex
          boldSpan {
            __typename
            startInclusive
            endExclusive
          }
        }
        lenseSuggestion {
          __typename
          shortcut
          description
        }
        bangSuggestion {
          __typename
          shortcut
          description
          domain
        }
        activeLensBangInfo {
          __typename
          domain
          shortcut
          description
          type
        }
      }
    }
    """

  public let operationName: String = "Suggestions"

  public let operationIdentifier: String? = "2d73a288d273d560f35449d364f40729b5ba6d453a2b189dc8c1be5f1f1a28b2"

  public var query: String

  public init(query: String) {
    self.query = query
  }

  public var variables: GraphQLMap? {
    return ["query": query]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("suggest", arguments: ["q": GraphQLVariable("query")], type: .object(Suggest.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(suggest: Suggest? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "suggest": suggest.flatMap { (value: Suggest) -> ResultMap in value.resultMap }])
    }

    /// Search suggestions.
    public var suggest: Suggest? {
      get {
        return (resultMap["suggest"] as? ResultMap).flatMap { Suggest(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "suggest")
      }
    }

    public struct Suggest: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Suggest"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("querySuggestion", type: .nonNull(.list(.nonNull(.object(QuerySuggestion.selections))))),
          GraphQLField("urlSuggestion", type: .nonNull(.list(.nonNull(.object(UrlSuggestion.selections))))),
          GraphQLField("lenseSuggestion", type: .list(.nonNull(.object(LenseSuggestion.selections)))),
          GraphQLField("bangSuggestion", type: .list(.nonNull(.object(BangSuggestion.selections)))),
          GraphQLField("activeLensBangInfo", type: .object(ActiveLensBangInfo.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(querySuggestion: [QuerySuggestion], urlSuggestion: [UrlSuggestion], lenseSuggestion: [LenseSuggestion]? = nil, bangSuggestion: [BangSuggestion]? = nil, activeLensBangInfo: ActiveLensBangInfo? = nil) {
        self.init(unsafeResultMap: ["__typename": "Suggest", "querySuggestion": querySuggestion.map { (value: QuerySuggestion) -> ResultMap in value.resultMap }, "urlSuggestion": urlSuggestion.map { (value: UrlSuggestion) -> ResultMap in value.resultMap }, "lenseSuggestion": lenseSuggestion.flatMap { (value: [LenseSuggestion]) -> [ResultMap] in value.map { (value: LenseSuggestion) -> ResultMap in value.resultMap } }, "bangSuggestion": bangSuggestion.flatMap { (value: [BangSuggestion]) -> [ResultMap] in value.map { (value: BangSuggestion) -> ResultMap in value.resultMap } }, "activeLensBangInfo": activeLensBangInfo.flatMap { (value: ActiveLensBangInfo) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// List of suggested queries based on initial query
      public var querySuggestion: [QuerySuggestion] {
        get {
          return (resultMap["querySuggestion"] as! [ResultMap]).map { (value: ResultMap) -> QuerySuggestion in QuerySuggestion(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: QuerySuggestion) -> ResultMap in value.resultMap }, forKey: "querySuggestion")
        }
      }

      /// List of suggested urls based on initial query
      public var urlSuggestion: [UrlSuggestion] {
        get {
          return (resultMap["urlSuggestion"] as! [ResultMap]).map { (value: ResultMap) -> UrlSuggestion in UrlSuggestion(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: UrlSuggestion) -> ResultMap in value.resultMap }, forKey: "urlSuggestion")
        }
      }

      /// List of suggested lenses
      public var lenseSuggestion: [LenseSuggestion]? {
        get {
          return (resultMap["lenseSuggestion"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [LenseSuggestion] in value.map { (value: ResultMap) -> LenseSuggestion in LenseSuggestion(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [LenseSuggestion]) -> [ResultMap] in value.map { (value: LenseSuggestion) -> ResultMap in value.resultMap } }, forKey: "lenseSuggestion")
        }
      }

      /// List of suggested bangs
      public var bangSuggestion: [BangSuggestion]? {
        get {
          return (resultMap["bangSuggestion"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [BangSuggestion] in value.map { (value: ResultMap) -> BangSuggestion in BangSuggestion(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [BangSuggestion]) -> [ResultMap] in value.map { (value: BangSuggestion) -> ResultMap in value.resultMap } }, forKey: "bangSuggestion")
        }
      }

      /// Info on the currently active lens or bang
      public var activeLensBangInfo: ActiveLensBangInfo? {
        get {
          return (resultMap["activeLensBangInfo"] as? ResultMap).flatMap { ActiveLensBangInfo(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "activeLensBangInfo")
        }
      }

      public struct QuerySuggestion: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["QuerySuggestion"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("type", type: .nonNull(.scalar(QuerySuggestionType.self))),
            GraphQLField("suggestedQuery", type: .nonNull(.scalar(String.self))),
            GraphQLField("boldSpan", type: .nonNull(.list(.nonNull(.object(BoldSpan.selections))))),
            GraphQLField("source", type: .nonNull(.scalar(QuerySuggestionSource.self))),
            GraphQLField("annotation", type: .object(Annotation.selections)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(type: QuerySuggestionType, suggestedQuery: String, boldSpan: [BoldSpan], source: QuerySuggestionSource, annotation: Annotation? = nil) {
          self.init(unsafeResultMap: ["__typename": "QuerySuggestion", "type": type, "suggestedQuery": suggestedQuery, "boldSpan": boldSpan.map { (value: BoldSpan) -> ResultMap in value.resultMap }, "source": source, "annotation": annotation.flatMap { (value: Annotation) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var type: QuerySuggestionType {
          get {
            return resultMap["type"]! as! QuerySuggestionType
          }
          set {
            resultMap.updateValue(newValue, forKey: "type")
          }
        }

        public var suggestedQuery: String {
          get {
            return resultMap["suggestedQuery"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "suggestedQuery")
          }
        }

        public var boldSpan: [BoldSpan] {
          get {
            return (resultMap["boldSpan"] as! [ResultMap]).map { (value: ResultMap) -> BoldSpan in BoldSpan(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: BoldSpan) -> ResultMap in value.resultMap }, forKey: "boldSpan")
          }
        }

        public var source: QuerySuggestionSource {
          get {
            return resultMap["source"]! as! QuerySuggestionSource
          }
          set {
            resultMap.updateValue(newValue, forKey: "source")
          }
        }

        public var annotation: Annotation? {
          get {
            return (resultMap["annotation"] as? ResultMap).flatMap { Annotation(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "annotation")
          }
        }

        public struct BoldSpan: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["SuggestionBoldSpan"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("startInclusive", type: .nonNull(.scalar(Int.self))),
              GraphQLField("endExclusive", type: .nonNull(.scalar(Int.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(startInclusive: Int, endExclusive: Int) {
            self.init(unsafeResultMap: ["__typename": "SuggestionBoldSpan", "startInclusive": startInclusive, "endExclusive": endExclusive])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var startInclusive: Int {
            get {
              return resultMap["startInclusive"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "startInclusive")
            }
          }

          public var endExclusive: Int {
            get {
              return resultMap["endExclusive"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "endExclusive")
            }
          }
        }

        public struct Annotation: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Annotation"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("annotationType", type: .scalar(String.self)),
              GraphQLField("description", type: .scalar(String.self)),
              GraphQLField("imageURL", type: .scalar(String.self)),
              GraphQLField("stockInfo", type: .object(StockInfo.selections)),
              GraphQLField("dictionaryInfo", type: .object(DictionaryInfo.selections)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(annotationType: String? = nil, description: String? = nil, imageUrl: String? = nil, stockInfo: StockInfo? = nil, dictionaryInfo: DictionaryInfo? = nil) {
            self.init(unsafeResultMap: ["__typename": "Annotation", "annotationType": annotationType, "description": description, "imageURL": imageUrl, "stockInfo": stockInfo.flatMap { (value: StockInfo) -> ResultMap in value.resultMap }, "dictionaryInfo": dictionaryInfo.flatMap { (value: DictionaryInfo) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var annotationType: String? {
            get {
              return resultMap["annotationType"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "annotationType")
            }
          }

          public var description: String? {
            get {
              return resultMap["description"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "description")
            }
          }

          public var imageUrl: String? {
            get {
              return resultMap["imageURL"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "imageURL")
            }
          }

          public var stockInfo: StockInfo? {
            get {
              return (resultMap["stockInfo"] as? ResultMap).flatMap { StockInfo(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "stockInfo")
            }
          }

          public var dictionaryInfo: DictionaryInfo? {
            get {
              return (resultMap["dictionaryInfo"] as? ResultMap).flatMap { DictionaryInfo(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "dictionaryInfo")
            }
          }

          public struct StockInfo: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["StockInfo"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("companyName", type: .scalar(String.self)),
                GraphQLField("ticker", type: .scalar(String.self)),
                GraphQLField("currentPrice", type: .scalar(Double.self)),
                GraphQLField("changeFromPreviousClose", type: .scalar(Double.self)),
                GraphQLField("percentChangeFromPreviousClose", type: .scalar(Double.self)),
                GraphQLField("fetchedAtTime", type: .scalar(String.self)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(companyName: String? = nil, ticker: String? = nil, currentPrice: Double? = nil, changeFromPreviousClose: Double? = nil, percentChangeFromPreviousClose: Double? = nil, fetchedAtTime: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "StockInfo", "companyName": companyName, "ticker": ticker, "currentPrice": currentPrice, "changeFromPreviousClose": changeFromPreviousClose, "percentChangeFromPreviousClose": percentChangeFromPreviousClose, "fetchedAtTime": fetchedAtTime])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var companyName: String? {
              get {
                return resultMap["companyName"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "companyName")
              }
            }

            public var ticker: String? {
              get {
                return resultMap["ticker"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "ticker")
              }
            }

            public var currentPrice: Double? {
              get {
                return resultMap["currentPrice"] as? Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "currentPrice")
              }
            }

            public var changeFromPreviousClose: Double? {
              get {
                return resultMap["changeFromPreviousClose"] as? Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "changeFromPreviousClose")
              }
            }

            public var percentChangeFromPreviousClose: Double? {
              get {
                return resultMap["percentChangeFromPreviousClose"] as? Double
              }
              set {
                resultMap.updateValue(newValue, forKey: "percentChangeFromPreviousClose")
              }
            }

            public var fetchedAtTime: String? {
              get {
                return resultMap["fetchedAtTime"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "fetchedAtTime")
              }
            }
          }

          public struct DictionaryInfo: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["DictionaryInfo"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("shortDefinition", type: .scalar(String.self)),
                GraphQLField("phoneticSpelling", type: .scalar(String.self)),
                GraphQLField("lexicalCategory", type: .scalar(String.self)),
                GraphQLField("word", type: .scalar(String.self)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(shortDefinition: String? = nil, phoneticSpelling: String? = nil, lexicalCategory: String? = nil, word: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "DictionaryInfo", "shortDefinition": shortDefinition, "phoneticSpelling": phoneticSpelling, "lexicalCategory": lexicalCategory, "word": word])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var shortDefinition: String? {
              get {
                return resultMap["shortDefinition"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "shortDefinition")
              }
            }

            public var phoneticSpelling: String? {
              get {
                return resultMap["phoneticSpelling"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "phoneticSpelling")
              }
            }

            public var lexicalCategory: String? {
              get {
                return resultMap["lexicalCategory"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "lexicalCategory")
              }
            }

            public var word: String? {
              get {
                return resultMap["word"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "word")
              }
            }
          }
        }
      }

      public struct UrlSuggestion: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["URLSuggestion"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("icon", type: .nonNull(.object(Icon.selections))),
            GraphQLField("suggestedURL", type: .nonNull(.scalar(String.self))),
            GraphQLField("title", type: .scalar(String.self)),
            GraphQLField("author", type: .scalar(String.self)),
            GraphQLField("timestamp", type: .scalar(String.self)),
            GraphQLField("subtitle", type: .scalar(String.self)),
            GraphQLField("sourceQueryIndex", type: .scalar(Int.self)),
            GraphQLField("boldSpan", type: .nonNull(.list(.nonNull(.object(BoldSpan.selections))))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(icon: Icon, suggestedUrl: String, title: String? = nil, author: String? = nil, timestamp: String? = nil, subtitle: String? = nil, sourceQueryIndex: Int? = nil, boldSpan: [BoldSpan]) {
          self.init(unsafeResultMap: ["__typename": "URLSuggestion", "icon": icon.resultMap, "suggestedURL": suggestedUrl, "title": title, "author": author, "timestamp": timestamp, "subtitle": subtitle, "sourceQueryIndex": sourceQueryIndex, "boldSpan": boldSpan.map { (value: BoldSpan) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var icon: Icon {
          get {
            return Icon(unsafeResultMap: resultMap["icon"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "icon")
          }
        }

        public var suggestedUrl: String {
          get {
            return resultMap["suggestedURL"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "suggestedURL")
          }
        }

        public var title: String? {
          get {
            return resultMap["title"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "title")
          }
        }

        public var author: String? {
          get {
            return resultMap["author"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "author")
          }
        }

        public var timestamp: String? {
          get {
            return resultMap["timestamp"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "timestamp")
          }
        }

        public var subtitle: String? {
          get {
            return resultMap["subtitle"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "subtitle")
          }
        }

        public var sourceQueryIndex: Int? {
          get {
            return resultMap["sourceQueryIndex"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "sourceQueryIndex")
          }
        }

        public var boldSpan: [BoldSpan] {
          get {
            return (resultMap["boldSpan"] as! [ResultMap]).map { (value: ResultMap) -> BoldSpan in BoldSpan(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: BoldSpan) -> ResultMap in value.resultMap }, forKey: "boldSpan")
          }
        }

        public struct Icon: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Icon"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("labels", type: .list(.nonNull(.scalar(String.self)))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(labels: [String]? = nil) {
            self.init(unsafeResultMap: ["__typename": "Icon", "labels": labels])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// A list of labels to use. The labels are looked up in order, and the
          /// client will use the first found label. If no icons are found matching the
          /// given labels, then it's up to the client to determine whether to
          /// use a default icon or no icon.
          public var labels: [String]? {
            get {
              return resultMap["labels"] as? [String]
            }
            set {
              resultMap.updateValue(newValue, forKey: "labels")
            }
          }
        }

        public struct BoldSpan: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["SuggestionBoldSpan"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("startInclusive", type: .nonNull(.scalar(Int.self))),
              GraphQLField("endExclusive", type: .nonNull(.scalar(Int.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(startInclusive: Int, endExclusive: Int) {
            self.init(unsafeResultMap: ["__typename": "SuggestionBoldSpan", "startInclusive": startInclusive, "endExclusive": endExclusive])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var startInclusive: Int {
            get {
              return resultMap["startInclusive"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "startInclusive")
            }
          }

          public var endExclusive: Int {
            get {
              return resultMap["endExclusive"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "endExclusive")
            }
          }
        }
      }

      public struct LenseSuggestion: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["LenseSuggestion"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("shortcut", type: .scalar(String.self)),
            GraphQLField("description", type: .scalar(String.self)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(shortcut: String? = nil, description: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "LenseSuggestion", "shortcut": shortcut, "description": description])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var shortcut: String? {
          get {
            return resultMap["shortcut"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "shortcut")
          }
        }

        public var description: String? {
          get {
            return resultMap["description"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "description")
          }
        }
      }

      public struct BangSuggestion: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["BangSuggestion"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("shortcut", type: .scalar(String.self)),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("domain", type: .scalar(String.self)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(shortcut: String? = nil, description: String? = nil, domain: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "BangSuggestion", "shortcut": shortcut, "description": description, "domain": domain])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var shortcut: String? {
          get {
            return resultMap["shortcut"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "shortcut")
          }
        }

        public var description: String? {
          get {
            return resultMap["description"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "description")
          }
        }

        public var domain: String? {
          get {
            return resultMap["domain"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "domain")
          }
        }
      }

      public struct ActiveLensBangInfo: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["ActiveLensBangInfo"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("domain", type: .scalar(String.self)),
            GraphQLField("shortcut", type: .scalar(String.self)),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("type", type: .scalar(ActiveLensBangType.self)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(domain: String? = nil, shortcut: String? = nil, description: String? = nil, type: ActiveLensBangType? = nil) {
          self.init(unsafeResultMap: ["__typename": "ActiveLensBangInfo", "domain": domain, "shortcut": shortcut, "description": description, "type": type])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var domain: String? {
          get {
            return resultMap["domain"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "domain")
          }
        }

        public var shortcut: String? {
          get {
            return resultMap["shortcut"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "shortcut")
          }
        }

        public var description: String? {
          get {
            return resultMap["description"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "description")
          }
        }

        public var type: ActiveLensBangType? {
          get {
            return resultMap["type"] as? ActiveLensBangType
          }
          set {
            resultMap.updateValue(newValue, forKey: "type")
          }
        }
      }
    }
  }
}

public final class SearchResultsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query SearchResults($query: String!) {
      search(q: $query) {
        __typename
        resultGroup {
          __typename
          result {
            __typename
            actionURL
          }
        }
      }
    }
    """

  public let operationName: String = "SearchResults"

  public let operationIdentifier: String? = "3f56834e1bcd1e8fe6b3fba04935f3417710ba801be600b88f2dab3452e43679"

  public var query: String

  public init(query: String) {
    self.query = query
  }

  public var variables: GraphQLMap? {
    return ["query": query]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("search", arguments: ["q": GraphQLVariable("query")], type: .object(Search.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(search: Search? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "search": search.flatMap { (value: Search) -> ResultMap in value.resultMap }])
    }

    /// The main search query. Note that latitude and longitude are deprecated parameters as of 2020/03/05 but kept for iOS app compatibility.
    public var search: Search? {
      get {
        return (resultMap["search"] as? ResultMap).flatMap { Search(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "search")
      }
    }

    public struct Search: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Search"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("resultGroup", type: .list(.object(ResultGroup.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(resultGroup: [ResultGroup?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Search", "resultGroup": resultGroup.flatMap { (value: [ResultGroup?]) -> [ResultMap?] in value.map { (value: ResultGroup?) -> ResultMap? in value.flatMap { (value: ResultGroup) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Results are grouped into 0 or more result groups according to criteria
      /// decided by the backend.
      public var resultGroup: [ResultGroup?]? {
        get {
          return (resultMap["resultGroup"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [ResultGroup?] in value.map { (value: ResultMap?) -> ResultGroup? in value.flatMap { (value: ResultMap) -> ResultGroup in ResultGroup(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [ResultGroup?]) -> [ResultMap?] in value.map { (value: ResultGroup?) -> ResultMap? in value.flatMap { (value: ResultGroup) -> ResultMap in value.resultMap } } }, forKey: "resultGroup")
        }
      }

      public struct ResultGroup: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["ResultGroup"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("result", type: .list(.object(Result.selections))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(result: [Result?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "ResultGroup", "result": result.flatMap { (value: [Result?]) -> [ResultMap?] in value.map { (value: Result?) -> ResultMap? in value.flatMap { (value: Result) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// An ordered list of all the results.
        public var result: [Result?]? {
          get {
            return (resultMap["result"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Result?] in value.map { (value: ResultMap?) -> Result? in value.flatMap { (value: ResultMap) -> Result in Result(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Result?]) -> [ResultMap?] in value.map { (value: Result?) -> ResultMap? in value.flatMap { (value: Result) -> ResultMap in value.resultMap } } }, forKey: "result")
          }
        }

        public struct Result: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Result"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("actionURL", type: .nonNull(.scalar(String.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(actionUrl: String) {
            self.init(unsafeResultMap: ["__typename": "Result", "actionURL": actionUrl])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// The primary url to navigate to when the user clicks on a result.
          public var actionUrl: String {
            get {
              return resultMap["actionURL"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "actionURL")
            }
          }
        }
      }
    }
  }
}
