/* Lightweight client-side index for the documentation search.
   Paths are relative to the docs/ site root. */
window.EERGN_SEARCH_INDEX = [
  {
    title: "Documentation home",
    path: "documentation/",
    category: "Introduction",
    description: "Start here: installation, tool guides, references and responsible use.",
    keywords: "docs documentation index start help overview"
  },
  {
    title: "Installation",
    path: "installation/",
    category: "Installation",
    description: "APT repository setup, .deb install, script download, verification and removal.",
    keywords: "install apt repository keyring deb curl source list update remove upgrade"
  },
  {
    title: "Getting started",
    path: "getting-started/",
    category: "Getting started",
    description: "Go from a fresh install to a first authorized check in a lab.",
    keywords: "quick start first use terminal menu check dry run beginner"
  },
  {
    title: "Supported tools catalog",
    path: "tools/",
    category: "Supported tools",
    description: "Search and filter all 13 tools installed by the tool groups.",
    keywords: "tools catalog search filter nmap netcat arp-scan fping mtr dig whois openssl testssl iperf3 iftop nethogs"
  },
  {
    title: "Nmap",
    path: "tools/nmap/",
    category: "Supported tools",
    description: "Host discovery, port scanning, service and version detection.",
    keywords: "nmap scan port service version discovery -sV -sT -sn -p"
  },
  {
    title: "Ncat",
    path: "tools/ncat/",
    category: "Supported tools",
    description: "Nmap's netcat implementation for connecting, listening and transferring data.",
    keywords: "ncat netcat listen connect ssl broker nmap"
  },
  {
    title: "Netcat (nc)",
    path: "tools/netcat/",
    category: "Supported tools",
    description: "OpenBSD netcat for TCP/UDP reachability checks and simple connections.",
    keywords: "nc netcat openbsd tcp udp port check -zv -l -u"
  },
  {
    title: "arp-scan",
    path: "tools/arp-scan/",
    category: "Supported tools",
    description: "Layer-2 IPv4 host discovery on the local network using ARP.",
    keywords: "arp scan local network layer2 mac vendor interface localnet"
  },
  {
    title: "fping",
    path: "tools/fping/",
    category: "Supported tools",
    description: "Fast ICMP reachability checks across many hosts and ranges.",
    keywords: "fping ping sweep icmp reachability range cidr -a -g -c"
  },
  {
    title: "MTR",
    path: "tools/mtr/",
    category: "Supported tools",
    description: "Combined traceroute and ping for route and latency troubleshooting.",
    keywords: "mtr traceroute latency packet loss report mode -r -w -c"
  },
  {
    title: "dig",
    path: "tools/dig/",
    category: "Supported tools",
    description: "DNS lookups, record inspection, reverse lookups and delegation tracing.",
    keywords: "dig dns bind query record a aaaa mx ns txt reverse +short +trace"
  },
  {
    title: "whois",
    path: "tools/whois/",
    category: "Supported tools",
    description: "Domain and IP registration data from registry and registrar services.",
    keywords: "whois registration registrar domain ip contact referral"
  },
  {
    title: "OpenSSL s_client",
    path: "tools/openssl/",
    category: "Supported tools",
    description: "Inspect a single TLS endpoint's handshake, chain and negotiated parameters.",
    keywords: "openssl s_client tls ssl certificate handshake servername showcerts starttls"
  },
  {
    title: "testssl.sh",
    path: "tools/testssl/",
    category: "Supported tools",
    description: "Active TLS configuration testing for protocols, ciphers and certificate issues.",
    keywords: "testssl tls ssl scan protocol cipher certificate vulnerability"
  },
  {
    title: "iperf3",
    path: "tools/iperf3/",
    category: "Supported tools",
    description: "Client/server throughput testing over TCP or UDP.",
    keywords: "iperf3 throughput bandwidth tcp udp server client -s -c -P -R"
  },
  {
    title: "iftop",
    path: "tools/iftop/",
    category: "Supported tools",
    description: "Live bandwidth usage by host and connection on an interface.",
    keywords: "iftop bandwidth traffic interface host connection monitor"
  },
  {
    title: "nethogs",
    path: "tools/nethogs/",
    category: "Supported tools",
    description: "Live bandwidth usage grouped by process.",
    keywords: "nethogs process bandwidth traffic monitor interface"
  },
  {
    title: "Practical guides",
    path: "guides/",
    category: "Guides",
    description: "Workflows for host discovery, service discovery, DNS, TLS, throughput, results and maintenance.",
    keywords: "guides workflows practical lab discovery dns tls throughput results maintenance"
  },
  {
    title: "Host discovery in an authorized lab",
    path: "guides/host-discovery/",
    category: "Guides",
    description: "Inventory hosts on a network you own using arp-scan, fping and Nmap.",
    keywords: "host discovery inventory local network lab arp fping nmap workflow"
  },
  {
    title: "Service discovery",
    path: "guides/service-discovery/",
    category: "Guides",
    description: "Identify exposed services with Nmap and confirm reachability with Netcat.",
    keywords: "service discovery ports nmap netcat verification workflow"
  },
  {
    title: "DNS reconnaissance",
    path: "guides/dns-reconnaissance/",
    category: "Guides",
    description: "Read DNS records and registration data with dig and whois.",
    keywords: "dns recon records dig whois domain registration workflow"
  },
  {
    title: "TLS inspection",
    path: "guides/tls-inspection/",
    category: "Guides",
    description: "Inspect one endpoint with OpenSSL, then assess configuration with testssl.sh.",
    keywords: "tls ssl inspection certificate openssl testssl workflow"
  },
  {
    title: "Throughput and bandwidth",
    path: "guides/throughput-and-bandwidth/",
    category: "Guides",
    description: "Measure throughput with iperf3 and attribute traffic with iftop or nethogs.",
    keywords: "iperf3 iftop nethogs throughput bandwidth traffic measurement workflow"
  },
  {
    title: "Working with results",
    path: "guides/working-with-results/",
    category: "Guides",
    description: "Save, organize, compare and safely store reconnaissance output.",
    keywords: "output save results files logs grep diff storage sensitive report"
  },
  {
    title: "Troubleshooting installation",
    path: "guides/troubleshooting-installation/",
    category: "Guides",
    description: "Fix APT repository, package manager, dependency and PATH problems.",
    keywords: "troubleshooting install apt keyring gpg package failed dependency path"
  },
  {
    title: "Maintaining the installation",
    path: "guides/maintaining-installation/",
    category: "Guides",
    description: "Update packages, audit tool versions and remove the installer.",
    keywords: "update upgrade maintain version remove uninstall apt audit"
  },
  {
    title: "Installer command reference",
    path: "reference/commands/",
    category: "Reference",
    description: "Every installer flag, mode, exit status and environment variable.",
    keywords: "command reference cli options flags --all --tool --check --dry-run --force no-banner"
  },
  {
    title: "Architecture",
    path: "reference/architecture/",
    category: "Reference",
    description: "How the single-file installer, package metadata and APT repository fit together.",
    keywords: "architecture source code files build package apt repository installer internals"
  },
  {
    title: "Configuration",
    path: "reference/configuration/",
    category: "Reference",
    description: "What is configurable, what is detected automatically, and what is fixed.",
    keywords: "configuration config environment variables no_color package manager version"
  },
  {
    title: "Troubleshooting",
    path: "reference/troubleshooting/",
    category: "Reference",
    description: "Installer, package manager, install verification and first-use problems.",
    keywords: "troubleshooting errors log failed package missing tools root sudo brew"
  },
  {
    title: "Security and responsible use",
    path: "reference/security/",
    category: "Reference",
    description: "Authorization, repository trust, privileges, sensitive output and rate limits.",
    keywords: "security authorization scope responsible use sudo trust signing key privacy"
  },
  {
    title: "Contributing",
    path: "reference/contributing/",
    category: "Reference",
    description: "Add tool groups, package managers, docs and verification steps.",
    keywords: "contributing development add tool package manager pull request test bash -n dry run"
  }
];
