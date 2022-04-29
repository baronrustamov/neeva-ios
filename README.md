# Neeva for iOS

Download on the [App Store](https://apps.apple.com/us/app/neeva-browser-search-engine/id1543288638).

## This branch (main)

This branch works with [Xcode 13.0](https://apps.apple.com/us/app/xcode/id497799835), Swift 5.5 and supports iOS 14.0 and above.

## Getting involved

Check out our [Contributor Guidelines](https://github.com/neevaco/neeva-ios/blob/main/CONTRIBUTING.md)

Want to contribute but don't know where to start? Here is a list of [good first issues](https://github.com/neevaco/neeva-ios/labels/good%20first%20issue).

## Building the code

1. Install the latest [Xcode developer tools](https://developer.apple.com/xcode/downloads/) from Apple.
1. Install Carthage, Node, and a Python 3 virtualenv for localization scripts:
   ```shell
   brew update
   brew install carthage
   brew install node
   pip3 install virtualenv
   ```
1. Clone the repository:
   ```shell
   git clone https://github.com/neevaco/neeva-ios.git
   ```
1. Pull in the project dependencies:
   ```shell
   cd neeva-ios
   sh ./bootstrap.sh
   ```
1. Open `Neeva.xcworkspace` in Xcode.
1. Build the `Client` scheme in Xcode.

## Building User Scripts

User Scripts (JavaScript injected into the `WKWebView`) are compiled, concatenated and minified using [webpack](https://webpack.js.org/). User Scripts to be aggregated are placed in the following directories:

```
/Client
|-- /Frontend
    |-- /UserContent
        |-- /UserScripts
            |-- /AllFrames
            |   |-- /AtDocumentEnd
            |   |-- /AtDocumentStart
            |-- /MainFrame
                |-- /AtDocumentEnd
                |-- /AtDocumentStart
```

This reduces the total possible number of User Scripts down to four. The compiled output from concatenating and minifying the User Scripts placed in these folders resides in `/Client/Assets` and are named accordingly:

- `AllFramesAtDocumentEnd.js`
- `AllFramesAtDocumentStart.js`
- `MainFrameAtDocumentEnd.js`
- `MainFrameAtDocumentStart.js`

To simplify the build process, these compiled files are checked-in to this repository. When adding or editing User Scripts, these files can be re-compiled with `webpack` manually. This requires Node.js to be installed and all required `npm` packages can be installed by running `npm install` in the root directory of the project. User Scripts can be compiled by running the following `npm` command in the root directory of the project:

```
npm run build
```

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

## History of the codebase

The Neeva browser stands on the shoulders of the excellent [Firefox for iOS](https://github.com/mozilla-mobile/firefox-ios) browser.
We forked on Feb 18 at [c23bd56293da4e2913e1d512ee559e784dd21e48](https://github.com/neevaco/neeva-ios/commit/c23bd56293da4e2913e1d512ee559e784dd21e48),
and the project has diverged substantially enough that it hasn't made sense to merge updates since.

Thank you to Mozilla for providing such a fantastic foundation for this project
and many others.
