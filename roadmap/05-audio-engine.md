# 05 — Motor de audio: ciclo de vida + tap (sin FFT)

## Meta

Una clase observable de **ciclo de vida** (`start`/`stop`) que instala un tap en el **input default de macOS** (`AVAudioEngine.inputNode`), copia PCM a una cola serial, y publica solo estado de UI de baja frecuencia (`isRunning`, `lastError`). Todavía **no** hay FFT ni bandas.

## Precondiciones

- 04 `[x]`.
- 01-B locked: default input. Seguir el device que la Mac tenga seleccionado.

## STOP

- **Prohibido** ScreenCaptureKit, `SystemAudioCapture.swift`, BlackHole, Loopback.
- No dejes un adapter de sistema “vacío para después”. v2 es un prompt nuevo cuando el usuario diga que v1 no cumple.
- No publiques `[Float]` de samples a SwiftUI (eso mata CPU).
- No hardcodees un UID de device: usá siempre el input default del sistema.

## Archivos

```text
macos/eqviz/Audio/AudioEngine.swift      # facade observable (UI state only)
macos/eqviz/Audio/AudioCapturing.swift   # protocol (un adapter en v1)
macos/eqviz/Audio/InputNodeCapture.swift # AVAudioEngine.inputNode
macos/eqviz/Audio/RingBuffer.swift       # copia lock-free o mutex; Float32 mono
```

Nombres exactos preferidos: los de arriba. No pongas FFT en estos archivos.

## Contrato `AudioCapturing`

```text
protocol AudioCapturing: AnyObject {
  var sampleRate: Double { get }
  func start() throws
  func stop()
  /// Called on capture thread. Implementation MUST copy; caller does not retain the buffer.
  var onSamples: ((UnsafeBufferPointer<Float>, Double) -> Void)? { get set }
}
```

`AudioEngine` (UI):

- `@Observable` o `ObservableObject` **solo** para `isRunning`, `lastError`, `permissionDenied`.
- Posee el capturer y un `DispatchQueue(label: "eqviz.audio", qos: .userInitiated)`.
- `start()` / `stop()` desde MainActor.
- El tap **nunca** hace `Task { @MainActor in }` por cada buffer.

## Input default (`AVAudioEngine.inputNode`)

Pitfalls que tenés que manejar (si no, 05 está incompleto):

1. `inputFormat(forBus: 0)` puede venir con `channelCount == 0` o `sampleRate == 0` antes del permiso o del device. Tratalo como error recuperable; no crashees.
2. Instalá el tap con el format del input node. Convertí a **mono Float32** en el tap (promedio L/R si stereo).
3. `bufferSize` del tap: 1024 o 2048. No 128 (overhead) ni 16384 (latencia).
4. `engine.prepare()` + `try engine.start()`.
5. Route / default-device change: cuando el usuario cambia la entrada en Ajustes del Sistema (o destapa un interface), observá la notificación de configuración del engine en macOS y **reinstalá el tap** sobre el nuevo default. No quedes pegado al device anterior.
6. Primera corrida: macOS muestra TCC de **micrófono**. Si el usuario niega, `lastError` + `permissionDenied = true`. No loops de reintento agresivos.
7. `stop()`: `removeTap`, `engine.stop()`. Idempotente.

## Fuera de alcance (v2, no ahora)

ScreenCaptureKit / audio de sistema. No hay sección de implementación acá.

## Integración UI (mínima)

`ContentView` puede mostrar texto de diagnóstico chico (`running` / error) **negro sobre negro no**. Usá gris oscuro 12pt, o dejalo solo en `#if DEBUG`. Preferí `#if DEBUG` para no pelear con la estética. En 10 se puede reemplazar por estado silencioso.

No arranques el engine en `init()` del `App`. Arranque: `.task { await engine.start() }` en `ContentView`, y `stop` en `onDisappear` / terminación.

## Verificación

Build 0. Run:

- Input default: diálogo TCC de micrófono (primera vez). Hablá al mic o mandá señal a la entrada seleccionada en macOS. En DEBUG, indicador de RMS o “buffers > 0” (contador `receivedBuffers` no publicado a 120Hz: `hasSignal` cada 250ms máx).
- Cambiá la entrada en Ajustes → Sonido mientras corre: el tap debe seguir al nuevo default (no quedarse mudo).
- Negar permiso: la app no crashea; `lastError` seteado.
- Stop/start dos veces sin crash.

Medí que **no** estás invalidando toda la vista 86 veces/seg: el overlay DEBUG no debe usar el array de samples como `@Observable`.

## Definition of Done

- [ ] Adapter `InputNodeCapture` solamente (default input).
- [ ] Tap copia PCM; cola serial; UI state de baja frecuencia.
- [ ] Route / default-device change no deja el tap muerto.
- [ ] Permiso denegado no crashea.
- [ ] Cero FFT. Cero SCK. `STATUS.md` 05 `[x]`.

## Fuera de alcance

vDSP, bandas, decay, Canvas, estilos.
