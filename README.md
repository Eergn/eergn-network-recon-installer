# Eergn's network reconnaissance tools installer

```
███████╗███████╗██████╗  ██████╗ ███╗   ██╗
██╔════╝██╔════╝██╔══██╗██╔════╝ ████╗  ██║
█████╗  █████╗  ██████╔╝██║  ███╗██╔██╗ ██║
██╔══╝  ██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║
███████╗███████╗██║  ██║╚██████╔╝██║ ╚████║
╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
```

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)

A single-file Bash CLI that installs a standard toolkit of network discovery and diagnostic utilities on Linux and macOS.

**Developer:** [@Eergn](https://github.com/Eergn)

> **Authorized use only.** These tools can generate traffic that looks like scanning. Use them only on networks and systems you own or have explicit permission to assess.

---

## Table of contents

1. [What gets installed](#what-gets-installed)
2. [Supported platforms](#supported-platforms)
3. [Installation](#installation)
4. [Quick start](#quick-start)
5. [Usage](#usage)
6. [Examples](#examples)
7. [How it works](#how-it-works)
8. [Quick reference for the installed tools](#quick-reference-for-the-installed-tools)
9. [Troubleshooting](#troubleshooting)
10. [Roadmap](#roadmap)
11. [Contributing](#contributing)
12. [License](#license)

---

## What gets installed

| ID          | Tools                | Purpose                                  |
|-------------|----------------------|------------------------------------------|
| `nmap`      | Nmap / Ncat          | Discovery and service inspection         |
| `netcat`    | Netcat               | Connection troubleshooting               |
| `arp-scan`  | arp-scan             | Local network discovery                  |
| `fping`     | fping                | Host reachability                        |
| `mtr`       | MTR                  | Route and latency troubleshooting        |
| `dns`       | dig / whois          | DNS and registration information         |
| `tls`       | OpenSSL / testssl.sh | TLS inspection                           |
| `iperf3`    | iperf3               | Throughput testing                       |
| `bandwidth` | iftop / nethogs      | Bandwidth visibility                     |

## Supported platforms

| Platform                      | Package manager |
|-------------------------------|-----------------|
| Debian, Ubuntu, Kali, Mint    | `apt`           |
| Fedora, RHEL, Rocky, Alma     | `dnf` / `yum`   |
| Arch, Manjaro                 | `pacman`        |
| openSUSE                      | `zypper`        |
| Alpine                        | `apk`           |
| macOS                         | Homebrew        |

Requirements: Bash 3.2 or newer (macOS default works), `sudo` or root on Linux, and an internet connection. On macOS, install [Homebrew](https://brew.sh) first and run the script **without** `sudo`.

## Installation

Pick one method.

**Option A: APT repository (Debian, Ubuntu, Kali, Mint) - recommended**

Add the signed repository once, then install and update like any other package:

```bash
curl -fsSL https://eergn.github.io/eergn-network-recon-installer/eergn-archive-keyring.gpg \
  | sudo tee /usr/share/keyrings/eergn-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/eergn-archive-keyring.gpg] https://eergn.github.io/eergn-network-recon-installer ./" \
  | sudo tee /etc/apt/sources.list.d/eergn.list
sudo apt update
sudo apt install eergn-recon-installer
```

Future versions arrive with `sudo apt update && sudo apt upgrade`.

**Option B: Debian package file**

Download the `.deb` from the [latest release](https://github.com/Eergn/eergn-network-recon-installer/releases/latest), then:

```bash
sudo apt install ./eergn-recon-installer_1.0.0_all.deb
sudo eergn-recon-installer
man eergn-recon-installer
```

Remove it later with `sudo apt remove eergn-recon-installer`.

**Option C: download just the script (any supported system)**

```bash
curl -LO https://github.com/Eergn/eergn-network-recon-installer/releases/latest/download/eergn-recon-installer.sh
chmod +x eergn-recon-installer.sh
sudo ./eergn-recon-installer.sh
```

**Option D: clone the repository**

```bash
git clone https://github.com/Eergn/eergn-network-recon-installer.git
cd eergn-network-recon-installer
chmod +x eergn-recon-installer.sh
sudo ./eergn-recon-installer.sh
```

To build the `.deb` yourself, run `./scripts/build-deb.sh` (needs `dpkg-deb`, from the `dpkg-dev` package). Maintainers publish the APT repository with `./scripts/make-apt-repo.sh`, which signs it and writes it to `docs/` for GitHub Pages.

## Quick start

With no options in a terminal, an interactive menu appears:

```
Select tools to install

   1) nmap       Nmap / Ncat       - discovery and service inspection
   2) netcat     Netcat            - connection troubleshooting
   ...
  a) all tools    q) quit

Choice (e.g. "1 3 5", or "a"):
```

## Usage

```
Usage: eergn-recon-installer.sh [options]

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
```

Notes:

- Running with no arguments in a terminal opens the menu. Piped or non-interactive runs install everything.
- `--check` needs no root and exits `0` only if every tool is present.
- Set `NO_COLOR=1` to disable colored output.

## Examples

```bash
# Install everything without prompts
sudo ./eergn-recon-installer.sh --all -y

# Install only Nmap/Ncat and the TLS tools
sudo ./eergn-recon-installer.sh -t nmap -t tls

# See what a full install would run, without changing anything
./eergn-recon-installer.sh --all --dry-run

# Audit the current machine
./eergn-recon-installer.sh --check

# Use in a provisioning script (no logo, no prompts)
sudo ./eergn-recon-installer.sh --all -y --no-banner
```

## How it works

1. Detects your package manager (or Homebrew on macOS).
2. Uses `sudo` only when needed (never for Homebrew).
3. Refreshes the package index where appropriate (`apt`, `zypper`, `apk`).
4. Installs each package **one at a time**, so a single missing package does not abort the run.
5. For `testssl.sh`, tries the distro package first, then falls back to cloning
   `https://github.com/testssl/testssl.sh` into `/opt/testssl.sh` and linking it into `/usr/local/bin`.
6. Skips groups whose commands already exist (override with `--force`).
7. Prints a status table and exits non-zero if anything is still missing.

Installer output is written to a temporary log file; its path is printed at the start and again if any package fails.

## Quick reference for the installed tools

```bash
# Nmap / Ncat
nmap -sV -T3 192.168.1.10          # service/version detection on one host
ncat -lvp 4444                     # listen on a port

# Netcat
nc -zv example.com 443             # test whether a port is reachable

# arp-scan (needs root)
sudo arp-scan --localnet           # list devices on the local network

# fping
fping -a -g 192.168.1.0/24 2>/dev/null   # show which hosts answer

# MTR
mtr -rw -c 20 example.com          # report-mode route and latency

# dig / whois
dig +short A example.com
whois example.com

# OpenSSL / testssl.sh
openssl s_client -connect example.com:443 -servername example.com
testssl.sh example.com

# iperf3
iperf3 -s                          # on the server
iperf3 -c <server-ip>              # on the client

# iftop / nethogs (need root)
sudo iftop -i eth0                 # bandwidth per connection
sudo nethogs                       # bandwidth per process
```

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `arp-scan`, `iftop` or `nethogs` fail on RHEL / Rocky / Alma | Enable EPEL: `sudo dnf install epel-release`, then re-run |
| `testssl.sh` not found after install | Some distros name it `testssl`. The installer accepts either name |
| `Homebrew must not be run as root` | Run without `sudo` on macOS |
| `Root privileges required` | Run as root or install `sudo` |
| A package failed | Open the log file path printed by the installer for the exact error |
| `nethogs` unavailable on macOS | It is Linux-focused; the installer will report it as failed and continue |
| Colors look broken | Run with `NO_COLOR=1` |

## Roadmap

Planned tools and features are tracked in the public [project board](https://github.com/Eergn/eergn-network-recon-installer/projects) and as [issues labeled `roadmap`](https://github.com/Eergn/eergn-network-recon-installer/issues?q=label%3Aroadmap).

Planned tool groups:

- Network traffic and detection (Wireshark, TShark, tcpdump, Suricata, Zeek, Snort, Arkime)
- Auditing and hardening (Lynis, AIDE, auditd, Fail2ban, CrowdSec)
- VPS monitoring (Prometheus, Grafana, Node Exporter, Alertmanager, Uptime Kuma)
- Endpoint security and SIEM (Wazuh, osquery, Velociraptor, Elastic, Graylog, Loki)
- Threat hunting and forensics (YARA, Sigma, Volatility 3, Autopsy, Sleuth Kit, Plaso)
- Containers and virtualization (Docker, KVM/QEMU, libvirt, virt-manager)
- Web, vulnerability and code scanning (ZAP, Nikto, Nuclei, Trivy, Grype, Semgrep, Gitleaks)
- Reverse engineering, wireless and password auditing for authorized lab use
- Identity, secrets and backups (age, SOPS, Restic, BorgBackup, KeePassXC)

Planned installer features: install profiles, a `--sysinfo` hardware report, `--uninstall`, `--update`, vendor-repository support, shell completions, JSON output, an RPM package, a Homebrew tap and a Docker image.

Want something added? [Open an issue](https://github.com/Eergn/eergn-network-recon-installer/issues/new) and describe the tool and why it belongs.

## Contributing

Issues and pull requests are welcome.

- Add a new tool by editing `ALL_IDS`, `tool_desc`, `tool_cmds` and `pkgs_for` in `eergn-recon-installer.sh`.
- Add a new package manager in `detect_pm`, `pm_install` and `pkgs_for`.
- Before submitting, run `bash -n eergn-recon-installer.sh` and `./eergn-recon-installer.sh --all --dry-run`.

## License

This project is licensed under the **GNU General Public License v3.0** (GPL-3.0). You are free to use, study, modify and share it, provided that any distributed derivative work is also released under GPL-3.0 with its source code available. The software comes with no warranty.

See the [LICENSE](LICENSE) file for the full terms.

---

Made by [@Eergn](https://github.com/Eergn)
