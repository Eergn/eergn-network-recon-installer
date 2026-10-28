#!/usr/bin/env bash
# ----------------------------------------------------------------------------
#  Eergn's network reconnaissance tools installer
#  Developer: @Eergn
#
#  Installs common network diagnostic / reconnaissance utilities on
#  Debian/Ubuntu/Kali, Fedora/RHEL, Arch, openSUSE, Alpine and macOS (Homebrew).
#
#  Use these tools only on networks and systems you own or are authorized
#  to test.
# ----------------------------------------------------------------------------
set -uo pipefail

VERSION="1.0.0"
DEV="@Eergn"
TOOL_NAME="Eergn's network reconnaissance tools installer"
ALL_IDS="nmap netcat arp-scan fping mtr dns tls iperf3 bandwidth"

# ------------------------------- colours ------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  G=$'\033[1;32m'; DG=$'\033[0;32m'; R=$'\033[1;31m'; Y=$'\033[1;33m'
  C=$'\033[1;36m'; B=$'\033[1m'; D=$'\033[2m'; X=$'\033[0m'
else
  G=""; DG=""; R=""; Y=""; C=""; B=""; D=""; X=""
fi

# ------------------------------- state --------------------------------------
MODE=""            # all | select | check | list
SELECTED=""
ASSUME_YES=0
DRY_RUN=0
SHOW_BANNER=1
FORCE=0
PM=""              # detected package manager
PKGKEY=""          # key used for package-name lookup
SUDO=""
LOG="$(mktemp -t Eergn-installer.XXXXXX 2>/dev/null || echo /tmp/Eergn-installer.log)"
FAILED_PKGS=""

# ------------------------------- helpers ------------------------------------
banner() {
  printf '%s' "$G"
  cat <<'EOF'

███████╗███████╗██████╗  ██████╗ ███╗   ██╗
██╔════╝██╔════╝██╔══██╗██╔════╝ ████╗  ██║
█████╗  █████╗  ██████╔╝██║  ███╗██╔██╗ ██║
██╔══╝  ██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║
███████╗███████╗██║  ██║╚██████╔╝██║ ╚████║
╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
EOF
  printf '%s' "$X"
  printf '%s  %s%s\n' "$B" "$TOOL_NAME" "$X"
  printf '%s  developer: %s   |   version: %s%s\n' "$D" "$DEV" "$VERSION" "$X"
  printf '%s  Authorized use only: test networks you own or have permission to assess.%s\n\n' "$Y" "$X"
}

die()  { printf '%s[x]%s %s\n' "$R" "$X" "$*" >&2; exit 1; }
info() { printf '%s[*]%s %s\n' "$C" "$X" "$*"; }
warn() { printf '%s[!]%s %s\n' "$Y" "$X" "$*"; }
step() { printf '\n%s==>%s %s%s%s\n' "$G" "$X" "$B" "$*" "$X"; }

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

  -a, --all            Install every tool group (no menu)
  -t, --tool ID        Install one group (repeatable). See --list for IDs
  -l, --list           List tool groups and exit
  -c, --check          Show what is installed and exit
  -y, --yes            Do not ask for confirmation
  -n, --dry-run        Print the commands without running them
  -f, --force          Reinstall even if the commands are already present
      --no-banner      Hide the EERGN logo
  -v, --version        Print version
  -h, --help           Show this help

With no options in a terminal, an interactive menu is shown.
Piped/non-interactive runs install everything.

Examples:
  sudo $(basename "$0") --all -y
  sudo $(basename "$0") -t nmap -t tls
  $(basename "$0") --check
EOF
}

# --------------------------- tool definitions -------------------------------
tool_desc() {
  case "$1" in
    nmap)      echo "Nmap / Ncat       - discovery and service inspection" ;;
    netcat)    echo "Netcat            - connection troubleshooting" ;;
    arp-scan)  echo "arp-scan          - local network discovery" ;;
    fping)     echo "fping             - host reachability" ;;
    mtr)       echo "MTR               - route and latency troubleshooting" ;;
    dns)       echo "dig / whois       - DNS and registration information" ;;
    tls)       echo "OpenSSL/testssl.sh - TLS inspection" ;;
    iperf3)    echo "iperf3            - throughput testing" ;;
    bandwidth) echo "iftop / nethogs   - bandwidth visibility" ;;
    *) echo "$1" ;;
  esac
}

# commands that must exist for a group to count as installed
tool_cmds() {
  case "$1" in
    nmap)      echo "nmap ncat" ;;
    netcat)    echo "nc" ;;
    arp-scan)  echo "arp-scan" ;;
    fping)     echo "fping" ;;
    mtr)       echo "mtr" ;;
    dns)       echo "dig whois" ;;
    tls)       echo "openssl testssl.sh" ;;
    iperf3)    echo "iperf3" ;;
    bandwidth) echo "iftop nethogs" ;;
  esac
}

# package names per package manager
pkgs_for() {
  case "$PKGKEY:$1" in
    apt:nmap)       echo "nmap" ;;
    apt:netcat)     echo "netcat-openbsd" ;;
    apt:arp-scan)   echo "arp-scan" ;;
    apt:fping)      echo "fping" ;;
    apt:mtr)        echo "mtr-tiny" ;;
    apt:dns)        echo "dnsutils whois" ;;
    apt:tls)        echo "openssl" ;;
    apt:iperf3)     echo "iperf3" ;;
    apt:bandwidth)  echo "iftop nethogs" ;;

    dnf:nmap)       echo "nmap nmap-ncat" ;;
    dnf:netcat)     echo "nmap-ncat" ;;
    dnf:arp-scan)   echo "arp-scan" ;;
    dnf:fping)      echo "fping" ;;
    dnf:mtr)        echo "mtr" ;;
    dnf:dns)        echo "bind-utils whois" ;;
    dnf:tls)        echo "openssl" ;;
    dnf:iperf3)     echo "iperf3" ;;
    dnf:bandwidth)  echo "iftop nethogs" ;;

    pacman:nmap)      echo "nmap" ;;
    pacman:netcat)    echo "openbsd-netcat" ;;
    pacman:arp-scan)  echo "arp-scan" ;;
    pacman:fping)     echo "fping" ;;
    pacman:mtr)       echo "mtr" ;;
    pacman:dns)       echo "bind whois" ;;
    pacman:tls)       echo "openssl" ;;
    pacman:iperf3)    echo "iperf3" ;;
    pacman:bandwidth) echo "iftop nethogs" ;;

    zypper:nmap)      echo "nmap" ;;
    zypper:netcat)    echo "netcat-openbsd" ;;
    zypper:arp-scan)  echo "arp-scan" ;;
    zypper:fping)     echo "fping" ;;
    zypper:mtr)       echo "mtr" ;;
    zypper:dns)       echo "bind-utils whois" ;;
    zypper:tls)       echo "openssl" ;;
    zypper:iperf3)    echo "iperf" ;;
    zypper:bandwidth) echo "iftop nethogs" ;;

    apk:nmap)       echo "nmap nmap-ncat" ;;
    apk:netcat)     echo "netcat-openbsd" ;;
    apk:arp-scan)   echo "arp-scan" ;;
    apk:fping)      echo "fping" ;;
    apk:mtr)        echo "mtr" ;;
    apk:dns)        echo "bind-tools whois" ;;
    apk:tls)        echo "openssl" ;;
    apk:iperf3)     echo "iperf3" ;;
    apk:bandwidth)  echo "iftop nethogs" ;;

    brew:nmap)      echo "nmap" ;;
    brew:netcat)    echo "netcat" ;;
    brew:arp-scan)  echo "arp-scan" ;;
    brew:fping)     echo "fping" ;;
    brew:mtr)       echo "mtr" ;;
    brew:dns)       echo "bind whois" ;;
    brew:tls)       echo "openssl@3" ;;
    brew:iperf3)    echo "iperf3" ;;
    brew:bandwidth) echo "iftop nethogs" ;;
  esac
}

# native testssl.sh package (if the distro has one); git fallback otherwise
testssl_pkg() {
  case "$PKGKEY" in
    apt|pacman|apk) echo "testssl.sh" ;;
    dnf|brew)       echo "testssl" ;;
    *)              echo "" ;;
  esac
}

# ------------------------------ detection -----------------------------------
have_cmd() {
  case "$1" in
    nc)         command -v nc >/dev/null 2>&1 || command -v ncat >/dev/null 2>&1 || command -v netcat >/dev/null 2>&1 ;;
    testssl.sh) command -v testssl.sh >/dev/null 2>&1 || command -v testssl >/dev/null 2>&1 ;;
    *)          command -v "$1" >/dev/null 2>&1 ;;
  esac
}

tool_ok() {
  local c
  for c in $(tool_cmds "$1"); do have_cmd "$c" || return 1; done
  return 0
}

detect_pm() {
  if [ "$(uname -s)" = "Darwin" ]; then
    command -v brew >/dev/null 2>&1 || die "Homebrew is required on macOS: https://brew.sh"
    PM=brew; PKGKEY=brew
  elif command -v apt-get >/dev/null 2>&1; then PM=apt;    PKGKEY=apt
  elif command -v dnf     >/dev/null 2>&1; then PM=dnf;    PKGKEY=dnf
  elif command -v yum     >/dev/null 2>&1; then PM=yum;    PKGKEY=dnf
  elif command -v pacman  >/dev/null 2>&1; then PM=pacman; PKGKEY=pacman
  elif command -v zypper  >/dev/null 2>&1; then PM=zypper; PKGKEY=zypper
  elif command -v apk     >/dev/null 2>&1; then PM=apk;    PKGKEY=apk
  else die "No supported package manager found (apt, dnf, yum, pacman, zypper, apk, brew)."
  fi
}

setup_privileges() {
  if [ "$PM" = "brew" ]; then
    [ "$(id -u)" -ne 0 ] || die "Homebrew must not be run as root. Run without sudo."
    SUDO=""
  elif [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then SUDO="sudo"
    else die "Root privileges required. Re-run as root or install sudo."
    fi
  fi
}

# ------------------------------ execution -----------------------------------
# run: honour --dry-run, log everything else
run() {
  if [ "$DRY_RUN" = 1 ]; then
    printf '     %s$ %s%s\n' "$D" "$*" "$X"
    return 0
  fi
  "$@" >>"$LOG" 2>&1
}

refresh_index() {
  step "Refreshing package index ($PM)"
  case "$PM" in
    apt)    run $SUDO apt-get update ;;
    zypper) run $SUDO zypper --non-interactive refresh ;;
    apk)    run $SUDO apk update ;;
    *)      info "Nothing to refresh for $PM" ;;
  esac
}

pm_install() {
  case "$PM" in
    apt)    run $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y "$1" ;;
    dnf)    run $SUDO dnf install -y "$1" ;;
    yum)    run $SUDO yum install -y "$1" ;;
    pacman) run $SUDO pacman -S --needed --noconfirm "$1" ;;
    zypper) run $SUDO zypper --non-interactive install "$1" ;;
    apk)    run $SUDO apk add "$1" ;;
    brew)   run brew install "$1" ;;
  esac
}

install_pkg() {
  local pkg="$1"
  printf '   %s*%s %-18s ' "$DG" "$X" "$pkg"
  if pm_install "$pkg"; then
    printf '%sok%s\n' "$G" "$X"
    return 0
  fi
  printf '%sfailed%s\n' "$R" "$X"
  FAILED_PKGS="$FAILED_PKGS $pkg"
  return 1
}

install_testssl_git() {
  [ "$PM" = "brew" ] && return 1
  command -v git >/dev/null 2>&1 || { install_pkg git || return 1; }
  printf '   %s*%s %-18s ' "$DG" "$X" "testssl.sh (git)"
  if [ -d /opt/testssl.sh/.git ]; then
    run $SUDO git -C /opt/testssl.sh pull --ff-only || { printf '%sfailed%s\n' "$R" "$X"; return 1; }
  else
    run $SUDO git clone --depth 1 https://github.com/testssl/testssl.sh.git /opt/testssl.sh \
      || { printf '%sfailed%s\n' "$R" "$X"; return 1; }
  fi
  run $SUDO ln -sf /opt/testssl.sh/testssl.sh /usr/local/bin/testssl.sh \
    || { printf '%sfailed%s\n' "$R" "$X"; return 1; }
  printf '%sok%s\n' "$G" "$X"
}

ensure_testssl() {
  have_cmd testssl.sh && return 0
  local p
  p="$(testssl_pkg)"
  if [ -n "$p" ]; then install_pkg "$p" && return 0; fi
  [ "$DRY_RUN" = 1 ] && { install_testssl_git; return 0; }
  have_cmd testssl.sh || install_testssl_git
}

install_tool() {
  local id="$1" pkg
  step "$(tool_desc "$id")"
  if [ "$FORCE" = 0 ] && [ "$DRY_RUN" = 0 ] && tool_ok "$id"; then
    printf '   %s*%s already installed, skipping (use --force to reinstall)\n' "$DG" "$X"
    return 0
  fi
  for pkg in $(pkgs_for "$id"); do
    install_pkg "$pkg"
  done
  [ "$id" = "tls" ] && ensure_testssl
  return 0
}

# ------------------------------- reporting ----------------------------------
print_status() {
  local id c all_ok=0 line
  printf '\n%s%s%s\n' "$B" "Tool status" "$X"
  printf '%s%s%s\n' "$D" "------------------------------------------------------------" "$X"
  for id in "$@"; do
    line=""
    for c in $(tool_cmds "$id"); do
      if have_cmd "$c"; then line="$line ${G}+${X}$c"
      else line="$line ${R}-${X}$c"; all_ok=1
      fi
    done
    printf ' %-10s%s\n' "$id" "$line"
  done
  printf '%s%s%s\n' "$D" "------------------------------------------------------------" "$X"
  return $all_ok
}

# -------------------------------- menu --------------------------------------
list_tools() {
  local i=1 id
  for id in $ALL_IDS; do
    printf '  %s%2d%s) %-10s %s\n' "$G" "$i" "$X" "$id" "$(tool_desc "$id")"
    i=$((i + 1))
  done
}

valid_id() {
  local id
  for id in $ALL_IDS; do [ "$id" = "$1" ] && return 0; done
  return 1
}

menu() {
  local ans n id i pick=""
  printf '%sSelect tools to install%s\n\n' "$B" "$X"
  list_tools
  printf '\n  %sa%s) all tools    %sq%s) quit\n\n' "$G" "$X" "$G" "$X"
  printf 'Choice (e.g. "1 3 5", or "a"): '
  read -r ans || exit 1
  case "$ans" in
    q|Q) exit 0 ;;
    a|A|"") SELECTED="$ALL_IDS"; return ;;
  esac
  for n in $ans; do
    case "$n" in
      *[!0-9]*) die "Invalid choice: $n" ;;
    esac
    i=1
    for id in $ALL_IDS; do
      [ "$i" = "$n" ] && pick="$pick $id"
      i=$((i + 1))
    done
  done
  [ -n "$pick" ] || die "Nothing selected."
  SELECTED="$pick"
}

confirm() {
  [ "$ASSUME_YES" = 1 ] && return 0
  [ -t 0 ] || return 0
  printf '\nInstall %s group(s) using %s%s%s? [Y/n] ' "$(echo "$SELECTED" | wc -w | tr -d ' ')" "$B" "$PM" "$X"
  local a; read -r a || exit 1
  case "$a" in n|N|no|NO) info "Aborted."; exit 0 ;; esac
}

# --------------------------------- args -------------------------------------
while [ $# -gt 0 ]; do
  case "$1" in
    -a|--all)       MODE="all" ;;
    -t|--tool)      shift; [ $# -gt 0 ] || die "--tool needs an ID"
                    valid_id "$1" || die "Unknown tool ID: $1 (see --list)"
                    SELECTED="$SELECTED $1"; MODE="select" ;;
    -l|--list)      MODE="list" ;;
    -c|--check)     MODE="check" ;;
    -y|--yes)       ASSUME_YES=1 ;;
    -n|--dry-run)   DRY_RUN=1 ;;
    -f|--force)     FORCE=1 ;;
    --no-banner)    SHOW_BANNER=0 ;;
    -v|--version)   echo "$TOOL_NAME $VERSION by $DEV"; exit 0 ;;
    -h|--help)      [ "$SHOW_BANNER" = 1 ] && banner; usage; exit 0 ;;
    *)              die "Unknown option: $1 (try --help)" ;;
  esac
  shift
done

# --------------------------------- main -------------------------------------
[ "$SHOW_BANNER" = 1 ] && banner

case "$MODE" in
  list)  list_tools; exit 0 ;;
  check) print_status $ALL_IDS; exit $? ;;
  all)   SELECTED="$ALL_IDS" ;;
  "")    if [ -t 0 ] && [ -t 1 ]; then menu; else SELECTED="$ALL_IDS"; fi ;;
esac

detect_pm
setup_privileges
info "Package manager : $PM"
info "Log file        : $LOG"
[ "$DRY_RUN" = 1 ] && warn "Dry run: no changes will be made."
confirm

refresh_index
for id in $SELECTED; do
  install_tool "$id"
done

print_status $SELECTED
rc=$?

if [ -n "$FAILED_PKGS" ]; then
  printf '\n%s[!]%s Packages that failed:%s\n' "$Y" "$X" "$FAILED_PKGS"
  case "$PM" in
    dnf|yum) warn "On RHEL/CentOS/Alma/Rocky, arp-scan, iftop and nethogs need EPEL: sudo $PM install epel-release" ;;
  esac
  warn "Details: $LOG"
fi

if [ "$DRY_RUN" = 1 ]; then
  info "Dry run finished."
  exit 0
fi

if [ "$rc" -eq 0 ]; then
  printf '\n%sAll selected tools are ready.%s Happy (authorized) hunting. - %s\n' "$G" "$X" "$DEV"
else
  printf '\n%sSome tools are missing.%s Check the log above and retry.\n' "$Y" "$X"
fi
exit $rc
