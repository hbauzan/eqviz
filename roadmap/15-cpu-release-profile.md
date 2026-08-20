# 15 — Perfil CPU: Release + Instruments

## Meta

Saber **dónde** está el ~30% (Debug) y el pico al mover la ventana. Medir **Release** y, si sigue alto, Time Profiler. No implementar Metal acá.

## Precondiciones

- 14 `[x]`.

## STOP

- No bajes más el Hz ni cambies el look “para que el número cierre”.
- No marques done sin una muestra humana de Activity Monitor (10 s, ventana visible, con audio).
- Si Instruments pide firmar con Team: el humano lo hace en Xcode. El agente no escribe `DEVELOPMENT_TEAM`.

## Qué hacer

1. Cableá `./setup.sh` si hace falta un `build-release` (DerivedData `macos/build`, mismo scheme). No pegues `xcodebuild` crudo al humano.
2. `./setup.sh run` en **Debug** post-14: anotá % idle y % al **arrastrar** la ventana.
3. Build **Release** arm64, correr, misma medición.
4. Si Release > ~5% con ventana quieta: Instruments → Time Profiler (10 s). Anotá el stack top (Canvas vs FFT vs SwiftUI vs WindowServer).
5. Con el stack, o bien un arreglo **barato que no cambie el look**, o reportá y dejá 16/17.

## Definition of Done

- [ ] Números Debug vs Release (idle + drag) escritos en lessons + CHANGELOG.
- [ ] Si Release sigue caro: stack de Instruments o “no pude firmar / no hay GUI”.
- [ ] `STATUS.md` 15 `[x]`.

## Fuera de alcance

Metal, ScreenCaptureKit, bajar a 30 Hz.
