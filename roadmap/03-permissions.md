# 03 — Permisos TCC, Info.plist, entitlements

## Meta

La app pide **solo micrófono** (input default, 01-B locked). Sin captura todavía: el motor va en 05. Este paso deja el manifiesto listo para que `start()` en 05 no falle por plist.

## Precondiciones

- 02 `[x]`, app compile.
- 01-E locked. Copy verbatim: `eqviz does not record or send audio.`

## STOP

Solo estas keys:

- `NSMicrophoneUsageDescription` (texto aprobado en 01-E)
- entitlement `com.apple.security.device.audio-input`

**No agregues:** ScreenCapture, Grabación de pantalla, cámara, Bluetooth, red, `SystemAudioCapture`, **`com.apple.security.app-sandbox`** (Sandbox OFF locked).

`com.apple.security.device.audio-input`: sin sandbox no es estrictamente necesario para mic + TCC. PoC: **no lo agregues** salvo que `xcodebuild`/TCC falle sin él; entonces documentalo en lessons-learned. No prendas Hardened Runtime.

Hardened Runtime / notarization: no. Fuera del PoC.

## Archivos

- `macos/eqviz/Info.plist` — keys de uso (las `NS*UsageDescription`)
- `macos/eqviz/eqviz.entitlements` — audio-input y sandbox si aplica
- `macos/project.yml` — `CODE_SIGN_ENTITLEMENTS`, `INFOPLIST_KEY_*` si usás generate, **sin duplicar** keys en plist y YAML. Elegí una sola fuente por key.

## Requisitos de copy

- Usá **exactamente**: `eqviz does not record or send audio.`
- No lo amplíes (no agregues “visualizes” ni “default input” si no está en el verbatim).

## Verificación

```bash
cd macos && xcodegen generate
xcodebuild -project macos/eqviz.xcodeproj -scheme eqviz -destination 'platform=macOS,arch=arm64' -configuration Debug build
plutil -lint macos/eqviz/Info.plist
```

Inspeccioná el producto:

```bash
# ajustar path al .app generado
defaults read <path>/eqviz.app/Contents/Info NSMicrophoneUsageDescription
codesign -d --entitlements - <path>/eqviz.app
```

Verificá `NSMicrophoneUsageDescription` en el .app. No debe haber keys de Screen Recording.

Aún **no** debe aparecer el diálogo TCC: no hay `engine.start()`. Si al correr la app vacía aparece un prompt de mic, algo instaló un tap demasiado pronto — revertí.

## Definition of Done

- [x] Plist: `NSMicrophoneUsageDescription` con copy aprobado. Sin sandbox.
- [x] Copy TCC es el aprobado, no uno inventado.
- [x] Build 0. App corre igual que en 02 (ventana negra, sin diálogo de permiso).
- [x] `STATUS.md` 03 `[x]`.

## Fuera de alcance

`AudioEngine`, UI de “permiso denegado” (eso es 05 + 10).
