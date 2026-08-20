# 13 — Sync de documentación

## Meta

Alinear README / CONTEXT / CHANGELOG / lessons-learned / `manifest.json` con la app **tal como quedó**, no con el master prompt original si algo se locked distinto en 01.

## Precondiciones

- 12 `[x]` (la app realmente corre). Si 12 no está, este paso es prematuro salvo que el usuario pida docs de avance.

## STOP

- No elijas licencia.
- No inventes Bundle ID en el README distinto al de Xcode.
- No documentes audio de sistema si 01-B fue solo mic (y viceversa).
- Sync **condicional** según `dev-protocol` `documentation.md`: no reescribas todo el glossary si no hay términos nuevos.

## Qué tocar

| Archivo | Si y solo si |
| :--- | :--- |
| `README.md` | Cómo instalar Xcode, `./setup.sh`, permisos TCC, signing |
| `CONTEXT.md` | Términos nuevos ya usados en código (Decay, Visualizer style, Segmented bar, Spectrum snapshot) |
| `CHANGELOG.md` | Capacidad v1: visualizer 5 estilos, captura X, FFT vDSP |
| `.agents/lessons-learned.md` | Invariantes reales (Canvas, snapshot lock, fuente de audio, CPU) |
| `manifest.json` | Si hay `state_schema` (estilo, band count). Si no hay config persistente, dejalo `{}` |
| `architecture_spec.md` | Crealo **solo** si el contrato de audio/FFT/UI merece un spec; no es obligatorio para v1 |

README debe decir: entrada de admin = `./setup.sh`. Quitar o relegar `uv run python main.py` si la app ya no es el stub.

## Definition of Done

- [ ] Un clon nuevo puede seguir el README y llegar a ⌘R / `setup.sh` run.
- [ ] Glossary y lessons coinciden con 01 locked + código.
- [ ] `STATUS.md` 13 `[x]`.
- [ ] Handoff al usuario: cómo probar, **approval gate** (no push/merge).
