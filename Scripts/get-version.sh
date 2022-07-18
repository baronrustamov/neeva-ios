#!/bin/sh

SCRIPTS_DIR=$NEEVA_REPO/client/browser/scripts/

. $SCRIPTS_DIR/version-util.sh

echo "Current version info:"
echo "  MARKETING_VERSION = $(get_marketing_version)"
echo "  CURRENT_PROJECT_VERSION = $(get_current_project_version)"
