#!/usr/bin/env bash
# Probe whether a PreToolUse hook can keep a subagent from losing its children.
#
# The failure: a foreground subagent launches a child agent in the background
# and ends its turn to wait. The harness closes it as finished, and the child's
# report reaches nobody who can use it. `dror-adr-review` lost a whole round this
# way on 2026-09-16.
#
# The fix under test: `hooks/subagent-foreground.py`, the plugin's own hook,
# which for an Agent call made by a subagent (its input carries `agent_id`)
# rewrites `run_in_background` to false through `updatedInput`. The main
# session's own calls are left alone.
#
# The scenario, run twice — once with only a logging hook (control), once with
# the fix beside it:
#
#   main  --Agent, foreground-->  A  --Agent, run_in_background true-->  B
#
# B runs `echo from-grandchild` and answers a secret word. A must put that word
# in its first and only report.
#
# It prints, per run: what the hook saw for each call (Q1: can it tell main from
# a subagent?), and from A's own transcript whether its Agent call came back as a
# background launch and whether its first report carries B's word. The fix run
# should read NO, YES, 1 report; the control YES, NO. Re-run it after a Claude
# Code upgrade.
#
# Each run is a real `claude -p` in a scratch directory, with the hooks given
# through `--settings` and the user's own settings not loaded — they may already
# carry the fix, which would spoil the control. Nothing is edited. Always exits 0.

set -u

readonly WORD=pineapple-7319
fix="$(cd "$(dirname "$0")/.." && pwd)/hooks/subagent-foreground.py"

prompt="Do exactly this and nothing else.
Call the Agent tool once: subagent_type general-purpose, run_in_background false, description \"agent A\", with this prompt:
---
You are agent A. Step 1: call the Agent tool once with subagent_type general-purpose, run_in_background true, description \"agent B\", and prompt: \"Run the shell command echo from-grandchild with the Bash tool, then reply with exactly this word and nothing else: $WORD\". Step 2: wait for agent B to finish and get its reply. Step 3: your final report must contain, first, the exact text the Agent tool returned to you in step 1, verbatim; then a line 'B SAID: ' followed by agent B's reply.
---
Then reply with agent A's report, verbatim."

run_once() {
    local mode=$1 work log hook settings fix_hook=""
    work=$(mktemp -d)
    log="$work/hook-input.jsonl"
    hook="$work/hook.py"
    settings="$work/settings.json"

    cat >"$hook" <<EOF
import json, sys
event = json.load(sys.stdin)
with open("$log", "a", encoding="utf-8") as f:
    f.write(json.dumps(event) + "\n")
EOF

    [ "$mode" = "fix" ] && fix_hook=", {\"type\": \"command\", \"command\": \"python3 $fix\"}"
    cat >"$settings" <<EOF
{"hooks": {"PreToolUse": [{"matcher": "Bash|Agent|Task",
  "hooks": [{"type": "command", "command": "python3 $hook"}$fix_hook]}]}}
EOF

    echo
    echo "=== Run: hook $mode (scratch $work) ==="
    ( cd "$work" && claude -p "$prompt" --settings "$settings" --setting-sources local \
        --allowedTools "Bash(echo:*)" "Agent" "Task" >"$work/answer.txt" 2>&1 )

    python3 - "$log" "$work/answer.txt" "$WORD" <<'EOF'
import json, sys
log_path, answer_path, word = sys.argv[1:4]
try:
    events = [json.loads(line) for line in open(log_path, encoding="utf-8")]
except FileNotFoundError:
    events = []
answer = open(answer_path, encoding="utf-8").read()

print(f"Hook calls logged: {len(events)}")
for e in events:
    tool_input = e.get("tool_input") or {}
    what = tool_input.get("command") or tool_input.get("description") or ""
    print(f"  {e.get('tool_name')} {what!r}: agent_id={e.get('agent_id')!r} "
          f"agent_type={e.get('agent_type')!r} run_in_background={tool_input.get('run_in_background')!r}")

a_call = next((e for e in events if e.get("tool_name") in ("Agent", "Task")
               and e.get("agent_id")), None)
print("Q1 - the hook saw agent A's Agent call as a subagent's:",
      "YES" if a_call else "NO (no Agent call carried agent_id)")
if a_call is None:
    print("--- answer ---\n" + answer.strip())
    sys.exit(0)

# Judge from A's own transcript, not from the main session's answer: A can
# paraphrase its tool result, and a late SendMessage can still carry B's word to
# the main session after A's real report went out without it.
transcript = a_call["transcript_path"].removesuffix(".jsonl") \
    + f"/subagents/agent-{a_call['agent_id']}.jsonl"
# A reports through SubagentHandback where the harness gives it that tool, and
# otherwise its first turn's closing text is the report.
agent_result, reports, first_turn_text = "", [], ""
for line in open(transcript, encoding="utf-8"):
    message = json.loads(line).get("message", {})
    content = message.get("content")
    for block in content if isinstance(content, list) else []:
        if block.get("type") == "tool_result" and not agent_result:
            agent_result = str(block.get("content"))
        if block.get("type") == "tool_use" and block.get("name") == "SubagentHandback":
            reports.append(block["input"].get("message", ""))
        if block.get("type") == "text" and message.get("role") == "assistant" \
                and not first_turn_text and message.get("stop_reason") == "end_turn":
            first_turn_text = block["text"]
reports = reports or [first_turn_text]

background = "Async agent launched" in agent_result
print("A's call to B came back as a background launch:", "YES" if background else "NO")
print("A's first report carries B's word:", "YES" if word in reports[0] else "NO")
print("A's reports:", len(reports))
EOF
}

echo "Claude Code: $(claude --version)"
run_once log
run_once fix
exit 0
