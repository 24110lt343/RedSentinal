#!/bin/sh
set -eu

PROJECT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"
COMMAND_NAMES="redsentinal redsentinel"
PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
REMOVE_PATH=0

for ARG in "$@"; do
    case "$ARG" in
        --remove-path) REMOVE_PATH=1 ;;
        -h|--help)
            echo "Usage: ./uninstall.sh [--remove-path]"
            echo "  --remove-path  also remove the ~/.local/bin PATH line from shell profiles"
            exit 0
            ;;
        *)
            echo "Unknown option: $ARG"
            exit 1
            ;;
    esac
done

echo "[1/4] Removing global launchers..."

for NAME in $COMMAND_NAMES; do
    LAUNCHER="$INSTALL_DIR/$NAME"
    if [ -e "$LAUNCHER" ] || [ -L "$LAUNCHER" ]; then
        # Only remove it if it belongs to this project
        if grep -Fq "$PROJECT_DIR/main.py" "$LAUNCHER" 2>/dev/null; then
            rm -f "$LAUNCHER"
            echo "Removed: $LAUNCHER"
        else
            echo "Skipped $LAUNCHER (not created by this project)."
        fi
    else
        echo "Not found: $LAUNCHER. Skipping."
    fi
done

echo "[2/4] Removing virtual environment..."

if [ -d "$PROJECT_DIR/.venv" ]; then
    if rm -rf "$PROJECT_DIR/.venv" 2>/dev/null; then
        echo "Removed: $PROJECT_DIR/.venv"
    else
        echo "Error: could not remove .venv (probably owned by root)."
        echo "Run: sudo rm -rf \"$PROJECT_DIR/.venv\""
        exit 1
    fi
else
    echo "Virtual environment not found. Skipping."
fi

echo "[3/4] Cleaning PATH configuration..."

if [ "$REMOVE_PATH" -eq 1 ]; then
    for PROFILE in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
        if [ -f "$PROFILE" ] && grep -Fq "$PATH_LINE" "$PROFILE"; then
            TEMP_PROFILE="$(mktemp)"
            grep -Fxv "$PATH_LINE" "$PROFILE" > "$TEMP_PROFILE" || true
            cat "$TEMP_PROFILE" > "$PROFILE"
            rm -f "$TEMP_PROFILE"
            echo "Updated: $PROFILE"
        fi
    done
else
    echo "Leaving PATH unchanged (other tools may use ~/.local/bin)."
    echo "To remove it too, run: ./uninstall.sh --remove-path"
fi

echo "[4/4] Uninstallation complete!"

echo ""
echo "=================================="
echo " RedSentinal uninstalled successfully"
echo "=================================="
echo "Restart your terminal, or run: hash -r"
echo "The project folder itself was not deleted."