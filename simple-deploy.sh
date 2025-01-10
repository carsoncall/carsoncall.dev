#!/bin/bash

set -e

# Function to display usage
usage() {
  echo "Usage: $0 [-u username] [-h hostname] [-k ssh_key] [--local] [-s site_name] [-v]"
  exit 1
}

LOCAL=false
VERBOSE=false

# Function to log messages
log() {
  if [[ "${VERBOSE}" == true ]]; then
    echo "$1"
  fi
}

# Function to handle errors
error_handler() {
  echo "Error occurred in script at line: ${BASH_LINENO[0]}"
  exit 1
}

COMMAND="
set -e

$(declare -f log)
$(declare -f error_handler)

trap 'error_handler' ERR
"

trap 'error_handler' ERR

# Parse command line arguments
while getopts ":u:h:k:ls:v" opt; do
  case "${opt}" in
    u)
      USERNAME=${OPTARG}
      ;;
    h)
      TARGET_HOST=${OPTARG}
      ;;
    k)
      SSH_KEY=${OPTARG}
      ;;
    l)
      LOCAL=true
      ;;
    s)
      SITE_NAME=${OPTARG}
      ;;
    v)
      VERBOSE=true
      ;;
    *)
      usage
      ;;
  esac
done

# Prompt for missing arguments
if [[ -z "${USERNAME}" && "${LOCAL}" == false ]]; then
  read -p "Enter username: " USERNAME
fi

if [[ -z "${TARGET_HOST}" && "${LOCAL}" == false ]]; then
  read -p "Enter hostname: " TARGET_HOST
fi

if [[ -z "${SITE_NAME}" ]]; then
  read -p "Enter site name: " SITE_NAME
fi

if [[ -z "${DIRECTORY_TO_COPY}" ]]; then
  read -p "Enter directory to copy: " DIRECTORY_TO_COPY
fi

# Function to add the command to create a new user to the COMMAND
create_user() {
  local site_name=$1
  COMMAND="${COMMAND}
log 'Creating user ${site_name} on host ${TARGET_HOST}'
if id '${site_name}' &>/dev/null; then
  log 'User ${site_name} already exists.'
else
  sudo useradd -m '${site_name}' && log 'User ${site_name} created successfully.' || { log 'Failed to create user ${site_name}.'; exit 1; }
fi;"
}

# Function to add the command to enable long-running services under the new user
enable_services() {
  local site_name=$1
  COMMAND="${COMMAND}
log 'Enabling long-running services for ${site_name}'
sudo loginctl enable-linger ${site_name} || { log 'Failed to enable long-running services for ${site_name}'; exit 1; }"
}

# Function to add the command to copy a directory to the remote host
copy_directory_to_tmp() {
  local directory=$1
  local copy_command=""
  if [[ "${LOCAL}" == true ]]; then
    copy_command="cp -r ${directory} /tmp/ && chmod -R a+r /tmp/$(basename ${directory})"
  else
    copy_command="scp -r ${directory} ${USERNAME}@${TARGET_HOST}:/tmp/ && ssh ${USERNAME}@${TARGET_HOST} 'chmod -R a+r /tmp/$(basename ${directory})'"
  fi

  COMMAND="${COMMAND}
log 'Copying directory ${directory} to /tmp'
${copy_command} || { log 'Failed to copy directory ${directory} to /tmp.'; exit 1; }
log 'Directory ${directory} copied successfully to /tmp.'"
}

# Function to add the command to switch to the newly created user using machinectl shell
switch_user() {
  local site_name=$1
  COMMAND="${COMMAND}
log 'Switching to user ${site_name}'
sudo machinectl shell ${site_name}@.host || { log 'Failed to switch to user ${site_name}'; exit 1; }"
}

# Function to copy the files from /tmp to the directory of the newly created user
copy_directory_to_home() {
  local directory=$1
  local site_name=$2
  COMMAND="${COMMAND}
log 'Copying directory from /tmp to home directory of ${site_name}'
cp -r /tmp/$(basename ${directory}) /home/${site_name}/ || { log 'Failed to copy directory to /home/${site_name}.'; exit 1; }
log 'Directory copied successfully to /home/${site_name}.'"
}

# Function to create a systemd user service to serve files using python http.server
create_systemd_service() {
  local site_name=$1
  while true; do
    PORT=$((RANDOM % 1000 + 8000))
    if ! ss -tuln | grep -q ":${PORT} "; then
      break
    fi
  done

  COMMAND="${COMMAND}
log 'Creating systemd user service for ${site_name} on port ${PORT}'
cat <<EOF > /home/${site_name}/.config/systemd/user/http-server.service
[Unit]
Description=Python HTTP Server
After=network.target

[Service]
ExecStart=/usr/bin/python3 -m http.server ${PORT} --directory /home/${site_name}/$(basename ${DIRECTORY_TO_COPY})
Restart=always

[Install]
WantedBy=default.target
EOF"
}

# Function to reload the daemons, enable the service, and start the service
start_systemd_service() {
  local site_name=$1
  COMMAND="${COMMAND}
log 'Reloading systemd daemons, enabling and starting the service for ${site_name}'
systemctl --user daemon-reload
systemctl --user enable http-server.service
systemctl --user start http-server.service || { log 'Failed to create or start systemd user service.'; exit 1; }
log 'Systemd user service created and started successfully.'"
}

# Function to check if the server is live
check_server() {
  local site_name=$1
  local port=$2
  COMMAND="${COMMAND}
log 'Checking if the server is live on port ${port}'
sleep 5
if curl -s http://localhost:${port} > /dev/null; then
  log 'Server is live.'
else
  log 'Server is not responding.'
fi;"
}

# Function to check server accessibility from the local machine
check_server_accessibility() {
  local hostname=$1
  local port=$2
  log "Checking server accessibility from the local machine on ${hostname}:${port}"
  if curl -s http://${hostname}:${port} > /dev/null; then
    log "Server is accessible from the local machine."
  else
    log "Server is not accessible from the local machine."
  fi
}

# Add the constituent parts to the COMMAND
create_user "${SITE_NAME}"
enable_services "${SITE_NAME}"
copy_directory_to_tmp "${DIRECTORY_TO_COPY}"
switch_user "${SITE_NAME}"
copy_directory_to_home "${DIRECTORY_TO_COPY}" "${SITE_NAME}"
create_systemd_service "${SITE_NAME}"
start_systemd_service "${SITE_NAME}"
check_server "${SITE_NAME}" "${PORT}"

if [[ "${LOCAL}" == true ]]; then
  log "Running locally, bypassing SSH."
  log "Executing command: ${COMMAND}"
  (bash -c "${COMMAND}")
else
  if [[ -z "${SSH_KEY}" ]]; then
    log "Running remotely without SSH key."
    log "Executing command on ${TARGET_HOST} as ${USERNAME}: ${COMMAND}"
    ssh "${USERNAME}@${TARGET_HOST}" "(bash -c \"${COMMAND}\")"
  else
    if [[ -f "${SSH_KEY}" ]]; then
      log "Running remotely with SSH key file: ${SSH_KEY}"
      log "Executing command on ${TARGET_HOST} as ${USERNAME}: ${COMMAND}"
      ssh -i "${SSH_KEY}" "${USERNAME}@${TARGET_HOST}" "(bash -c \"${COMMAND}\")"
    else
      log "Running remotely with SSH key content."
      log "Executing command on ${TARGET_HOST} as ${USERNAME}: ${COMMAND}"
      ssh -o "IdentityFile=<(echo '${SSH_KEY}')" "${USERNAME}@${TARGET_HOST}" "(bash -c \"${COMMAND}\")"
    fi
  fi
fi

check_server_accessibility "localhost" "${PORT}"
