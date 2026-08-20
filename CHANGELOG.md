# Changelog

All notable changes to eqviz are documented here.

## [Unreleased]

- Peak decay: instant attack, gravity 1.2 /s on the display clock (`TimelineView` 120 Hz). No Canvas yet.
- vDSP real FFT (2048, Hann, hop 2048) → 32 log bands 0…1 behind `SpectrumSnapshot` (lock, not SwiftUI-published). `DSPTests` inject a sine; they do not use the mic.
- Capture default-input via `AVAudioEngine.inputNode` (TCC + route-change retap verified).
- Hidden titlebar + opaque black window (800×240, min 400×120); background drag via AppKit (macOS 14). Always-on-top still deferred.
- Add mic TCC copy to the PoC Info.plist (`eqviz does not record or send audio.`); sandbox and audio-input entitlements still omitted.
- Scaffold the macOS PoC app (`macos/`, XcodeGen, ad-hoc Debug build, window 800×240).
- Add interactive `./setup.sh` as the admin menu (Python tooling now; macOS build/run gated until the Xcode project exists).
- Add project rule: ask before assuming unless the user writes `SECURITY OVERRIDE`.

## [0.0.1] — 2026-08-20

- Bootstrap the repo: product identity, `uv` project, domain glossary, and portable `dev-protocol` skill.
