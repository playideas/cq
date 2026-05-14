#!/bin/bash
set -euo pipefail

# ============================================================
#  CQ 설치 스크립트 (macOS / Linux)
#
#  사용법:
#    curl -fsSL https://raw.githubusercontent.com/playideas/cq/main/install.sh | bash
#    curl -fsSL ... | bash -s -- --version v1.2.3
# ============================================================

GITHUB_REPO="playideas/cq"
TOOL_NAME="cq"
INSTALL_DIR="/usr/local/bin"

# --- 옵션 ---
VERSION=""

while [ $# -gt 0 ]; do
  case "$1" in
    --version) VERSION="$2"; shift 2 ;;
    *)         shift ;;
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

echo "[1/2] 바이너리 다운로드..."
if command -v curl &>/dev/null; then
  curl -fSL --progress-bar -o "${TMP}/${TOOL_NAME}" "$DOWNLOAD_URL"
elif command -v wget &>/dev/null; then
  wget -q --show-progress -O "${TMP}/${TOOL_NAME}" "$DOWNLOAD_URL"
else
  echo "curl 또는 wget이 필요합니다."; exit 1
fi

# --- 설치 ---
echo "[2/2] 바이너리 설치 -> ${INSTALL_DIR}/${TOOL_NAME}"
chmod +x "${TMP}/${TOOL_NAME}"
if [ -w "$INSTALL_DIR" ]; then
  mv "${TMP}/${TOOL_NAME}" "${INSTALL_DIR}/${TOOL_NAME}"
else
  sudo mv "${TMP}/${TOOL_NAME}" "${INSTALL_DIR}/${TOOL_NAME}"
fi

echo ""
echo "설치 완료!"
echo "  바이너리: ${INSTALL_DIR}/${TOOL_NAME}"
echo "  버전 확인: ${TOOL_NAME} --version"
