# Features

Numbered register of every feature; a number is never reused. Every feature is covered by tests listed in [TESTS.md](TESTS.md); the guard `tests/docs-contract.sh` fails when a feature has no test.

- **F1 — Minimal Python runtime.** The image holds Python with its standard library and every shared library the standard modules load (OpenSSL, SQLite, zlib, libffi …), and nothing else: no shell, no package manager, no pip.
- **F2 — Script as command.** `python` is the entrypoint and `main.py` in `/app` runs by default; a derived image names another script with `CMD ["other.py"]`.
- **F3 — Unprivileged.** The script runs as `somebody` in `/app`.
- **F4 — Published for amd64 and arm64.** Every push builds the image natively for both architectures and publishes it under one tag on Docker Hub, with the reusable workflow of `mwaeckerlin/scratch`.
