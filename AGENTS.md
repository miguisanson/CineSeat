# Rules for any agent working on this repo

These apply to every agent — Claude Code, Codex, a local model, or a human.

**CineSeat / TicketPlease** — an iOS 17.5 booking app in **Swift 5 + UIKit**,
**MVVM with protocol-based dependency injection**, storing everything locally
(JSON, plist, UserDefaults, Keychain, FileManager). No Core Data, no CocoaPods.
Books movies, concerts and seminars. Overview:
[CineSeat/CINESEAT_ONE_PAGE.md](CineSeat/CINESEAT_ONE_PAGE.md). Gaps before a real
launch: [CineSeat/TICKETPLEASE_LIVE_READINESS_CHECKLIST.md](CineSeat/TICKETPLEASE_LIVE_READINESS_CHECKLIST.md).

This folder is the **Xcode project root**: `CineSeat.xcodeproj`, the `CineSeat/`
source group, `CineSeatTests/`, `CineSeatUITests/`, and the `Training_Deliverables/`
video work that ships alongside it.

---

## Rule 1 — The test comes first. Always.

A test written after the code passes that code and proves nothing.

1. Read the goal of the item.
2. Write the test from that goal, in `CineSeatTests/`.
3. **Run it and watch it fail** for the right reason — a wrong value or
   "not implemented", not a build error. Show the output.
4. Implement until it passes. Run the same targeted test again.
5. Then the gate.

Do not weaken, skip or delete a failing test to get green. If you cannot write
a failing test for the goal, stop and say so — the goal is underspecified.

| Work | The test you write first |
|---|---|
| A ViewModel behaviour (filter, sort, count text) | An `XCTestCase` driving the ViewModel directly and asserting its published output — the existing tests are the pattern |
| A domain rule (booking eligibility, review permission, ID format) | A test against the `Domain/` type, with a protocol-based fake injected |
| A formatter (`RatingDisplayFormatter`, `ShowingMetadataFormatter`, durations) | An assertion on the exact string, e.g. `"4.7 / 5.0"`, `"2h 32m"` — these exist to stop drift, so pin them |
| A repository / persistence change | A test with a temp `FileManager` directory, asserting what lands on disk and what reads back |
| A storyboard or Auto Layout screen | No unit test fits. Write a written acceptance check-list in the item and have the owner confirm it in the simulator; add a `CineSeatUITests` case when the flow is stable |
| A bug | A test that reproduces it and fails, before the fix |

## Rule 2 — Run only the tests that matter

```bash
xcodebuild test -scheme CineSeat \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:CineSeatTests/CineSeatTests/testMovieSearchAndRatingSortAcrossCategories
```

Targeted while working. The full gate once, at the end.

## Rule 4 — Formatters are the single source of display truth

Every visible score is `4.7 / 5.0` and every duration keeps lowercase units
(`2h 32m`) because **one** formatter produces each. `RatingDisplayFormatter`,
`ShowingMetadataFormatter`, `BookingNumberFormatter` and the date formatters in
`Constants/` exist precisely so list, detail, summary and booking text cannot
drift apart. Never format a rating, duration or booking ID inline at a call site.

What enforces it: `CineSeatTests` pins the exact output strings, so an inline
format that disagrees shows up as a failing assertion.

## Rule 3 — Stay inside the item

Do the item you were given. Noticing adjacent work is good; doing it is not —
list it at the end. Read the files the item needs, not the whole repo.

## Rule 5 — Leave the repo ready for whoever comes next

Any session can end without warning (usage limit, crash, the owner switching
agents), so an agent never waits until the end to write things down. Keep
`.planning/STATE.md` current as you go:

- **After every step that lands** (a check written, an implementation passing,
  a review done, a commit), update STATE.md's *Current Position*: what is
  done, what is in progress and on which branch or worktree, the exact next
  action, and anything learned that is not obvious from the code. Commit it
  with the work, or on its own if nothing else changed.
- **Before a long or risky step** (a delegated packet, a big refactor, a run
  in the background), write down first what you are about to do and where the
  output will go, so a session that dies halfway through can be picked up.
- **Never leave work only in your context.** Half-finished code gets a WIP
  commit on a branch (not the main branch) or a note in STATE.md naming the
  files it touched. Worktrees and background jobs are listed by path.
- **If you know the session is ending**, run `/gsd-pause-work` (Claude) or
  write the same thing by hand into STATE.md (any other agent).

The next agent starts with `/continue_CineSeat`, or, outside Claude, by reading
this file and `.planning/STATE.md` and running `git status`.

---

## The gate

Nothing merges that has not passed both:

```bash
xcodebuild build -scheme CineSeat -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild test  -scheme CineSeat -destination 'platform=iOS Simulator,name=iPhone 15'
```

`CineSeatUITests` needs a booted simulator and is slow; run it before a release,
not on every item.

## Where things are

| | |
|---|---|
| `CineSeat.xcodeproj` | The Xcode project. Scheme: `CineSeat`. |
| `CineSeat/Domain/` | Contracts and use cases. No UIKit in here. |
| `CineSeat/View/`, `CineSeat/ViewModel/` | Presentation. One ViewModel per screen. |
| `CineSeat/Persistence/` | Per-feature repositories: bookings, profiles, reviews, settings, seat layouts. |
| `CineSeat/Constants/` | The formatters. Read Rule 4 before touching these. |
| `CineSeat/Models/` | `Codable` models, including the separate TMDB review models. |
| `CineSeat/Design/`, `CustomViews/` | Shared UI: seat views, list headers, settings rows. |
| `CineSeatTests/` | Unit tests. `CineSeatUITests/` — launch and flow tests. |
| `Training_Deliverables/` | The training video/PPT deliverables. Not app code. |
| `.agents/skills/`, `skills-lock.json` | Vendored HyperFrames skills for the video work, restorable from the lock file. |

## Traps

- **`TMDB_READ_ACCESS_TOKEN` is an environment variable**, read in
  `Persistence/Reviews/TMDBConfiguration.swift` and wired through `Info.plist`.
  It is **never** hardcoded and must never be committed. Without it, online
  reviews degrade gracefully — that is intended, not a bug.
- **TicketPlease reviews and TMDB reviews are deliberately separate models.**
  Do not merge them into one list or one average rating.
- `LocalContent` JSON is **device-local storage**, not a shared database.
  Bookings, profiles and reviews live inside one installation. Do not design as
  if other users can see them.
- Writing a review requires a confirmed ticket **and** a start time in the past.
  Developer Mode bypasses the clock — do not "fix" that bypass away.
- `Training_Deliverables/_reference/footage/` and `hyperframes_videos/` are
  gitignored on purpose (312 MB). The finished deliverables are tracked.
- `Training_Deliverables.zip` is 353 MB — over GitHub's 100 MB per-file hard
  limit. It is gitignored and must stay that way.

## How the team splits work

| Agent | Does | Does not |
|---|---|---|
| **Claude** | Architecture, types and contracts, writing the failing test, reviewing and merging, anything touching security, data or licensing | Grind through bulk mechanical work |
| **Codex** | Makes a written failing test pass; implements a module or screen against a stated contract; works in its own git worktree | Change a check to match its code; widen scope |
| **Local model** (Ollama, `mcp__ollama__ask_local`, qwen2.5-coder:7b) | Free mechanical work: boilerplate, summaries of long text, commit messages, docstrings | Design, multi-file reasoning, anything unverified |

All three run on both machines — the MacBook (M3, 16 GB) and the Windows PC both
serve qwen2.5-coder:7b through Ollama. The failing test is the handoff: a precise,
checkable spec. Every delegated result is reviewed and gated before it merges.

### When an agent is unavailable — the fallback ladder

If one is out — Codex at its usage limit or erroring, Ollama not running — the
work moves down the ladder instead of stopping:

1. **Codex unavailable:** implementation goes to a **Claude subagent on a
   cheaper model** (`Agent` with `model: "sonnet"`) in the same worktree, with
   the same brief Codex would get. Independent packets run in parallel.
   The main Claude session keeps to checks, contracts, review and the gate.
2. **Local model unavailable** (Ollama not running, or the model not pulled):
   its mechanical work goes to a Claude subagent on `haiku` (or `sonnet` when it
   needs judgement). Start it with `open -a Ollama` before falling back.
3. **Both unavailable:** Claude subagents do both, cheapest model that can.
4. **Only the main session:** it implements inline, in the smallest packets.

Every rung keeps the same shape: failing test first, review, gate, commit the
check and the implementation together. Return to Codex as soon as it is back.
Note in `.planning/STATE.md` which rung a packet used.

- **Pilot before a batch.** Repetitive delegated work goes out as one item
  first; the rest follow only after that one is reviewed.
- **Escalate, don't retry.** If a packet fails twice, or passing it would
  change a locked type, contract or check, it comes back to Claude.

### Parallel Codex packets

```bash
git worktree add -b <branch> /Users/miguelsanson/Projects/CineSeat-wt/<short> HEAD
codex exec -C "/Users/miguelsanson/Projects/CineSeat-wt/<short>" -s workspace-write \
  --add-dir "/Users/miguelsanson/Projects/CineSeat/.git" --skip-git-repo-check \
  -o <short>.out.md - < <short>.prompt.md
```

The prompt starts with: read `AGENTS.md`; the check is the spec, **do not modify
it**; stop and explain if something looks wrong; touch only the named files.
**Codex's sandbox cannot spawn processes** — it cannot run the checks. Always run
them yourself before landing a packet. Remove the worktree after landing.

### The process: one owner per job

Several installed skill sets overlap if used naively, so every job has exactly
one owner. When a skill's default disagrees with this file, this file wins.

| Job | Owner | Not used for this job |
|---|---|---|
| Memory across sessions, the phase loop, context rot | **GSD Core** (local install, `budget` model profile). `/gsd-progress` or `/gsd-resume-work` to start; per phase `/gsd-discuss-phase` → `/gsd-plan-phase` → `/gsd-execute-phase` → `/gsd-verify-work`; `/gsd-pause-work` to stop; `/gsd-complete-milestone` | Superpowers `brainstorming`, `writing-plans`, `executing-plans`, `subagent-driven-development`, `dispatching-parallel-agents`; hand-written handoff files |
| Discipline inside a task: check first, debugging, proving it works, code review, worktrees, closing a branch | **Superpowers**: `test-driven-development`, `systematic-debugging`, `verification-before-completion`, `requesting-code-review`, `receiving-code-review`, `using-git-worktrees`, `finishing-a-development-branch` | GSD `/gsd-add-tests`, `/gsd-debug`, `/gsd-code-review`, `/gsd-audit-fix` |
| Stress-testing a design decision that is the owner's to make | **grill-me** (user-level skill, never committed: it has no licence) | ad-hoc question batches |
| Writing implementation code | **Codex**, else the fallback ladder above | Claude subagents writing implementations while Codex is available, including GSD's executor |
| Mechanical text work | **Local model** (Ollama, `mcp__ollama__ask_local`); a `haiku` subagent only if Ollama is down | Opus |


**The task shape inside `/gsd-execute-phase` is fixed:** (1) Claude writes the
failing test and watches it fail for the right reason; (2) Claude writes the
contract and hands implementation to Codex in a worktree; (3) Claude runs the
targeted checks and the gate itself; (4) `requesting-code-review` on the diff;
(5) `verification-before-completion`; (6) commit the check and the implementation
together. If GSD's executor starts writing the implementation in a Claude
subagent while Codex is available, stop and route the task to Codex.
