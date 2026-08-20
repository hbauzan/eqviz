# Prompt de ejecución — 03 + lecciones

Usando dev-protocol, ejecutá **solo** `roadmap/03-permissions.md`.

Leé primero: `roadmap/00-invariants.md`, `roadmap/STATUS.md`, `.agents/lessons-learned.md`, `roadmap/01-decision-gate.md`, `macos/project.yml`.

## Lecciones relevantes

- TCC **verbatim** (no ampliar): `eqviz does not record or send audio.`
- Sandbox **OFF**: no `com.apple.security.app-sandbox`. No `audio-input` salvo que el build/TCC falle; si lo agregás, anotá en lessons-learned.
- Bundle ID `dev.local.eqviz`. No `DEVELOPMENT_TEAM`. Firma CLI ad-hoc ya está en `project.yml`.
- No `engine.start()` en este paso: la app vacía **no** debe mostrar el diálogo de mic.
- Host tools: no `brew install`. Si `xcodebuild` falla por plugins: el humano (o, si ya se documentó) `xcodebuild -runFirstLaunch`.
- Regenerá con `(cd macos && xcodegen generate)` después de tocar plist/yml. DerivedData: `macos/build`.
- No adelantes `AudioEngine` (05). Un prompt por sesión.
- No commit/push salvo pedido explícito.

## Verificación

`plutil -lint`, `xcodebuild` Debug arm64 0, `NSMicrophoneUsageDescription` en el `.app` igual al verbatim, sin keys de Screen Recording.
