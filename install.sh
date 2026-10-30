#!/bin/sh
set -eu

PROJECT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"
COMMAND_NAMES="redsentinal"
MIN_PY_MAJOR=3
MIN_PY_MINOR=8

echo "[1/6] Checking files and Python..."

[ -f "$PROJECT_DIR/main.py" ] || { echo "Error: main.py not found in $PROJECT_DIR"; exit 1; }
[ -f "$PROJECT_DIR/requirements.txt" ] || { echo "Error: requirements.txt not found in $PROJECT_DIR"; exit 1; }

command -v python3 >/dev/null 2>&1 || {
    echo "Error: Python 3 is required but was not found."
    exit 1
}

python3 -c "import sys; sys.exit(0 if sys.version_info >= ($MIN_PY_MAJOR, $MIN_PY_MINOR) else 1)" || {
    echo "Error: Python $MIN_PY_MAJOR.$MIN_PY_MINOR or newer is required."
    exit 1
}

echo "[2/6] Creating virtual environment..."

# Recreate the venv if it exists but is broken
if [ -d "$PROJECT_DIR/.venv" ] && ! "$PROJECT_DIR/.venv/bin/python" -c "import sys" >/dev/null 2>&1; then
    echo "Existing virtual environment is broken, recreating..."
    rm -rf "$PROJECT_DIR/.venv"
fi

if [ ! -x "$PROJECT_DIR/.venv/bin/python" ]; then
    python3 -m venv "$PROJECT_DIR/.venv" || {
        echo "Error: could not create virtual environment."
        echo "On Debian/Ubuntu, try: sudo apt install python3-venv"
        exit 1
    }
fi

echo "[3/6] Installing dependencies..."

"$PROJECT_DIR/.venv/bin/python" -m pip install --upgrade pip || echo "Warning: pip upgrade failed, continuing."
"$PROJECT_DIR/.venv/bin/python" -m pip install -r "$PROJECT_DIR/requirements.txt"

echo "[4/6] Creating global launchers..."

mkdir -p "$INSTALL_DIR"

for NAME in $COMMAND_NAMES; do
    LAUNCHER="$INSTALL_DIR/$NAME"
    cat > "$LAUNCHER" <<EOF
#!/bin/sh
# Run from the project folder so relative paths (config, data files) work.
# To keep your current directory instead, run: REDSENTINAL_KEEP_CWD=1 $NAME
if [ -z "\${REDSENTINAL_KEEP_CWD:-}" ]; then
    cd "$PROJECT_DIR" || exit 1
fi
exec "$PROJECT_DIR/.venv/bin/python" "$PROJECT_DIR/main.py" "\$@"
EOF
    chmod +x "$LAUNCHER"
    echo "Created $LAUNCHER"
done

echo "[5/6] Configuring PATH..."

PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'

add_to_profile() {
    profile="$1"
    touch "$profile"
    if ! grep -Fq "$PATH_LINE" "$profile"; then
        printf '\n%s\n' "$PATH_LINE" >> "$profile"
        echo "Added ~/.local/bin to PATH in $profile"
    fi
}

case "${SHELL:-}" in
    */zsh)
        add_to_profile "$HOME/.zshrc"
        ;;
    */bash)
        add_to_profile "$HOME/.bashrc"
        # macOS bash opens login shells, which read .bash_profile
        if [ "$(uname -s)" = "Darwin" ]; then
            add_to_profile "$HOME/.bash_profile"
        fi
        ;;
    *)
        add_to_profile "$HOME/.profile"
        ;;
esac

echo "[6/6] Verifying launchers..."

for NAME in $COMMAND_NAMES; do
    [ -x "$INSTALL_DIR/$NAME" ] || { echo "Error: $NAME launcher was not created."; exit 1; }
done

echo ""
echo "=================================="
echo " RedSentinal installed successfully"
echo "=================================="
echo ""
echo "Open a NEW terminal, or run this in the current one:"
echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
echo "Then just run either of these:"
echo "    redsentinal"
