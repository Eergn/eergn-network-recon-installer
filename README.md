# greenk's network reconnaissance tools installer

```
 ██████╗ ██████╗ ███████╗███████╗███╗   ██╗██╗  ██╗
██╔════╝ ██╔══██╗██╔════╝██╔════╝████╗  ██║██║ ██╔╝
██║  ███╗██████╔╝█████╗  █████╗  ██╔██╗ ██║█████╔╝
██║   ██║██╔══██╗██╔══╝  ██╔══╝  ██║╚██╗██║██╔═██╗
╚██████╔╝██║  ██║███████╗███████╗██║ ╚████║██║  ██╗
 ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝
```

A single-file Bash CLI that installs a standard toolkit of network discovery and diagnostic utilities on Linux and macOS.

**Developer:** [@greenk](https://github.com/greenk)

> **Authorized use only.** These tools can generate traffic that looks like scanning. Use them only on networks and systems you own or have explicit permission to assess.

---

## Table of contents

1. [What gets installed](#what-gets-installed)
2. [Supported platforms](#supported-platforms)
3. [Quick start](#quick-start)
4. [Usage](#usage)
5. [Examples](#examples)
6. [How it works](#how-it-works)
7. [Quick reference for the installed tools](#quick-reference-for-the-installed-tools)
8. [Troubleshooting](#troubleshooting)
9. [Contributing](#contributing)
10. [License](#license)

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

## Quick start

```bash
git clone https://github.com/greenk/<your-repo-name>.git
cd <your-repo-name>
chmod +x greenk-recon-installer.sh
sudo ./greenk-recon-installer.sh
```

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
Usage: greenk-recon-installer.sh [options]

  -a, --all            Install every tool group (no menu)
  -t, --tool ID        Install one group (repeatable). See --list for IDs
  -l, --list           List tool groups and exit
  -c, --check          Show what is installed and exit
  -y, --yes            Do not ask for confirmation
  -n, --dry-run        Print the commands without running them
  -f, --force          Reinstall even if the commands are already present
      --no-banner      Hide the GREENK logo
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
sudo ./greenk-recon-installer.sh --all -y

# Install only Nmap/Ncat and the TLS tools
sudo ./greenk-recon-installer.sh -t nmap -t tls

# See what a full install would run, without changing anything
./greenk-recon-installer.sh --all --dry-run

# Audit the current machine
./greenk-recon-installer.sh --check

# Use in a provisioning script (no logo, no prompts)
sudo ./greenk-recon-installer.sh --all -y --no-banner
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

## Contributing

Issues and pull requests are welcome.

- Add a new tool by editing `ALL_IDS`, `tool_desc`, `tool_cmds` and `pkgs_for` in `greenk-recon-installer.sh`.
- Add a new package manager in `detect_pm`, `pm_install` and `pkgs_for`.
- Before submitting, run `bash -n greenk-recon-installer.sh` and `./greenk-recon-installer.sh --all --dry-run`.

## License

Add a license file of your choice (for example MIT) and reference it here.

---

Made by [@greenk](https://github.com/greenk)
