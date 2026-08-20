# 17 — Renderer más liviano (Metal / drawingGroup)

## Meta

Si 15–16 dejan el Canvas SwiftUI caro en **Release**, evaluar un renderer que no sea 32×16 fills de `Path` por frame. El humano ya entiende el trade: más liviano, más complejidad.

## Precondiciones

- 15 `[x]` con stack. No adivinar que “Metal arregla”.

## STOP

- **No implementes** Metal, `drawingGroup()`, SpriteKit ni Core Animation layers hasta que el humano diga explícitamente **cuál** de las opciones de abajo.
- No ScreenCaptureKit. No `window.level`.
- Si el stack de 15 es WindowServer / GPU compositor y no nuestro fill: **pará** y reportá; Metal puede no bajar el % de Activity Monitor.

## Opciones (elegí una, no combines)

| Id | Qué | Look | Riesgo |
| :--- | :--- | :--- | :--- |
| A | `Canvas` + `drawingGroup()` | Casi igual | Raster extra; puede empeorar |
| B | Un `CALayer` / `NSView` drawRect 32×16 | Igual si copiamos geometría | Sale de SwiftUI Canvas |
| C | Metal (un quad + shader de barras) | Puede verse distinto (filtros, gamma) | Más código, PoC más pesado de mantener |
| D | No hacer nada | El de ahora | CPU queda como 15 midió |

## Definition of Done

- [ ] Humano eligió A/B/C/D por escrito.
- [ ] Si A–C: implementación + `./setup.sh test-mac` + nueva muestra de CPU.
- [ ] `STATUS.md` 17 `[x]`.

## Fuera de alcance

Captura v2, Bundle ID prolijo, persistencia de estilo.
