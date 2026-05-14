#Requires -RunAsAdministrator
# ============================================================
#  CQ 설치 스크립트 (Windows)
#
#  사용법:
#    irm https://raw.githubusercontent.com/playideas/cq/main/install.ps1 | iex
# ============================================================
param(
    [string]$Version = ""
)

$ErrorActionPreference = "Stop"

$GithubRepo  = "playideas/cq"
$ToolName    = "cq"
$InstallDir  = "$env:ProgramFiles\cq"
$Asset       = "${ToolName}-windows-amd64.exe"

# --- 버전 결정 ---
if (-not $Version) {
    Write-Host "최신 릴리즈 확인 중..."
    try {
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$GithubRepo/releases/latest"
        $Version = $release.tag_name
    } catch {
        Write-Host "최신 릴리즈를 찾을 수 없습니다."; exit 1
    }
}

$DownloadUrl = "https://github.com/$GithubRepo/releases/download/$Version/$Asset"

Write-Host "설치: $ToolName $Version (windows/amd64)"
Write-Host ""

# --- 다운로드 ---
Write-Host "[1/2] 바이너리 다운로드..."
$TmpFile = Join-Path $env:TEMP $Asset
Invoke-WebRequest -Uri $DownloadUrl -OutFile $TmpFile -UseBasicParsing

# --- 설치 ---
Write-Host "[2/2] 바이너리 설치 -> $InstallDir\$ToolName.exe"
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Move-Item -Force $TmpFile "$InstallDir\$ToolName.exe"

# PATH 등록
$MachinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($MachinePath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$MachinePath;$InstallDir", "Machine")
    Write-Host "  PATH에 $InstallDir 추가됨 (새 터미널에서 적용)"
}

Write-Host ""
Write-Host "설치 완료!"
Write-Host "  바이너리: $InstallDir\$ToolName.exe"
Write-Host "  버전 확인: $ToolName --version"
