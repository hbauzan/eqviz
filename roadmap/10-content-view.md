# 10 — ContentView: hover chrome + selector de estilos

## Meta

UI minimalista: por defecto solo las barras. Al hover, aparecen con opacidad suave el selector de 5 estilos y close/minimize. Sin reiniciar la app ni el audio al cambiar estilo.

## Precondiciones

- 09 `[x]`.
- 01-D: política de close y always-on-top. Si close no está locked: **STOP** y preguntá (terminate vs hide). No asumas Cmd+Q vs hide.

## STOP

- No agregues settings window, preferencias en UserDefaults, ni persistencia de estilo salvo que el usuario lo pida (no está en el spec v1). Default cada launch: Retro Red.
- No uses `NSHostingView` extra.
- No muestres el chrome al 100% opacidad todo el tiempo “porque si no no se descubre”. Hover only. Podés dejar 1s de fade-out al salir.

## Archivos

```text
macos/eqviz/UI/HoverChrome.swift
macos/eqviz/ContentView.swift
macos/eqviz/eqvizApp.swift          # solo si hace falta terminate
```

## Comportamiento

- `onHover { hovering in }` sobre el root.
- Chrome: `opacity(hovering ? 1 : 0)` + `animation(.easeInOut(duration: 0.18))`.
- `allowsHitTesting(hovering)` para no robar clicks cuando está invisible.
- Fondo del chrome: negro a 0.55 alpha, padding chico, **no** material vibrancy (rompe el look OLED).

Selector: 5 opciones, `Picker` o 5 botones de texto 11pt. Debe poder cambiarse en caliente; assert mental: `engine.isRunning` no cambia.

Close / minimize:

- Minimize: `NSApp.mainWindow?.miniaturize(nil)` (o el `NSWindow` de esta ventana).
- Close: según 01-D. `NSApp.terminate(nil)` vs `window.close()`. Si 01-D no respondió: **STOP**.
- Iconos simples (× y −), no SF Pro gigante, blanco 70% opacity.

No reimplementes un titlebar completo. No traffic lights custom animados tipo Arcade.

## Teclado

No es spec. No agregues atajos salvo `esc` para hide chrome — ni eso, skip.

## Verificación

- Sin hover: solo barras, cero controles.
- Hover: selector + close + min, sutil.
- Click estilo 1→5: paleta cambia, audio sigue, picos no se resetean a 0 (el decay no se reinstancia).
- Minimize funciona. Close hace exactamente lo locked en 01-D.
- CPU sigue en zona 08.

## Definition of Done

- [ ] Chrome hover-only.
- [ ] 5 estilos en caliente.
- [ ] Close/min según 01-D.
- [ ] `STATUS.md` 10 `[x]`.

## Fuera de alcance

Menú de dispositivos de audio. v1 sigue al input default de macOS; no hay picker. Audio de sistema = v2, prompt nuevo.
