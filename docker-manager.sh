#!/bin/bash

# Color definitions for enhanced terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"
PROJECT_NAME=$(grep -E '^NAME=' "$ENV_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d '\r\n')
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME="docker-compose-php"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

empty_line() {
    echo "";
}

error_message() {
  echo -e "${RED}✗ $1${NC}"
  exit 1
}

success_message() {
  echo -e "${GREEN}✓ $1${NC}"
}

warning_message() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

step_message() {
  echo -e "${BLUE}➜ $1${NC}"
}

standard_message() {
  echo -e "${CYAN}$1${NC}"
}

display_header() {
    standard_message "╔════════════════════════════════════════╗"
    standard_message "║        Docker Compose PHP v1.0.0       ║"
    standard_message "║     Docker Compose Management Tool     ║"
    standard_message "╚════════════════════════════════════════╝"
    empty_line
}

check_prerequisites() {
    step_message "Checking prerequisites..."
    standard_message "Project Name: $PROJECT_NAME"

    if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z-]+$ ]]; then
        error_message "Invalid PROJECT_NAME format: '$PROJECT_NAME'. Only letters (a-zA-Z) and hyphens (-) are allowed."
    fi

    if ! command -v docker &> /dev/null; then
        error_message "Docker is not installed. Please install Docker and try again."
    fi

    if ! docker compose version &> /dev/null; then
        error_message "Docker Compose is not installed. Please install Docker Compose and try again."
    fi

    if ! docker info &> /dev/null; then
        error_message "Docker is not running. Please start Docker and try again."
    fi

    if [ ! -f "$COMPOSE_FILE" ]; then
        error_message "Docker Compose file ($COMPOSE_FILE) not found in the current directory."
    fi

    if [ ! -f "$ENV_FILE" ]; then
        error_message "Environment file ($ENV_FILE) not found in the current directory."
    fi

    success_message "All prerequisites are met."
    empty_line
}

display_help() {
    standard_message "Usage: $0 {start|stop|restart|status|logs|connect|help}"
    empty_line
    standard_message "Commands:"
    standard_message "  start             Start Docker containers"
    standard_message "  stop              Stop Docker containers"
    standard_message "  restart           Restart Docker containers"
    standard_message "  status            Show status of Docker containers"
    standard_message "  logs [SERVICE]    Show logs of Docker containers"
    standard_message "  connect [SERVICE] Connect to a running container (default: app)"
    standard_message "  env               Show environment variables"
    standard_message "  recreate          Recreate Docker containers and restart them"
    standard_message "  prune             Remove stopped containers and unused images and volumes"
    standard_message "  backup            Backup all Docker volumes"
    standard_message "  restore [FILE]    Restore Docker volumes from backup file"
    standard_message "  help              Display this help message"
    empty_line
}

start_services() {
    step_message "Starting Docker containers..."

    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" -p "$PROJECT_NAME" up -d

    if [ $? -ne 0 ]; then
        error_message "Failed to start Docker containers."
    fi

    success_message "Docker containers started successfully."
    empty_line
}

stop_services() {
    step_message "Stopping Docker containers..."

    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" -p "$PROJECT_NAME" down

    if [ $? -ne 0 ]; then
        error_message "Failed to stop Docker containers."
    fi

    success_message "Docker containers stopped successfully."
    empty_line
}

restart_services() {
    step_message "Restarting Docker containers..."

    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" -p "$PROJECT_NAME" restart

    if [ $? -ne 0 ]; then
        error_message "Failed to restart Docker containers."
    fi

    success_message "Docker containers restarted successfully."
    empty_line
}

status_services() {
    step_message "Showing status of Docker containers..."

    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" -p "$PROJECT_NAME" ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

    if [ $? -ne 0 ]; then
        error_message "Failed to display Docker containers status."
    fi

    success_message "Docker containers status displayed successfully."
    empty_line
}

logs_services() {
    step_message "Showing logs of Docker containers..."
    local service="$1"

    if [ -n "$service" ]; then
        docker compose --env-file "$ENV_FILE" -p "$PROJECT_NAME" logs "$service"
    else
        docker compose --env-file "$ENV_FILE" -p "$PROJECT_NAME" logs
    fi

    if [ $? -ne 0 ]; then
        error_message "Failed to display Docker containers logs."
    fi

    success_message "Docker containers logs displayed successfully."
    empty_line
}

connect_services() {
    local service="$1"
    
    if [ -z "$service" ]; then
        error_message "No service specified. Please provide a service name."
        return 1
    fi
    
    step_message "Connecting to container: $service"
    
    local container_status
    container_status=$(docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" -p "$PROJECT_NAME" ps "$service" --format "{{.Status}}" 2>/dev/null)
    
    if [ -z "$container_status" ]; then
        error_message "Service '$service' not found in the compose file or not running."
    fi
    
    if [[ ! "$container_status" =~ "Up" ]]; then
        error_message "Service '$service' is not running. Please start the services first."
    fi

    step_message "Attempting to connect with bash..."
    if ! docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" -p "$PROJECT_NAME" exec "$service" bash 2>/dev/null; then
        step_message "Bash not available, trying with sh..."
        if ! docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" -p "$PROJECT_NAME" exec "$service" sh; then
            error_message "Failed to connect to service '$service'. No compatible shell found."
        fi
    fi
    
    success_message "Disconnected from service '$service'."
    empty_line
}

env_services() {
    step_message "Showing environment variables..."

    while IFS='=' read -r key value || [ -n "$key" ]; do
        if [[ -n "$key" && ! "$key" =~ ^[[:space:]]*# && ! "$key" =~ ^[[:space:]]*$ ]]; then
            value=$(echo "$value" | tr -d '\r' | sed 's/[[:space:]]*$//')
            echo -e "${CYAN}$key${NC} = ${GREEN}$value${NC}"
        fi
    done < "$ENV_FILE"

    success_message "Environment variables displayed successfully."
    empty_line
}

recreate_services() {
    step_message "Recreating Docker containers..."

    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" -p "$PROJECT_NAME" pull

    if [ $? -ne 0 ]; then
        error_message "Failed to pull latest images."
    fi

    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" -p "$PROJECT_NAME" build

    if [ $? -ne 0 ]; then
        error_message "Failed to build images."
    fi

    docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" -p "$PROJECT_NAME" up -d --force-recreate

    if [ $? -ne 0 ]; then
        error_message "Failed to recreate and start Docker containers."
    fi

    success_message "Docker containers recreated and started successfully."
    empty_line
}

prune_services() {
    step_message "Pruning unused Docker objects..."

    docker compose --env-file "$ENV_FILE" -p "$PROJECT_NAME" down -v --remove-orphans

    if [ $? -ne 0 ]; then
        error_message "Failed to prune Docker containers."
    fi

    success_message "Docker containers pruned successfully."
    empty_line
}

backup_services() {

    stop_services

    step_message "Backing up Docker volumes..."

    local volumes=$(docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" -p "$PROJECT_NAME" config --volumes)
    if [ -z "$volumes" ]; then
        error_message "No volumes found for project ${PROJECT_NAME}."
    fi

    step_message "Creating backup directories..."
    local backup_directory="${SCRIPT_DIR}/backups"
    local backup_directory_tmp="${backup_directory}/tmp"
    local backup_date=$(date +%Y%m%d%H%M)
    rm -rf "$backup_directory_tmp"
    mkdir -p "$backup_directory_tmp"

    if [ $? -ne 0 ]; then
        error_message "Failed to create backup directories."
    fi

    step_message "Backing up volumes..."
    for volume in $volumes; do
        local volume_name="$PROJECT_NAME"_"$volume"
        step_message "Backing up volume: $volume / $volume_name"
        docker run --rm -v "$volume_name":/volume -v "$backup_directory_tmp":/backup busybox sh -c "cd /volume && tar czf /backup/$volume.tar.gz ."
        if [ $? -eq 0 ]; then
            success_message "Volume ${volume} backed up."
        else
            error_message "Failed to back up volume ${volume}."
        fi
    done

    step_message "Creating backup archive..."
    local backup_file="${backup_directory}/all_volumes_${backup_date}.tar.gz"
    tar czf "$backup_file" -C "$backup_directory_tmp" .

    if [ $? -ne 0 ]; then
        error_message "Failed to create backup archive."
    fi

    step_message "Cleaning up backup directories..."
    rm -rf "$backup_directory_tmp"

    success_message "Backup archive created successfully."
    empty_line

    start_services
}

restore_services() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        error_message "Please specify a backup file to restore from."
    fi

    if [ ! -f "$backup_file" ]; then
        error_message "Backup file not found: $backup_file"
    fi

    stop_services

    step_message "Restoring Docker volumes from backup: $backup_file"

    local volumes=$(docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" -p "$PROJECT_NAME" config --volumes)
    if [ -z "$volumes" ]; then
        error_message "No volumes found for project ${PROJECT_NAME}."
    fi

    step_message "Creating restore directories..."
    local backup_directory="${SCRIPT_DIR}/backups"
    local restore_directory_tmp="${backup_directory}/restore_tmp"
    rm -rf "$restore_directory_tmp"
    mkdir -p "$restore_directory_tmp"

    if [ $? -ne 0 ]; then
        error_message "Failed to create restore directories."
    fi

    step_message "Extracting backup archive..."
    tar xzf "$backup_file" -C "$restore_directory_tmp"

    if [ $? -ne 0 ]; then
        error_message "Failed to extract backup archive."
    fi

    step_message "Comparing archive contents with volumes..."
    local archive_files=($(ls "$restore_directory_tmp"/*.tar.gz 2>/dev/null))
    local archive_count=${#archive_files[@]}
    local volume_list=($(echo "$volumes" | tr '\n' ' '))
    local volume_count=${#volume_list[@]}
    
    if [ $archive_count -ne $volume_count ]; then
        error_message "Archive contains $archive_count files but project has $volume_count volumes. Counts must match."
    fi
    
    step_message "Verifying volume names match archive files..."
    for volume in $volumes; do
        local expected_file="${restore_directory_tmp}/${volume}.tar.gz"
        if [ ! -f "$expected_file" ]; then
            error_message "Archive missing file for volume: ${volume}.tar.gz"
        fi
    done

    step_message "Restoring volumes..."
    for volume in $volumes; do
        local volume_name="$PROJECT_NAME"_"$volume"
        step_message "Restoring volume: $volume / $volume_name"
        docker run --rm -v "$volume_name":/volume -v "$restore_directory_tmp":/backup busybox sh -c "cd /volume && rm -rf ./* && tar xzf /backup/${volume}.tar.gz"
        if [ $? -eq 0 ]; then
            success_message "Volume ${volume} restored."
        else
            error_message "Failed to restore volume ${volume}."
        fi
    done

    step_message "Cleaning up restore directories..."
    rm -rf "$restore_directory_tmp"

    success_message "Volumes restored successfully."
    empty_line

    start_services
}

main() {
    display_header

    case "$1" in
        start)
            check_prerequisites
            start_services
            ;;
        stop)
            check_prerequisites
            stop_services
            ;;
        restart)
            check_prerequisites
            restart_services
            ;;
        status)
            check_prerequisites
            status_services
            ;;
        logs)
            check_prerequisites
            logs_services "$2"
            ;;
        connect)
            check_prerequisites
            connect_services "$2"
            ;;
        env)
            env_services
            ;;
        recreate)
            check_prerequisites
            recreate_services
            ;;
        prune)
            check_prerequisites
            prune_services
            ;;
        backup)
            check_prerequisites
            backup_services
            ;;
        restore)
            check_prerequisites
            restore_services "$2"
            ;;
        help)
            display_help
            ;;
        *)
            warning_message "Unknown command: $1"
            display_help
            ;;
    esac
}

main "$@"
