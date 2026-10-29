#!/bin/bash
#  Copies the iOS en-US What's New of a version into every other locale on iOS and macOS.
#
#  Usage: Scripts/asc-whats-new.sh <version> [--dry-run]
#

set -euo pipefail

readonly APP_ID="${ASC_APP_ID:-1476153872}"
readonly SOURCE_LOCALE="en-US"
readonly MAX_LENGTH=4000

version=""
dry_run=false

usage() {
	echo "Usage: $0 <version> [--dry-run]" >&2
	exit 64
}

fail() {
	echo "error: $1" >&2
	exit 1
}

# Prints the ID of the version on the given platform.
version_id() {
	asc versions list --app "$APP_ID" --version "$version" --platform "$1" --output json | jq -r '.data[0].id // empty'
}

# Prints the version localizations as JSON.
localizations() {
	asc localizations list --version "$1" --paginate --output json
}

# Writes the source text into every locale of the version that differs from it.
sync_version() {
	local platform="$1"
	local id="$2"

	localizations "$id" |
		jq -r --rawfile text "$source_file" '.data[] | select((.attributes.whatsNew // "") != $text) | [.id, .attributes.locale] | @tsv' |
		while IFS=$'\t' read -r localization_id locale; do
			if $dry_run; then
				echo "$platform $locale: would update"
			else
				asc localizations update --id "$localization_id" --whats-new "@file:$source_file" --output json > /dev/null
				echo "$platform $locale: updated"
			fi
		done
}

# Prints every locale of the version whose What's New differs from the source text.
mismatched_locales() {
	localizations "$1" | jq -r --rawfile text "$source_file" '.data[] | select((.attributes.whatsNew // "") != $text) | .attributes.locale'
}

for argument in "$@"; do
	case "$argument" in
		--dry-run)
			dry_run=true
			;;
		-*)
			usage
			;;
		*)
			[ -z "$version" ] || usage
			version="$argument"
			;;
	esac
done

[ -n "$version" ] || usage

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT
source_file="$work_dir/whats-new.txt"

ios_id=$(version_id IOS)
[ -n "$ios_id" ] || fail "no iOS version $version"
mac_id=$(version_id MAC_OS)

localizations "$ios_id" | jq -j --arg locale "$SOURCE_LOCALE" '.data[] | select(.attributes.locale == $locale) | .attributes.whatsNew // ""' > "$source_file"
length=$(jq -Rs 'length' "$source_file")

[ "$length" -gt 0 ] || fail "iOS $SOURCE_LOCALE What's New for $version is empty"
[ "$length" -le "$MAX_LENGTH" ] || fail "iOS $SOURCE_LOCALE What's New for $version is $length characters, the limit is $MAX_LENGTH"
echo "Source: iOS $SOURCE_LOCALE What's New for $version, $length characters"

sync_version iOS "$ios_id"

if [ -n "$mac_id" ]; then
	sync_version macOS "$mac_id"
else
	echo "No macOS version $version, skipping macOS"
fi

if $dry_run; then
	exit 0
fi

ios_mismatches=$(mismatched_locales "$ios_id")
mac_mismatches=""

if [ -n "$mac_id" ]; then
	mac_mismatches=$(mismatched_locales "$mac_id")
fi

if [ -n "$ios_mismatches$mac_mismatches" ]; then
	[ -z "$ios_mismatches" ] || echo "iOS locales that still differ: $(echo $ios_mismatches)" >&2
	[ -z "$mac_mismatches" ] || echo "macOS locales that still differ: $(echo $mac_mismatches)" >&2
	exit 1
fi

echo "Every locale matches the iOS $SOURCE_LOCALE What's New"
