#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/jacgood/ProxmoxVE/refs/heads/feature/openclaw/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: jacobgood
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/openclaw/openclaw

APP="OpenClaw"
var_tags="${var_tags:-ai;assistant}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-10}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

# =============================================================================
# CONFIGURATION GUIDE
# =============================================================================
# APP           - Display name, title case (e.g. "OpenClaw")
# var_tags      - Max 2 tags, semicolon separated (e.g. "ai;assistant")
# var_cpu       - CPU cores: 1-4 typical
# var_ram       - RAM in MB: 512, 1024, 2048, 4096 typical
# var_disk      - Disk in GB: 4, 6, 8, 10, 20 typical
# var_os        - OS: debian, ubuntu, alpine
# var_version   - OS version: 12/13 (debian), 22.04/24.04 (ubuntu), 3.20/3.21 (alpine)
# var_unprivileged - 1 = unprivileged (secure, default), 0 = privileged (for docker etc.)

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  # Check if installation exists
  if [[ ! -d /opt/openclaw ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  msg_info "Stopping ${APP}"
  systemctl stop openclaw
  msg_ok "Stopped ${APP}"

  NODE_VERSION="22" setup_nodejs

  msg_info "Updating ${APP}"
  $STD npm update -g openclaw
  msg_ok "Updated ${APP}"

  msg_info "Starting ${APP}"
  systemctl start openclaw
  msg_ok "Started ${APP}"

  RELEASE=$(openclaw --version 2>/dev/null | head -1)
  echo "${RELEASE}" >/opt/openclaw_version.txt
  msg_ok "Updated successfully to ${RELEASE}"
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:18789${CL}"
