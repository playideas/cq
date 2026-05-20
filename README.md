# CQ

ML 연구원을 위한 GPU 워커 관리 CLI 도구.

원격 GPU 머신을 릴레이 서버에 등록하고, 실험(Job)을 실행/모니터링하며, MCP 프로토콜을 통해 AI 에이전트와 연동합니다.

## 설치

### macOS / Linux

```bash
curl -fsSL https://github.com/playideas/cq/releases/latest/download/install.sh | bash
```

### Windows (PowerShell 관리자)

```powershell
irm https://github.com/playideas/cq/releases/latest/download/install.ps1 | iex
```

### 특정 버전 설치

```bash
curl -fsSL https://github.com/playideas/cq/releases/latest/download/install.sh | bash -s -- --version v1.0.0b
```

> 설치 스크립트와 바이너리는 [GitHub Releases](https://github.com/playideas/cq/releases)에서 배포됩니다.

## 빠른 시작

```bash
# 워커 등록 + 백그라운드 서비스 시작
cq worker install <registration_key>

# 상태 확인
cq worker status

# 제거
cq worker uninstall
```

## 명령어

| 명령어 | 설명 |
|---|---|
| `cq --version` | 버전 확인 |
| `cq auth login` | 브라우저 로그인 |
| `cq auth logout` | 로그아웃 |
| `cq auth status` | 인증 상태 확인 |
| `cq worker install <key>` | 릴레이 등록 + OS 서비스 설치 + 시작 |
| `cq worker uninstall` | 서비스 제거 + 릴레이 삭제 + 정리 |
| `cq worker start` | 백그라운드 서비스 시작 |
| `cq worker stop` | 백그라운드 서비스 종료 |
| `cq worker status` | 등록/서비스/PID 상태 확인 |
| `cq worker <key>` | 등록 후 포그라운드 실행 (개발용) |
| `cq projects list` | 프로젝트 목록 조회 |
| `cq update` | 최신 버전으로 업데이트 |
| `cq update --version v1.0.0b` | 특정 버전으로 업데이트 |
| `cq uninstall` | CQ 완전 제거 |
| `cq mcp` | MCP 서버 시작 (stdio) |
| `cq ui` | TUI 채팅 인터페이스 |

## 지원 플랫폼

| OS | 아키텍처 |
|---|---|
| macOS | amd64, arm64 |
| Linux | amd64, arm64 |
| Windows | amd64 |

## 버전 체계

`vX.Y.Zb` — `b` 접미사는 베타를 의미합니다. 정식 출시 후 제거됩니다.

## 라이선스

Proprietary - PlayIdea Lab
