# LESSONS LEARNED & ARCHITECTURAL INVARIANTS

Memoria de **este producto** (`eqviz`), no parte de la skill `dev-protocol`. Vive en `.agents/lessons-learned.md` (hermano de `skills/`). El protocolo de proceso se copia a otras apps; este archivo no.

Registra invariantes de arquitectura y patrones descubiertos acá. Si existe, los agentes lo consultan y actualizan en cada ciclo.

---

## 1. Product identity

- **eqviz** is an **ultralight real-time audio graphic visualizer**.
- Do not import VHectorLab / embedding / WebGL-lab invariants here. This is a different product.
- **Public lab (2026-08-20):** repo stays public with agent kitchen (`roadmap/`, `.agents/`). License is **CC BY 4.0** — use, fork, modify, cite [hbauzan/eqviz](https://github.com/hbauzan/eqviz). Human README is Spanish; agent contract stays in `roadmap/00-invariants.md`.

## 2. Design constraints (bootstrap)

- **Ultralight**: prefer the smallest stack that can paint audio in real time. Do not add LLM, 3D, or heavy UI frameworks unless the product explicitly needs them.
- **Real-time**: the audio → analysis → draw path is the latency budget. Analysis must not block the capture callback; drawing must not drop the audio thread.
- **macOS-first** until ported: this working copy lives on Darwin; do not claim Windows/Linux support without testing.

## 2.1. Ask / SECURITY OVERRIDE

- If a product, stack, permission, signing, or audio-source choice is missing: **ask and wait**.
- Do not treat “do what you think” as authorization.
- The only unlock phrase is literal `SECURITY OVERRIDE` plus the concrete decision.
- That phrase does not authorize committing secrets, capturing system audio in v1, or deleting the Python tooling bootstrap.

## 2.2. Path locked (2026-08-20)

- **App:** Swift + SwiftUI in `macos/eqviz/`. XcodeGen `project.yml`.
- **Tooling:** `./setup.sh` + Python/`uv`. Do not implement the visualizer in Python. Do not delete the Python bootstrap.
- **setup.sh is the chore funnel (2026-08-20):** every test, build, run, lint, or other repeatable task goes through a `./setup.sh` menu item (and its CLI alias). Never hand the human a raw `xcodebuild` / `pytest` / `ruff` recipe. If you add a test target or a new chore, wire it to the menu in the same change. macOS tests: option 11 / `./setup.sh test-mac`. DerivedData is `$ROOT/macos/build` (gitignored). Stop lists PIDs and asks y/N before SIGTERM; KILL is a second prompt. Never `pkill -9` from the agent.
- **PoC identity:** Bundle ID `dev.local.eqviz`. Not a distribution identity; changing it later resets mic TCC.
- **Signing:** Personal Team (free). Do not put `DEVELOPMENT_TEAM` in git. Human picks the team once in Xcode.
- **Host tools:** Human installs Homebrew/Xcode/XcodeGen. Agent never `brew install`. If a binary is missing: STOP and print the command.
- **Capture v1:** macOS default input via `AVAudioEngine.inputNode`. Follow device changes (reinstall tap). No device picker.
- **Capture v2:** system audio (ScreenCaptureKit) only if the user later says v1 does not meet expectations. Do not add SCK or BlackHole now.
- **Window size:** 800×240 (PoC start).
- **Window policy (10, 2026-08-20):** **normal** window; **no** always-on-top; **do not** set `window.level`. Close **terminates** (`AppDelegate.applicationShouldTerminateAfterLastWindowClosed` → true). Traffic lights **native** (close / miniaturize / zoom). Hover chrome is the 5-style picker only — no custom `×`/`−`. Overlay leading inset 78 pt so it does not cover the lights. No UserDefaults; style resets to `.retroRed` each launch. Changing style does not stop the engine.
- **TCC mic string (verbatim):** `eqviz does not record or send audio.` Do not expand the copy.
- **XcodeGen:** human-installed 2.46.x at `/opt/homebrew/bin/xcodegen`. Agent never brew-installs it.
- **CLI build:** `xcodebuild` may fail with IDESimulatorFoundation plugin errors until `xcodebuild -runFirstLaunch` (Xcode system content, not Homebrew). Do not `brew install` Xcode. If it needs sudo/GUI, STOP and ask the human.
- **Ad-hoc signing:** `CODE_SIGN_IDENTITY: "-"` + `CODE_SIGNING_REQUIRED: NO` lets CLI Debug builds succeed without a Team ID in git. Human still selects Personal Team in Xcode for interactive runs.
- **Sandbox:** OFF for this PoC. Turning it on is explicit later “prolijo” work.
- **TCC source of truth (03):** `NSMicrophoneUsageDescription` lives only in `macos/eqviz/Info.plist`. Do not also set `INFOPLIST_KEY_NSMicrophoneUsageDescription` in `project.yml` (duplicate keys).
- **No entitlements file (03):** Debug build succeeded without `eqviz.entitlements`, without `com.apple.security.device.audio-input`, and without `com.apple.security.app-sandbox`. Xcode still injects Debug-only `com.apple.security.get-task-allow`. Add `audio-input` only if a later `xcodebuild`/TCC path fails without it.
- **Inspecting the built plist:** `plutil -p …/eqviz.app/Contents/Info.plist` is reliable. `defaults read …/Contents/Info` can fail against a file path even when the key is present.
- **Window chrome (04 + 10, 2026-08-20):** `.windowStyle(.hiddenTitleBar)` + opaque black `NSWindow` via `WindowConfigurator`. Drag uses `isMovableByWindowBackground` because `.windowBackgroundDragBehavior` is macOS 15+ and the PoC deploys to 14.0. Traffic lights are un-hidden; window level stays default `.normal`.
- **Audio facade (05, runtime OK 2026-08-20):** TCC + default input + route-change retap verified by the human. DEBUG overlay: `running · signal` (human may type it with a hyphen). `@Observable` only for `isRunning` / `lastError` / `permissionDenied` / DEBUG `hasSignal`. Capturer, ring, and `eqviz.audio` queue are `@ObservationIgnored`. Mic via `AVAudioApplication.requestRecordPermission` before `engine.start()`. No `audio-input` entitlement was needed even after TCC succeeded. Do not publish PCM arrays to SwiftUI.
- **FFT / bands (06, 2026-08-20):** Accelerate vDSP only. Size 2048, `log2n = 11`, Hann, hop 2048 **no overlap**. Linear magnitude (not dB). One `fftsetup`, destroy in `deinit`. 32 log bands 20 Hz–min(20 kHz, Nyquist); band energy is the **mean** of magnitudes; empty low bands take the nearest bin (never NaN/Inf). `Normalizer`: `peak = max(peak * 0.99, max(bands))` per audio hop, clamp `[0, 1]`.
- **Snapshot (06):** `AudioEngine.spectrum` is a `SpectrumSnapshot` with `NSLock`. **Forbidden:** `@Observable var bands` / publishing the 32-float array to SwiftUI. DEBUG overlay may show `bands.max()` at the existing 250 ms `hasSignal` cadence (`debugBandMax`), not at audio rate.
- **Hop / ring (06):** `RingBuffer.read(_:)` consumes. The tap copies then `processQueue.async` (`eqviz.audio`); FFT never runs in the capture callback and never on every 1024-sample tap buffer. `sampleRate` comes from `InputNodeCapture` into `BandMapper` — do not hardcode 44100 as the only runtime path.
- **Tests (06):** target `eqvizTests` is a **logic** test (DSP sources compiled into the bundle, no `TEST_HOST`, no app launch). Hosting `eqviz.app` would auto-start capture via `ContentView.task`. Tests inject a synthetic sine; they must not touch the mic. Agent verifies with `./setup.sh test-mac` (that script already runs `xcodegen generate` + `xcodebuild test` against `macos/build`). Do not paste raw `xcodebuild` at the human.
- **Peak decay (07, 2026-08-20):** `PeakDecay.tick(bands:dt:)` — instant attack, linear gravity `1.2` amplitude units/second. Display clock only (`TimelineView(.animation(minimumInterval: DisplayClock.frameDuration))` wrapping **only** the Canvas, calling `AudioEngine.tickPeaks`). **Forbidden:** `withAnimation`, `Timer.scheduledTimer(1/120)`, decaying in the audio callback. `AudioEngine.peaks` is a second `SpectrumSnapshot` (lock); not `@Observable`. One `tickPeaks` per frame, then `peaks.copy()`. Do not nest a second TimelineView or tick twice.
- **Display clock (14, 2026-08-20):** `DisplayClock.framesPerSecond = 60`. Human: 120 Hz Debug was ~30% idle / ~40% while moving the window; 60 Hz is an accepted trade. Gravity still uses real `dt`. First-frame fallback is `DisplayClock.frameDuration`, not `1/120`.
- **Lit-only paint (14, 2026-08-20):** do **not** draw unlit cells. Opaque black canvas is OLED off. Palette still *computes* unlit RGB for tests; `VisualizerPainter` only `addRect`s `0..<litCount`. Metal/`drawingGroup` is roadmap 17 (STOP until A/B/C/D).
- **Visualizer Canvas (08, live OK 2026-08-20):** one `VisualizerView` = one `Canvas`, 32×16 square cells. Host ticks once, then `let peaks = engine.peaks.copy()` into the view (local `[Float]`; not `@Observable`). `VisualizerLayout.fitting` picks `min(cellX, cellY)` and centers the grid (letterbox black). Segment 0 is the bar base (canvas bottom). Lit `s < Int(peak * 16)` (floor). **Forbidden:** `HStack`/`VStack`/`Rectangle` per segment, SpriteKit/Metal, nested `TimelineView`, `print` in the Canvas, `withAnimation` on bars.
- **Layout tests (08):** `eqvizTests` compiles `eqviz/UI` (logic tests, still no `TEST_HOST`). `VisualizerLayoutTests` covers square cells, letterbox, base-at-bottom, and lit-count. Do not host the app in tests (that would auto-start capture).
- **Palettes (09, 2026-08-20):** one `VisualizerView`, five `VisualizerStyle` cases (`retroRed`, `whiteMatrix`, `rainbowSpectrum`, `fireGradient`, `cyberNeon`). Labels locked: `"Retro Red"` etc. Colors live in `VisualizerPalette.rgb` — copy the numbers from `roadmap/09-visualizer-styles.md`, do not invent hues. Default `@State style = .retroRed` in `ContentView`; changing it must not call `engine.stop()`. No UserDefaults. Unlit RGB still exists for tests; **paint skips unlit** (14). Fire and cyber lerp **by segment** (`t = segment/15`); rainbow hue **by band** (`hue = band/32`). Tests: `PaletteTests` (logic).
- **Hover chrome (10, 2026-08-20):** `onHover` on the root; opacity 0.18 s easeInOut; `allowsHitTesting(hovering)`; background black 0.55, no vibrancy. Five 11 pt text buttons. Does not recreate `PeakDecay` or call `engine.stop()`.
- **CPU (12, 2026-08-20):** human measured **~30%** Debug idle and **~40%** while moving the window at 120 Hz (goal 1–2%). 14 shipped 60 Hz + lit-only. Next: 15 Release/Instruments, 16 drag spike, 17 Metal only after a written A/B/C/D choice.
- **Live verify (12, 2026-08-20):** Darwin arm64. Bars, decay, five hot-swapped styles, hover-only chrome, native close=quit / miniaturize, resize, denied-permission no-crash. TCC already granted from 05/08.
- **Verify via setup.sh:** `./setup.sh test-mac` (menu 11). Do not paste `xcodebuild test` at the human.

## 2.3. Performance invariants (for when the visualizer exists)

- Draw segmented bars with one SwiftUI `Canvas`, not a View per block.
- Band/peak arrays are a lock-protected snapshot read on the display clock (`TimelineView` 60Hz). They are not `@Published` at audio rate.
- Peak decay uses real `dt` (amplitude per second), not a per-frame multiply that changes between 60Hz and 120Hz.
- `TimelineView` 60 Hz must not wrap hover chrome, `WindowConfigurator`, or `.task { engine.start() }`.
- Do not paint unlit segments. Do not add Metal unless 17 is chosen.

---

## 3. Protocolo de mantenimiento

1. **Consulta obligatoria**: leer este archivo al iniciar implementación, diseño de análisis de audio o render.
2. **Actualización continua**: al descubrir una invariante técnica, registrarla acá antes de cerrar la tarea.
