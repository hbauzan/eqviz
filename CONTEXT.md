# CONTEXT — eqviz domain glossary

Ubiquitous language for this product. Definitions say what a concept **is**, not how it is implemented.

## eqviz

The product: an ultralight real-time audio graphic visualizer.

## Audio source

The live input being visualized (microphone, system loopback, or a file played as if live). One source is active at a time.

## Capture

The stream of PCM frames taken from the audio source at a fixed sample rate.

## Frame

One visualization tick: a window of samples analyzed and drawn together.

## Analyzer

The transform from a frame of samples into drawable values (spectrum, bands, waveform, or envelope).

## Spectrum

Energy per frequency bin for the current frame.

## Band

A grouped range of frequencies treated as one drawable value (e.g. an EQ bar).

## Visualizer

The draw surface that maps analyzer output to graphics each frame.

## Latency budget

The wall-clock time allowed from capture to pixels so the picture still feels live.

### Avoid

- **Equalizer** as the product name — eqviz visualizes; it does not necessarily process/mix audio.
- **Embedding / token / thread** — those belong to VHectorLab, not this product.
