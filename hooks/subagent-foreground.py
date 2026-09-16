#!/usr/bin/env python3
"""PreToolUse hook: a subagent's Agent call always runs in the foreground.

A foreground subagent that launches a child in the background and ends its turn
to wait is closed as finished, and the child's report reaches nobody who can use
it. A subagent has no way to wait for a background child, so for a subagent the
foreground is the only launch that works. Launched together in one message,
foreground children still run at the same time.

The main session is left alone: its input carries no `agent_id`, and for it a
background launch is what keeps the user free to talk while agents work.

`dror-internal-shared/hook-agent-probe.sh` proves both halves against the
running Claude Code: re-run it after an upgrade.
"""

import json
import sys

event = json.load(sys.stdin)
tool_input = event.get("tool_input") or {}
if event.get("agent_id") and tool_input.get("run_in_background") is not False:
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "updatedInput": {**tool_input, "run_in_background": False},
    }}))
