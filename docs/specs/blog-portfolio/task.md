# Tasks — Blog de portfólio (Ciência de Dados & Dev)

<!--
No frontmatter — spec.md is the source of truth.
Execution tracking for the current implementation pass. See plan.md for the
step-by-step and spec.md for scope decisions.
-->

## Checklist

- [ ] step 1 — <name>
- [ ] step 2 — <name>

## State Handover

<!--
Active memory. OVERWRITE this whole section each session — it is not a log.
- Done: <what is complete and verified>
- Next: <the very next concrete action>
- Blockers / open decisions: <anything waiting on someone>
- Watch out: <traps a fresh session would hit>
-->

## Execution Log

<!-- Append-only. Newest entries at the bottom. One block per session/pass. -->

### YYYY-MM-DD — <summary>

- <what was done>
- <decisions made that were not in the plan>

## Verification

<!--
Per pass. Copy this block for each pass. Never report results as prose —
record the actual command run (from plan.md) and a count, not "it passed".
-->

### YYYY-MM-DD

- [ ] Full test suite — `<command>` — `<N tests, 0 failures>`
- [ ] Static analysis scoped to changed files — `<command>` — `<0 new errors>` (pre-existing confirmed by reverting the change: `<...>`)
- [ ] Lint / formatting — `<command>` — pass
- [ ] Any artifact the change is expected to (re)produce — `<what, and where to see it>`

## Wrap up

- [ ] PR opened (`<branch>` → `<base>`)
- [ ] Spec linked from the issue (`<ISSUE>`)
- [ ] Follow-up issues created and referenced in `spec.md` / `plan.md`
- [ ] `spec.md` `status:` updated (`implemented` / `archived`)