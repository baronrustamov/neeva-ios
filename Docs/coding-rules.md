# Coding Rules & Style Guide

## Swift style

- Swift code should generally follow the conventions listed at https://github.com/raywenderlich/swift-style-guide.
  - Exception: we use 4-space indentation instead of 2.
  - This is a loose standard. We do our best to follow this style.
  - Run `Scripts/swift-format.sh` to format your code automatically.

## Whitespace

- New code should not contain any trailing whitespace.
- We recommend enabling both the "Automatically trim trailing whitespace" and "Including whitespace-only lines" preferences in Xcode (under Text Editing).
- <code>git rebase --whitespace=fix</code> can also be used to remove whitespace from your commits before issuing a pull request.

## Code Formatting

We use [Swift-format](https://github.com/apple/swift-format) to format our code.

Swift-format is built as a part of [bootstrap.sh](https://github.com/neevaco/neeva-ios/blob/main/bootstrap.sh#L58)
You can run `Scripts/swift-format.sh` with no arguments in the project root dir to check and format all the files modified on your branch.

You should also turn on "Automatically trim trailing whitespace" and "Including whitespace-only lines" in your Xcode settings (Preferences->Text Editing->Editing->While Editing)

## Periphery

Periphery scans the project (currently just the `Client` code) for unused variables, constants, functions, structs, and classes.
To use Periphery, first install it using [Homebrew](https://brew.sh):

```sh
brew tap peripheryapp/periphery && brew install periphery
```

Then switch to the Periphery target in Xcode and build (⌘B). You‘ll get a large number of warnings as a result. Note that many of the warnings are either false positives (i.e. the constant is actually used somewhere in the project) or are due to parameters passed in iOS’s standard delegate pattern.
