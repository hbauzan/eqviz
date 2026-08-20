# 02 — Bootstrap del proyecto macOS

## Meta

Dejar un target de app macOS **reproducible** que compile y abra una ventana vacía negra. Cero audio, cero visualizer.

## Precondiciones

- `01-decision-gate.md` está `[x]`. Stack = Swift + SwiftUI (locked).
- Bundle ID locked: `dev.local.eqviz`. Firma: Personal Team; **omitir** `DEVELOPMENT_TEAM` en `project.yml`.

## STOP

- Si `xcodegen` no está en PATH: **STOP**. Decile al humano que lo instale (p. ej. `brew install xcodegen`). **Nunca** `brew install` desde el agente.
- No pises `pyproject.toml` ni el menú Python de `setup.sh` (tooling locked).
- No agregues ScreenCaptureKit, mic “de sistema”, ni un segundo target.
- No actives App Sandbox (locked OFF).
- No escribas un Team ID.

## Archivos a crear (layout locked)

```text
macos/
  project.yml                 # XcodeGen
  eqviz/
    eqvizApp.swift            # @main App, Window placeholder
    Info.plist                # mínimo; permisos van en 03
  eqviz.xcodeproj/            # GENERADO, no editar a mano
.gitignore                    # agregar artefactos Xcode (append, no reescribir)
```

No uses un `.xcodeproj` escrito a mano. No uses Package.swift como app (entitlements/TCC salen mal).

## `project.yml` — requisitos

- Nombre: `eqviz`
- SDK: macOS
- `MACOSX_DEPLOYMENT_TARGET: "14.0"`
- `SWIFT_VERSION: "5.0"` (modo 5, no 6)
- `GENERATE_INFOPLIST_FILE: YES` + `INFOPLIST_FILE` apuntando al plist
- `PRODUCT_BUNDLE_IDENTIFIER: dev.local.eqviz`
- `DEVELOPMENT_TEAM`: **omitido**. El humano selecciona Personal Team en Xcode una vez.
- `ARCHS: [arm64]` (Apple Silicon). No agregues `x86_64` salvo pedido.
- Sources: `macos/eqviz`
- Entitlements: en 02 podés omitir el archivo. Si lo creás, dict **sin** `com.apple.security.app-sandbox`. Sandbox OFF locked. Mic entitlement va en 03 (`audio-input` no es obligatorio sin sandbox; 03 decide el mínimo).

## `eqvizApp.swift`

- `@main struct EqvizApp: App`
- Una `Window("eqviz", id: "main")` con un `Color.black.ignoresSafeArea()` placeholder
- Nada de audio, nada de estilos
- Sin `TODO`

## `.gitignore` (append)

Agregá, si no están:

```
macos/eqviz.xcodeproj/xcuserdata/
macos/eqviz.xcodeproj/project.xcworkspace/xcuserdata/
DerivedData/
*.xcuserstate
```

El `project.pbxproj` **sí** se commitea (es generado, pero es el proyecto). `project.yml` es la fuente; si regenerás, regenerá commiteando ambos.

## Comandos de verificación

Desde la raíz del repo (o vía `setup.sh` cuando 11 lo cablee; ahora a mano):

```bash
command -v xcodegen
cd macos && xcodegen generate
xcodebuild -project macos/eqviz.xcodeproj -scheme eqviz -destination 'platform=macOS,arch=arm64' -configuration Debug build
```

Si `xcodegen` no existe: STOP, no generes pbxproj a mano.

Abrir una vez:

```bash
open macos/eqviz.xcodeproj
```

Correr la app (⌘R) o:

```bash
xcodebuild ... build
# luego open el .app en DerivedData, o `xcodebuild ... run` no es fiable; preferí open -a
```

La ventana debe aparecer negra. Cerrar a mano.

## Definition of Done

- [x] `macos/project.yml` + `eqvizApp.swift` existen.
- [x] `xcodegen generate` + `xcodebuild` Debug arm64 terminan 0.
- [x] La app abre una ventana negra.
- [x] Python bootstrap intacto.
- [x] `STATUS.md` 02 `[x]`.

## Fuera de alcance

Permisos, motor de audio, visualizer, `ContentView` real, firma automática.
