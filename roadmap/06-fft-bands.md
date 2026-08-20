# 06 — FFT vDSP → bandas log normalizadas

## Meta

Convertir cada ventana de samples en `[Float]` de longitud **32**, valores 0.0…1.0, graves→agudos, usando **Accelerate vDSP**. El resultado vive en un snapshot con lock, no en el graph de SwiftUI.

## Precondiciones

- 05 `[x]`, hay samples Float32 mono y `sampleRate` real.
- Defaults técnicos de `00-invariants.md`: FFT 2048, Hann, 32 bandas, 20 Hz–20 kHz, EMA de pico.

## STOP

- No cambies a 4096/8192 “por calidad” sin pedido: CPU.
- No uses `AVAudioNode` tap para dibujar. No uses librerías FFT de terceros.
- No hagas FFT dentro del callback de captura si te pasa de presupuesto: copiá al ring buffer; la cola `eqviz.audio` corre FFT. Si 2048 samples tardan de más, igual es el diseño correcto — no bajes a FFT en el hilo de I/O.

## Archivos

```text
macos/eqviz/DSP/FFTProcessor.swift     # setup vDSP, process(samples) -> spectrum bins
macos/eqviz/DSP/BandMapper.swift       # bins -> 32 log bands
macos/eqviz/DSP/Normalizer.swift       # EMA peak → 0...1
macos/eqviz/Audio/AudioEngine.swift    # orquesta: samples → processor → snapshot
macos/eqvizTests/DSPTests.swift        # seno inyectado → banda esperada
```

Agregá un **test target** en `project.yml` (`eqvizTests`). Sin test de seno, este paso no está done. Los tests no pegan al mic: inyectan un buffer sintético.

## FFTProcessor — requisitos

- `vDSP_create_fftsetup` / destroy en `deinit`. Un setup, reuso.
- `log2n = 11` (2048).
- Ventana Hann (`vDSP_hann_window` + `vDSP_vmul`).
- `vDSP_ctoz` + `vDSP_fft_zrip` (real FFT).
- Magnitud: `vDSP_zvmags` (potencia) o magnitud; **potencia (mags²) o magnitud**: usá magnitud (`sqrt` o `vDSP_vdbcon` no hace falta). Preferí magnitud lineal para el EQ visual, no dB en v1 (dB comprime el look). Documentalo.
- Si llegan menos de 2048 samples, no proceses (esperá el ring). Si llegan más, tomá 2048 (hop = 2048, sin overlap en v1 — overlap 50% es extra CPU; no).

## BandMapper

- `fftBinCount = 1024` (nyquist).
- Bandas log: edge `fmin * (fmax/fmin)^(i/32)`.
- bin = `f * fftSize / sampleRate`.
- Energía de banda = max o media de bins en el rango; usá **media** de magnitudes (max es más nervioso). Si una banda no tiene bins (graves a sr bajo), asigná el bin más cercano — no dejes NaN ni 0 permanente en banda 0 sin comentario.
- Output: exactamente 32 floats, no más, no menos.

## Normalizer

- `peak = max(peak * 0.99, max(bands))` (EMA). Constantes: `attack` instantáneo al nuevo max, `release` 0.99/frame de **audio** (no display). Si el pico es ~0, bandas ~0 (silencio).
- Clamp `[0, 1]`. Sin NaN/Inf (`isnan` → 0).

## Snapshot (CPU)

```text
final class SpectrumSnapshot: @unchecked Sendable {
  private let lock = NSLock()
  private var bands = [Float](repeating: 0, count: 32)
  func write(_ src: [Float]) { lock.lock(); bands = src; lock.unlock() }
  func copy() -> [Float] { lock.lock(); defer { lock.unlock() }; return bands }
}
```

`AudioEngine.spectrum` es este objeto. **No** `@Observable var bands`.

## Tests

Casos mínimos:

1. Seno ~440 Hz a `sampleRate` 44100 o 48000, amplitud 0.5, 2048 samples → la banda que cubre 440 Hz es la de mayor valor; las lejanas < 0.2× esa.
2. Buffer de ceros → todas las bandas ≈ 0.
3. `BandMapper` edges: 32 bandas, `edges.count == 33`, monótonas, `edges.first >= 20-epsilon`, última ≤ nyquist.

Correr tests:

```bash
xcodebuild -project macos/eqviz.xcodeproj -scheme eqviz -destination 'platform=macOS,arch=arm64' -configuration Debug test
```

Si el scheme no corre tests, arreglá `project.yml` (test target + scheme test action).

## Verificación en app

DEBUG overlay: 32 números o un sparkline **no** es necesario si los tests pasan. Opcional: una línea de texto con `bands.max()`. No implementes el Canvas acá.

## Definition of Done

- [ ] vDSP real FFT, Hann, 2048, 32 bandas log, 0…1.
- [ ] Snapshot con lock; SwiftUI no observa el array.
- [ ] `DSPTests` verdes.
- [ ] `STATUS.md` 06 `[x]`.

## Fuera de alcance

Decay/peaks, Canvas, estilos, 120Hz.
