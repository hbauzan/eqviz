# Changelog

All notable changes to eqviz are documented here.

## [Unreleased]

- Add mic TCC copy to the PoC Info.plist (`eqviz does not record or send audio.`); sandbox and audio-input entitlements still omitted.
- Scaffold the macOS PoC app (`macos/`, XcodeGen, ad-hoc Debug build, window 800×240).
- Add interactive `./setup.sh` as the admin menu (Python tooling now; macOS build/run gated until the Xcode project exists).
- Add project rule: ask before assuming unless the user writes `SECURITY OVERRIDE`.

## [0.0.1] — 2026-08-20

- Bootstrap the repo: product identity, `uv` project, domain glossary, and portable `dev-protocol` skill.
