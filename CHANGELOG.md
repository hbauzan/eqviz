# Changelog

All notable changes to eqviz are documented here.

## [Unreleased]

- README: screenshot, schematic layout, palette badges.
- GitHub About: description + topics; `dev-protocol` git-workflow §3.6 for public repos.
- License: CC BY 4.0 (use with attribution to https://github.com/hbauzan/eqviz).
- v1 PoC visualizer: 32×16 Canvas bars, five palettes, hover style picker, native traffic lights, close quits.
- Capture: macOS default input (`AVAudioEngine.inputNode`), route-change retap. No ScreenCaptureKit.
- DSP: vDSP FFT 2048 Hann, hop 2048, 32 log bands, display-clock peak gravity 1.2 /s.
- Admin: `./setup.sh` build / test-mac / run / stop (stop asks y/N). DerivedData `macos/build/`.
- Window: 800×240, hidden titlebar, normal level (not always-on-top).
- Display: 60 Hz Canvas, **lit cells only** (black canvas = off). Debug CPU was ~30% idle / ~40% while moving at 120 Hz; 15–17 continue that work.

## [0.0.1] — 2026-08-20

- Bootstrap the repo: product identity, `uv` project, domain glossary, and portable `dev-protocol` skill.
