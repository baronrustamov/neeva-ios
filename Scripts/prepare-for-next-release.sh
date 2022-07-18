#!/bin/sh

SCRIPTS_DIR=$NEEVA_REPO/client/browser/scripts/

. $SCRIPTS_DIR/git-util.sh
. $SCRIPTS_DIR/version-util.sh

echo "Make sure Xcode does not have the project open."
echo "Press ENTER to continue. Ctrl+C to cancel."
read

# 1- Make sure the tree is clean
retry_script_prompt_with_uncommitted_files

# 2- Run update-version.sh
$SCRIPTS_DIR/update-version.sh

# check if it's on a valid branch
if ! is_branch_of_release && ! is_branch_of_main; then
  echo "You are not on main or release branch. Are you sure you want to continue? Press ENTER to proceed. Ctrl+C to cancel."
  read
fi

# 3- Get version and create branch accordingly or push directly onto release branch

CURRENT_PROJECT_VERSION=$(get_current_project_version)

BRANCH_NAME="$(git_user_name)/prepare-for-build-$CURRENT_PROJECT_VERSION"
REMOTE_ORIGIN_BRANCH_NAME="$(get_remote_origin_branch)"
REMOTE_BRANCH_NAME="$(get_remote_branch)"

if is_branch_of_release; then
  if [ "$SKIP_PROMPT" = true ] ; then
    echo "You are on release branch, changes will be pushed directly onto branch."
  else
    read -r -p "You are on release branch, do you want to push changes directly onto branch? [Y/n] " response
  fi
  if [[ "$response" =~ ^([nN][oO]?)$ ]]
  then
    continue
  else
    git diff
    git commit -a -m "Preparing for build $CURRENT_PROJECT_VERSION"
    echo "Push changes? Press ENTER to continue. Ctrl+C to cancel."
    read
    git push origin $REMOTE_BRANCH_NAME --no-verify
    exit 0
  fi
fi

echo "Proposing to create branch:"
echo "  name = $BRANCH_NAME"
echo "  from = $REMOTE_ORIGIN_BRANCH_NAME"
if [ "$SKIP_PROMPT" = true ] ; then
  echo "Creating branch..."
else
  echo "Create branch? Press ENTER to continue. Ctrl+C to cancel."
  read
fi

git checkout -b $BRANCH_NAME $REMOTE_ORIGIN_BRANCH_NAME
git diff
git commit -a -m "Preparing for build $CURRENT_PROJECT_VERSION"

# 4- Upload branch for review

if [ "$SKIP_PROMPT" = true ] ; then
  echo "Pushing branch..."
else
  echo "Push branch? Press ENTER to continue. Ctrl+C to cancel."
  read
fi

git push origin $BRANCH_NAME --no-verify

if command -v gh &> /dev/null && is_branch_of_main; then
  read -r -p "Looks like you have cli tool set up, do you want to create a PR? [Y/n] " response
  if [[ "$response" =~ ^([nN][oO]?)$ ]]
  then
    continue
  else
    gh pr create -t "Preparing for build $CURRENT_PROJECT_VERSION" -r "neevaco/ios" -b "Bumping up version for next build"
  fi
fi

