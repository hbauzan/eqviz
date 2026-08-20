# Roadmap eqviz — prompts ejecutables por un agente

Este directorio **no implementa** la app. Son prompts secuenciales, con STOP/ASK, para que un agente de programación construya eqviz con la menor tasa de error posible.

## Cómo usarlo

```bash
./setup.sh
```

Opción **Roadmap: siguiente paso**. Eso imprime el primer prompt pendiente. Pegalo (o decile al agente: `Ejecutá el siguiente prompt de roadmap/` siguiendo `dev-protocol`).

Reglas:

1. Leé `00-invariants.md` antes de tocar código.
2. Un prompt numerado por sesión.
3. Ante la duda: preguntá. Sin `SECURITY OVERRIDE` + decisión concreta, no asumas.
4. `STATUS.md` es la fuente de verdad de progreso.

## Orden

| # | Archivo | Qué entrega | Compila app? |
| :---: | :--- | :--- | :---: |
| 00 | [00-invariants.md](./00-invariants.md) | Contrato. No es una tarea. | — |
| 01 | [01-decision-gate.md](./01-decision-gate.md) | Decisiones A–E locked (Swift, input default, ventana normal, close=quit, semáforos nativos). | no |
| 02 | [02-xcode-bootstrap.md](./02-xcode-bootstrap.md) | Proyecto macOS reproducible | sí (ventana vacía) |
| 03 | [03-permissions.md](./03-permissions.md) | Info.plist + entitlements TCC | sí |
| 04 | [04-app-window.md](./04-app-window.md) | Ventana negra, chrome mínimo | sí |
| 05 | [05-audio-engine.md](./05-audio-engine.md) | Ciclo de vida AVAudioEngine + tap | sí |
| 06 | [06-fft-bands.md](./06-fft-bands.md) | vDSP FFT → 32 bandas 0…1 | sí |
| 07 | [07-decay-gravity.md](./07-decay-gravity.md) | Caída de picos vintage | sí |
| 08 | [08-visualizer-view.md](./08-visualizer-view.md) | Canvas de bloques cuadrados 120Hz | sí |
| 09 | [09-visualizer-styles.md](./09-visualizer-styles.md) | 5 paletas VFD/LED | sí |
| 10 | [10-content-view.md](./10-content-view.md) | Hover, selector, close/min | sí |
| 11 | [11-setup-sh.md](./11-setup-sh.md) | Acciones admin reales para la app | sí |
| 12 | [12-verify-run.md](./12-verify-run.md) | Corrida en Mac Apple Silicon | sí |
| 13 | [13-docs-sync.md](./13-docs-sync.md) | README / CONTEXT / CHANGELOG | sí |

## Extra de producto (ya creado, no es un prompt de implementación)

- `./setup.sh` — menú admin único (sync, tests, lint, build/run/stop con confirmación).
- `.cursor/rules/no-assumptions.mdc` — la regla de no-asumir aplica a **toda** sesión, no solo al roadmap.

## Camino locked

- App: Swift + SwiftUI. Tooling: `./setup.sh` + `uv`.
- **PoC:** Bundle ID `dev.local.eqviz`, Personal Team (set in Xcode, not in git), Sandbox OFF.
- Captura v1: input default de macOS (`AVAudioEngine`). Sistema = solo si v1 no alcanza.
- Ventana: normal, no always-on-top; close termina; semáforos nativos.
- `STATUS.md` 01–13 `[x]`. Extra de producto: CPU Debug ~30% (goal 1–2%).
