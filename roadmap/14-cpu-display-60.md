# 14 — Display 60 Hz, solo segmentos lit

## Meta

Bajar CPU del visualizer **sin Metal**: reloj de display a **60 Hz** y **no dibujar unlit**. El fondo negro del Canvas es el apagado (OLED).

## Precondiciones

- 13 `[x]`. Humano: 120 Hz Debug ~30% idle visual, ~40% al mover la ventana.

## Locked (2026-08-20, humano)

- 60 Hz: sí, sin drama.
- Unlit: no se pinta. No VFD dim.
- Metal/`drawingGroup`: **no** en este paso. Queda `17-cpu-metal.md`.

## Archivos

```text
macos/eqviz/DSP/DisplayClock.swift
macos/eqviz/ContentView.swift
macos/eqviz/Audio/AudioEngine.swift
macos/eqviz/UI/VisualizerView.swift
```

## Reloj

`TimelineView(.animation(minimumInterval: DisplayClock.frameDuration))` con `framesPerSecond = 60`. Gravity sigue usando `dt` real (PeakDecay no cambia). Primer frame: `DisplayClock.frameDuration`, no `1/120`.

Un solo TimelineView, solo alrededor del Canvas.

## Paint

- Fill negro opaco del canvas.
- Solo `Path.addRect` de celdas lit (`segment < litCount`).
- No construir ni fill de unlit.

## Verificación

`./setup.sh test-mac`. Live CPU lo re-mide el humano (15).

## Definition of Done

- [x] 60 Hz en `DisplayClock`.
- [x] Unlit no se dibuja.
- [x] Tests. `STATUS.md` 14 `[x]`.

## Fuera de alcance

Release vs Debug, Instruments, drag 40%, Metal.
