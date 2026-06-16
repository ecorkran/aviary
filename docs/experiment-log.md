# aviary experiment log

Append-only observations. Date, what ran, what happened, what surprised you.

## 2026-06-15 — first bot run: gather_oak_logs

- setup: Paper 1.21.6, Mindcraft (latest main), scout profile (claude-sonnet-4-6), Node v22.22.1, Java 21
- task: `tasks/basic/single_agent.json / gather_oak_logs` — collect 4 oak logs, starts with wooden axe
- outcome: **PASS** — `Collected 4 oak_log`, task framework confirmed via inventory check before shutdown
- surprises / failure modes:
  - Custom `conversing` field in scout.json caused command hallucinations (`!nearby`, `!lookAround`). Fix: drop `conversing`, use Mindcraft's built-in system prompt. Keep profiles minimal (name + model only).
  - First run failed: bot collected logs then was killed by zombie and dropped inventory before task checker ran. Fix: set server to `/difficulty peaceful` for controlled experiments.
  - Mineflayer patch (4.33.0 → 4.37.1 version bump) failed silently during `npm install`; patch was already obsolete. No impact on this task.
  - Embedding model error on startup is harmless — falls back to word-overlap, no OpenAI key needed.

## YYYY-MM-DD — template
- setup:
- task:
- outcome (world-state verified?):
- surprises / failure modes:
