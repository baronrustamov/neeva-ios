#!/bin/sh

SCRIPTS_DIR=$NEEVA_REPO/client/browser/scripts/

. $SCRIPTS_DIR/version-util.sh

MARKETING_VERSION=$(get_marketing_version)
CURRENT_PROJECT_VERSION=$(get_current_project_version)

title="Uploaded Build #*$CURRENT_PROJECT_VERSION* (*v$MARKETING_VERSION*) to App Store"
subtitle="<https://appstoreconnect.apple.com/apps/1543288638/testflight/ios/|App Store TestFlight>"

echo "Build uploaded to App Store? Press ENTER to continue. Ctrl+C to cancel."
read

if test -f "$NEEVA_REPO/client/browser/scripts/send-slack-message.sh"; then
  $NEEVA_REPO/client/browser/scripts/send-slack-message.sh "$title" "$subtitle"
else
  if [ -z ${NEEVA_REPO} ]; then
    echo 'Set $NEEVA_REPO to point to your neeva main repository'
  else
    echo "No slack script detected, make sure you have the latest changes from main Neeva repo"
  fi
  exit 1
fi
