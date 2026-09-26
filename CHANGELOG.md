# Changelog

- 2026-09-26 **1.1.1**
    - The image is published for amd64 and arm64 under one tag, built and published automatically on every change and every week
    - Image build no longer emits warnings (modernized instruction format)

- 2026-07-16 **1.1.0**
    - The shipped image is now automatically verified to contain no shell and no scripting language besides Python — an attacker who reaches code execution in the container finds no tool to pivot with

- 2026-03-27 **1.0.0**
    - `python` is the entrypoint, so a derived image names only its script with `CMD`; `main.py` in `/app` runs by default
    - The image contains Python and every shared library its standard modules need, and runs as the unprivileged user in `/app`
