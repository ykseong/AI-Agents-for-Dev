#!/bin/bash
set -euo pipefail

COMMANDS_DIR="$HOME/.claude/commands"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() { echo -e "${BLUE}▶ $1${NC}"; }
print_ok()   { echo -e "${GREEN}✓ $1${NC}"; }
print_info() { echo -e "${YELLOW}  $1${NC}"; }

echo ""
echo "AI Agents for Dev — 설치 스크립트"
echo "=================================="
echo ""

# ── 1. 글로벌 슬래시 커맨드 설치 ──────────────────────────────────────────
print_step "글로벌 슬래시 커맨드 설치 중..."

mkdir -p "$COMMANDS_DIR"
cp "$SCRIPT_DIR/commands/dev-agents.md" "$COMMANDS_DIR/dev-agents.md"
print_ok "/dev-agents 커맨드 설치 완료 → $COMMANDS_DIR/dev-agents.md"
print_info "모든 프로젝트에서 /dev-agents [요구사항] 으로 사용 가능"

echo ""

# ── 2. 현재 프로젝트에 CLAUDE.md 설정 여부 확인 ───────────────────────────
print_step "현재 프로젝트에 CLAUDE.md 설치 여부 확인..."

TARGET_DIR="${1:-$(pwd)}"

if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    echo ""
    read -r -p "  $TARGET_DIR/CLAUDE.md 이 이미 존재합니다. 덮어쓸까요? [y/N] " answer
    answer="${answer:-N}"
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        cp "$SCRIPT_DIR/templates/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
        print_ok "CLAUDE.md 업데이트 완료"
    else
        print_info "CLAUDE.md 설치를 건너뜁니다"
    fi
else
    cp "$SCRIPT_DIR/templates/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
    print_ok "CLAUDE.md 설치 완료 → $TARGET_DIR/CLAUDE.md"
fi

echo ""

# ── 3. 설치 완료 안내 ─────────────────────────────────────────────────────
echo "설치 완료"
echo "=========="
echo ""
echo "사용 방법:"
echo ""
echo "  방법 1 — 어느 프로젝트에서나 슬래시 커맨드로 시작"
echo "    /dev-agents 쇼핑몰을 만들어줘. 상품 목록, 장바구니, 결제 기능 필요해"
echo ""
echo "  방법 2 — 새 프로젝트에 CLAUDE.md 설치 후 사용"
echo "    bash install.sh /path/to/your-project"
echo "    → 해당 프로젝트에서 에이전트 역할이 자동으로 활성화됨"
echo ""
echo "  방법 3 — 특정 에이전트 직접 지시"
echo "    \"QA Agent로서 이 코드를 테스트해줘\""
echo "    \"Review Agent로서 보안 취약점을 검토해줘\""
echo ""
