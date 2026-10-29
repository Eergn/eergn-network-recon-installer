#!/usr/bin/env bash
# ----------------------------------------------------------------------------
#  Builds a signed APT repository for eergn-recon-installer in ./docs
#  so it can be served by GitHub Pages and installed with:
#
#  An existing docs/index.html (the documentation landing page) is preserved.
#  A minimal repository page is written only when no landing page exists.
#
#      sudo apt install eergn-recon-installer
#
#  Developer: @Eergn
#
#  Run this on YOUR machine (the signing key stays in your GPG keyring):
#      ./scripts/make-apt-repo.sh
#
#  Requires: gnupg, dpkg-dev (dpkg-deb, dpkg-scanpackages)
#      sudo apt install gnupg dpkg-dev
#
#  Optional environment variables:
#      SITE_URL   public URL of the repo   (default: GitHub Pages URL below)
#      KEY_FPR    fingerprint of an existing GPG key to sign with
#      KEY_NAME / KEY_EMAIL   identity used when a new key is generated
# ----------------------------------------------------------------------------
set -euo pipefail
cd "$(dirname "$0")/.."

SITE_URL="${SITE_URL:-https://eergn.github.io/eergn-network-recon-installer}"
KEY_NAME="${KEY_NAME:-Eergn APT Repository}"
KEY_EMAIL="${KEY_EMAIL:-Eergn@users.noreply.github.com}"
KEY_FPR="${KEY_FPR:-}"
OUT="docs"
PKG="eergn-recon-installer"

need() {
  command -v "$1" >/dev/null 2>&1 || { echo "error: '$1' not found. Install it with: $2" >&2; exit 1; }
}
need gpg                "sudo apt install gnupg"
need dpkg-deb           "sudo apt install dpkg-dev"
need dpkg-scanpackages  "sudo apt install dpkg-dev"
need gzip               "sudo apt install gzip"
[ -x ./scripts/build-deb.sh ] || { echo "error: ./scripts/build-deb.sh missing or not executable (chmod +x scripts/build-deb.sh)" >&2; exit 1; }

find_fpr() {
  gpg --batch --list-secret-keys --with-colons "$KEY_NAME" 2>/dev/null \
    | awk -F: '$1=="fpr"{print $10; exit}'
}

# --- 1. signing key ----------------------------------------------------------
if [ -z "$KEY_FPR" ]; then
  KEY_FPR="$(find_fpr || true)"
fi
if [ -z "$KEY_FPR" ]; then
  echo "==> No signing key named '$KEY_NAME' found. Generating one (ed25519, no expiry, no passphrase)."
  gpg --batch --passphrase '' --quick-generate-key "$KEY_NAME <$KEY_EMAIL>" ed25519 sign never
  KEY_FPR="$(find_fpr)"
fi
[ -n "$KEY_FPR" ] || { echo "error: could not determine the signing key" >&2; exit 1; }
echo "==> Signing key: $KEY_FPR"

# --- 2. build the package ----------------------------------------------------
echo "==> Building the .deb"
./scripts/build-deb.sh >/dev/null
mkdir -p "$OUT"
cp -f dist/${PKG}_*_all.deb "$OUT"/
touch "$OUT/.nojekyll"

# --- 3. repository indexes ---------------------------------------------------
echo "==> Generating repository indexes"
cd "$OUT"
rm -f Packages Packages.gz Release Release.gpg InRelease
dpkg-scanpackages --multiversion . /dev/null > Packages
gzip -9nkf Packages
{
  echo "Origin: Eergn"
  echo "Label: Eergn tools"
  echo "Date: $(LC_ALL=C date -u '+%a, %d %b %Y %H:%M:%S UTC')"
  echo "SHA256:"
  for f in Packages Packages.gz; do
    printf ' %s %16d %s\n' "$(sha256sum "$f" | cut -d' ' -f1)" "$(wc -c < "$f" | tr -d ' ')" "$f"
  done
} > Release

# --- 4. sign -----------------------------------------------------------------
echo "==> Signing"
gpg --batch --yes --default-key "$KEY_FPR" --clearsign -o InRelease Release
gpg --batch --yes --default-key "$KEY_FPR" -abs -o Release.gpg Release
gpg --batch --yes --export "$KEY_FPR" > eergn-archive-keyring.gpg
gpg --batch --yes --armor --export "$KEY_FPR" > eergn-archive-keyring.asc

# --- 5. landing page fallback -----------------------------------------------
if [ ! -f index.html ]; then
cat > index.html <<EOF
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Eergn APT repository</title>
<style>
  body { font-family: system-ui, sans-serif; max-width: 46rem; margin: 2rem auto; padding: 0 1rem; line-height: 1.5; }
  pre { background: #f2f2f2; padding: 1rem; overflow-x: auto; border-radius: 6px; }
  @media (prefers-color-scheme: dark) { body { background: #111; color: #eee; } pre { background: #222; } a { color: #7ab7ff; } }
</style>
</head>
<body>
<h1>Eergn APT repository</h1>
<p>Packages: <strong>$PKG</strong> &mdash; installer for network reconnaissance and diagnostic tools.</p>
<pre>curl -fsSL $SITE_URL/eergn-archive-keyring.gpg | sudo tee /usr/share/keyrings/eergn-archive-keyring.gpg &gt;/dev/null
echo "deb [signed-by=/usr/share/keyrings/eergn-archive-keyring.gpg] $SITE_URL ./" | sudo tee /etc/apt/sources.list.d/eergn.list
sudo apt update
sudo apt install $PKG</pre>
<p>Source: <a href="https://github.com/Eergn/eergn-network-recon-installer">github.com/Eergn/eergn-network-recon-installer</a></p>
</body>
</html>
EOF
fi
cd ..

echo
echo "Done. Repository files are in ./$OUT"
echo "Next:  git add -A && git commit -m \"Update APT repository\" && git push"
echo "Then enable GitHub Pages: Settings > Pages > Source: main branch, /docs folder."
echo "Users install with the commands shown at $SITE_URL"
