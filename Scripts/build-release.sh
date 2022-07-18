#!/bin/sh

export EXPORT_BUILD=false
export CREATE_BRANCH=false
export SKIP_PROMPT=true
export BROWSER_PLATFORM=ios

IOS_SCRIPTS_DIR=$(dirname $0)
SCRIPTS_DIR=$NEEVA_REPO/client/browser/scripts/

. $SCRIPTS_DIR/git-util.sh
. $SCRIPTS_DIR/version-util.sh

while getopts "ebp" option; do
  case $option in
    e) # export
       EXPORT_BUILD=true
       ;;
    b) # create branch
       CREATE_BRANCH=true
       ;;
    p) # prompt on every build step
       SKIP_PROMPT=false
       ;;
  esac
done

# Script used to build a release. Use the Xcode Organizer to distribute
# the resulting archive.

./bootstrap.sh

if ! test -f "$NEEVA_REPO/client/browser/scripts/send-slack-message.sh"; then
  if [ -z ${NEEVA_REPO} ]; then
    echo 'Set $NEEVA_REPO to point to your neeva main repository'
  else
    echo "No slack script detected, make sure you have the latest changes from main Neeva repo"
  fi
  exit 1
fi


if $EXPORT_BUILD; then
  xcodebuild clean archive -scheme Client -workspace Neeva.xcworkspace -configuration Release

  # Open Xcode Organizer
  osascript $IOS_SCRIPTS_DIR/open-organizer.as > /dev/null
else
  if [ -z ${APP_STORE_USERNAME} ] || [ -z ${APP_STORE_TOKEN} ]; then
    echo "APP_STORE_USERNAME or APP_STORE_TOKEN not defined for upload. Abort"
    exit 1
  fi

  ARCHIVE_PATH=~/Library/Developer/Xcode/Archives
  NEEVA_ARCHIVE_PATH=$ARCHIVE_PATH/Neeva

  # Create Neeva Archive directory to store archive for upload
  # Note that Xcode looks at all the Archive files in Archives
  # directory so we have record in Xcode Organizer
  mkdir -p $ARCHIVE_PATH
  mkdir -p $NEEVA_ARCHIVE_PATH
  if [ ! -d $NEEVA_ARCHIVE_PATH ]; then
    echo "Failed to create directory $NEEVA_ARCHIVE_PATH"
    exit 1
  fi

  ARCHIVE_FILENAME=Client_$(date '+%Y-%m-%d_%H_%M').xcarchive
  xcodebuild clean archive -scheme Client -workspace Neeva.xcworkspace -configuration Release -archivePath $NEEVA_ARCHIVE_PATH/$ARCHIVE_FILENAME
  if [ ! $? -eq 0 ]; then
    echo "Build failed. Abort"
    exit 1
  fi

  $IOS_SCRIPTS_DIR/upload-release.sh $NEEVA_ARCHIVE_PATH/$ARCHIVE_FILENAME
  if [ ! $? -eq 0 ]; then
    exit 1
  fi
fi

# Confirm uploading build to app store
$SCRIPTS_DIR/confirm-upload-binary.sh

# Generate tag for build
$SCRIPTS_DIR/tag-release.sh

if $CREATE_BRANCH; then
  $SCRIPTS_DIR/branch-release.sh
fi

read -r -p "Bump up the version for next build? [Y/n] " response
if [[ "$response" =~ ^([nN][oO]?)$ ]]
then
  continue
else
  if $CREATE_BRANCH; then
    $SCRIPTS_DIR/prepare-for-next-release.sh
    # switch back to main for preparing next version
    git checkout main
  fi
  $SCRIPTS_DIR/prepare-for-next-release.sh
fi

