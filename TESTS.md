# Tests

Register of all tests, sorted by the [FEATURES.md](FEATURES.md) number each test covers. `npm test` runs everything; the guard `tests/docs-contract.sh` fails when a feature has no test entry here.

## Image contract

- **F1** `tests/image-contract.sh` › no sh, no bash, no busybox, no perl — the image is headless.
- **F1** `tests/config-contract.sh` › shared_libraries_present — a script imports `ssl`, `sqlite3`, `hashlib`, `zlib` and `ctypes` and opens an SQLite database.
- **F2** `tests/config-contract.sh` › default_main_py_runs, cmd_override_runs — `main.py` runs without any `CMD`, and `CMD ["other.py"]` runs the other script.
- **F3** `tests/config-contract.sh` › runs_as_somebody, workdir_app — the script runs as `somebody` in `/app`.

## Workflow contract

- **F4** `tests/workflow-contract.sh` of `mwaeckerlin/scratch` — the reusable workflow selects exactly the images a repository publishes; this repository calls it from `.github/workflows/docker.yml`.
