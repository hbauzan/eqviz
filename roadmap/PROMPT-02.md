# Prompt de ejecución — 02 + lecciones para lo que sigue

Pegá esto a un agente (o seguí vos). Un prompt numerado. No adelantes 03.

---

Usando dev-protocol, ejecutá **solo** `roadmap/02-xcode-bootstrap.md`.

Antes de tocar código leé:

- `roadmap/00-invariants.md`
- `roadmap/STATUS.md`
- `.agents/lessons-learned.md`
- `roadmap/01-decision-gate.md` (decisiones locked)
- este archivo

## Lecciones que aplican YA (02)

- App = Swift + SwiftUI. Layout `macos/` + XcodeGen `project.yml`. No Package.swift. No pbxproj a mano.
- Bundle ID `dev.local.eqviz`. No escribas `DEVELOPMENT_TEAM`. Sandbox OFF: no pongas `app-sandbox`.
- Host tools las instala el humano. `xcodegen` ya está. Si falta: STOP y el comando; nunca `brew install`.
- CLI: firma ad-hoc `CODE_SIGN_IDENTITY: "-"` / no required, para no inventar Team. El humano elige Personal Team en Xcode para ⌘R.
- Ventana placeholder negra. Tamaño **800×240**. No hidden titlebar, no hover, no `ContentView` (eso es 04). Cero audio (03/05). Cero FFT. Cero estilos.
- No pises `pyproject.toml` / `main.py` / `setup.sh` Python.
- `macos/eqviz.xcodeproj` se genera y se versiona. DerivedData en `macos/build/` (gitignored).
- Rama de trabajo: `feat/macos-xcode-bootstrap`. No push, no merge, no commit salvo que el usuario lo pida (user rule de commits).

## Lecciones para NO adelantar (03+)

- 03: `NSMicrophoneUsageDescription` **verbatim** `eqviz does not record or send audio.` No ampliar. Sin sandbox. Sin `audio-input` salvo que el build/TCC falle.
- 04: negro + hidden titlebar + drag. Always-on-top y close-vs-hide **STOP** si no están locked.
- 05: solo `AVAudioEngine.inputNode` (default input). Seguir route change. No SCK, no BlackHole. Bandas no son `@Observable` de alta frecuencia.
- 06–08: vDSP 2048 Hann, 32 bandas log, decay con `dt` real, un `Canvas`, `TimelineView` 120Hz.
- 09: un renderer, cinco paletas. 10: hover chrome. Close/min según lock o STOP.

## Verificación 02

```bash
command -v xcodegen
(cd macos && xcodegen generate)
xcodebuild -project macos/eqviz.xcodeproj -scheme eqviz \
  -destination 'platform=macOS,arch=arm64' -configuration Debug \
  -derivedDataPath macos/build build
```

DoD: build 0, ventana negra 800×240, Python intacto, `STATUS.md` 02 `[x]`, lección nueva si xcodebuild exigió un flag de signing.

No abras un commit. Handoff: cómo abrir en Xcode y setear Personal Team.
