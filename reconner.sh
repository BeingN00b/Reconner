#!/bin/bash

# ========================================================
# Recon Script by djinfosec ⚔️
# GitHub: https://github.com/BeingN00b
# ========================================================

file_path="/absolute/path/to/tools"  # 🔧 Change this to your actual tools directory
mkdir -p "$file_path/logs"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
YELLOW='\033[1;33m'

banner() {
  echo -e "${YELLOW}"
  echo "============================================================"
  echo "           ⚔️  Recon Script by djinfosec  ⚔️"
  echo "============================================================"
  echo -e "${NC}"
}

subdomain() {
  echo -e "${GREEN}[+] Enumerating subdomains and fetching favicons 🔍${NC}"
  assetfinder --subs-only "$1" | httprobe | tee -a "$file_path/$1.txt" | python3 "$file_path/FavFreak/favfreak.py" -o output --shodan
}

subcheck() {
  echo -e "${GREEN}[+] Checking for Subdomain Takeover 🛡️${NC}"
  subjack -w "$file_path/$1.txt" -t 100 -o "$file_path/$1_TOC.txt" -ssl -c "$file_path/subjack/fingerprints.json" -v
}

cloudfail() {
  echo -e "${GREEN}[+] Checking for Cloudflare Bypass ☁️${NC}"
  (cd "$file_path" && python3 CloudFail/cloudfail.py -t "$1")
}

corscanner() {
  echo -e "${GREEN}[+] Scanning for CORS Misconfigurations 🌐${NC}"
  python3 "$file_path/cors_scan.py" -i "$file_path/$1.txt" -t 200 -o "$file_path/$1_COR.txt"
}

smuggler() {
  echo -e "${GREEN}[+] Running HTTP Request Smuggling check 🧨${NC}"
  cat "$file_path/$1.txt" | python3 "$file_path/smuggler/smuggler.py" | tee -a "$file_path/smuggler/$1_smuggler.txt"
}

scripthunter() {
  echo -e "${GREEN}[+] Running ScriptHunter 🧙‍♂️${NC}"
  (cd "$file_path/scripthunter" && ./scripthunter.sh "$1" | tee -a "$file_path/results/scripts/${1}_Scripts.txt")
}

arjun() {
  echo -e "${GREEN}[+] Discovering hidden GET params with Arjun 🔎${NC}"
  python3 "$file_path/arjun/arjun.py" -u "$1" --get -oT "$file_path/${1}_arjun.txt"
}

recon_all() {
  banner
  subdomain "$1"
  subcheck "$1"
  cloudfail "$1"
  corscanner "$1"
  smuggler "$1"
  scripthunter "$1"
  arjun "$1"
  echo -e "${GREEN}✅ Recon complete for: $1${NC}"
}

usage() {
  echo -e "${RED}[!] Usage: bash recon.sh <domain> [--full|--subdomain|--cors|--smuggler|--arjun|--cloudfail|--scripts]${NC}"
  exit 1
}

if [[ $# -lt 2 ]]; then
  usage
fi

DOMAIN="$1"
COMMAND="$2"

case "$COMMAND" in
  --full) recon_all "$DOMAIN" ;;
  --subdomain) subdomain "$DOMAIN" ;;
  --subcheck) subcheck "$DOMAIN" ;;
  --cloudfail) cloudfail "$DOMAIN" ;;
  --cors) corscanner "$DOMAIN" ;;
  --smuggler) smuggler "$DOMAIN" ;;
  --scripts) scripthunter "$DOMAIN" ;;
  --arjun) arjun "$DOMAIN" ;;
  *) usage ;;
esac
