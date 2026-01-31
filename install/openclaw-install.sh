#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: jacobgood
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/openclaw/openclaw

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os
get_lxc_ip

msg_info "Installing Dependencies"
$STD apt-get install -y \
  ca-certificates \
  build-essential \
  git \
  python3 \
  python3-setuptools
msg_ok "Installed Dependencies"

NODE_VERSION="22" setup_nodejs

msg_info "Installing OpenClaw (Patience)"
$STD npm install -g openclaw@latest
msg_ok "Installed OpenClaw"

msg_info "Saving Version"
mkdir -p /opt/openclaw
RELEASE=$(openclaw --version 2>/dev/null | head -1)
echo "${RELEASE}" >/opt/openclaw_version.txt
msg_ok "Installed OpenClaw ${RELEASE}"

echo -e "\n${INFO}${YW} To complete setup, run inside the container:${CL}"
echo -e "${TAB}${GN}openclaw onboard --install-daemon${CL}"
echo -e "${INFO}${YW} This will configure your API keys and install the service.${CL}\n"

motd_ssh
customize
cleanup_lxc
