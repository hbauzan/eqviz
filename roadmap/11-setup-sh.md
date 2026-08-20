# 11 — Cablear `setup.sh` a la app real

## Meta

El menú `./setup.sh` (ya existe) deja de mostrar “proyecto Xcode ausente” y ejecuta build/run/stop **reales** contra el scheme `eqviz` arm64. Sigue pidiendo confirmación para stop. No se asume que el proceso se llama igual si el producto cambió de nombre — verificá.

## Precondiciones

- 02 `[x]` como mínimo. Idealmente 10 `[x]` para un run útil.
- App = Swift (locked). Python en este menú es tooling, no un segundo producto.

## STOP

- No hagas `pkill -9` sin confirmar.
- No hardcodees un path de DerivedData de *tu* usuario (`/Users/alguien/Library/Developer/...`). Usá `xcodebuild -showBuildSettings` o `-derivedDataPath` **dentro del repo** (ej. `macos/build`) para que run sea reproducible.

Recomendado en `project.yml` / script:

```text
DERIVED="$ROOT/macos/build"
xcodebuild -derivedDataPath "$DERIVED" ...
APP="$DERIVED/Build/Products/Debug/eqviz.app"
```

Agregá `macos/build/` a `.gitignore`.

## Qué debe quedar en el menú (ids estables)

Las opciones pueden renumerarse en UI, pero el script debe exponer funciones:

| Función | Comportamiento |
| :--- | :--- |
| `status` | Python uv, xcodegen, xcodeproj, último build, proceso eqviz corriendo (pgrep) |
| `sync_python` | `uv sync --group dev` |
| `test_python` | `uv run pytest` si hay tests; si no hay, decirlo y exit 0 |
| `lint_python` | `uv run ruff check .` |
| `build_macos` | `xcodegen generate` si hay `project.yml`, luego `xcodebuild` Debug arm64 |
| `run_macos` | build si hace falta + `open` el `.app` |
| `stop_macos` | listar PIDs, **confirm y/N**, después `kill` (TERM). Si no muere en 3s, preguntar antes de KILL |
| `open_xcode` | `open macos/eqviz.xcodeproj` |
| `test_macos` | `xcodebuild test` mismo destination |
| `roadmap_next` | primer `- [ ]` de `STATUS.md` |
| `quit` | sale 0 |

No agregues `sudo`, no instales Xcode, no `xcode-select` automático.

## Verificación

```bash
./setup.sh
```

Probar a mano: estado, build, test macOS, run, stop (cancelar una vez, confirmar otra).

## Definition of Done

- [ ] DerivedData del repo, no del usuario.
- [ ] build/run/test/stop funcionan.
- [ ] Stop pide confirmación.
- [ ] `STATUS.md` 11 `[x]`.

## Fuera de alcance

CI GitHub, notarize, Sparkle.
