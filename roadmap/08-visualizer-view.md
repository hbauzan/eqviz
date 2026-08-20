# 08 — VisualizerView: bloques cuadrados a 120Hz

## Meta

Un `Canvas` que dibuja **32 columnas × 16 filas** de bloques cuadrados apilados (segmented bars VFD/LED), sincronizado al display con `TimelineView`. Un solo color placeholder (rojo) — las 5 paletas son 09.

## Precondiciones

- 07 `[x]`, hay `peaks` 0…1 por banda.

## STOP

- **Prohibido** `HStack { VStack { Rectangle() } }` por segmento. Eso no cumple el budget de CPU.
- No uses `SpriteKit`, `Metal` raw, ni `NSOpenGL` en v1.
- No leas `@Observable bands` para redibujar el árbol. El reloj es `TimelineView`; el Canvas hace `peaks.copy()`.

## Archivos

```text
macos/eqviz/UI/VisualizerView.swift
macos/eqviz/ContentView.swift          # hostea VisualizerView full size
```

## Reloj

```text
TimelineView(.animation(minimumInterval: 1.0 / 120.0, paused: false)) { timeline in
  Canvas { context, size in
    let dt = /* from last timeline.date; first frame dt = 1/120 */
    let peaks = decay.tick(bands: engine.spectrum.copy(), dt: dt)
    draw(peaks, in: context, size: size)
  }
}
```

Pitfall: `Canvas` closure no es `@MainActor` de la forma que creés; copiá peaks a un `[Float]` local antes de dibujar. No captures `engine` mutando.

Si `minimumInterval` no está disponible en el SDK del Mac de build, usá `.animation` a secas (sigue vsync) y anotalo en lessons-learned. No bajes a `TimelineView(.periodic(from:by: 1/60))` salvo que compilemos a un OS sin esa API.

## Geometría

- `bandCount = 32`, `segmentCount = 16`
- Gaps: `gapX` y `gapY` ~ 2 pt a tamaño default. Bloques **cuadrados** (el spec). Si el aspect de la ventana no da cuadrados perfectos: priorizá cuadrados y centrá el grid (letterbox negro), no estires a rectángulos altos.
- Segmento `s` (0 = base / graves visuales de la barra, abajo) se prende si `s < Int(peak * 16)` con `floor`. Peak 0 → 0 bloques. Peak 1 → 16.
- Color placeholder: sRGB rojo clásico lit `rgb(1, 0.15, 0.1)`, unlit según 01-F o default técnico **dim** `rgb(0.12, 0.02, 0.02)` para que se lea como VFD apagado.

`context.fill(Path(roundedRect: corner 0 o 1pt), with: .color(...))`. Corner 0 = más LED vintage.

## CPU

- Un `VisualizerView` en todo el árbol.
- No `print` en el Canvas.
- No crees `Path` concatenando miles de ops si podés fill rects en loop 32×16 (512 fills es aceptable; 5000 no).

## Verificación

Build + run + señal de audio:

- Barras reaccionan; picos caen suave al callar.
- Activity Monitor: proceso `eqviz` **< ~2% CPU** en M4 con la ventana visible (una muestra de 10s). Si > 5%, no marques done: buscá Views por segmento o publicación Observable del array.
- Redimensionar ventana: el grid se reacomoda, no crash, no barras fuera.

## Definition of Done

- [ ] Solo Canvas + TimelineView.
- [ ] 32×16 bloques, cuadrados, apilados desde abajo.
- [ ] Decay visible. CPU en zona del spec.
- [ ] Un color. `STATUS.md` 08 `[x]`.

## Fuera de alcance

Cambio de estilo, hover, close button.
