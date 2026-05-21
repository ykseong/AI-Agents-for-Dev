#Requires -Version 5.1
<#
.SYNOPSIS
    AI Agents for Dev — Windows 설치 스크립트

.DESCRIPTION
    글로벌 슬래시 커맨드(/dev-agents)를 설치하고
    선택적으로 프로젝트에 CLAUDE.md를 복사한다.

.PARAMETER TargetDir
    CLAUDE.md를 설치할 프로젝트 경로.
    생략하면 현재 디렉토리에 설치한다.

.EXAMPLE
    .\install.ps1
    .\install.ps1 -TargetDir "C:\projects\my-app"

.NOTES
    실행 정책 오류가 발생하면 PowerShell을 관리자 권한으로 열고 아래를 실행:
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
#>

param(
    [string]$TargetDir = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$CommandsDir = Join-Path $env:USERPROFILE '.claude\commands'
$ScriptDir   = $PSScriptRoot

function Write-Step { param($msg) Write-Host "▶ $msg" -ForegroundColor Cyan }
function Write-Ok   { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "  $msg" -ForegroundColor Yellow }
function Write-Err  { param($msg) Write-Host "✗ $msg" -ForegroundColor Red }

Write-Host ""
Write-Host "AI Agents for Dev — 설치 스크립트 (Windows)" -ForegroundColor White
Write-Host "==============================================" -ForegroundColor White
Write-Host ""

# ── 1. 글로벌 슬래시 커맨드 설치 ─────────────────────────────────────────
Write-Step "글로벌 슬래시 커맨드 설치 중..."

$SourceCommand = Join-Path $ScriptDir 'commands\dev-agents.md'

if (-not (Test-Path $SourceCommand)) {
    Write-Err "commands\dev-agents.md 파일을 찾을 수 없습니다."
    Write-Info "이 스크립트는 레포지토리 루트에서 실행해야 합니다."
    exit 1
}

if (-not (Test-Path $CommandsDir)) {
    New-Item -ItemType Directory -Path $CommandsDir -Force | Out-Null
}

Copy-Item -Path $SourceCommand -Destination (Join-Path $CommandsDir 'dev-agents.md') -Force
Write-Ok "/dev-agents 커맨드 설치 완료 → $CommandsDir\dev-agents.md"
Write-Info "모든 프로젝트에서 /dev-agents [요구사항] 으로 사용 가능"

Write-Host ""

# ── 2. GitHub CLI 설치 확인 ───────────────────────────────────────────────
Write-Step "GitHub CLI(gh) 설치 확인..."

$ghInstalled = $null -ne (Get-Command gh -ErrorAction SilentlyContinue)

if ($ghInstalled) {
    $ghVersion = (gh --version 2>&1 | Select-Object -First 1)
    Write-Ok "GitHub CLI 설치됨 ($ghVersion)"

    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "GitHub 로그인 상태 확인됨"
    } else {
        Write-Info "GitHub 로그인이 필요합니다: gh auth login"
    }
} else {
    Write-Info "GitHub CLI가 없습니다. 수동으로 저장소를 생성해야 합니다."
    Write-Info "설치 방법: winget install GitHub.cli"
    Write-Info "또는: https://cli.github.com"
}

Write-Host ""

# ── 3. Git 설치 확인 ──────────────────────────────────────────────────────
Write-Step "Git 설치 확인..."

$gitInstalled = $null -ne (Get-Command git -ErrorAction SilentlyContinue)

if ($gitInstalled) {
    $gitVersion = (git --version 2>&1)
    Write-Ok "Git 설치됨 ($gitVersion)"
} else {
    Write-Err "Git이 설치되어 있지 않습니다."
    Write-Info "설치 방법: winget install Git.Git"
    Write-Info "또는: https://git-scm.com/download/win"
    Write-Host ""
    Write-Info "Git 설치 후 다시 실행해주세요."
    exit 1
}

Write-Host ""

# ── 4. CLAUDE.md 설치 ─────────────────────────────────────────────────────
Write-Step "프로젝트에 CLAUDE.md 설치 여부 확인..."

$SourceClaude = Join-Path $ScriptDir 'templates\CLAUDE.md'
$DestClaude   = Join-Path $TargetDir 'CLAUDE.md'

if (-not (Test-Path $SourceClaude)) {
    Write-Err "templates\CLAUDE.md 파일을 찾을 수 없습니다."
    exit 1
}

if (Test-Path $DestClaude) {
    Write-Host ""
    $answer = Read-Host "  $DestClaude 이 이미 존재합니다. 덮어쓸까요? [y/N]"
    if ($answer -match '^[Yy]$') {
        Copy-Item -Path $SourceClaude -Destination $DestClaude -Force
        Write-Ok "CLAUDE.md 업데이트 완료"
    } else {
        Write-Info "CLAUDE.md 설치를 건너뜁니다"
    }
} else {
    Copy-Item -Path $SourceClaude -Destination $DestClaude -Force
    Write-Ok "CLAUDE.md 설치 완료 → $DestClaude"
}

Write-Host ""

# ── 5. 설치 완료 안내 ─────────────────────────────────────────────────────
Write-Host "설치 완료" -ForegroundColor Green
Write-Host "==========" -ForegroundColor Green
Write-Host ""
Write-Host "GitHub 자동 커밋을 위한 사전 준비:" -ForegroundColor White
Write-Host ""
Write-Host "  1. GitHub 저장소를 먼저 생성하세요 (github.com/ykseong/[프로젝트명])"
Write-Host "     또는 gh CLI 사용: gh repo create ykseong/[프로젝트명] --public"
Write-Host ""
Write-Host "  2. Claude Code에서 /dev-agents 실행 시"
Write-Host "     에이전트가 자동으로 git init, remote 설정, 단계별 commit·push를 수행합니다"
Write-Host ""
Write-Host "사용 방법:" -ForegroundColor White
Write-Host ""
Write-Host "  방법 1 — 슬래시 커맨드 (어느 프로젝트에서나)"
Write-Host "    /dev-agents 쇼핑몰을 만들어줘. 상품 목록, 장바구니, 결제 기능 필요해"
Write-Host "    → 단계별 커밋이 github.com/ykseong/shopping-mall 에 자동 push됩니다" -ForegroundColor Yellow
Write-Host ""
Write-Host "  방법 2 — 새 프로젝트에 CLAUDE.md 설치 후 사용"
Write-Host "    .\install.ps1 -TargetDir C:\projects\my-app"
Write-Host "    → 해당 프로젝트에서 에이전트 역할 및 git 규칙이 자동으로 활성화됩니다" -ForegroundColor Yellow
Write-Host ""
Write-Host "  방법 3 — 특정 에이전트 직접 지시"
Write-Host "    `"QA Agent로서 이 코드를 테스트해줘`""
Write-Host "    `"Review Agent로서 보안 취약점을 검토해줘`""
Write-Host ""
