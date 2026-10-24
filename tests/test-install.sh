#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

##==================================================================================================
##	DEPENDENCY CHECKS
##==================================================================================================

requireCommand() { command -v "$1" >/dev/null 2>&1 || {
	printf "Abort: '%s' not found\n" "$1" >&2
	exit 1
}; }

requireCommand bash
requireCommand grep
requireCommand mkdir
requireCommand mktemp

##==================================================================================================
##	GLOBALS
##==================================================================================================

declare -r SCRIPT_NAME="${0##*/}"
declare REPOSITORY_ROOT
REPOSITORY_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
declare -r REPOSITORY_ROOT
declare -r BUILD_ROOT="$REPOSITORY_ROOT/tests/build"
declare -a SCRIPT_NAMES=(
	synth-shell-greeter
	synth-shell-prompt
	better-ls
	alias
	better-history
)

##==================================================================================================
##	UTILITIES
##==================================================================================================

die() {
	printf '%s: %s\n' "$SCRIPT_NAME" "$1" >&2
	exit "${2:-1}"
}

##==================================================================================================
##	CORE FUNCTIONS
##==================================================================================================

assertFile() {
	local file_path="$1"

	[[ -f "$file_path" ]] || die "missing file: $file_path"
}

assertContains() {
	local expected_text="$1"
	local file_path="$2"

	grep -Fqx -- "$expected_text" "$file_path" >/dev/null ||
		die "missing text in $file_path: $expected_text"
}

assertNotContains() {
	local unexpected_text="$1"
	local file_path="$2"

	if grep -Fqx -- "$unexpected_text" "$file_path"; then
		die "unexpected text in $file_path: $unexpected_text"
	fi
}

createTestRoot() {
	mkdir -p "$BUILD_ROOT"
	mktemp -d "$BUILD_ROOT/test-install.XXXXXX"
}

prepareTestHome() {
	local test_root="$1"

	export HOME="$test_root/home"
	mkdir -p "$HOME"
	: >"$HOME/.bashrc"
}

loadInstaller() {
	local installer_path="$1"

	set +u
	# shellcheck disable=SC1090,SC1091
	source "$installer_path"
	set -u
}

installScripts() {
	local script_name

	for script_name in "${SCRIPT_NAMES[@]}"; do
		installScript install "$script_name"
	done
}

assertInstallation() {
	local install_dir="$1"
	local config_dir="$2"
	local rc_file="$3"
	local script_name

	for script_name in "${SCRIPT_NAMES[@]}"; do
		assertFile "$install_dir/$script_name.sh"
	done

	assertFile "$config_dir/synth-shell-greeter.config"
	assertFile "$config_dir/synth-shell-prompt.config"
	assertContains "## better-ls" "$rc_file"
	assertContains "## alias" "$rc_file"
	assertContains "## better-history" "$rc_file"
	assertContains "## synth-shell-greeter.sh" "$rc_file"
	assertContains "## synth-shell-prompt.sh" "$rc_file"
	[[ $(grep -c '^#!/usr/bin/env bash$' "$install_dir/synth-shell-greeter.sh") -eq 1 ]] ||
		die "greeter has duplicate shebangs"
	[[ $(grep -c '^#!/usr/bin/env bash$' "$install_dir/synth-shell-prompt.sh") -eq 1 ]] ||
		die "prompt has duplicate shebangs"
}

validateAssembledScripts() {
	local install_dir="$1"
	local script_path

	for script_path in "$install_dir"/*.sh; do
		bash -n "$script_path"
		HOME="$HOME" TERM=dumb bash --noprofile --norc -c 'source "$1"' bash "$script_path"
	done
}

runAssembledScripts() {
	local install_dir="$1"

	HOME="$HOME" TERM=dumb bash --noprofile --norc -c '
        source "$1"
        source "$2"
        source "$3"
        source "$4"
        source "$5"
        type better_ls >/dev/null
        type take >/dev/null
        type betterHistory >/dev/null
        alias ls >/dev/null
    ' bash \
		"$install_dir/synth-shell-greeter.sh" \
		"$install_dir/synth-shell-prompt.sh" \
		"$install_dir/better-ls.sh" \
		"$install_dir/alias.sh" \
		"$install_dir/better-history.sh"
}

##==================================================================================================
##	ARGUMENT PARSING
##==================================================================================================

[[ $# -eq 0 ]] || die "no arguments expected"

##==================================================================================================
##	MAIN
##==================================================================================================

main() {
	local test_root

	test_root="$(createTestRoot)"
	prepareTestHome "$test_root"
	cd "$REPOSITORY_ROOT"
	loadInstaller "$REPOSITORY_ROOT/setup.sh"

	INSTALL_DIR="$test_root/install with spaces"
	CONFIG_DIR="$INSTALL_DIR"
	# shellcheck disable=SC2034
	RC_FILE="$HOME/.bashrc"
	installScripts
	assertInstallation "$INSTALL_DIR" "$CONFIG_DIR" "$RC_FILE"
	validateAssembledScripts "$INSTALL_DIR"
	runAssembledScripts "$INSTALL_DIR"

	installScript uninstall synth-shell-greeter
	installScript uninstall synth-shell-prompt
	assertNotContains "## synth-shell-greeter.sh" "$RC_FILE"
	assertNotContains "## synth-shell-prompt.sh" "$RC_FILE"

	printf 'PASS: isolated install, sourcing, and runtime: %s\n' "$test_root"
}

##==================================================================================================
##	SCRIPT ENTRY POINT
##==================================================================================================

main
