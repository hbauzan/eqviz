# 00 — Contrato del agente (leer SIEMPRE primero)

Este archivo es ley para cualquier agente que ejecute prompts de `roadmap/`. Si choca con un hábito del modelo, gana este contrato.

## Cómo ejecutar el roadmap

1. Leé `roadmap/00-invariants.md`, `roadmap/STATUS.md`, `.agents/lessons-learned.md`, `CONTEXT.md`.
2. Ejecutá **un solo** prompt numerado por sesión (el primero `- [ ]` de `STATUS.md`).
3. No adelantes el siguiente prompt. No “dejes listo” código del paso N+1.
4. Al terminar, actualizá `STATUS.md` (`- [x]`), registrá invariantes nuevas en `.agents/lessons-learned.md`, y listá verificación hecha.
5. Si un paso pide confirmación humana, **pará**. No inventes la respuesta.

Idioma: prompts y menús en español. Código, identificadores y comentarios de código en inglés.

## SECURITY OVERRIDE

Regla de oro del repo:

> Ante la duda, **preguntá y esperá**. No asumas. No implementes la opción “obvia”.

La única excepción es una frase **literal** del usuario:

```text
SECURITY OVERRIDE
```

seguida de la decisión concreta (qué se autoriza). Sin esa frase, una preferencia vaga (“hace lo que te parezca”, “usa el default”, “vos sabrás”) **no** desbloquea un STOP.

`SECURITY OVERRIDE` no autoriza:

- commitear secretos, `.env`, keys, certificados
- push/merge sin el approval gate de `dev-protocol`
- capturar audio del sistema (ScreenCaptureKit / BlackHole) en v1
- borrar el tooling Python (`pyproject.toml`, `.venv`, tests de repo, menú de `setup.sh`)

## Camino locked (no reabrir)

- **App:** Swift + SwiftUI. Layout: `macos/eqviz/` + XcodeGen `project.yml`.
- **PoC:** Bundle ID `dev.local.eqviz`. Firma Personal Team (no Team ID en git). Sandbox **OFF**.
- **Host tools:** las instala el humano (Homebrew, Xcode, XcodeGen). El agente no corre `brew install` ni instaladores de sistema. Si falta algo: STOP + comando para el humano.
- **Tooling de desarrollo:** `./setup.sh` (y `uv` para lint/tests/hooks del repo). Tests, build, run y cualquier chore repetible van por un ítem del menú (o su subcomando). No pegar `xcodebuild`/`pytest` crudos al humano; si aparece un test o tarea nueva, cableala al menú en el mismo cambio.
- **Captura v1:** entrada por defecto de macOS (`AVAudioEngine.inputNode`). Seguir el device que la Mac tenga seleccionado; reinstalar tap en route change.
- **Captura v2:** audio de sistema solo si el usuario dice que v1 no cumple expectativas. Hasta entonces, prohibido.
- **Ventana PoC:** 800×240, **normal** (no floating, no always-on-top, no `window.level`). Close **termina** el proceso. Semáforos **nativos**.
- **TCC mic (verbatim):** `eqviz does not record or send audio.`
- **Prolijo (después, no ahora):** Bundle ID de org real, Team pago si hay distribución, Sandbox on. No lo hagas en este PoC.

Detalle y fecha: `roadmap/01-decision-gate.md` § Decisiones locked.

## Qué es duda (STOP obligatorio)

Pará y preguntá si falta cualquiera de:

- cambiar el lock de ventana (normal / no always-on-top / close=terminate / semáforos nativos) — ya está en `01-decision-gate.md`
- borrar o reemplazar archivos que ya existen y no son el target del prompt
- host tools faltantes (no instalarlas vos: pedile al humano el comando)
- cualquier API de captura que no sea default input
- escribir `DEVELOPMENT_TEAM` o un Bundle ID distinto de `dev.local.eqviz`

## Defaults técnicos (no son product decisions)

Estos sí se usan sin preguntar, porque bajan la tasa de error. El usuario puede cambiarlos después con un prompt explícito.

| Tema | Default | Por qué |
| :--- | :--- | :--- |
| Reloj de dibujo | `TimelineView` con `minimumInterval: DisplayClock.frameDuration` (60 Hz) | Humano 2026-08-20: 120 Hz era caro; gravity sigue con `dt` |
| Unlit | No se pinta; el canvas negro es el apagado | Humano: no dibujar unlit |
| Dibujo de barras | `Canvas` (un view) | N barras × M segmentos como `View`s explota la CPU |
| FFT | Accelerate `vDSP`, size 2048, ventana Hann | Spec + tamaño clásico; setup creado una vez y reutilizado |
| Bandas | 32, espaciado log 20 Hz–20 kHz | Graves→agudos perceptivo; vintage EQ |
| Normalización | 0.0…1.0 con EMA del pico de espectro | Evita que todo salte a 1.0 en cada frame |
| Decay | ataque instantáneo, caída por frame de display (no del tap de audio) | Gravedad de picos vintage |
| Segmentos por barra | 16 bloques cuadrados | Look VFD/LED |
| Concurrencia | picos/bandas **no** son `@Published`/`@Observable` de alta frecuencia; snapshot con lock leído desde `Canvas` | Goal < 1–2% CPU; ~30% Debug / ~40% al mover (120 Hz, 2026-08-20). Seguí 15–17. |
| Lenguaje Swift | modo Swift 5 en el target de la app | Swift 6 strict concurrency hace fallar a agentes |
| macOS mínimo | 14.0 (Sonoma) | Spec Sonoma/Sequoia |
| Layout Swift | `macos/eqviz/` + XcodeGen `project.yml` | `.xcodeproj` a mano es frágil |

## Prohibido

- Placeholders (`TODO`, `// your code here`, funciones vacías que el siguiente paso “va a llenar” salvo que el prompt actual lo delimitó).
- Capturar audio del sistema “por las dudas”, ScreenCaptureKit en v1, o instalar drivers tipo BlackHole.
- Inventar Team ID / Bundle ID.
- Matar procesos (`pkill`, `killall`) sin confirmación explícita en esa sesión.
- Mezclar el loop de audio con el de SwiftUI: el tap de `AVAudioEngine` no debe tocar la UI; copia samples y procesa en una cola serial.
- Usar `pip install` o activar venv a mano. Tooling Python del repo: solo `uv`.
- Implementar el visualizer o el DSP de producto en Python.
- Agregar LLM, red, analytics, Sparkle, o dependencias no pedidas.

## Verificación mínima de cada paso

Todo prompt tiene “Definition of Done”. No marques `STATUS.md` si:

- el proyecto no compila (cuando el paso ya tiene target compilable)
- dejaste un `TODO`
- asumiste una respuesta de un STOP
- no corriste la verificación **vía `./setup.sh`** (ítem de menú o subcomando; no un `xcodebuild` suelto en el handoff)

## Relación con el bootstrap actual

El **producto** es la app Swift/SwiftUI. Python/`uv` es **tooling** (glossary, `dev-protocol`, ruff, pytest de repo, hooks). `./setup.sh` es el menú admin de ese tooling y, desde el paso 11, de `xcodebuild`.

- Sources Swift de producto: a partir de `02-xcode-bootstrap.md`, no antes, y no sin Bundle ID (o “lo seteo en Xcode”).
- No borres `pyproject.toml` / `main.py` / `.pre-commit-config.yaml`.
