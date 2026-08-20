# 09 — Cinco estilos visuales (paletas, un renderer)

## Meta

El mismo `Canvas` del 08, alimentado por un `VisualizerStyle` y una paleta. Cambiar estilo **no** reinicia el audio ni recrea el engine.

## Precondiciones

- 08 `[x]`.

## STOP

- No dupliques cinco `VisualizerView`. Un renderer, cinco mapas de color.
- No cargues imágenes/texturas. Color plano por bloque (spec: bloques cuadrados).
- No agregues más de 5 estilos.

## Archivos

```text
macos/eqviz/UI/VisualizerStyle.swift      # enum CaseIterable, Identifiable
macos/eqviz/UI/VisualizerPalette.swift    # color(style:band:segment:lit:) -> Color / RGB
macos/eqviz/UI/VisualizerView.swift       # usa paleta
macos/eqvizTests/PaletteTests.swift       # no crash, lit ≠ unlit, fire sube verde→rojo
```

## Enum (nombres locked)

```text
enum VisualizerStyle: String, CaseIterable, Identifiable {
  case retroRed
  case whiteMatrix
  case rainbowSpectrum
  case fireGradient
  case cyberNeon
}
```

Labels UI (paso 10 las muestra): `"Retro Red"`, `"White Matrix"`, `"Rainbow Spectrum"`, `"Fire Gradient"`, `"Cyber Neon"`.

## Paletas (spec extendido, no improvisar hues)

Colores en sRGB 0…1. `segment` 0 = base, 15 = tope. `band` 0 = grave, 31 = agudo. `lit` false = unlit.

### 1. Retro Red

- Lit: `(1.0, 0.12, 0.08)`
- Unlit: `(0.12, 0.02, 0.02)` (VFD dim; si 01-F pidió OLED off, unlit `(0,0,0)`)

### 2. White Matrix

- Lit: `(1, 1, 1)`
- Unlit: `(0, 0, 0)` — spec OLED/MiniLED, fondo negro absoluto. No gris.

### 3. Rainbow Spectrum

- Lit: HSV hue = `CGFloat(band) / 32`, saturation 1, brightness 1 (grave≈rojo, agudo≈violeta). Misma columna, mismo color en todos los segmentos lit.
- Unlit: mismo hue, brightness 0.12, o negro si 01-F OLED global. Default: brightness 0.12.

### 4. Fire Gradient

Por **segmento**, no por banda (spec: verde base → amarillo medio → rojo tope):

- `t = CGFloat(segment) / 15`
- `t < 0.5`: lerp verde `(0.05, 0.85, 0.12)` → amarillo `(1, 0.92, 0.05)`
- `t >= 0.5`: lerp ese amarillo → rojo `(1, 0.08, 0.02)`
- Unlit: mismo hue a brightness ~0.12 (o negro si 01-F)

### 5. Cyber Neon

Por segmento, lerp cian → azul eléctrico → magenta:

- `t = CGFloat(segment) / 15`
- `t < 0.5`: `(0.0, 1.0, 1.0)` → `(0.15, 0.35, 1.0)`
- `t >= 0.5`: azul → `(1.0, 0.0, 0.85)`
- Unlit: dim del color target

## Estado del estilo

- Vive en `ContentView` `@State` (o un `SessionState` chico). Default `.retroRed`.
- `VisualizerView(style:peaks:...)` — el Canvas lee `style` actual cada tick. Cambiar `@State` no llama `engine.stop()`.

El **selector visible** es 10. Acá: el enum funciona y `ContentView` puede tener un `Picker` temporal `#if DEBUG` o un default fijo Retro Red. Preferí default fijo Retro Red y un hook `var style` ya listo para 10, sin menú feo permanente.

## Tests

- `fireGradient` segmento 0 lit más verde que rojo (`g > r`).
- segmento 15 lit más rojo que verde (`r > g`).
- `whiteMatrix` lit = blanco; unlit = negro.
- `allCases.count == 5`.

## Definition of Done

- [ ] Un renderer, 5 paletas, números de color de este prompt.
- [ ] Switch de estilo en memoria no toca `AudioEngine.start/stop`.
- [ ] Tests de paleta. `STATUS.md` 09 `[x]`.

## Fuera de alcance

Menú hover, atajos de teclado (no pedidos).
