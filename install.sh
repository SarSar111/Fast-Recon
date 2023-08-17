#!/bin/bash

# Install Go language
echo "Installing Go..."
echo -e "\n"
sudo apt-get update
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -xvf go1.21.0.linux-amd64.tar.gz -C /usr/local
rm go1.21.0.linux-amd64.tar.gz

# Set Go environment variables
echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >>$HOME/.bashrc
source $HOME/.bashrc

# Install required tools
echo "Installing required tools..."
echo -e "\n"
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/rverton/webanalyze/cmd/webanalyze@latest
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
go install -v github.com/projectdiscovery/notify/cmd/notify@latest

echo "Installation completed!"
