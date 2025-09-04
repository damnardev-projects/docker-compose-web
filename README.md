## Docker Compose Web

[![en](https://img.shields.io/badge/lang-en-blue.svg)](README.md)
[![fr](https://img.shields.io/badge/lang-fr-blue.svg)](README.fr.md)

## Introduction

This project provides a ready-to-use Docker Compose configuration to launch NGINX + PHP-FPM, all containerized in Docker. It offers a streamlined foundation for developing PHP applications using NGINX + PHP-FPM as the PHP processing engine. The project includes a comprehensive management script (`docker-manager.sh`) that simplifies Docker operations and provides an intuitive interface for managing your containerized services.

## Software Versions

This Docker Compose setup includes the following software versions:

| Software | Version |
|----------|---------|
| NGINX    | 1.29.1  |
| PHP-FPM  | 8.4     |

### Project Structure

```text
.
├── .github/
│   └── workflows/          # GitHub Actions workflows
├── config/
│   ├── nginx.conf          # NGINX configuration
│   └── php.ini             # PHP configuration
├── .env.example            # Development environment variables
├── docker-compose.yml      # Docker Compose configuration
├── docker-manager.sh       # Management script for Docker operations
├── LICENSE                 # Project license
├── README.md               # This file
└── www/                    # Root directory for PHP files
```

### Prerequisites

Before using this Docker Web setup, make sure you have the following tools installed:

- **Docker**: Container platform (version 20.10 or higher recommended)
- **Docker Compose**: Multi-container Docker applications (version 2.0 or higher)

## Usage

### Installation

1. Clone or download this repository to your local machine
2. Navigate to the project directory
3. Make the management script executable:
   ```bash
   chmod +x docker-manager.sh
   ```
4. Ensure Docker and Docker Compose are running

### Configuration

To get started, create a `.env` file by copying the `.env.example` file as a starting point:

```bash
cp .env.example .env
```

Configure your environment variables in the appropriate file according to your deployment target. The script automatically uses `.env` by default.

| Variable     | Description                                             |
|--------------|---------------------------------------------------------|
| NAME         | Project name (used in container names)                  |
| EXPOSE_PHP   | Port on which PHP-FPM will be exposed                   |
| EXPOSE_NGINX | Port on which NGINX will be exposed                     |

### Running the Project

Use the `docker-manager.sh` script to manage your Docker containers. The script provides the following commands:

| Command                                 | Description                                                        |
|------------------------------------------|--------------------------------------------------------------------|
| `./docker-manager.sh start`              | Start all Docker containers in detached mode                       |
| `./docker-manager.sh stop`               | Stop all running Docker containers                                 |
| `./docker-manager.sh restart`            | Stop then start all Docker containers                              |
| `./docker-manager.sh status`             | Show the current status of all containers                          |
| `./docker-manager.sh logs [CONTAINER]`   | Show logs for all containers or a specific container               |
| `./docker-manager.sh connect [SERVICE]`  | Connect to a running container                                    |
| `./docker-manager.sh env`                | Display current environment variables                              |
| `./docker-manager.sh recreate`           | Pull latest images, rebuild and recreate containers                |
| `./docker-manager.sh prune`              | Remove stopped containers and unused images/volumes                |
| `./docker-manager.sh backup`             | Create a backup of all Docker volumes                              |
| `./docker-manager.sh restore [FILE]`     | Restore Docker volumes from the backup file                        |
| `./docker-manager.sh help`               | Show help information with all available commands                  |
