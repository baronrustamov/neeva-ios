#!/bin/sh

SCRIPTS_DIR=$NEEVA_REPO/client/browser/scripts/

. $SCRIPTS_DIR/git-util.sh

TAG_NAME=$(get_latest_tag)
RELEASE_BRANCH_NAME="$TAG_NAME-release-branch"

echo "Proposing to create release branch from tag:"
echo "  name = $RELEASE_BRANCH_NAME"
echo "  from = $TAG_NAME"
echo "Create branch? Press ENTER to continue. Ctrl+C to cancel."
read

retry_script_prompt_with_uncommitted_files

git checkout -b "$RELEASE_BRANCH_NAME" "$TAG_NAME"

if [ "$SKIP_PROMPT" = true ] ; then
  echo "Pushing branch..."
else
  echo "Push branch? Press ENTER to continue. Ctrl+C to cancel."
  read
fi

git push origin "$RELEASE_BRANCH_NAME"

title="Release branch *$RELEASE_BRANCH_NAME* created"
subtitle="<https://github.com/neevaco/neeva-ios/tree/$RELEASE_BRANCH_NAME|Github branch>"

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

