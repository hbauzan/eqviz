# 04 — Ventana negra, chrome mínimo

## Meta

Ventana estilo “pantalla de música”: negra, titlebar pesada fuera, arrastrable. Todavía sin visualizer ni hover chrome completo (el hover de controles es 10).

## Precondiciones

- 02 y 03 `[x]`.
- 01-D ventana: si close/min/always-on-top no están locked, usá **solo** lo no ambiguo (fondo negro + hidden titlebar + drag). Dejá always-on-top y política de close para 10 **si** 01-D no respondió esas sub-preguntas. Si 01-D dijo always-on-top, aplicarlo acá.

## STOP

- No pongas `NSWindow.level = .floating` / `.statusBar` sin 01-D.
- No implementes el selector de estilos acá.
- No uses transparencia real (material/blur) si el spec dice fondo **completamente negro**. Negro opaco.

## Implementación

Archivos:

- `macos/eqviz/eqvizApp.swift` — scene de ventana
- `macos/eqviz/ContentView.swift` — root view, por ahora `Color.black` full size
- Opcional chico: `macos/eqviz/WindowConfigurator.swift` si necesitás `NSWindow` (titlebar transparent, `backgroundColor = .black`, `isOpaque = true`, `titlebarAppearsTransparent = true`)

SwiftUI:

```text
Window("eqviz", id: "main") { ContentView() }
  .windowStyle(.hiddenTitleBar)
  .windowBackgroundDragBehavior(.enabled)
```

Tamaño locked: **800×240**. `windowResizability` con mínimo razonable (`400×120`) está bien; default size 800×240.

No agregues padding gris, no `NavigationSplitView`, no `Settings` scene.

## Verificación

Build + run. Checklist visual:

- Fondo negro de borde a borde
- Sin titlebar clásica pesada
- Se puede arrastrar la ventana desde el fondo
- Semáforos: si quedaron visibles por el sistema, no los pelees todavía (10 define hover/custom)

## Definition of Done

- [ ] `ContentView.swift` existe y es el root.
- [ ] Ventana negra, hidden titlebar, drag.
- [ ] Always-on-top solo si 01-D lo locked.
- [ ] Build 0. `STATUS.md` 04 `[x]`.

## Fuera de alcance

Hover, botones close/min, `AudioEngine`, Canvas.
