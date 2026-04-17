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