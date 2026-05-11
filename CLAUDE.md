# Project context

<!-- Keep this file small. Conventions live in skills, not here. -->

## Stack

- Language: <FILL IN>
- Framework: <FILL IN>
- Test runner: <FILL IN>
- Linter / formatter: <FILL IN>
- Package manager: <FILL IN>

## Architecture

This project follows <FILL IN: e.g. hexagonal architecture with DDD>. See the `architecture` skill for the rules.

## How you (the agent) work here

- Before writing or modifying code, read the relevant skill(s) in `.claude/skills/`. Match by the skill's description.
- For any ticket-driven work, use the `/work` command rather than coding directly from a prompt. It enforces Explore → Plan → Implement → Verify with checkpoints.
- Tests come first. Do not write production code without a failing test that motivates it. See the `testing-conventions` skill.
- Never bypass hooks. If a hook blocks you, fix the underlying issue rather than working around it.
- Never invent ticket IDs, API contracts, or library APIs. If unsure, ask or read the code.
- When you finish a piece of work, the `code-reviewer` subagent reviews your diff before you hand back to the human.

## Project-specific notes

<!-- Anything truly always-relevant: domain glossary pointer, deployment quirks, "the foo service is being decommissioned, don't extend it" -->
