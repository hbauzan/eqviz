# 12 — Verificación de ejecución en Apple Silicon

## Meta

Correr la app en un Mac ARM (M4 u otro Apple Silicon) y cerrar el loop del master prompt: visualizer live, 5 estilos, hover, CPU, permisos. Sin esto, el roadmap no está “listo para ejecutar sin inconvenientes”.

## Precondiciones

- 10 `[x]`, 11 `[x]` preferible.
- App Swift, captura = input default.

## STOP

- Si estás en CI sin GUI / sin TTY / no es Darwin arm64: no marques done. Reportá y preguntá.
- No bajes el target de CPU moviendo el goalpost a “5–8% está bien”.

## Checklist (todas)

Ejecutá vía `./setup.sh` → build → run.

1. **Build** Debug arm64 exit 0.
2. **Tests** DSP + paleta + decay exit 0.
3. **TCC**: diálogo de **micrófono**. Aceptar. Si ya estaba autorizado, anotalo.
4. **Señal**: hablá al mic o mandá audio a la **entrada** que macOS tenga seleccionada (Ajustes → Sonido → Entrada). Las barras se mueven. Cambiar de device en caliente debe seguir funcionando.
5. **Silencio**: los picos caen con gravedad, no se apagan en un frame.
6. **5 estilos** en hover, en caliente, sin corte de audio.
7. **Hover**: chrome visible solo con mouse encima.
8. **Close/min**: según 01-D.
9. **CPU**: Activity Monitor, 10 s con ventana visible y audio: **≤ 2%** típico en M4. Si 2–5%, abrí Instruments Time Profiler, identificá, arreglá, re-medí. Si > 5% después de un intento de arreglo: no done, reportá el stack.
10. **Resize**: grid de cuadrados se mantiene, no crash.
11. **Permiso denegado** (resetear en Ajustes del Sistema → Privacidad, o usar un user nuevo): la app no crashea.

## Guía Xcode (para el humano, también en 13)

1. Xcode 15+ en el Mac.
2. `./setup.sh` → abrir Xcode, o `open macos/eqviz.xcodeproj`.
3. Signing: Team del usuario (el agente no lo inventó).
4. Scheme `eqviz`, destination My Mac (arm64).
5. ⌘R. Aceptar TCC.

## Artefacto

Dejá una nota corta en `CHANGELOG.md` [Unreleased] o en el handoff: “verificado en &lt;chip&gt;, macOS &lt;versión&gt;, CPU ~X%”. Si no corriste en hardware real, **no** tildes este paso.

## Definition of Done

- [ ] Checklist 1–11 OK en Darwin arm64 real.
- [ ] Nota de verificación escrita.
- [ ] `STATUS.md` 12 `[x]`.
