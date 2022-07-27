#!/bin/sh

#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/. */
#
# Bootstrap the Carthage dependencies. If the Carthage directory
# already exists then nothing is done. This speeds up builds on
# CI services where the Carthage directory can be cached.
#
# Use the --force option to force a rebuild of the dependencies.
#

if [ "$1" == "--force" ]; then
    rm -rf ./Carthage/*
    rm -rf ~/Library/Caches/org.carthage.CarthageKit
    rm -rf ~/Library/Developer/Xcode/DerivedData
fi

# Build API Config
./Scripts/build-api-config.sh

# Run carthage
./carthage_command.sh

# Install Node.js dependencies and build user scripts
yarn install
yarn build

# Build Node.js dependencies and build user scripts for NeevaForSafari
./NeevaForSafari/NeevaForSafariExtension/Scripts/config.sh

# swift-format
git submodule update --init --recursive
pushd swift-format
swift build -c release
popd

# Link githooks
./Scripts/link-git-hooks.sh
