# CONTEXT — eqviz domain glossary

Ubiquitous language for this product. Definitions say what a concept **is**, not how it is implemented.

## eqviz

The product: an ultralight real-time audio graphic visualizer.

## Audio source

The live input being visualized. v1 is the Mac’s current **default input** (microphone or interface selected in System Settings). System loopback is out of scope until v1 is judged insufficient.

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

## Decay

The peak-fall of a band after the live energy drops: attack is instant; the peak then falls with gravity so bars look like vintage VU/LED meters.

## Visualizer style

One of five palettes for the same segmented bars: Retro Red, White Matrix, Rainbow Spectrum, Fire Gradient, Cyber Neon.

## Segmented bar

A vertical column of discrete square blocks (lit from the bottom) representing one band. Not a continuous rectangle.

## Spectrum snapshot

The current band values (and peaks) held behind a lock and read by the draw loop. Not a SwiftUI-published high-frequency array.

## Avoid

- **Equalizer** as the product name — eqviz visualizes; it does not necessarily process/mix audio.
- **Embedding / token / thread** — those belong to VHectorLab, not this product.
