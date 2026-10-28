#!/usr/bin/env bash
# ----------------------------------------------------------------------------
#  Creates a PUBLIC GitHub Project (roadmap) for eergn-recon-installer,
#  links it to the repository, and adds one issue per planned tool group or
#  feature. Each tool-group issue contains a checklist of the tools to cover.
#  Developer: @Eergn
#
#  Requirements:
#    * GitHub CLI (gh), logged in with a token that has the scopes:
#        repo, read:org, project
#      (Projects v2 for personal accounts needs a *classic* token; fine-grained
#       tokens cannot manage user-level projects.)
#
#  Usage:
#    ./make-roadmap.sh --dry-run     show what would be created
#    ./make-roadmap.sh               create everything (run it ONCE)
#
#  Edit the TOOLS and FEATURES lists below before running.
#    TOOLS     lines:  "Title|Description|Tool1,Tool2,Tool3"
#    FEATURES  lines:  "Title|Description"
# ----------------------------------------------------------------------------
set -euo pipefail

OWNER="Eergn"
REPO="Eergn/eergn-network-recon-installer"
TITLE="eergn-recon-installer Roadmap"
DESC="Planned tools and features for eergn-recon-installer. Suggestions welcome: open an issue."
README_TXT="Public roadmap for eergn-recon-installer. Each card is an issue. Want something added? Open an issue in the repository."

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

# ---------------------------------------------------------------------------
# New tool groups (ordered roughly by priority)
# ---------------------------------------------------------------------------
TOOLS=(
"Network traffic and detection|Packet capture, analysis and network IDS/IPS.|Wireshark,TShark,tcpdump,Suricata,Zeek,Snort,Arkime"
"Network diagnostics extras|Small additions to the existing diagnostics group.|socat,traceroute"
"Auditing and hardening|Host auditing, integrity monitoring and brute-force protection.|Lynis,AIDE,auditd,Fail2ban,CrowdSec,UFW"
"VPS monitoring stack|Metrics, dashboards, uptime checks and alerting.|Prometheus,Grafana,Node Exporter,Alertmanager,Blackbox Exporter,Uptime Kuma,Netdata"
"Endpoint security and visibility|Endpoint monitoring, querying and DFIR collection.|Wazuh agent,osquery,Velociraptor,ClamAV,Falco"
"SIEM and log management|Central log platforms and log forwarders. Pick one platform first.|Wazuh server,Elastic Stack,OpenSearch,Graylog,Grafana Loki + Alloy,Fluent Bit,Vector"
"Threat hunting and intelligence|Rule-based detection and threat intelligence tools.|YARA,Sigma,CyberChef,MISP,OpenCTI"
"Digital forensics and incident response|Disk, memory and timeline forensics.|The Sleuth Kit,Autopsy,Volatility 3,Plaso,Timesketch,bulk_extractor,ExifTool,PhotoRec/TestDisk"
"Containers and virtualization|Container engines and local virtualization for isolated labs.|Docker Engine,Docker Compose,Podman,Buildah,KVM/QEMU,libvirt,virt-manager"
"Web application testing|Authorized web application security testing.|OWASP ZAP,Burp Suite Community,Nikto,Gobuster,ffuf,WhatWeb,Nuclei,SQLmap,Wapiti"
"Vulnerability and code scanning|Image, dependency, code and infrastructure scanners.|Greenbone Community Edition,Trivy,Grype,OSV-Scanner,Semgrep,Checkov,Gitleaks,TruffleHog"
"Reverse engineering and malware analysis|Static and dynamic analysis tooling. Intended for isolated VMs.|Ghidra,GDB,strace,ltrace,Radare2,Cutter,Detect It Easy,FLOSS"
"Wireless auditing|Authorized wireless assessment tools. Hardware support varies.|Aircrack-ng,Kismet,Bettercap,Wifite,hcxtools"
"Password auditing|Authorized password strength auditing and password management.|John the Ripper,Hashcat,KeePassXC"
"Identity, secrets and backups|Encryption, secret management, backups and everyday admin utilities.|age,GnuPG,SOPS,Restic,BorgBackup,Certbot,step-ca,smartmontools,ncdu,lm-sensors,sysstat"
)

# ---------------------------------------------------------------------------
# Installer features
# ---------------------------------------------------------------------------
FEATURES=(
"Add install profiles|Install a preset bundle with one flag, for example --profile minimal, --profile soc, --profile vps or --profile pentest."
"Add --sysinfo hardware report|Read-only report of OS, CPU, virtualization support, RAM and disk to help plan VMs and services."
"Add --uninstall option|Remove the tools the installer added."
"Add --update option|Upgrade already-installed tools."
"Detect Kali and warn about mixed repositories|Detect Kali/Parrot hosts and warn against mixing Kali repositories into Ubuntu APT sources."
"Support vendor repositories and containers|Install tools that are not in default distro repositories (Wazuh, Docker, Grafana) from official repos or containers, with signature checks."
"Add shell completions (bash and zsh)|Tab completion for options and tool IDs."
"Add JSON output for --check|Machine-readable status for scripts and CI."
"Support WSL and Termux|Detect and handle Windows Subsystem for Linux and Termux."
"Publish RPM package|Native package for Fedora and RHEL users."
"Publish Homebrew tap|Install on macOS with brew install."
"Publish Docker image|Run the toolkit in a container."
"Add automated tests and CI|ShellCheck and dry-run tests in GitHub Actions."
)

say() { printf '%s\n' "$*"; }

# Builds the issue body.  $1=kind  $2=description  $3=comma-separated tools (optional)
build_body() {
  local kind="$1" desc="$2" items="${3:-}" body i
  local -a arr
  body="$desc"
  if [ -n "$items" ]; then
    body+=$'\n\n'"Tools to cover:"$'\n'
    IFS=',' read -ra arr <<< "$items"
    for i in "${arr[@]}"; do body+="- [ ] $i"$'\n'; done
  fi
  body+=$'\n'"Status: planned. Comments and suggestions are welcome."
  if [ "$kind" = "tool" ]; then
    body+=$'\n\n'"Notes: some of these tools are not in the default Ubuntu/Debian repositories and may need the vendor's official repository or a container. Use them only on systems and networks you own or are explicitly authorized to assess."
  fi
  printf '%s' "$body"
}

if [ "$DRY_RUN" = 1 ]; then
  say "DRY RUN: nothing will be created."
  say "Project : $TITLE (PUBLIC, owner $OWNER, linked to $REPO)"
  say
  say "Tool-group issues (${#TOOLS[@]}):"
  for t in "${TOOLS[@]}"; do
    IFS='|' read -r title desc items <<< "$t"
    n="$(printf '%s' "$items" | tr ',' '\n' | grep -c .)"
    say "  - $title ($n tools)"
  done
  say
  say "Feature issues (${#FEATURES[@]}):"
  for f in "${FEATURES[@]}"; do say "  - ${f%%|*}"; done
  say
  say "Sample issue body:"
  say "------------------------------------------------------------"
  IFS='|' read -r title desc items <<< "${TOOLS[0]}"
  say "Title: $title"
  build_body tool "$desc" "$items"
  say
  say "------------------------------------------------------------"
  exit 0
fi

command -v gh >/dev/null 2>&1 || { say "error: gh not found (sudo apt install gh)"; exit 1; }
gh auth status >/dev/null 2>&1 || { say "error: not logged in. Run: gh auth login"; exit 1; }
if ! gh auth status 2>&1 | grep -q "project"; then
  say "error: your token lacks the 'project' scope."
  say "Create a classic token with scopes: repo, read:org, project"
  say "  https://github.com/settings/tokens/new"
  say "then run: gh auth logout && gh auth login"
  exit 1
fi

# --- labels ------------------------------------------------------------------
say "==> Creating labels"
gh label create roadmap --color 0E8A16 --description "Planned work" -R "$REPO" 2>/dev/null || true
gh label create tool    --color 1D76DB --description "A tool group to add to the installer" -R "$REPO" 2>/dev/null || true
gh label create feature --color 5319E7 --description "An installer feature" -R "$REPO" 2>/dev/null || true

# --- project -----------------------------------------------------------------
say "==> Creating public project"
NUM="$(gh project create --owner "$OWNER" --title "$TITLE" --format json --jq .number)"
gh project edit "$NUM" --owner "$OWNER" --visibility PUBLIC \
  --description "$DESC" --readme "$README_TXT" >/dev/null
gh project link "$NUM" --owner "$OWNER" --repo "$REPO" >/dev/null
say "    Project #$NUM created, public, linked to $REPO"

# --- issues ------------------------------------------------------------------
add_issue() {
  local kind="$1" entry="$2" title desc items url
  IFS='|' read -r title desc items <<< "$entry"
  url="$(gh issue create -R "$REPO" --title "$title" \
          --body "$(build_body "$kind" "$desc" "${items:-}")" \
          --label roadmap --label "$kind")"
  gh project item-add "$NUM" --owner "$OWNER" --url "$url" >/dev/null
  say "    + $title"
}

say "==> Adding tool-group issues"
for t in "${TOOLS[@]}"; do add_issue tool "$t"; done
say "==> Adding feature issues"
for f in "${FEATURES[@]}"; do add_issue feature "$f"; done

say
say "Done. Open your roadmap:"
say "  https://github.com/users/$OWNER/projects/$NUM"
say "Then, in the project, add a Board view grouped by Status."
