# Changelog

All notable changes to eqviz are documented here.

## [Unreleased]

- v1 PoC visualizer: 32×16 Canvas bars, five palettes, hover style picker, native traffic lights, close quits.
- Capture: macOS default input (`AVAudioEngine.inputNode`), route-change retap. No ScreenCaptureKit.
- DSP: vDSP FFT 2048 Hann, hop 2048, 32 log bands, display-clock peak gravity 1.2 /s.
- Admin: `./setup.sh` build / test-mac / run / stop (stop asks y/N). DerivedData `macos/build/`.
- Window: 800×240, hidden titlebar, normal level (not always-on-top).
- **Verified 2026-08-20** on Darwin arm64 (live bars, 5 styles, hover, close/min, resize, denied-permission path). Debug CPU ~30% in Activity Monitor (goal 1–2%). Cheap draw-path cuts applied (TimelineView wraps only the Canvas; batched fills; opaque Canvas); re-measure before chasing Metal.

## [0.0.1] — 2026-08-20

- Bootstrap the repo: product identity, `uv` project, domain glossary, and portable `dev-protocol` skill.
