#!/bin/bash
# Show tmux window numbers where Claude Code is waiting for input.
# Marker files are written/cleared by Claude Code hooks in settings.json.

waiting=""
for f in /tmp/claude-status/*; do
  [ -f "$f" ] || continue
  pane=$(basename "$f")
  win=$(tmux display -t "$pane" -p '#{window_index}' 2>/dev/null)
  if [ -n "$win" ]; then
    waiting="${waiting:+$waiting,}$win"
  else
    # stale marker — pane no longer exists
    rm -f "$f"
  fi
done

[ -n "$waiting" ] && echo " waiting: $waiting " || echo ""
