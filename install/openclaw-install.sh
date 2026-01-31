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

# Tailscale installation (only available in advanced mode with TUN enabled)
if [[ "${ENABLE_TUN:-no}" == "yes" ]]; then
  read -r -p "${TAB3}Would you like to install Tailscale for secure remote access? <y/N> " prompt
  if [[ ${prompt,,} =~ ^(y|yes)$ ]]; then
    msg_info "Installing Tailscale"
    ID=$(grep "^ID=" /etc/os-release | cut -d"=" -f2)
    VER=$(grep "^VERSION_CODENAME=" /etc/os-release | cut -d"=" -f2)

    # Try fetching GPG key, fallback to Cloudflare DNS if blocked
    if ! curl -fsSL "https://pkgs.tailscale.com/stable/${ID}/${VER}.noarmor.gpg" \
        -o /usr/share/keyrings/tailscale-archive-keyring.gpg 2>/dev/null; then
      cp /etc/resolv.conf /tmp/resolv.conf.backup
      echo "nameserver 1.1.1.1" >/etc/resolv.conf
      $STD curl -fsSL "https://pkgs.tailscale.com/stable/${ID}/${VER}.noarmor.gpg" \
        -o /usr/share/keyrings/tailscale-archive-keyring.gpg
    fi

    echo "deb [signed-by=/usr/share/keyrings/tailscale-archive-keyring.gpg] https://pkgs.tailscale.com/stable/${ID} ${VER} main" \
      >/etc/apt/sources.list.d/tailscale.list
    $STD apt-get update
    $STD apt-get install -y tailscale

    # Restore DNS if modified
    [[ -f /tmp/resolv.conf.backup ]] && mv /tmp/resolv.conf.backup /etc/resolv.conf

    msg_ok "Installed Tailscale"
    echo -e "${INFO}${YW} After setup, run 'tailscale up' to connect to your tailnet.${CL}"
    echo -e "${INFO}${YW} Configure OpenClaw's Tailscale mode in the onboarding wizard.${CL}\n"
  fi
fi

echo -e "\n${INFO}${YW} To complete setup, run inside the container:${CL}"
echo -e "${TAB}${GN}openclaw onboard --install-daemon${CL}"
echo -e "${INFO}${YW} This will configure your API keys and install the service.${CL}\n"

motd_ssh
customize
cleanup_lxc
