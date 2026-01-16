#!/usr/bin/env bash
#
# spawning-pool-common.sh - Shared functions for spawning pool scripts
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Launch Claude in a directory using iTerm2 vertical splits
# Uses persistent window ID for shared spawning pool window
# Usage: launch_claude_in_iterm <repo_path> <display_name>
launch_claude_in_iterm() {
    local repo_path="$1"
    local display_name="$2"
    local window_id_file="/tmp/spawning-pool-window-id"

    log_info "Launching Claude in $display_name..."

    if [[ "$(uname)" == "Darwin" ]]; then
        osascript <<EOF
tell application "iTerm"
    set windowID to missing value

    -- Check if we have a stored window ID using shell command
    try
        set windowIDString to do shell script "cat '$window_id_file' 2>/dev/null || echo ''"
        if windowIDString is not "" then
            set windowID to windowIDString as integer
        end if
    end try

    -- Check if the stored window still exists
    set windowExists to false
    if windowID is not missing value then
        try
            tell window id windowID
                set windowExists to true
            end tell
        on error
            -- Window doesn't exist, clear the stored ID
            do shell script "rm -f '$window_id_file'"
            set windowID to missing value
        end try
    end if

    if windowExists then
        -- Try to split vertically in existing spawning pool window
        try
            tell window id windowID
                -- Activate the window to ensure it's focused
                activate
                tell current tab
                    set initialSessionCount to count of sessions
                    tell current session
                        split vertically with default profile
                    end tell
                    delay 2.0  -- Longer delay for split completion

                    -- Target the last session (newly created split)
                    tell last item of sessions
                        select
                        delay 0.5
                        write text "cd '$repo_path' && claude"
                    end tell
                end tell
            end tell
        on error
            -- Window disappeared, fall back to creating new window
            do shell script "rm -f '$window_id_file'"
            set windowExists to false
        end try
    end if

    if not windowExists then
        -- Create new spawning pool window
        create window with default profile
        delay 1.0  -- Wait for window to fully initialize
        set newWindowID to id of current window

        -- Store the window ID for future use
        do shell script "echo " & newWindowID & " > '$window_id_file'"

        tell current session of current window
            write text "cd '$repo_path' && claude"
        end tell
    end if
end tell
EOF
    else
        # On Linux, try common terminal emulators
        if command -v gnome-terminal &>/dev/null; then
            gnome-terminal --working-directory="$repo_path" -- claude &
        elif command -v xterm &>/dev/null; then
            xterm -e "cd '$repo_path' && claude" &
        else
            log_warn "Could not launch terminal for $display_name. Please run 'claude' manually in: $repo_path"
        fi
    fi
}

# Launch Cursor in a directory
# Usage: launch_cursor <repo_path>
launch_cursor() {
    local repo_path="$1"

    log_info "Opening Cursor in workspace..."
    if [[ "$(uname)" == "Darwin" ]]; then
        open -a "Cursor" "$repo_path" 2>/dev/null || cursor "$repo_path" 2>/dev/null || log_warn "Could not open Cursor. Please open it manually in: $repo_path"
    else
        log_warn "Cursor launch not supported on non-macOS systems. Please open Cursor manually in: $repo_path"
    fi
}

# Find runner repo path in a pool
# Usage: find_runner_repo_path <pool_path>
find_runner_repo_path() {
    local pool_path="$1"
    local runner_path="$pool_path/runner"

    if [[ -d "$runner_path" ]]; then
        # Find the repo directory inside runner
        local runner_repo_dirs=($(find "$runner_path" -maxdepth 1 -type d ! -name "runner" 2>/dev/null))
        if [[ ${#runner_repo_dirs[@]} -gt 0 ]]; then
            echo "${runner_repo_dirs[0]}"
            return 0
        fi
    fi

    return 1
}