# Development Environment Setup Script

## Overview
This script automates the installation and setup of essential development tools for backend developers, particularly those working with PHP and Laravel on **Ubuntu**. It configures Git, Docker, PHP 8.3, Composer, Node.js, NPM, Net-Tools and various applications via Snap, streamlining the environment setup process.

## Features
- Installs Git and configures user credentials
- Generates SSH keys for GitHub access
- Installs Docker and adds the user to the Docker group
- Installs PHP 8.3 with necessary extensions
- Installs PostgreSQL client
- Installs Composer for PHP dependency management
- Installs Node.js and npm
- Installs Net-Tools
- Installs Snap and popular applications like VLC, Discord, Beekeeper Studio, Postman, PhpStorm, and Visual Studio Code

## Requirements
- Ubuntu 20.04 or later
- sudo privileges

## Usage
1. Clone the repository:
   ```bash
   git clone https://github.com/DevKandil/php-dev-environment.git
   cd php-dev-environment
   ```
   
2. Make the script executable:
   ```bash
   chmod +x setup_dev_tools.sh
   ```

3. Run the script:
   ```bash
   ./setup_dev_tools.sh
   ```

4. Follow the prompts to configure Git and other tools as needed.

## Script Details
- **Script Name:** `setup_dev_tools.sh`
- **Creator:** Abdelrazek Kandil
- **License:** MIT License

## Contribution
Feel free to contribute by submitting issues or pull requests.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
