# Claude Code — project notes

**Read [`AGENTS.md`](AGENTS.md) first.** It holds the rules every agent follows
and how work is split between Claude, Codex and the cheaper subagents. Do not
restate them here.

[CineSeat/CINESEAT_ONE_PAGE.md](CineSeat/CINESEAT_ONE_PAGE.md) is the overview and
the module-by-module reflection.
[CineSeat/TICKETPLEASE_LIVE_READINESS_CHECKLIST.md](CineSeat/TICKETPLEASE_LIVE_READINESS_CHECKLIST.md)
lists what a real launch would still need — the best starting point for a roadmap.

Commands: **`/continue_CineSeat`** — start every session with it.

## Claude-specific conventions

- The architecture is MVVM with protocol-based DI and `AppFactory` as the
  composition root. Inject a fake through the protocol rather than reaching for
  a singleton; the existing tests show the pattern.
- `Domain/` must not import UIKit. If a change wants it to, the logic is in the
  wrong layer.
- Read `Constants/` before formatting anything for display — see AGENTS.md Rule 4.
- `xcodebuild` output is enormous. Pipe it through `| tail -40`, or use
  `-quiet`, rather than flooding context.
- `Training_Deliverables/` and `.agents/skills/` are the HyperFrames video work,
  not app code. Do not refactor them as if they were.
