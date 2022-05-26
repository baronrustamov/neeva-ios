# Settings & Preferences

We store some settings and preferences in [`UserDefaults`](https://developer.apple.com/documentation/foundation/userdefaults). The primary interface to this storage is via the [`Defaults`](https://github.com/sindresorhus/Defaults/) package.

You can find these defined in [`/Shared/Prefs.swift`](../Shared/Prefs.swift).

## Deprecating a value

Simply removing the definition and code for a value can leave any existing value in storage. If a key is used again in the future, the old value can still be present and cause unexpected behavior.

The current convention to remove a preference is as follows:
- Remove relevant calling code.
- If the setting isn't already optional, redefine to be optional. (i.e. `Bool` becomes `Bool?`)
- Add an availability macro to the preference. Example:
  ```swift
  @available(*, deprecated)  // 2022-05-18
  public static let somePreferenceKey = Defaults.Key<Bool?>("profile.SomePreferenceKey")
  ```
- Add a line inside the `onAppUpdate` method in `Client/Application/SceneDelegate.swift` that resets the value and adds the date of deprecation as a comment. Example:
  ```
  Defaults.reset(.somePreferenceKey)  // deprecated 2022-05-18
  ```
- Sometime in the future when we see most/all users are beyond a certain version, we can fully delete the setting definition and the addition we made to `onAppUpdate`.

See an example PR of this here: https://github.com/neevaco/neeva-ios/pull/3619
