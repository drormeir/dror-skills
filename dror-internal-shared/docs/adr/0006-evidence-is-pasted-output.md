# Red and green mean pasted output, and mutations happen in a copy

An item counts as red only when a real run's failing assertion is on screen, and
green only when a real run's passing summary is. A test believed to fail is worth
nothing. This is the spine of `dror-prove` and `dror-code-repair`: it is the one rule
whose removal makes the whole thing theatre.

Where the code already works, the test passes on its first run and proves
nothing, so it earns **red by mutation**: the item's own negation, made in a copy
of the repo in the scratchpad, never in the working tree.

## Consequences

A run that broke the code to prove a test works would leave a repo that may not
be put back — and refuters run in parallel, so an edit in the working tree is
another agent reading a file mid-edit. Where no copy can stage the mutation the
item is recorded as **unproven**: the test is kept, and what is missing is the
evidence, not the test.

A test that goes green *before* any fix means the bug was never real: the code is
left alone, the test is kept, and the item is reported as not reproduced.
