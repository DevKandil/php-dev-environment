#!/bin/bash

# Ensure figlet is installed silently
if ! command -v figlet &> /dev/null; then
    sudo apt-get install -y figlet > /dev/null 2>&1
fi

# Set green text color
GREEN='\e[32m'
NC='\e[0m' # No Color

# Display centered ASCII art banner for "DevKandil"
clear
echo -e "${GREEN}$(figlet "DevKandil")${NC}"

# Add author and script details
echo -e "${GREEN}------------------------------------------------------------${NC}"
echo -e "${GREEN}Installation Script                                         ${NC}"
echo -e "${GREEN}Author: Abdelrazek Kandil                                   ${NC}"
echo -e "${GREEN}Description: This script sets up essential development tools${NC}"
echo -e "${GREEN}and configures your environment.                            ${NC}"
echo -e "${GREEN}Last Modified: $(date +'%Y-%m-%d')                          ${NC}"
echo -e "${GREEN}------------------------------------------------------------${NC}"
echo ""

# Update system packages
echo -e "${GREEN}Updating system packages...${NC}"
sudo apt-get update -y && sudo apt-get upgrade -y

# Install Git
echo -e "${GREEN}Installing Git...${NC}"
if ! command -v git &> /dev/null; then
    sudo apt-get install -y git
else
    echo -e "${GREEN}Git is already installed.${NC}"
fi
echo -e "${GREEN}Git version: $(git --version)${NC}"

# Checking for existing SSH keys
echo -e "${GREEN}Checking for existing SSH keys...${NC}"
if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    echo -e "${GREEN}Existing SSH key found:${NC}"
    cat "$HOME/.ssh/id_ed25519.pub"
else

    # Prompt the user for their email to associate with the SSH key
    echo -e "${GREEN}No SSH key found. Generating a new SSH key...${NC}"
    
    # Generate a new SSH key
    read -p "Enter your email address for the SSH key: " user_email
    ssh-keygen -t ed25519 -C "$user_email"
    
    # Start the SSH agent and add the key
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    
    # Display the SSH key for easy copying to GitHub
    echo -e "${GREEN}Here is your new SSH key. Copy it to your GitHub account:${NC}"
    cat "$HOME/.ssh/id_ed25519.pub"
fi

# Check if the user wants to login to GitHub
read -p "Do you want to login to your GitHub account? (y/n): " login_to_github
if [ "$login_to_github" = "y" ]; then
    
    # Prompt for GitHub username and personal access token
    echo -e "${GREEN}Logging into GitHub...${NC}"
    read -p "Enter your GitHub username: " github_username
    read -s -p "Enter your GitHub personal access token: " github_token
    echo

    # Configure Git with GitHub credentials
    git config --global user.name "$github_username"
    git config --global user.email "$user_email" # Use the email used for SSH key generation
    echo -e "${GREEN}Git configured with username: $github_username and email: $user_email${NC}"

    # Store credentials using the Git credential helper
    git config --global credential.helper store
    echo -e "${GREEN}Credentials caching enabled for Git.${NC}"
fi

# Install Docker following official documentation
echo -e "${GREEN}Installing Docker...${NC}"

if ! command -v docker &> /dev/null; then
    # Add Docker's official GPG key
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the Docker repository to apt sources
    echo -e "${GREEN}Adding Docker repository...${NC}"
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update package list and install Docker packages
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Create docker group and add user if not already in group
    if ! groups $USER | grep &>/dev/null '\bdocker\b'; then
        sudo groupadd docker 2>/dev/null || true
        sudo usermod -aG docker $USER
        echo -e "${GREEN}Docker installed. Please log out and log back in for group permissions to take effect.${NC}"
        echo -e "${GREEN}You can do this by closing this terminal session and opening a new one, or by running 'exit' and then logging in again.${NC}"
    fi

else
    echo -e "${GREEN}Docker is already installed.${NC}"
fi

echo -e "${GREEN}Docker version: $(docker --version)${NC}"

# Install PHP 8.3 and extensions
echo -e "${GREEN}Installing PHP 8.3...${NC}"
if ! command -v php &> /dev/null || ! php -v | grep -q "PHP 8.3"; then
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt-get update -y
    sudo apt-get install -y php8.3 libapache2-mod-php php8.3-common php8.3-cli php8.3-mbstring php8.3-bcmath php8.3-fpm php8.3-mysql php8.3-zip php8.3-gd php8.3-curl php8.3-xml php8.3-intl php8.3-pgsql
else
    echo -e "${GREEN}PHP 8.3 is already installed.${NC}"
fi
echo -e "${GREEN}PHP version: $(php -v)${NC}"

# Install PostgreSQL client
echo -e "${GREEN}Installing PostgreSQL client...${NC}"
if ! command -v psql &> /dev/null; then
    sudo apt-get install -y postgresql-client
else
    echo -e "${GREEN}PostgreSQL client is already installed.${NC}"
fi

# Install Composer
echo -e "${GREEN}Installing Composer...${NC}"
if ! command -v composer &> /dev/null; then
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    EXPECTED_CHECKSUM="dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6"
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
    if [ "$EXPECTED_CHECKSUM" = "$ACTUAL_CHECKSUM" ]; then
        php composer-setup.php
        sudo mv composer.phar /usr/local/bin/composer
        echo -e "${GREEN}Composer installed successfully.${NC}"
    else
        echo -e "${GREEN}Composer installer corrupt. Exiting.${NC}"
        rm -f composer-setup.php
        exit 1
    fi
    php -r "unlink('composer-setup.php');"
else
    echo -e "${GREEN}Composer is already installed.${NC}"
fi
echo -e "${GREEN}Composer version: $(composer --version 2>/dev/null)${NC}"

# Install Node.js 22 and npm
echo -e "${GREEN}Installing Node.js 22 and npm...${NC}"
if ! command -v node &> /dev/null || ! node -v | grep -q "^v22"; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo -e "${GREEN}Node.js 22 is already installed.${NC}"
fi
echo -e "${GREEN}Node.js version: $(node -v)${NC}"
echo -e "${GREEN}NPM version: $(npm -v)${NC}"

# Install net-tools for network management
echo -e "${GREEN}Installing net-tools...${NC}"
if ! command -v ifconfig &> /dev/null; then
    sudo apt-get install -y net-tools
else
    echo -e "${GREEN}Net-tools is already installed.${NC}"
fi

# Get the local IP address
LOCAL_IP=$(ifconfig | grep -oP 'inet \K192\.168\.\d+\.\d+')

# Display the IP address and set it as default (informing the user)
if [ -n "$LOCAL_IP" ]; then
    echo -e "${GREEN}Your local IP address is: $LOCAL_IP${NC}"
else
    echo -e "${GREEN}Could not retrieve a local IP address in the 192.168.x.x range.${NC}"
fi

# Install Snap and applications
echo -e "${GREEN}Installing Snap...${NC}"
if ! command -v snap &> /dev/null; then
    sudo apt-get install -y snapd
else
    echo -e "${GREEN}Snap is already installed.${NC}"
fi

# Install applications using Snap
echo -e "${GREEN}Installing applications via Snap...${NC}"
declare -a apps=("vlc" "discord" "beekeeper-studio" "postman")

for app in "${apps[@]}"; do
    if ! snap list | grep -q "$app"; then
        echo -e "${GREEN}Installing $app...${NC}"
        sudo snap install "$app"
    else
        echo -e "${GREEN}$app is already installed.${NC}"
    fi
done

# Install classic confinement applications separately
declare -a classic_apps=("phpstorm" "code")

for app in "${classic_apps[@]}"; do
    if ! snap list | grep -q "$app"; then
        echo -e "${GREEN}Installing $app with classic confinement...${NC}"
        sudo snap install "$app" --classic
    else
        echo -e "${GREEN}$app is already installed.${NC}"
    fi
done

echo -e "${GREEN}All installations are complete!${NC}"

exit 0