# Updating the GraphQL API

## Updating the generated `API.swift` file

(This must be done by a Neeva employee who has access to the internal `neeva` repo.)

Copy the latest `schema.json` file from the internal `neeva` repo to `Shared/API/schema.json`

You can get the latest `schema.json` file from:

```
cd client/packages/neeva-lib
yarn install && yarn build
```

You will then see a `gen` directory with the generated `gen/graphql/schema.json` file.

Add your query or mutation to one of the `.graphql` files in `Codegen/Sources/Codegen/` (grouped approximately by theme).
The name of the query/mutation (with `Query` or `Mutation` appended) will be used as the Swift struct name.

In Xcode, select the “Codegen” scheme and click the run button to regenerate `API.swift` with Swift bindings to the queries/mutations.

For queries, implement a `QueryController` subclass to interface with SwiftUI:

- The `Query` type is the GraphQL query type
- The `Data` type is the type you provide to your SwiftUI code. This is typically nested in the `Data` typeof the `Query` type.
  - I recommend defining a `typealias` in your subclass to make it easier for users to reference your data type
- Implement `func reload() -> Void` by calling `self.perform(query:)` with your desired query
  - To add a refresh control to a `List` or `Form`, pass your `QueryController` subclass into `List { ... }.refreshControl(refreshing:)`
- If your `Data` type is different from the `Data` type returned by the raw query, implement `class func processData(_ data: Query.Data) -> Data` to convert the raw query result to the desired type
  - If you need to access information from the query that was sent to the server, instead implement `class func processData(_ data: Query.Data, for query: Query) -> Data` which calls `processData(data)` by default.
- See `SuggestionsController` for an example of how to handle a query that responds to user input.

There is currently less infrastructure for calling mutations, but there’s a convenience API `SomeMutation().perform { result in ... }` that provides the authentication and other headers, and converts a “successful” result with errors into a failure.
