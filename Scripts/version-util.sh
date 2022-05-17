# This script is meant to be source included.

CONFIG_FILE="Client/AppConfig.xcconfig"
ROOT_PLIST_FILE="Client/Application/Settings.bundle/Root.plist"

# Extract version field specified by $1 from $CONFIG_FILE. Expect version
# field to be of the form: (whitespace)$1 = (version);(whitespace)
get_version() {
    if [ $# != 1 ]; then
        echo "get_version: expected one argument"
        exit 1
    fi
    field_name=$1
    fgrep "$field_name = " $CONFIG_FILE | uniq | cut -d' ' -f3 | cut -d';' -f1
}

get_marketing_version() {
    get_version "BROWSER_MARKETING_VERSION"
}

get_current_project_version() {
    get_version "BROWSER_PROJECT_VERSION"
}
