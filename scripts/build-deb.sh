#!/usr/bin/env bash
# ----------------------------------------------------------------------------
#  Builds a .deb package for eergn-recon-installer.
#  Developer: @Eergn
#
#  Usage:   ./scripts/build-deb.sh
#  Output:  eergn-recon-installer_<version>_all.deb  (in the dist/ folder)
#
#  Requires: dpkg-deb  (sudo apt install dpkg-dev)
#  The version is read from VERSION="..." in eergn-recon-installer.sh.
# ----------------------------------------------------------------------------
set -euo pipefail
cd "$(dirname "$0")/.."

PKG="eergn-recon-installer"
SRC="eergn-recon-installer.sh"
MAINTAINER="Eergn <Eergn@users.noreply.github.com>"
HOMEPAGE="https://github.com/Eergn/eergn-network-recon-installer"
YEAR="$(date +%Y)"

[ -f "$SRC" ] || { echo "error: $SRC not found in the repository root" >&2; exit 1; }
command -v dpkg-deb >/dev/null 2>&1 || { echo "error: dpkg-deb not found (sudo apt install dpkg-dev)" >&2; exit 1; }

VERSION="$(sed -n 's/^VERSION="\(.*\)"/\1/p' "$SRC" | head -n1)"
[ -n "$VERSION" ] || { echo "error: could not read VERSION from $SRC" >&2; exit 1; }

BUILD="$(mktemp -d)"
trap 'rm -rf "$BUILD"' EXIT
ROOT="$BUILD/${PKG}_${VERSION}_all"
DOC="$ROOT/usr/share/doc/$PKG"

install -d "$ROOT/DEBIAN" "$ROOT/usr/bin" "$DOC" "$ROOT/usr/share/man/man1"

# --- the program -------------------------------------------------------------
install -m 0755 "$SRC" "$ROOT/usr/bin/$PKG"

# --- docs --------------------------------------------------------------------
[ -f README.md ] && install -m 0644 README.md "$DOC/README.md"

cat > "$DOC/copyright" <<EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: $PKG
Upstream-Contact: $MAINTAINER
Source: $HOMEPAGE

Files: *
Copyright: $YEAR Eergn
License: GPL-3

License: GPL-3
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, version 3.
 .
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 .
 On Debian systems, the complete text of the GNU General Public
 License version 3 can be found in /usr/share/common-licenses/GPL-3.
EOF
chmod 0644 "$DOC/copyright"

cat > "$BUILD/changelog" <<EOF
$PKG ($VERSION) unstable; urgency=low

  * Release $VERSION.

 -- $MAINTAINER  $(date -R)
EOF
gzip -9n -c "$BUILD/changelog" > "$DOC/changelog.Debian.gz"
chmod 0644 "$DOC/changelog.Debian.gz"

# --- man page ----------------------------------------------------------------
cat > "$BUILD/$PKG.1" <<EOF
.TH EERGN-RECON-INSTALLER 1 "$(date '+%B %Y')" "$VERSION" "User Commands"
.SH NAME
eergn-recon-installer \- install network reconnaissance and diagnostic tools
.SH SYNOPSIS
.B eergn-recon-installer
[\fIOPTIONS\fR]
.SH DESCRIPTION
Installs Nmap/Ncat, Netcat, arp-scan, fping, MTR, dig/whois, OpenSSL/testssl.sh,
iperf3 and iftop/nethogs using the system package manager (apt, dnf, yum,
pacman, zypper, apk or Homebrew).
.PP
Use these tools only on networks and systems you own or are authorized to test.
.SH OPTIONS
.TP
.BR \-a ", " \-\-all
Install every tool group without showing the menu.
.TP
.BR \-t ", " \-\-tool " " \fIID\fR
Install one group. May be repeated. See \-\-list for IDs.
.TP
.BR \-l ", " \-\-list
List tool groups and exit.
.TP
.BR \-c ", " \-\-check
Show which tools are installed and exit.
.TP
.BR \-y ", " \-\-yes
Do not ask for confirmation.
.TP
.BR \-n ", " \-\-dry\-run
Print the commands without running them.
.TP
.BR \-f ", " \-\-force
Reinstall even if the commands are already present.
.TP
.B \-\-no\-banner
Hide the logo.
.TP
.BR \-v ", " \-\-version
Print the version and exit.
.TP
.BR \-h ", " \-\-help
Show help and exit.
.SH EXAMPLES
.nf
sudo eergn-recon-installer \-\-all \-y
sudo eergn-recon-installer \-t nmap \-t tls
eergn-recon-installer \-\-check
.fi
.SH EXIT STATUS
0 if all selected tools are present at the end, 1 otherwise.
.SH AUTHOR
Eergn (https://github.com/Eergn)
.SH LICENSE
GNU General Public License version 3.
EOF
gzip -9n -c "$BUILD/$PKG.1" > "$ROOT/usr/share/man/man1/$PKG.1.gz"
chmod 0644 "$ROOT/usr/share/man/man1/$PKG.1.gz"

# --- control -----------------------------------------------------------------
INSTALLED_SIZE="$(du -sk "$ROOT" | cut -f1)"
cat > "$ROOT/DEBIAN/control" <<EOF
Package: $PKG
Version: $VERSION
Section: net
Priority: optional
Architecture: all
Depends: bash
Installed-Size: $INSTALLED_SIZE
Maintainer: $MAINTAINER
Homepage: $HOMEPAGE
Description: installer for network reconnaissance and diagnostic tools
 One command installs Nmap/Ncat, Netcat, arp-scan, fping, MTR, dig/whois,
 OpenSSL/testssl.sh, iperf3 and iftop/nethogs on Debian, Ubuntu, Kali and
 other supported systems. Includes an interactive menu, a dry-run mode and
 a status check.
 .
 Use only on networks and systems you own or are authorized to test.
EOF

# --- build -------------------------------------------------------------------
mkdir -p dist
OUT="dist/${PKG}_${VERSION}_all.deb"
dpkg-deb --root-owner-group --build "$ROOT" "$OUT" >/dev/null
echo "Built $OUT"
dpkg-deb -I "$OUT" | sed -n '1,12p'
