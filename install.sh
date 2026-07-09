#!/bin/sh
# Litmus CLI installer.
#
#
#   curl -fsSL https://raw.githubusercontent.com/litmusautomation/litmus-sdk-releases/main/install.sh | sh
#
# Downloads the latest cli-v* release of litmus-cli for this machine,
# verifies it against SHA256SUMS, and installs it to ~/.local/bin.
#
# Environment overrides:
#   LITMUS_CLI_VERSION      install a specific release tag (e.g. cli-v0.2.0)
#   LITMUS_CLI_INSTALL_DIR  install directory (default ~/.local/bin)
#
# Notes:
#   - Windows is not supported by this script; download the .exe asset from
#     the releases page instead.
#   - Because the download happens via curl, macOS never sets the quarantine
#     attribute, so Gatekeeper does not block the binary.

set -eu

REPO="litmusautomation/litmus-sdk-releases"
INSTALL_DIR="${LITMUS_CLI_INSTALL_DIR:-$HOME/.local/bin}"

fail() { echo "install.sh: $*" >&2; exit 1; }

command -v curl >/dev/null 2>&1 || fail "curl is required"

# --- detect platform -> release asset suffix ---
os=$(uname -s)
arch=$(uname -m)
case "$os" in
  Darwin) os=darwin ;;
  Linux)  os=linux ;;
  *) fail "unsupported OS '$os'. Download manually: https://github.com/$REPO/releases" ;;
esac
case "$arch" in
  arm64|aarch64) arch=arm64 ;;
  x86_64|amd64)  arch=amd64 ;;
  *) fail "unsupported architecture '$arch'. Download manually: https://github.com/$REPO/releases" ;;
esac
case "$os-$arch" in
  darwin-arm64|linux-amd64|linux-arm64) ;;
  *) fail "no prebuilt binary for $os-$arch. Download options: https://github.com/$REPO/releases" ;;
esac

# --- resolve version (the releases repo also hosts Python SDK releases, so
# --- 'latest' cannot be trusted; filter for the cli-v tag prefix) ---
if [ -n "${LITMUS_CLI_VERSION:-}" ]; then
  tag="$LITMUS_CLI_VERSION"
else
  tag=$(curl -fsSL "https://api.github.com/repos/$REPO/releases?per_page=100" |
    grep -o '"tag_name": *"cli-v[^"]*"' | head -1 | cut -d'"' -f4)
  [ -n "$tag" ] || fail "could not find a cli-v* release (set LITMUS_CLI_VERSION to pin one)"
fi
base="https://github.com/$REPO/releases/download/$tag"

# --- download and verify ---
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL -o "$tmp/SHA256SUMS" "$base/SHA256SUMS" || fail "download failed: $base/SHA256SUMS"

# --- pick the binary name from the release manifest (renamed from
# --- litmus-sdk-cli to litmus-cli in cli-v0.4.0; pinned older releases
# --- keep the old asset names) ---
if grep -q " litmus-cli-$os-$arch\$" "$tmp/SHA256SUMS"; then
  BIN_NAME="litmus-cli"
elif grep -q " litmus-sdk-cli-$os-$arch\$" "$tmp/SHA256SUMS"; then
  BIN_NAME="litmus-sdk-cli"
else
  fail "no binary for $os-$arch listed in SHA256SUMS of $tag"
fi
asset="$BIN_NAME-$os-$arch"

echo "Downloading $asset ($tag)..."
curl -fsSL -o "$tmp/$asset" "$base/$asset" || fail "download failed: $base/$asset"

expected=$(grep " $asset\$" "$tmp/SHA256SUMS" | cut -d' ' -f1)
[ -n "$expected" ] || fail "$asset not listed in SHA256SUMS"
if command -v sha256sum >/dev/null 2>&1; then
  actual=$(sha256sum "$tmp/$asset" | cut -d' ' -f1)
else
  actual=$(shasum -a 256 "$tmp/$asset" | cut -d' ' -f1)
fi
[ "$actual" = "$expected" ] || fail "checksum mismatch for $asset (expected $expected, got $actual)"

# --- install ---
mkdir -p "$INSTALL_DIR"
chmod +x "$tmp/$asset"
mv "$tmp/$asset" "$INSTALL_DIR/$BIN_NAME"
echo "Installed $BIN_NAME $tag to $INSTALL_DIR/$BIN_NAME"

case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *) echo "Note: $INSTALL_DIR is not on your PATH. Add it with:"
     echo "  export PATH=\"$INSTALL_DIR:\$PATH\"" ;;
esac

"$INSTALL_DIR/$BIN_NAME" --version | head -1
