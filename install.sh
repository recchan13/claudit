#!/bin/sh
set -e

# ── Colors ──────────────────────────────────────────────────────────────────
BOLD="\033[1m"
DIM="\033[2m"
RESET="\033[0m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RED="\033[31m"

# ── Header ──────────────────────────────────────────────────────────────────
echo ""
echo "${BOLD}  Claudit${RESET}"
echo "${DIM}  Smart Contract Security Findings for AI Coding Agents${RESET}"
echo ""

# ── Detect CLIs ─────────────────────────────────────────────────────────────
HAS_CLAUDE=false
HAS_CODEX=false

if command -v claude >/dev/null 2>&1; then
  HAS_CLAUDE=true
fi
if command -v codex >/dev/null 2>&1; then
  HAS_CODEX=true
fi

if [ "$HAS_CLAUDE" = false ] && [ "$HAS_CODEX" = false ]; then
  echo "  ${RED}No supported CLI found.${RESET} Install at least one of:"
  echo ""
  echo "    Claude Code  ${DIM}https://docs.anthropic.com/en/docs/claude-code/overview${RESET}"
  echo "    Codex CLI    ${DIM}https://github.com/openai/codex${RESET}"
  echo ""
  exit 1
fi

echo "  ${DIM}Detected:${RESET}"
[ "$HAS_CLAUDE" = true ] && echo "    ${GREEN}●${RESET} Claude Code"
[ "$HAS_CODEX" = true ]  && echo "    ${GREEN}●${RESET} Codex CLI"
echo ""

# ── API Key ─────────────────────────────────────────────────────────────────
echo "  ${DIM}Get your key at:${RESET} ${CYAN}https://solodit.cyfrin.io${RESET} ${DIM}› Profile › API Keys${RESET}"
echo ""
printf "  ${BOLD}API Key:${RESET} "
stty -echo </dev/tty 2>/dev/null || true
read -r API_KEY </dev/tty
stty echo </dev/tty 2>/dev/null || true
echo ""
if [ -z "$API_KEY" ]; then
  echo "  ${RED}Error:${RESET} API key is required"
  echo ""
  exit 1
fi

# ── Install ─────────────────────────────────────────────────────────────────
echo ""

if [ "$HAS_CLAUDE" = true ]; then
  printf "  ${DIM}Setting up Claude Code...${RESET}"
  claude mcp remove solodit 2>/dev/null || true
  claude mcp add --scope user --transport stdio solodit \
    --env "SOLODIT_API_KEY=$API_KEY" \
    -- npx -y @marchev/claudit >/dev/null 2>&1
  echo "\r  ${GREEN}✓${RESET} Claude Code     ${DIM}MCP server registered${RESET}"

  printf "  ${DIM}Installing skill...${RESET}"
  mkdir -p ~/.claude/skills/solodit
  if curl -fsSL https://raw.githubusercontent.com/marchev/claudit/main/.claude/skills/solodit/SKILL.md \
    -o ~/.claude/skills/solodit/SKILL.md 2>/dev/null; then
    echo "\r  ${GREEN}✓${RESET} Companion skill ${DIM}installed${RESET}          "
  else
    echo "\r  ${YELLOW}○${RESET} Companion skill ${DIM}skipped (optional)${RESET}"
  fi
fi

if [ "$HAS_CODEX" = true ]; then
  printf "  ${DIM}Setting up Codex CLI...${RESET}"
  codex mcp remove solodit 2>/dev/null || true
  codex mcp add solodit \
    --env "SOLODIT_API_KEY=$API_KEY" \
    -- npx -y @marchev/claudit >/dev/null 2>&1
  echo "\r  ${GREEN}✓${RESET} Codex CLI       ${DIM}MCP server registered${RESET}"
fi

# ── Done ────────────────────────────────────────────────────────────────────
echo ""
echo "  ${GREEN}${BOLD}Ready!${RESET} Open your AI coding agent and try:"
echo ""
echo "    ${CYAN}Search Solodit for reentrancy HIGH severity findings${RESET}"
echo ""
