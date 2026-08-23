# The report's shape follows the entrypoint

`dror-prove` and `dror-repair` check `CLAUDE_CODE_ENTRYPOINT` before reporting:
`claude-vscode` gets a table, anything else gets one line per item carrying the
same fields in the same order. A Markdown table renders in the IDE extension and
reads badly in a terminal.

## Consequences

The two forms must carry identical facts, or the same run would say different
things depending on where it was launched. The line form spells its fields
(`— test: … — found: … — outcome: …`) because a bare list of values has no
header to read them against.
