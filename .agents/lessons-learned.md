# LESSONS LEARNED & ARCHITECTURAL INVARIANTS

Memoria de **este producto** (`eqviz`), no parte de la skill `dev-protocol`. Vive en `.agents/lessons-learned.md` (hermano de `skills/`). El protocolo de proceso se copia a otras apps; este archivo no.

Registra invariantes de arquitectura y patrones descubiertos acá. Si existe, los agentes lo consultan y actualizan en cada ciclo.

---

## 1. Product identity

- **eqviz** is an **ultralight real-time audio graphic visualizer**.
- Do not import VHectorLab / embedding / WebGL-lab invariants here. This is a different product.

## 2. Design constraints (bootstrap)

- **Ultralight**: prefer the smallest stack that can paint audio in real time. Do not add LLM, 3D, or heavy UI frameworks unless the product explicitly needs them.
- **Real-time**: the audio → analysis → draw path is the latency budget. Analysis must not block the capture callback; drawing must not drop the audio thread.
- **macOS-first** until ported: this working copy lives on Darwin; do not claim Windows/Linux support without testing.

---

## 3. Protocolo de mantenimiento

1. **Consulta obligatoria**: leer este archivo al iniciar implementación, diseño de análisis de audio o render.
2. **Actualización continua**: al descubrir una invariante técnica, registrarla acá antes de cerrar la tarea.
