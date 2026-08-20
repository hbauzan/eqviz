# eqviz

Ultralight real-time audio graphic visualizer.

This repo holds a **Swift + SwiftUI** macOS PoC (black window compiles) plus Python/`uv` **tooling** and `./setup.sh`. The visualizer loop is not implemented yet. Sequenced in [`roadmap/`](roadmap/). v1 captures the Mac’s **default audio input**.

## Status

`0.0.1` — initialized. Path: Swift PoC, default input, Bundle ID `dev.local.eqviz`, Personal Team, sandbox off.

Admin entry point: `./setup.sh`. Next prompt: `./setup.sh next` (`03-permissions.md`).

## Stack

- **App:** Swift + SwiftUI, XcodeGen (`macos/project.yml`), Bundle ID `dev.local.eqviz`
- **Tooling:** Python 3.12+ via [`uv`](https://docs.astral.sh/uv/) — lint, repo tests, pre-commit. Not the visualizer.
- macOS 14+ / Apple Silicon first

## Setup

```bash
./setup.sh
```

Build/run the PoC app (after `macos/` exists):

```bash
./setup.sh build
./setup.sh run
```

First interactive run in Xcode: open `macos/eqviz.xcodeproj`, Signing & Capabilities → **Personal Team**. Host tools (Xcode, XcodeGen) you install yourself. If `xcodebuild` complains about plugins: `xcodebuild -runFirstLaunch`.

The menu also covers tooling (`sync`, tests, lint). Destructive actions ask `y/N`.

```bash
./setup.sh next
uv sync --group dev
```

Copy `.env.example` to `.env` if you add local runtime config. Never commit `.env`.

Agents: read `roadmap/00-invariants.md` first. Do not assume product decisions unless the user writes `SECURITY OVERRIDE` plus the concrete choice.

## License

Not chosen yet.
