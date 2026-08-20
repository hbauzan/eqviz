# 07 — Decay gravity (picos vintage)

## Meta

Un segundo vector de **picos** que sube instantáneo con las bandas y cae con gravedad en el **reloj de display**, no en el tap de audio. Es el look de equipos de sonido clásicos.

## Precondiciones

- 06 `[x]`, `SpectrumSnapshot` con 32 bandas.

## STOP

- No uses animaciones SwiftUI (`withAnimation` / `spring`) para las barras: no es decay de VU y pelea con 120Hz.
- No caigas los picos en el callback de audio (rate ≠ vsync → look irregular).

## Archivos

```text
macos/eqviz/DSP/PeakDecay.swift
macos/eqviz/Audio/AudioEngine.swift   # expone snapshot de peaks, o PeakDecay vive junto al view clock
```

Diseño preferido (menor error):

- `PeakDecay` tiene `func tick(bands: [Float], dt: CFTimeInterval) -> [Float]`
- Lo llama el `TimelineView` (paso 08). En **este** paso 07, si 08 no existe, llamalo desde un `TimelineView` placeholder invisible o desde `AudioEngine` con un `CADisplayLink`/`DisplayLink` **solo si** ya estás en AppKit. Más simple: `PeakDecay` + test unitario ahora, y `AudioEngine.peaksSnapshot` actualizado en un `Timer` 120Hz **no**. Timer ≠ vsync.

Compromiso de este paso: implementá `PeakDecay` testable y cablealo a un tick que **sí** exista. Opciones permitidas (elegí una y documentala):

1. `TimelineView` mínimo en `ContentView` que solo llama `tick` y guarda peaks en `PeakSnapshot` (sin dibujar barras). Preferida.
2. `CADisplayLink` (macOS 14+) en `AudioEngine`, `preferredFrameRateRange` 120. Más código AppKit.

No uses `Timer.scheduledTimer(1/120)`.

## Modelo

Para cada banda `i`:

```text
if bands[i] >= peaks[i]:
    peaks[i] = bands[i]          # ataque instantáneo
else:
    peaks[i] = max(0, peaks[i] - gravity * Float(dt))
    # o peaks[i] *= pow(decayPerSecond, dt)
```

Elegí **gravedad lineal en unidades de amplitud/segundo**, no un * 0.92 mágico por frame (depende de 60 vs 120Hz). Default técnico:

- `gravity = 1.2` unidades por segundo (un pico a 1.0 llega a 0 en ~0.83s). Ajustable constante `PeakDecay.gravity`.

Opcional v1 (no obligatorio): peak-hold 80 ms antes de caer. Si lo agregás, constante `holdSeconds = 0.08`.

Clamp 0…1. Longitud 32. Sin alloc en el hot path si podés (`peaks` mutables reutilizados).

## Tests

```text
macos/eqvizTests/PeakDecayTests.swift
```

1. `tick` con bands `[1,0,0,…]` luego bands todo 0, `dt=1/120`, repetido: pico 0 cae; pico no-cero no sube sin señal.
2. Mismo estado inicial, 60 ticks a 1/60s vs 120 ticks a 1/120s: picos finales cercanos (invariante vs fps).
3. Ataque: bands 0.2 luego 0.9 → peak 0.9 en un tick.

## Definition of Done

- [x] Picos independientes de las bandas instantáneas.
- [x] Caída en dt real (independiente de 60/120).
- [x] Tests verdes.
- [x] Nada de Canvas de bloques todavía (salvo TimelineView vacío).
- [x] `STATUS.md` 07 `[x]`.

## Fuera de alcance

Estilos de color, hover UI, 5 temas.
