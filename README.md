# eqviz

Ultralight real-time audio graphic visualizer.

This repo is a bootstrap: product identity, Python/`uv` toolchain, and the portable `dev-protocol` skill. The visualizer itself is not implemented yet.

## Status

`0.0.1` — initialized. No capture, analysis, or draw loop yet.

## Stack

- Python 3.12+ via [`uv`](https://docs.astral.sh/uv/)
- macOS-first (created on Darwin)

## Setup

```bash
uv sync --group dev
uv run python main.py
```

Copy `.env.example` to `.env` if you add local runtime config. Never commit `.env`.

## License

Not chosen yet.
