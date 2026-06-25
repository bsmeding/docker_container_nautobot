# Building the image (maintainers)

For **using** the published images on Docker Hub, see [README.md](README.md).

## Quick build (recommended)

Use the provided build script for easy building of any version:

```bash
# Build Nautobot 3.1.0 (default Python 3.12)
./build.sh 3.1.0

# Build Nautobot 2.4.31 with Python 3.11
./build.sh -p 3.11 2.4.31

# Build Nautobot 1.6.32
./build.sh 1.6.32

# List available versions
./build.sh --list
```

## Using Makefile

Alternatively, use the Makefile for even simpler commands:

```bash
# Build Nautobot 3.1.0
make build VERSION=3.1.0

# Build with specific Python version
make build-3x VERSION=3.1.0 PYTHON_VER=3.11

# Build Nautobot 2.x
make build-2x VERSION=2.4.31

# Build Nautobot 1.x
make build-1x VERSION=1.6.32

# Show help
make help
```

## Manual Docker Build

For manual builds, use docker build with the appropriate arguments:

```bash
# Build Nautobot 3.x
docker build \
  --build-arg BASE_TAG=3.1.0 \
  --build-arg NAUTOBOT_VER=3.1.0 \
  --build-arg PYTHON_VER=3.12 \
  -t bsmeding/nautobot:3.1.0 \
  .

# Build Nautobot 2.x
docker build \
  --build-arg BASE_TAG=2.4.31 \
  --build-arg NAUTOBOT_VER=2.4.31 \
  --build-arg PYTHON_VER=3.12 \
  -t bsmeding/nautobot:2.4.31 \
  .
```

The Dockerfile automatically selects the correct requirements file based on the `NAUTOBOT_VER`:
- `1.*` → uses `requirements-1.x.txt`
- `2.*`, `stable`, `latest` → uses `requirements-2.x.txt`
- `3.*` → uses `requirements-3.x.txt`

## Dev image (local-only, for testing packages)

Use a `-dev` image to try out experimental packages / version bumps **before**
promoting them into `requirements-extra.txt` or the per-major
`requirements-{1,2,3}.x.txt` files and the CI build matrix.

It uses `Dockerfile.dev`, which simply layers [`requirements-dev.txt`](requirements-dev.txt)
on top of an existing Nautobot image — it does **not** rebuild Nautobot, so
iteration is fast. Dev images are never published by CI.

1. Add the packages you want to test to `requirements-dev.txt`.
2. Build a `-dev` image on top of an existing tag:

```bash
# Layer onto a locally built image -> bsmeding/nautobot:3.1.0-py3.12-dev
./build.sh --dev 3.1.0

# Layer onto a published tag without building the full image first
./build.sh --dev -b bsmeding/nautobot:stable -t bsmeding/nautobot:stable-dev stable
```

Or with the Makefile:

```bash
make build-dev VERSION=3.1.0
make build-dev BASE_IMAGE=bsmeding/nautobot:stable
```

3. Run and test it:

```bash
docker run -d -p 8080:8080 bsmeding/nautobot:3.1.0-py3.12-dev
```

> The base image already carries build tooling (build-essential, python3-dev,
> etc.). If a dev package needs to compile against system libraries that aren't
> present, add an `apt-get update && apt-get install -y ...` step to
> `Dockerfile.dev` while you iterate.