# Build & Install

## Prerequisites

(as of February 15, 2022)

- Mac OS X 11.3
- Xcode 13.2.1, Swift 5.5.2, and the iOS 15 SDK (Betas not supported)
- Carthage 0.37.0 or newer

When running on a device:

- A device that supports iOS 14 GM or later
- One of the following:
 - A developer account and Admin access to the *Certificates, Identifiers & Profiles* section of the *iOS DevCenter*
 - A free developer account (create an Apple ID for free and add as an account in Xcode)

## Get the code

```
git clone https://github.com/neevaco/neeva-ios
cd neeva-ios
```

(If you have forked the repository, substitute the URL with your own repository location.)

## Install dependencies

We use Carthage to manage some of the projects that we depend on. (Others are fetched as Swift packages, which Xcode manages automatically.) __The build will currently only work with Carthage v0.37.0 or newer__. If you do not already have Carthage installed, you need to grab it via Homebrew. Assuming you have Homebrew installed, execute the following:

```
brew update
brew upgrade
brew install carthage node yarn
pip3 install virtualenv
```

You can now run the bootstrap script from the project root directory:

```
./bootstrap.sh
```

At this point you have checked out the source code for both the Neeva for iOS project and built it's dependencies. You can now build and run the application.

## Open the workspace

Open `Neeva.xcworkspace` in Xcode.

Everything after this point is done from within Xcode.

## Run on the simulator

- Make sure you have the *Client* scheme and a simulated device selected. The app should run on any simulator.
- Select *Product -> Run* and the application should build and run on the selected simulator.

## Run on a physical device

(requires an active Apple Developer subscription)

- Open `Client.xcodeproj` and make sure you have the *Client* scheme and your registered device selected. You might need to give your device's UDID to a Neeva employee.
- Execute our `Scripts/prep-for-physical.sh` script.
- Select *Product -> Run* and the application should build and run on your device.
