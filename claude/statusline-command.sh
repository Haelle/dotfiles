#!/bin/bash

# Read Claude Code input data
input=$(cat)

# Check if jq is available, fallback to basic parsing if not
if command -v jq >/dev/null 2>&1; then
  # Extract data from JSON using jq
  current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
  model_name=$(echo "$input" | jq -r '.model.display_name')
else
  # Basic fallback parsing without jq
  current_dir=$(echo "$input" | grep -o '"current_dir":"[^"]*"' | cut -d'"' -f4)
  model_name=$(echo "$input" | grep -o '"display_name":"[^"]*"' | cut -d'"' -f4)
fi

# Fallback to PWD if current_dir is empty
if [[ -z "$current_dir" ]]; then
  current_dir="$PWD"
fi

# Get current directory name
dir_name=$(basename "$current_dir")

# Get git branch if available
git_branch=""
if git rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
    git_branch="${branch}"
  fi
fi

# Function to format token numbers with 'k' abbreviation
format_tokens() {
  local tokens="$1"
  if [[ "$tokens" =~ ^[0-9]+$ ]]; then
    if (( tokens >= 1000 )); then
      # Round to nearest thousand and append 'k'
      printf "%dk" $(( (tokens + 500) / 1000 ))
    else
      printf "%s" "$tokens"
    fi
  else
    printf "%s" "$tokens"
  fi
}

# Extract current context usage from transcript
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty' 2>/dev/null)
context_tokens=""
context_pct=""
if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
  context_tokens=$(tac "$transcript_path" | jq -r 'select(.message.usage?) | .message.usage | (.input_tokens + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0))' 2>/dev/null | head -n1)
  if [[ "$context_tokens" =~ ^[0-9]+$ ]]; then
    if [[ "$model_name" == *"1M"* || "$model_name" == *"1m"* ]]; then
      max_context=1000000
    else
      max_context=200000
    fi
    context_pct=$(( context_tokens * 100 / max_context ))
  fi
fi

# Get ccusage information (check if ccusage command exists)
if command -v ccusage >/dev/null 2>&1; then
  TODAY_DATA=$(ccusage --json 2>/dev/null | jq --arg today "$(date +%Y-%m-%d)" '.daily[] | select(.date == $today)')
  if [[ -n "$TODAY_DATA" ]]; then
    TOTAL_COST=$(echo "$TODAY_DATA" | jq -r '.totalCost | . * 100 | round / 100')
    TOTAL_TOKENS=$(echo "$TODAY_DATA" | jq -r '.totalTokens | (. / 1000 | floor | tostring)')
  fi
fi

# Build the status line: model name (red), daily usage (yellow), directory name (blue), git branch (green)
# Model info in red
if command -v tput >/dev/null 2>&1; then
  printf '%s%s%s' "$(tput setaf 1)" "[$model_name]" "$(tput sgr0)"
else
  printf '%s' "[$model_name]"
fi

# Daily usage info (if available)
if [[ -n "$TODAY_DATA" ]]; then
  printf '%s' " [Tokens ${TOTAL_TOKENS}k ($TOTAL_COST$)]"
fi

# Current context usage (yellow)
if [[ -n "$context_tokens" && -n "$context_pct" ]]; then
  formatted_ctx=$(format_tokens "$context_tokens")
  if command -v tput >/dev/null 2>&1; then
    printf ' %s[Contexte %s - %d%%]%s' "$(tput setaf 3)" "$formatted_ctx" "$context_pct" "$(tput sgr0)"
  else
    printf ' [Contexte %s - %d%%]' "$formatted_ctx" "$context_pct"
  fi
fi

# Directory in clearer blue (bright blue)
if command -v tput >/dev/null 2>&1; then
  printf ' %s%s%s' "$(tput bold)$(tput setaf 4)" "[$dir_name]" "$(tput sgr0)"
else
  printf ' %s' "[$dir_name]"
fi

# Git branch info (if available)
if [[ -n "$git_branch" ]]; then
  if command -v tput >/dev/null 2>&1; then
    printf ' %s[%s]%s' "$(tput setaf 2)" "$git_branch" "$(tput sgr0)"
  else
    printf ' [%s]' "$git_branch"
  fi
fi

# Add newline at the end
printf '\n'
