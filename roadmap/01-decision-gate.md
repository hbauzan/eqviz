# 01 — Decision gate (STOP humano)

## Meta

Obtener por escrito las decisiones de producto que el resto del roadmap no puede inferir. **Este paso no escribe código de la app.**

## Precondiciones

- `00-invariants.md` leído.

## A y B — LOCKED (2026-08-20)

Verbatim del usuario:

- Stack: **Swift + SwiftUI** para la app. **Sin lugar a dudas.**
- Tooling: **`setup.sh` automatiza** lo demás necesario para trabajar mientras se desarrolla (Python/`uv` queda como tooling de repo: sync, lint, tests de repo, hooks — **no** como visualizer).
- Captura v1: **entrada por defecto de macOS** (el dispositivo de input que la Mac tiene seleccionado en ese momento). Seguir cambios de device (route change).
- Si esa entrada **no cumple expectativas**, recién ahí se evalúa audio de sistema (ScreenCaptureKit). **No implementar SCK ni BlackHole en v1.**

## C — LOCKED (PoC, 2026-08-20)

Verbatim / intención:

- Velocidad: PoC rapidísimo para evaluar después el esfuerzo de hacerlo prolijo. Identidad de producto **no** es un org real ahora.
- Bundle ID PoC: **`dev.local.eqviz`**. Descartable. Cambiarlo después resetea el permiso de mic (macOS lo ve como otra app). Eso es parte del costo “prolijo”.
- Firma: **Personal Team, gratis**. El agente **no escribe** `DEVELOPMENT_TEAM` en el repo. El humano elige Personal Team una vez en Xcode (Signing & Capabilities).
- App Sandbox: **OFF** en el PoC. Prenderlo es trabajo del paso “prolijo”, no de v1.

## Host tools — LOCKED (2026-08-20)

Verbatim: el usuario instala las cosas **fuera** del repo (Homebrew, XcodeGen, etc.) **él**. El agente **nunca** corre `brew install`, `xcode-select`, ni instaladores de sistema. Si falta una herramienta: STOP y listá el comando para que lo corra el humano.

`xcodegen`: el usuario ya lo instaló.

## D / E — LOCKED (2026-08-20)

- Tamaño de ventana: **800×240**.
- TCC mic, verbatim (no ampliar): `eqviz does not record or send audio.`
- Ventana: **normal** (no flotante, no always-on-top, no `window.level`).
- Close: **termina el proceso** (`applicationShouldTerminateAfterLastWindowClosed`).
- Semáforos: **nativos** (close / miniaturize / zoom). Hover chrome = selector de estilos, no `×`/`−` custom.

## STOP residual

1. ~~Ventana normal vs widget flotante~~ — **normal**, 2026-08-20.
2. ~~Close: termina vs oculta~~ — **termina**, 2026-08-20.
3. ~~Semáforos nativos vs custom~~ — **nativos**, 2026-08-20.
4. Segmentos apagados: **no se dibujan** (canvas negro OLED). Locked 2026-08-20.
5. Labels del selector: **en** locked en 09 (`"Retro Red"`, etc.).

## Qué no hacer (sigue vigente)

- No crees `macos/` en este paso (eso es 02).
- No instales host tools (`brew`, XcodeGen, Xcode). Eso lo hace el humano.
- No borres `pyproject.toml` / `main.py` / pre-commit: son tooling.
- No instales BlackHole, Loopback, ni ScreenCaptureKit “por si acaso”.

## Definition of Done

- [x] A (stack) respondido por el usuario, por escrito.
- [x] B (fuente de audio) respondido por el usuario, por escrito.
- [x] Respuestas copiadas a este archivo (sección Decisiones locked) y `lessons-learned.md`.
- [x] `STATUS.md` ítem 01 en `[x]`.
- [x] Ningún source Swift de producto creado en este paso.

## Decisiones locked

| Clave | Valor | Fecha |
| :--- | :--- | :--- |
| App | Swift + SwiftUI nativo (`macos/eqviz/`) | 2026-08-20 |
| Tooling | `./setup.sh` + Python/`uv` (no visualizer) | 2026-08-20 |
| Captura v1 | Default input de macOS via `AVAudioEngine.inputNode` | 2026-08-20 |
| Device | El que la Mac tenga seleccionado como entrada; re-tap en route change | 2026-08-20 |
| Captura v2 (no ahora) | Audio de sistema solo si v1 no cumple expectativas | 2026-08-20 |
| Bundle ID | `dev.local.eqviz` (PoC; no es identidad de distribución) | 2026-08-20 |
| Firma | Personal Team gratis; `DEVELOPMENT_TEAM` no va al repo | 2026-08-20 |
| App Sandbox | OFF (PoC). On = trabajo “prolijo” posterior | 2026-08-20 |
| Host tools | Las instala el humano (brew/Xcode/xcodegen). El agente no. | 2026-08-20 |
| Ventana size | 800×240 | 2026-08-20 |
| Ventana tipo | Normal; no floating / always-on-top; no `window.level` | 2026-08-20 |
| Close | Termina el proceso (última ventana) | 2026-08-20 |
| Semáforos | Nativos (close / min / zoom) | 2026-08-20 |
| TCC mic | `eqviz does not record or send audio.` (verbatim) | 2026-08-20 |
| Python bootstrap | Conservar; no es el producto | 2026-08-20 |
