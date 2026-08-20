# eqviz

Ultralight real-time audio graphic visualizer for macOS.

v1 is a Swift + SwiftUI PoC: 32×16 segmented bars, five palettes, default-input capture. Python/`uv` is **tooling only** (lint, repo tests, hooks). Admin entry: `./setup.sh`.

## Status

`0.0.1` PoC on Apple Silicon. Bundle ID `dev.local.eqviz`, Personal Team, sandbox off. Roadmap 01–13 is in [`roadmap/STATUS.md`](roadmap/STATUS.md).

Verified 2026-08-20 on Darwin arm64: live bars, decay, five styles, hover picker, native close (quits) / minimize, resize. Debug CPU was ~30% in Activity Monitor — still above the 1–2% goal; see CHANGELOG.

## Stack

- **App:** Swift 5 + SwiftUI, macOS 14+, XcodeGen (`macos/project.yml`), Bundle ID `dev.local.eqviz`
- **Capture v1:** Mac default input (`AVAudioEngine.inputNode`). No system-audio loopback in v1.
- **Tooling:** Python 3.12+ via [`uv`](https://docs.astral.sh/uv/)
- Apple Silicon first

## Setup

Host tools you install yourself: Xcode 15+, [XcodeGen](https://github.com/yonaskolb/XcodeGen). Never commit a Team ID.

```bash
./setup.sh
```

Or CLI:

```bash
./setup.sh status
./setup.sh test-mac
./setup.sh run
```

Stop asks `y/N` before SIGTERM (`./setup.sh stop`). Do not `pkill`.

First interactive run: `./setup.sh xcode` (or `open macos/eqviz.xcodeproj`) → Signing & Capabilities → **Personal Team**. If `xcodebuild` complains about plugins: `xcodebuild -runFirstLaunch`.

TCC microphone prompt (verbatim, do not expand): `eqviz does not record or send audio.` Grant it, then speak or send audio to the input selected in System Settings → Sound → Input.

## Layout

- `macos/eqviz/` — app
- `macos/eqvizTests/` — logic tests (no mic, no app launch)
- `./setup.sh` — build / test / run / stop / Python tooling
- `roadmap/` — sequenced prompts; `00-invariants.md` first for agents

```bash
./setup.sh next
uv sync --group dev
```

Copy `.env.example` to `.env` if you add local runtime config. Never commit `.env`.

Agents: read `roadmap/00-invariants.md` first. Do not assume product decisions unless the user writes `SECURITY OVERRIDE` plus the concrete choice.

## License

Not chosen yet.
