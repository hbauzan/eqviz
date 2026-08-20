# eqviz

Un visor gráfico de audio en tiempo real para macOS. Barras segmentadas, pinta vintage, livianito. No es un equalizer: no toca el sonido, lo mira.

Lo armé una mañana de licencia. Sin fiebre, un poquito de THC, música puesta. Quería un visor como este — de esos que te recuerdan a los equipos vintage de mi viejo, los VU, los LEDs, esa cosa de hi-fi de living que parece tablero de avión. Sigue siendo un PoC y le voy a ir toqueteando cosas, pero ya se deja mirar.

Justo estaba (estoy) escuchando **Cassettes**: la playlist con la música de los cassettes de mi viejo. Si querés el mood:

[Cassettes en Spotify](https://open.spotify.com/playlist/5Ge72ozP9x4JMIkllf7Aej?si=7fe0e815c3df4929)

<iframe data-testid="embed-iframe" style="border-radius:12px" src="https://open.spotify.com/embed/playlist/5Ge72ozP9x4JMIkllf7Aej?utm_source=generator&theme=0&si=7fe0e815c3df4929" width="100%" height="152" frameBorder="0" allowfullscreen="" allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture" loading="lazy"></iframe>

Esto es un **lab público**. Lo dejé acá para que se vea cómo nació, con el roadmap, las invariantes y hasta los prompts que le fui pasando al agente. No es un producto de App Store. Es lo que salió de esa mañana.

## Qué hay

32 barras × 16 segmentos, cinco paletas (Retro Red, White Matrix, Rainbow Spectrum, Fire Gradient, Cyber Neon), 60 Hz, solo se pintan las celdas prendidas. Captura la entrada por defecto de la Mac (el mic o la interfaz que tengas en Ajustes del Sistema). No graba, no manda audio a ningún lado: entra, se hace FFT y se tira. La ventanita de permisos dice exactamente eso: `eqviz does not record or send audio.`

Apple Silicon, macOS 14+, Swift + SwiftUI. Python/`uv` es solo tooling (lint, tests del repo, hooks). El menú de la casa es `./setup.sh`.

PoC: bundle `dev.local.eqviz`, Personal Team, sandbox off. Si clonás y corrés, es una app sin sandbox que pide el mic. Tratála como lo que es.

## Cómo se prende

Instalá vos Xcode 15+ y [XcodeGen](https://github.com/yonaskolb/XcodeGen). El Team ID no va en git.

```bash
./setup.sh
```

O directo:

```bash
./setup.sh status
./setup.sh test-mac
./setup.sh run
```

La primera vez en Xcode: `./setup.sh xcode` (o `open macos/eqviz.xcodeproj`) → Signing & Capabilities → **Personal Team**. Si `xcodebuild` se queja de plugins: `xcodebuild -runFirstLaunch`.

`./setup.sh stop` pregunta `y/N` antes de mandar SIGTERM. No hagas `pkill` a lo loco.

Otorgá el mic, y hablá o mandale audio a la entrada que tengas seleccionada.

## El lab

- `macos/eqviz/` — la app
- `macos/eqvizTests/` — tests de lógica (sin mic, sin abrir la app)
- `roadmap/` — los prompts en orden; si sos un agente, empezá por [`00-invariants.md`](roadmap/00-invariants.md)
- `./setup.sh next` — el siguiente paso pendiente

```bash
./setup.sh next
uv sync --group dev
```

Si agregás config local, copiá `.env.example` a `.env` y no lo subas.

## Licencia

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Usalo, forkéalo, rompelo, lo que se te ocurra — **citá la fuente**: este repo, [hbauzan/eqviz](https://github.com/hbauzan/eqviz). El texto legal está en [`LICENSE`](LICENSE).
