# Prompt de ejecución — 08→13 sin parar (salvo STOP humano)

Pegá esto a un agente. Usando **dev-protocol**, seguí el roadmap **en orden** desde el primer `- [ ]` de `roadmap/STATUS.md` (hoy: **08**). No saltees pasos. No adelantes código del N+1 mientras N no esté `[x]`.

**Política de esta sesión (el humano la pidió):** no te detengas a esperar “OK” de rutina. Implementá → verificá vía `./setup.sh` → actualizá `STATUS.md` + `.agents/lessons-learned.md` → **commit + push + merge a `main`** → siguiente paso. Pará **solo** si aplica un STOP de abajo.

---

Antes de tocar código leé:

- `roadmap/00-invariants.md`
- `roadmap/STATUS.md`
- `.agents/lessons-learned.md`
- `roadmap/01-decision-gate.md` (locked + STOP residual)
- el prompt numerado del paso (`08` … `13`)
- este archivo

## Estado al arrancar (2026-08-20)

- `main` tiene **01–07 `[x]`**. Working tree debería estar limpio. Rama nueva por paso (`feat/visualizer-canvas`, etc.).
- App: Swift+SwiftUI, Bundle ID `dev.local.eqviz`, Swift 5, macOS 14, sandbox OFF, firma ad-hoc. **No** `DEVELOPMENT_TEAM`. **No** `brew install`.
- Captura v1: input default (`AVAudioEngine.inputNode`). Cero ScreenCaptureKit / BlackHole. Cero `window.level`.
- DSP: FFT 2048 Hann vDSP, hop 2048 consume, 32 bandas log, `spectrum` + `peaks` con `NSLock`. `tickPeaks` ya corre en `TimelineView` 120 Hz en `ContentView`.
- Tests: `eqvizTests` es **logic test** (no lanza la app, no pega al mic).
- `./setup.sh` ya tiene build / `test-mac` / run / stop. Toda verificación humana o de agente va por el menú o su CLI. **Prohibido** pegar `xcodebuild` crudo al humano. Si agregás un test o chore, cablealo al menú en el mismo cambio.

## Cómo verificar (siempre)

```bash
./setup.sh test-mac    # xcodegen + xcodebuild test (macos/build)
./setup.sh build       # si el paso tiene app compilable
./setup.sh run         # solo cuando el DoD pide ver la ventana; no pkill
```

Stop de la app: `./setup.sh` opción 13 (pide y/N). **Nunca** `pkill`/`killall` sin confirmación explícita en esa sesión.

## Git (autorizado a entregar sin preguntar)

Por cada paso **cerrado** (DoD + verificación, sin haber asumido un STOP):

1. Rama `feat/<short>` si no estás en una.
2. Commit (mensaje `feat(macos): …` / `docs: …`, trailer `Co-Authored-By: Cursor <cursoragent@cursor.com>`).
3. `git push -u origin HEAD`
4. `git checkout main && git merge --no-ff <rama> && git push origin main`

No force-push. Si hay conflicto, hook rojo, o `main` divergió: **STOP** y preguntá.

## STOP — acá sí pará y esperá al humano

No inventes. No uses `SECURITY OVERRIDE` que no escribió el humano.

1. **08 live / CPU:** después de Canvas compilando y `./setup.sh test-mac` verde, `./setup.sh run` y **preguntá**. DoD 08 exige barras reaccionando, decay al callar, resize OK, y CPU `< ~2%` (Activity Monitor, 10 s). Vos no podés fingir esa mirada. Con el OK, marcá 08 `[x]`, mergeá, seguí 09.
2. **10 — STOP residual 01-D (no implementes hasta respuesta):**
   - ventana normal vs flotante / always-on-top
   - close: termina el proceso vs solo oculta
   - semáforos nativos vs botones custom en hover  
   Mientras tanto podés hacer hover chrome + selector de 5 estilos + **minimize** (`miniaturize`). **No** `window.level`. **No** asumas terminate vs hide.
3. **12 entero:** checklist en hardware Darwin arm64 real (TCC, señal, 5 estilos, hover, CPU, resize, permiso denegado). Si no hay GUI/humano: reportá y no tildes 12.
4. **13:** no lo corras hasta 12 `[x]` (docs de la app que *corre*).
5. Cualquier duda de producto / permisos / firma / borrar archivos / host tool faltante / captura que no sea default input.
6. Labels del selector (en vs es vs iconos): usá los strings **locked en 09** (`"Retro Red"`, etc.). No preguntes eso. Unlit: default técnico **VFD dim** salvo donde 09 manda negro (`whiteMatrix` unlit `(0,0,0)`).

## 08 — Canvas (siguiente)

Archivos locked: `macos/eqviz/UI/VisualizerView.swift`, `ContentView.swift`.

- **Un** `TimelineView` (ya existe). **No** anides otro. **No** llames `tickPeaks` dos veces por frame (la gravedad se duplicaría).
- Reloj: `tickPeaks(at:)` una vez; el `Canvas` hace `let peaks = engine.peaks.copy()` (array local). No `@Observable` del array. No `HStack/VStack/Rectangle` por segmento. No SpriteKit/Metal.
- 32×16 bloques **cuadrados**, gaps ~2 pt, letterbox negro si hace falta. Lit placeholder `rgb(1, 0.15, 0.1)`, unlit dim `rgb(0.12, 0.02, 0.02)`. Corner 0.
- Paletas = 09. Hover = 10.

## 09 — cinco paletas, un renderer

Nombres locked: `retroRed`, `whiteMatrix`, `rainbowSpectrum`, `fireGradient`, `cyberNeon`. Un `VisualizerView`, no cinco. Default `.retroRed`. Switch no llama `engine.stop()`. Tests en `eqvizTests/PaletteTests.swift` (logic tests, mismo target). Colores: copiá los números de `roadmap/09-visualizer-styles.md`, no improvises hues. Sin Picker permanente feo; `var style` listo para 10.

## 10 — hover chrome

Tras respuesta del STOP 01-D: `HoverChrome`, picker 5 estilos, close/min según lo locked. Hover-only, fade ~0.18 s, sin UserDefaults, sin vibrancy, sin atajos. Persistencia de estilo: no.

## 11 — setup.sh

El menú **ya** build/test/run/stop contra `macos/build`. No lo reescribas. DoD: verificar que funciona, sacar copy obsoleta (“falta proyecto hasta 02”), confirmar `macos/build/` en `.gitignore` (ya está). Stop sigue pidiendo y/N. No `pkill -9`.

## 12 / 13

12 = humano en el Mac. 13 = README/`CONTEXT`/`CHANGELOG`/lessons alineados a cómo **se corre** (`./setup.sh` es la entrada). No elijas licencia. No documentes SCK.

## Qué no hacer nunca

- Placeholders `TODO` / funciones vacías “para el siguiente paso”.
- Publicar `[Float]` de 32 bandas a SwiftUI.
- `withAnimation` en las barras; `Timer` 1/120.
- Cambiar Bundle ID. Entitlement `audio-input` salvo que TCC/xcodebuild lo exija.
- Borrar tooling Python (`pyproject.toml`, `main.py`, `./setup.sh` como menú).

Cuando termines un paso: lecciones nuevas, handoff corto (qué verificaste, comando `./setup.sh …`). Si no hay STOP, seguí. Si hay STOP, una pregunta concreta y esperá.
