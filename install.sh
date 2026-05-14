#!/bin/bash
set -euo pipefail

# ============================================================
#  CQ 설치 스크립트 (macOS / Linux)
#
#  사용법:
#    curl -fsSL https://raw.githubusercontent.com/OWNER/REPO/main/install.sh | bash
#    curl -fsSL ... | bash -s -- --version v1.2.3
#    curl -fsSL ... | bash -s -- --no-service
# ============================================================

GITHUB_REPO="playideas/cq"
TOOL_NAME="cq"
INSTALL_DIR="/usr/local/bin"

# --- 옵션 ---
VERSION=""
SKIP_SERVICE=false

while [ $# -gt 0 ]; do
  case "$1" in
    --version)    VERSION="$2"; shift 2 ;;
    --no-service) SKIP_SERVICE=true; shift ;;
    *)            shift ;;
  esac
done

# --- OS / 아키텍처 ---
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$OS" in
  darwin|linux) ;;
  *) echo "지원하지 않는 OS: $OS"; exit 1 ;;
esac

case "$ARCH" in
  x86_64)          ARCH="amd64" ;;
  aarch64|arm64)   ARCH="arm64" ;;
  *) echo "지원하지 않는 아키텍처: $ARCH"; exit 1 ;;
esac

ASSET="${TOOL_NAME}-${OS}-${ARCH}"

# --- 버전 결정 ---
if [ -z "$VERSION" ]; then
  echo "최신 릴리즈 확인 중..."
  VERSION=$(curl -fsSL "https://api.github.com/repos/${GITHUB_REPO}/releases/latest" \
    | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
  if [ -z "$VERSION" ]; then
    echo "최신 릴리즈를 찾을 수 없습니다."; exit 1
  fi
fi

DOWNLOAD_URL="https://github.com/${GITHUB_REPO}/releases/download/${VERSION}/${ASSET}"

echo "설치: ${TOOL_NAME} ${VERSION} (${OS}/${ARCH})"
echo ""

# --- 다운로드 ---
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "[1/3] 바이너리 다운로드..."
if command -v curl &>/dev/null; then
  curl -fSL --progress-bar -o "${TMP}/${TOOL_NAME}" "$DOWNLOAD_URL"
elif command -v wget &>/dev/null; then
  wget -q --show-progress -O "${TMP}/${TOOL_NAME}" "$DOWNLOAD_URL"
else
  echo "curl 또는 wget이 필요합니다."; exit 1
fi

# --- 설치 ---
echo "[2/3] 바이너리 설치 -> ${INSTALL_DIR}/${TOOL_NAME}"
chmod +x "${TMP}/${TOOL_NAME}"
if [ -w "$INSTALL_DIR" ]; then
  mv "${TMP}/${TOOL_NAME}" "${INSTALL_DIR}/${TOOL_NAME}"
else
  sudo mv "${TMP}/${TOOL_NAME}" "${INSTALL_DIR}/${TOOL_NAME}"
fi

# --- 서비스 등록 함수 ---
setup_launchd() {
  local plist_name="com.cq.worker"
  local plist_file="$HOME/Library/LaunchAgents/${plist_name}.plist"
  local log_dir="$HOME/.cq/logs"

  mkdir -p "$HOME/Library/LaunchAgents" "$log_dir"

  cat > "$plist_file" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${plist_name}</string>
  <key>ProgramArguments</key>
  <array>
    <string>${INSTALL_DIR}/${TOOL_NAME}</string>
    <string>worker</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>${log_dir}/worker.log</string>
  <key>StandardErrorPath</key>
  <string>${log_dir}/worker.log</string>
</dict>
</plist>
PLIST

  launchctl bootout "gui/$(id -u)" "$plist_file" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$plist_file"

  echo "  서비스: ${plist_name} (로그인 시 자동 시작)"
  echo "  로그:   ${log_dir}/worker.log"
}

setup_systemd() {
  local service_name="cq-worker"
  local service_file="/etc/systemd/system/${service_name}.service"
  local run_user="${SUDO_USER:-$USER}"

  sudo tee "$service_file" > /dev/null <<UNIT
[Unit]
Description=CQ Worker
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=${INSTALL_DIR}/${TOOL_NAME} worker
Restart=always
RestartSec=5
User=${run_user}

[Install]
WantedBy=multi-user.target
UNIT

  sudo systemctl daemon-reload
  sudo systemctl enable "$service_name"
  sudo systemctl restart "$service_name"

  echo "  서비스: ${service_name} (부팅 시 자동 시작)"
  echo "  로그:   journalctl -u ${service_name} -f"
}

# --- 서비스 등록 ---
if [ "$SKIP_SERVICE" = true ]; then
  echo "[3/3] 서비스 등록 건너뜀 (--no-service)"
else
  echo "[3/3] 서비스 등록..."
  case "$OS" in
    darwin) setup_launchd ;;
    linux)  setup_systemd ;;
  esac
fi

echo ""
echo "설치 완료!"
echo "  바이너리: ${INSTALL_DIR}/${TOOL_NAME}"
echo "  버전 확인: ${TOOL_NAME} --version"
