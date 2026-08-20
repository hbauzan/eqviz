# Prompt de ejecución — 06 + lecciones

Pegá esto a un agente (o seguí vos). Un prompt numerado. No adelantes 07.

---

Usando dev-protocol, ejecutá **solo** `roadmap/06-fft-bands.md`.

Antes de tocar código leé:

- `roadmap/00-invariants.md`
- `roadmap/STATUS.md`
- `.agents/lessons-learned.md`
- `roadmap/01-decision-gate.md` (decisiones locked)
- `macos/project.yml`
- `macos/eqviz/Audio/AudioEngine.swift`
- `macos/eqviz/Audio/RingBuffer.swift`
- este archivo

## Estado al arrancar

- 01–05 están `[x]` (humano verificó 05: ventana negra, `running · signal`, route change OK).
- Código 04+05 vive en `macos/eqviz/` (`ContentView`, `WindowConfigurator`, `Audio/`). Rama típica: `feat/app-window`. Si el working tree está sucio, **no lo revirtás**: es trabajo ya verificado. No reimplementes 04/05.
- `main` puede no tener 04+05 todavía. Trabajá sobre el árbol actual. Rama nueva OK (`feat/fft-bands`) si el árbol está limpio; si está sucio, seguí en la rama actual.
- No commit/push/merge salvo pedido explícito.

## Lecciones que aplican YA (06)

- FFT: Accelerate **vDSP** solamente. Size **2048**, `log2n = 11`, ventana **Hann**, hop **2048**, **sin overlap**. No 4096/8192 “por calidad”.
- Magnitud **lineal** (no dB en v1). Un `fftsetup`, reuso; destroy en `deinit`.
- 32 bandas log 20 Hz–20 kHz. Energía de banda = **media** de magnitudes. Output exacto: 32 floats 0…1. Sin NaN/Inf.
- `SpectrumSnapshot` con `NSLock`. `AudioEngine.spectrum` es ese objeto. **Prohibido** `@Observable var bands` / publicar el array a SwiftUI.
- Cola `eqviz.audio` (`qos: .userInitiated`) ya existe. El tap **copia** al ring y sale. La FFT corre en esa cola, nunca en el callback de captura.
- `RingBuffer` hoy: `write` + `readLatest` (peek). Hop 2048 sin overlap exige **consumo** (read que avanza) o un acumulador en la cola. No hagas FFT por cada buffer del tap (1024).
- `sampleRate` real sale del capturer (`InputNodeCapture.sampleRate`). Cablealo a `BandMapper`; no hardcodees 44100 como único path (los tests sí pueden fijar 44100 o 48000).
- Tests: target **`eqvizTests`** en `project.yml` (hoy `testTargets: []`). Sin seno inyectado este paso no está done. Los tests **no** pegan al mic.
- Regenerá con `(cd macos && xcodegen generate)` después de tocar `project.yml`. DerivedData: `macos/build`. Firma ad-hoc ya está. No `DEVELOPMENT_TEAM`. No `brew install`.
- Sandbox OFF. No `audio-input` entitlement (TCC ya funcionó sin él).
- Lenguaje Swift 5, macOS 14. Bundle ID `dev.local.eqviz`.

## Qué no adelantar (07+)

- 07: `PeakDecay` + tick de display. No `withAnimation`. No Timer 1/120.
- 08: `Canvas` 32×16, `TimelineView` 120Hz. Un view, no un `Rectangle` por segmento.
- 09: un renderer, cinco paletas. Unlit VFD vs OLED sigue STOP residual.
- 10: hover chrome, always-on-top, close-vs-hide, semáforos — **STOP**, no inventes.
- Cero ScreenCaptureKit / BlackHole. Cero `window.level`.

## Archivos (nombres locked)

```text
macos/eqviz/DSP/FFTProcessor.swift
macos/eqviz/DSP/BandMapper.swift
macos/eqviz/DSP/Normalizer.swift
macos/eqviz/Audio/AudioEngine.swift      # orquesta samples → snapshot
macos/eqvizTests/DSPTests.swift
macos/project.yml                        # test target + scheme test action
```

## Verificación

```bash
command -v xcodegen
(cd macos && xcodegen generate)
xcodebuild -project macos/eqviz.xcodeproj -scheme eqviz \
  -destination 'platform=macOS,arch=arm64' -configuration Debug \
  -derivedDataPath macos/build build
xcodebuild -project macos/eqviz.xcodeproj -scheme eqviz \
  -destination 'platform=macOS,arch=arm64' -configuration Debug \
  -derivedDataPath macos/build test
```

Tests mínimos (06): seno ~440 Hz → esa banda gana; ceros → ~0; `BandMapper` 32 bandas, 33 edges, monótonas.

Opcional DEBUG: una línea con `bands.max()`. **No** Canvas.

DoD: FFT 2048 Hann, 32 bandas 0…1, snapshot con lock, `DSPTests` verdes, `STATUS.md` 06 `[x]`, lecciones nuevas en `.agents/lessons-learned.md`.

Handoff: reportá verificación, cómo correr tests, y **esperá**. No push/merge.
