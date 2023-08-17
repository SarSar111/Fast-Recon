#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD="\e[1m"
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

domain=""

print_banner() {
    echo -e "${CYAN}${BOLD}"
    echo -e "  ______        _     _____                      "
    echo -e " |  ____|      | |   |  __ \                     "
    echo -e " | |__ __ _ ___| |_  | |__) |___  ___ ___  _ __  "
    echo -e " |  __/ _\ / __| __| |  _  // _ \/ __/ _ \| '_ \ "
    echo -e " | | | (_| \__ \ |_  | | \ \  __/ (_| (_) | | | |"
    echo -e " |_|  \__,_|___/\__| |_|  \_\___|\___\___/|_| |_|"
    echo -e "${NC}"
}

show_help_menu() {
    print_banner
    echo -e "${GREEN}Usage:${NC}"
    echo -e "  $0 [options]"
    echo
    echo -e "${GREEN}Options:${NC}"
    echo -e "  -h, --help           Display this help menu"
    echo -e "  -d, --domain DOMAIN  Specify the domain name"
}

create_directories() {
    working_dir=$(pwd)
    target_dir="$working_dir/$1"
    mkdir -p "$target_dir"
    mkdir -p "$target_dir/subdomains"
    mkdir -p "$target_dir/technologies"
    mkdir -p "$target_dir/vulnerabilities"
}

start_recon() {
    print_banner
    echo -e "\n"
    echo -e "${YELLOW}Domain: $domain${NC}"
    echo -e "\n"

    echo -e "${CYAN}Subdomain Enumeration Started....${NC}"
    echo -e "\n"
    subfinder -silent -d $domain -o "$target_dir/subdomains/subdomains.txt" && sort "$target_dir/subdomains/subdomains.txt" -u -o "$target_dir/subdomains/subdomains.txt"
    echo -e "\n"
    echo -e "${GREEN}DONE!${NC}"
    echo -e "\n"

    echo -e "${CYAN}Filtering Alive Hosts....${NC}"
    echo -e "\n"
    httpx -silent -l "$target_dir/subdomains/subdomains.txt" -o "$target_dir/subdomains/alive_subdomains.txt" && sort "$target_dir/subdomains/alive_subdomains.txt" -u -o "$target_dir/subdomains/alive_subdomains.txt"
    echo -e "\n"
    echo -e "${GREEN}DONE!${NC}"
    echo -e "\n"

    echo -e "${CYAN}Taking Screenshots....${NC}"
    echo -e "\n"
    httpx -silent -l "$target_dir/subdomains/alive_subdomains.txt" -screenshot -srd "$target_dir/screenshots"
    echo -e "\n"
    echo -e "${GREEN}DONE!${NC}"
    echo -e "\n"

    echo -e "${CYAN}Detecting Technologies....${NC}"
    echo -e "\n"
    webanalyze -update
    webanalyze -hosts "$target_dir/subdomains/alive_subdomains.txt" -silent | tee "$target_dir/technologies/subdomains_technologies.txt"
    echo -e "\n"
    echo -e "${GREEN}DONE!${NC}"
    echo -e "\n"

    echo -e "${CYAN}Finding Vulnerabilities....${NC}"
    echo -e "\n"
    nuclei -silent -l "$target_dir/subdomains/alive_subdomains.txt" -t ~/nuclei-templates/http/misconfiguration/ -c 100 | tee "$target_dir/vulnerabilities/vulnerabilities.txt"
    echo -e "\n"
    echo -e "${GREEN}DONE!${NC}"
    echo -e "\n"
}

# Check if no arguments are provided
if [[ $# -eq 0 ]]; then
    show_help_menu
    exit 1
fi

# Main logic to parse arguements and perform the requested operation
while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
        show_help_menu
        exit 0
        ;;
    -d | --domain)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Input domain is missing${NC}"
            show_help_menu
            exit 1
        fi
        domain="$2"
        create_directories "$domain"
        start_recon
        shift 2
        ;;
    *)
        echo -e "${RED}Error: Unsuppported option '$1'${NC}"
        show_help_menu
        exit 1
        ;;
    esac
done

echo -e "${GREEN}Recon completed! Results are saved in: ${target_dir}${NC}" | notify -silent -provider-config ./notify-config.yaml
