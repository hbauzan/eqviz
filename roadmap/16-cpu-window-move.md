# 16 — CPU al mover la ventana (~40%)

## Meta

El humano vio **~40%** al mover eqviz (además de ~30% quieto en Debug 120 Hz). Bajar el costo de **drag / hover / live resize** sin tocar el look de las barras.

## Precondiciones

- 14 `[x]`. Idealmente 15 (Release vs Debug) para no optimizar Debug-only.

## STOP

- No asumas que es el Canvas: puede ser `isMovableByWindowBackground`, hover chrome (opacity animation 0.18 s), `onHover` a 60 Hz, o compositor de macOS.
- No desactives arrastrar por el fondo sin preguntar (es el substitute de titlebar en macOS 14).
- No pongas `window.level` / always-on-top.

## Hipótesis a probar (en orden, una por vez)

1. Hover: sacar `.animation` del chrome (opacity instantánea) y medir drag.
2. No invalidar Canvas en `windowDidMove` si el size no cambió (evitar relayout).
3. Pause TimelineView mientras `mouseDragged` en la ventana, resume al soltar — **solo si** 15 confirma que el tick de display es el costo al mover.
4. Resize: `VisualizerLayout` cacheado por `CGSize` (ya es barato; no lo toques si Instruments no lo señala).

Cada hipótesis: un cambio, `./setup.sh test-mac`, el humano re-mide drag 10 s.

## Definition of Done

- [ ] Al menos una hipótesis medida.
- [ ] Drag ya no es un pico absurdo **o** lessons dice “es WindowServer, no hay arreglo SwiftUI barato”.
- [ ] `STATUS.md` 16 `[x]`.

## Fuera de alcance

Metal (17). Cambiar política de close / semáforos.
