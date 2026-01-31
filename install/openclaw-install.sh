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

msg_info "Creating Service"
mkdir -p /opt/openclaw
cat <<EOF >/opt/openclaw/config.env
OPENCLAW_PORT=18789
OPENCLAW_HOST=0.0.0.0
EOF

cat <<EOF >/etc/systemd/system/openclaw.service
[Unit]
Description=OpenClaw Personal AI Assistant Gateway
After=network.target

[Service]
Type=simple
EnvironmentFile=/opt/openclaw/config.env
ExecStart=/usr/bin/openclaw gateway --port 18789 --allow-unconfigured
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now openclaw
msg_ok "Created Service"

msg_info "Saving Version"
RELEASE=$(openclaw --version 2>/dev/null | head -1)
echo "${RELEASE}" >/opt/openclaw_version.txt
msg_ok "Saved Version ${RELEASE}"

motd_ssh
customize
cleanup_lxc
