# LESSONS LEARNED & ARCHITECTURAL INVARIANTS

Memoria de **este producto** (`eqviz`), no parte de la skill `dev-protocol`. Vive en `.agents/lessons-learned.md` (hermano de `skills/`). El protocolo de proceso se copia a otras apps; este archivo no.

Registra invariantes de arquitectura y patrones descubiertos acá. Si existe, los agentes lo consultan y actualizan en cada ciclo.

---

## 1. Product identity

- **eqviz** is an **ultralight real-time audio graphic visualizer**.
- Do not import VHectorLab / embedding / WebGL-lab invariants here. This is a different product.

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
- **setup.sh is the chore funnel (2026-08-20):** every test, build, run, lint, or other repeatable task goes through a `./setup.sh` menu item (and its CLI alias). Never hand the human a raw `xcodebuild` / `pytest` / `ruff` recipe. If you add a test target or a new chore, wire it to the menu in the same change. macOS tests: option 11 / `./setup.sh test-mac`. Step 11 still owns verifying the full menu; this rule applies from now on.
- **PoC identity:** Bundle ID `dev.local.eqviz`. Not a distribution identity; changing it later resets mic TCC.
- **Signing:** Personal Team (free). Do not put `DEVELOPMENT_TEAM` in git. Human picks the team once in Xcode.
- **Host tools:** Human installs Homebrew/Xcode/XcodeGen. Agent never `brew install`. If a binary is missing: STOP and print the command.
- **Capture v1:** macOS default input via `AVAudioEngine.inputNode`. Follow device changes (reinstall tap). No device picker.
- **Capture v2:** system audio (ScreenCaptureKit) only if the user later says v1 does not meet expectations. Do not add SCK or BlackHole now.
- **Window size:** 800×240 (PoC start). Always-on-top and close-vs-hide still open → STOP at 10 (04 shipped without floating / close policy).
- **TCC mic string (verbatim):** `eqviz does not record or send audio.` Do not expand the copy.
- **XcodeGen:** human-installed 2.46.x at `/opt/homebrew/bin/xcodegen`. Agent never brew-installs it.
- **CLI build:** `xcodebuild` may fail with IDESimulatorFoundation plugin errors until `xcodebuild -runFirstLaunch` (Xcode system content, not Homebrew). Do not `brew install` Xcode. If it needs sudo/GUI, STOP and ask the human.
- **Ad-hoc signing:** `CODE_SIGN_IDENTITY: "-"` + `CODE_SIGNING_REQUIRED: NO` lets CLI Debug builds succeed without a Team ID in git. Human still selects Personal Team in Xcode for interactive runs.
- **Sandbox:** OFF for this PoC. Turning it on is explicit later “prolijo” work.
- **TCC source of truth (03):** `NSMicrophoneUsageDescription` lives only in `macos/eqviz/Info.plist`. Do not also set `INFOPLIST_KEY_NSMicrophoneUsageDescription` in `project.yml` (duplicate keys).
- **No entitlements file (03):** Debug build succeeded without `eqviz.entitlements`, without `com.apple.security.device.audio-input`, and without `com.apple.security.app-sandbox`. Xcode still injects Debug-only `com.apple.security.get-task-allow`. Add `audio-input` only if a later `xcodebuild`/TCC path fails without it.
- **Inspecting the built plist:** `plutil -p …/eqviz.app/Contents/Info.plist` is reliable. `defaults read …/Contents/Info` can fail against a file path even when the key is present.
- **Window chrome (04):** `.windowStyle(.hiddenTitleBar)` + opaque black `NSWindow` via `WindowConfigurator`. Drag uses `isMovableByWindowBackground` because `.windowBackgroundDragBehavior` is macOS 15+ and the PoC deploys to 14.0. Do not set `window.level` — always-on-top and close-vs-hide stay STOP until 10.
- **Audio facade (05, runtime OK 2026-08-20):** TCC + default input + route-change retap verified by the human. DEBUG overlay: `running · signal` (human may type it with a hyphen). `@Observable` only for `isRunning` / `lastError` / `permissionDenied` / DEBUG `hasSignal`. Capturer, ring, and `eqviz.audio` queue are `@ObservationIgnored`. Mic via `AVAudioApplication.requestRecordPermission` before `engine.start()`. No `audio-input` entitlement was needed even after TCC succeeded. Do not publish PCM arrays to SwiftUI.
- **FFT / bands (06, 2026-08-20):** Accelerate vDSP only. Size 2048, `log2n = 11`, Hann, hop 2048 **no overlap**. Linear magnitude (not dB). One `fftsetup`, destroy in `deinit`. 32 log bands 20 Hz–min(20 kHz, Nyquist); band energy is the **mean** of magnitudes; empty low bands take the nearest bin (never NaN/Inf). `Normalizer`: `peak = max(peak * 0.99, max(bands))` per audio hop, clamp `[0, 1]`.
- **Snapshot (06):** `AudioEngine.spectrum` is a `SpectrumSnapshot` with `NSLock`. **Forbidden:** `@Observable var bands` / publishing the 32-float array to SwiftUI. DEBUG overlay may show `bands.max()` at the existing 250 ms `hasSignal` cadence (`debugBandMax`), not at audio rate.
- **Hop / ring (06):** `RingBuffer.read(_:)` consumes. The tap copies then `processQueue.async` (`eqviz.audio`); FFT never runs in the capture callback and never on every 1024-sample tap buffer. `sampleRate` comes from `InputNodeCapture` into `BandMapper` — do not hardcode 44100 as the only runtime path.
- **Tests (06):** target `eqvizTests` is a **logic** test (DSP sources compiled into the bundle, no `TEST_HOST`, no app launch). Hosting `eqviz.app` would auto-start capture via `ContentView.task`. Tests inject a synthetic sine; they must not touch the mic. Agent verifies with `./setup.sh test-mac` (that script already runs `xcodegen generate` + `xcodebuild test` against `macos/build`). Do not paste raw `xcodebuild` at the human.
- **Peak decay (07, 2026-08-20):** `PeakDecay.tick(bands:dt:)` — instant attack, linear gravity `1.2` amplitude units/second. Display clock only (`TimelineView(.animation(minimumInterval: 1/120))` in `ContentView` calling `AudioEngine.tickPeaks`). **Forbidden:** `withAnimation`, `Timer.scheduledTimer(1/120)`, decaying in the audio callback. `AudioEngine.peaks` is a second `SpectrumSnapshot` (lock); not `@Observable`. 08 draws inside this **same** TimelineView: one `tickPeaks` per frame, Canvas reads `peaks.copy()`. Do not nest a second TimelineView or tick twice.
- **Verify via setup.sh:** `./setup.sh test-mac` (menu 11). Do not paste `xcodebuild test` at the human.

## 2.3. Performance invariants (for when the visualizer exists)

- Draw segmented bars with one SwiftUI `Canvas`, not a View per block.
- Band/peak arrays are a lock-protected snapshot read on the display clock (`TimelineView` 120Hz). They are not `@Published` at audio rate.
- Peak decay uses real `dt` (amplitude per second), not a per-frame multiply that changes between 60Hz and 120Hz.

---

## 3. Protocolo de mantenimiento

1. **Consulta obligatoria**: leer este archivo al iniciar implementación, diseño de análisis de audio o render.
2. **Actualización continua**: al descubrir una invariante técnica, registrarla acá antes de cerrar la tarea.
