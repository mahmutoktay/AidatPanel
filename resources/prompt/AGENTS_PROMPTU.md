# 🤖 AGENTS PROMPT - AGENTS.md Creation Guide

**Version:** 3.0 (Solo dev adaptation + Score rubric + Removed duplicates)  
**Date:** 2026-05-07  
**Target Score:** 9.0/10 (Current: 7.5/10)

---

## 📋 TASK

Create or rewrite **AGENTS.md** for software projects. Goal: **SIGNAL DENSITY** (high signal-to-noise ratio).

**Output:** Minimal, project-specific, action-guiding, mistake-preventing AGENTS.md (1-2 pages).

AGENTS.md should be a minimal, high-value instruction file for coding agents working in the repo. It must only include information that is:
1) project-specific,
2) non-obvious,
3) action-guiding,
4) likely to prevent costly mistakes.

## Core Principles (must follow)
- Be minimal. Shorter is better if it preserves critical constraints.
- Include only information an agent cannot quickly infer from the codebase, standard tooling, or README.
- Prefer hard constraints over general advice.
- Prefer "must / must not" rules over vague recommendations.
- Do not duplicate docs, onboarding guides, or style guides.
- Do not include generic best practices (e.g., "write clean code", "add comments", "handle errors").
- Do not include rules already enforced by tooling (linters, formatters, CI) unless there is a known exception or trap.
- Optimize for task success, not human-facing prose quality.

## What AGENTS.md SHOULD contain (if applicable)
- Critical repo-specific safety constraints (e.g., migrations, API contracts, secrets, compatibility requirements)
- Required validation commands before finishing (test/lint/typecheck/build) only if they are actually used
- Non-obvious workflow constraints (e.g., pnpm-only, codegen order, required service startup dependencies)
- Unusual repository conventions that agents routinely miss
- Important file locations only when not obvious
- Change-safety expectations (e.g., preserve backward compatibility unless explicitly requested)
- Known gotchas that have caused repeated mistakes

## What AGENTS.md MUST NOT contain
- README replacement content
- Architecture deep-dives unless absolutely required to avoid breakage
- Generic coding philosophy
- Long examples unless the example captures a critical non-obvious pattern
- Repeated/duplicated rules
- Aspirational rules not enforced by the team
- Anything stale, uncertain, or "nice to know"

## Output Requirements
- Output ONLY the final AGENTS.md content (no commentary, no analysis, no preface).
- Use concise Markdown.
- Keep sections tight and skimmable.
- Prefer bullets over paragraphs.
- If information is missing or uncertain, omit it rather than invent.
- If a section has no high-signal content, omit the section entirely.
- Aim for the shortest document that still prevents major mistakes.

## Preferred Structure (adapt as needed)
- # AGENTS.md
- ## Must-follow constraints
- ## Validation before finishing
- ## Repo-specific conventions
- ## Important locations (only non-obvious)
- ## Change safety rules
- ## Known gotchas (optional)

## Rewrite Mode Behavior (important)
When given an existing AGENTS.md:
- Aggressively remove low-value or generic content
- Deduplicate overlapping rules
- Rewrite vague language into explicit action rules
- Preserve truly critical project-specific constraints
- Shorten relentlessly without losing important meaning

## Quality Bar (self-check before finalizing)
Before producing output, ensure:
- Every bullet is project-specific OR prevents a real mistake
- No generic advice remains
- No duplicated information remains
- The file reads like an operational checklist, not documentation
- A coding agent could use it immediately during implementation

---

## 📊 CONTEXT COLLECTION METHOD

Collect context from these sources before creating AGENTS.md:

### 1. Project Structure (5-10 min)
- [ ] Read `README.md` (stack, setup, conventions)
- [ ] Read `package.json` / `pubspec.yaml` / `go.mod` (dependencies, scripts)
- [ ] Read existing `AGENTS.md` if present (what's there, what's missing?)
- [ ] Read `.github/workflows/` (CI/CD, validation commands)
- [ ] Read `tsconfig.json` / `eslint.config.js` / `dart_defines` (tooling)

### 2. Code Analysis (10-15 min)
- [ ] Project root: Scan file structure (`src/`, `lib/`, `app/`, etc.)
- [ ] Critical files: Read `main.ts`, `main.dart`, `app.ts`, `index.js`
- [ ] API/Backend: Endpoint definitions, auth middleware, validation
- [ ] Frontend: State management, routing, component structure
- [ ] Database: Schema, migrations, constraints
- [ ] Secrets/Config: `.env.example`, environment variables

### 3. Error History (5-10 min)
- [ ] Scan git log: Frequently repeated errors, revert commits
- [ ] Scan commit messages: Look for "fix", "revert", "hotfix" entries
- [ ] Scan PR descriptions: Rejected or revised changes

### 4. Developer Notes (5 min)
- [ ] Is there a CLAUDE.md or project notes file? Read it.
- [ ] Planning files: What decisions were made and why?
- [ ] "What mistakes have I repeatedly made myself?"

### 5. Standard Checklist (2-3 min)
- [ ] Is backward compatibility required?
- [ ] How are breaking changes handled?
- [ ] What is the migration strategy?
- [ ] How are secrets managed?
- [ ] Is there API versioning?

---

## ✅ VALIDATION & QUALITY CONTROL

After creating AGENTS.md, check in a single pass:

### Content
- [ ] **Signal Density:** Is every line project-specific or mistake-preventing?
- [ ] **Minimal:** 1-2 pages (3+ = too much)
- [ ] **Actionable:** In must/must not format?
- [ ] **Accurate:** Matches the code? (no stale rules?)
- [ ] **No duplication:** README/tooling overlap removed?
- [ ] **Gotchas:** Repeated mistakes captured?

### Technical
- [ ] Are validation commands actually used?
- [ ] Are API contract / migration rules present?
- [ ] Are non-obvious workflow constraints specified?

---

## 🔄 VERSION MANAGEMENT

### Version Numbering
- **Patch (v1.0.1):** Typo, minor clarification
- **Minor (v1.1.0):** New rule added, existing rule revised
- **Major (v2.0.0):** Complete rewrite, 3+ rules changed

### Update Triggers
- [ ] New stack component added (dependency)
- [ ] New validation tool added (linter, formatter, test framework)
- [ ] Repeated mistake identified (in code review)
- [ ] API contract changed (breaking change)
- [ ] Migration strategy changed
- [ ] Secrets management method changed

### Update Process
1. Trigger event occurred
2. Collect context (what are the new rules?)
3. Revise AGENTS.md
4. Pass the validation checklist
5. Increment version number
6. Add to revision history

### Revision History Format
```markdown
## 📝 REVISION HISTORY

| Version | Date | Change |
|---------|------|--------|
| v1.0 | 2026-05-03 | Initial version (signal density principle) |
| v1.1 | 2026-05-04 | Flutter-specific rules added |
| v2.0 | 2026-05-05 | Context collection, validation, version management added |
```

---

## 📊 SCORE RUBRIC

| Score | Criteria |
|-------|----------|
| 4/10 | Every rule is generic — valid for any project |
| 5/10 | Stack specified, a few project-specific rules present |
| 6/10 | In must/must not format, validation commands present |
| 7/10 | Gotchas captured, no stale rules |
| 8/10 | No duplication, 1-2 pages, skimmable |
| 9/10 | "Reading this file gives a clear picture of the project" |
| 10/10 | No line can be removed, no line is missing |

---

## 📝 REVISION HISTORY

| Version | Date | Change |
|---------|------|--------|
| v1.0 | 2026-05-03 | Initial version (signal density principle, core principles, output requirements) |
| v2.0 | 2026-05-04 | Operational detail: Context collection method (5 sources), validation checklist, version management, quality control. Score: 7.5 → 8.5/10 |
| v3.0 | 2026-05-07 | Solo dev adaptation: Team Knowledge → personal notes, removed Slack references, merged VALIDATION+QUALITY, added score rubric |
| v3.1 | 2026-05-07 | Translated to English for better AI tool comprehension |
