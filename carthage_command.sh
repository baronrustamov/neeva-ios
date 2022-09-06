#!/bin/sh

echo 'IPHONEOS_DEPLOYMENT_TARGET=14.1' > /tmp/tmp.xcconfig
echo 'SWIFT_TREAT_WARNINGS_AS_ERRORS=NO' >> /tmp/tmp.xcconfig
echo 'GCC_TREAT_WARNINGS_AS_ERRORS=NO' >> /tmp/tmp.xcconfig
echo 'ENABLE_BITCODE[sdk=iphoneos*]=NO' >> /tmp/tmp.xcconfig
export XCODE_XCCONFIG_FILE=/tmp/tmp.xcconfig

carthage bootstrap --platform iOS --color auto --cache-builds --use-xcframeworks

# Remove these fonts as we don't need them and they make appstoreconnect unhappy.
rm -fr `find Carthage/Build/GCDWebServers.xcframework -name fonts`
