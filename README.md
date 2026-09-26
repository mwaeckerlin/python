# Docker Image to Run Python Software

This is a minimalistic, highly optimized and secure image to run Python software. Use it in the last build step when building docker images for your Python project using [mwaeckerlin/python-build](https://github.com/mwaeckerlin/python-build).

This image contains only Python and its direct dependencies, so it is about 51MB, while the official Python image of the Docker Hub library is 925MB. It has no shell, no package manager and no pip, runs as the unprivileged user `somebody` in `/app`, and is published for `linux/amd64` and `linux/arm64`.

## Usage

`python` is the entrypoint and `main.py` in `/app` runs by default. Another script is named with `CMD`:

```Dockerfile
FROM mwaeckerlin/python
COPY --from=build /app /app
CMD ["other.py"]
```

## Development

```bash
$ npm run build
$ npm test
```

`npm test` checks the feature register ([FEATURES.md](FEATURES.md), [TESTS.md](TESTS.md)), the headless image contract and runs a small script in a child image. The image is built and published by the reusable workflow of [mwaeckerlin/scratch](https://github.com/mwaeckerlin/scratch#publishing-on-docker-hub).
