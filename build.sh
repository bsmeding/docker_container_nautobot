#!/bin/bash
# Build script for Nautobot Docker image
# Supports Nautobot 1.x, 2.x, and 3.x versions

set -e

# Default values
DEFAULT_PYTHON_VER="3.12"
DEFAULT_REGISTRY="bsmeding"
DEFAULT_IMAGE_NAME="nautobot"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS] VERSION

Build Nautobot Docker image for specified version.

Arguments:
  VERSION              Nautobot version to build (e.g., 1.6.32, 2.4.19, 3.0.2, stable, latest)

Options:
  -p, --python VER     Python version (default: ${DEFAULT_PYTHON_VER})
                       Supported: 3.10, 3.11, 3.12
  -t, --tag TAG        Custom tag for the image (default: auto-generated)
  -r, --registry REG   Docker registry/username (default: ${DEFAULT_REGISTRY})
  -n, --name NAME      Image name (default: ${DEFAULT_IMAGE_NAME})
  -d, --dev            Build a local-only "-dev" image: layer requirements-dev.txt
                       on top of a base image (uses Dockerfile.dev, fast iteration).
  -b, --base-image IMG Base image for --dev builds
                       (default: <registry>/<name>:<VERSION>-py<python>).
                       Use this to layer onto e.g. an upstream/published tag.
  -l, --list           List available versions
  -h, --help           Show this help message

Examples:
  # Build Nautobot 3.0.2 with Python 3.12
  $0 3.0.2

  # Build Nautobot 2.4.19 with Python 3.11
  $0 -p 3.11 2.4.19

  # Build with custom tag
  $0 -t my-custom-tag 3.0.2

  # Build latest stable
  $0 stable

  # Build a -dev image on top of a locally built 3.1.0-py3.12 image
  # (produces <registry>/<name>:3.1.0-py3.12-dev)
  $0 --dev 3.1.0

  # Build a -dev image on top of a published tag without a local build first
  $0 --dev -b bsmeding/nautobot:stable -t bsmeding/nautobot:stable-dev stable

EOF
}

# Function to list available versions
list_versions() {
    cat << EOF
Available Nautobot versions to build:

Nautobot 1.x:
  1.6.31, 1.6.32

Nautobot 2.x:
  2.4.17, 2.4.18, 2.4.19

Nautobot 3.x:
  3.0.0, 3.0.1, 3.0.2

Special tags:
  stable, latest

Python versions:
  3.10, 3.11, 3.12

EOF
}

# Function to determine requirements file based on version
get_requirements_file() {
    local version=$1
    if [[ "$version" == 1.* ]]; then
        echo "requirements-1.x.txt"
    elif [[ "$version" == 2.* ]] || [[ "$version" == "stable" ]] || [[ "$version" == "latest" ]]; then
        echo "requirements-2.x.txt"
    elif [[ "$version" == 3.* ]]; then
        echo "requirements-3.x.txt"
    else
        echo "unknown"
    fi
}

# Function to validate version
validate_version() {
    local version=$1
    local req_file=$(get_requirements_file "$version")
    
    if [[ "$req_file" == "unknown" ]]; then
        echo -e "${RED}Error: Unsupported Nautobot version: $version${NC}" >&2
        echo -e "${YELLOW}Use -l or --list to see available versions${NC}" >&2
        exit 1
    fi
    
    if [[ ! -f "$req_file" ]]; then
        echo -e "${RED}Error: Requirements file not found: $req_file${NC}" >&2
        exit 1
    fi
}

# Parse arguments
PYTHON_VER="${DEFAULT_PYTHON_VER}"
CUSTOM_TAG=""
REGISTRY="${DEFAULT_REGISTRY}"
IMAGE_NAME="${DEFAULT_IMAGE_NAME}"
NAUTOBOT_VER=""
DEV_MODE=false
BASE_IMAGE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--python)
            PYTHON_VER="$2"
            shift 2
            ;;
        -t|--tag)
            CUSTOM_TAG="$2"
            shift 2
            ;;
        -r|--registry)
            REGISTRY="$2"
            shift 2
            ;;
        -n|--name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -d|--dev)
            DEV_MODE=true
            shift
            ;;
        -b|--base-image)
            BASE_IMAGE="$2"
            shift 2
            ;;
        -l|--list)
            list_versions
            exit 0
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo -e "${RED}Error: Unknown option: $1${NC}" >&2
            usage
            exit 1
            ;;
        *)
            if [[ -z "$NAUTOBOT_VER" ]]; then
                NAUTOBOT_VER="$1"
            else
                echo -e "${RED}Error: Multiple versions specified${NC}" >&2
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if version is provided
# In --dev mode a version is optional as long as an explicit --base-image is given
# (the version is otherwise only used to derive the base image and tag).
if [[ -z "$NAUTOBOT_VER" ]]; then
    if [[ "$DEV_MODE" == true && -n "$BASE_IMAGE" ]]; then
        :
    else
        echo -e "${RED}Error: Nautobot version is required${NC}" >&2
        usage
        exit 1
    fi
fi

# Validate version (skipped in --dev mode: dev images layer onto a base image and
# do not select a per-major requirements file).
if [[ "$DEV_MODE" != true && -n "$NAUTOBOT_VER" ]]; then
    validate_version "$NAUTOBOT_VER"
fi

# ---------------------------------
# Dev build: layer requirements-dev.txt on top of a base image
# ---------------------------------
if [[ "$DEV_MODE" == true ]]; then
    # Default base image: the standard locally built/published tag for this version
    if [[ -z "$BASE_IMAGE" ]]; then
        BASE_IMAGE="${REGISTRY}/${IMAGE_NAME}:${NAUTOBOT_VER}-py${PYTHON_VER}"
    fi

    # Default output tag: base image + "-dev"
    if [[ -n "$CUSTOM_TAG" ]]; then
        DEV_TAG="$CUSTOM_TAG"
    else
        DEV_TAG="${BASE_IMAGE}-dev"
    fi

    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Building Nautobot DEV Docker Image${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo -e "Base image:   ${YELLOW}${BASE_IMAGE}${NC}"
    echo -e "Dev reqs:     ${YELLOW}requirements-dev.txt${NC}"
    echo -e "Image Tag:    ${YELLOW}${DEV_TAG}${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    echo -e "${GREEN}Starting dev build...${NC}"
    docker build \
        -f Dockerfile.dev \
        --build-arg BASE_IMAGE="${BASE_IMAGE}" \
        -t "${DEV_TAG}" \
        .

    if [[ $? -eq 0 ]]; then
        echo ""
        echo -e "${GREEN}✓ Dev build successful!${NC}"
        echo -e "Image tagged as: ${YELLOW}${DEV_TAG}${NC}"
        echo ""
        echo "To run the image:"
        echo -e "  ${YELLOW}docker run -d -p 8080:8080 ${DEV_TAG}${NC}"
    else
        echo ""
        echo -e "${RED}✗ Dev build failed!${NC}"
        exit 1
    fi
    exit 0
fi

# Determine image tag
# Always include Python version suffix for clarity
if [[ -n "$CUSTOM_TAG" ]]; then
    IMAGE_TAG="$CUSTOM_TAG"
else
    IMAGE_TAG="${REGISTRY}/${IMAGE_NAME}:${NAUTOBOT_VER}-py${PYTHON_VER}"
fi

# Determine BASE_TAG (use NAUTOBOT_VER unless it's stable/latest)
if [[ "$NAUTOBOT_VER" == "stable" ]] || [[ "$NAUTOBOT_VER" == "latest" ]]; then
    BASE_TAG="$NAUTOBOT_VER"
else
    BASE_TAG="$NAUTOBOT_VER"
fi

# Get requirements file for display
REQ_FILE=$(get_requirements_file "$NAUTOBOT_VER")

# Print build information
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Building Nautobot Docker Image${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Nautobot Version: ${YELLOW}${NAUTOBOT_VER}${NC}"
echo -e "Python Version:   ${YELLOW}${PYTHON_VER}${NC}"
echo -e "Base Tag:         ${YELLOW}${BASE_TAG}${NC}"
echo -e "Requirements:     ${YELLOW}${REQ_FILE}${NC}"
echo -e "Image Tag:        ${YELLOW}${IMAGE_TAG}${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Build the image
echo -e "${GREEN}Starting build...${NC}"
docker build \
    --build-arg BASE_TAG="${BASE_TAG}" \
    --build-arg NAUTOBOT_VER="${NAUTOBOT_VER}" \
    --build-arg PYTHON_VER="${PYTHON_VER}" \
    -t "${IMAGE_TAG}" \
    .

if [[ $? -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}✓ Build successful!${NC}"
    echo -e "Image tagged as: ${YELLOW}${IMAGE_TAG}${NC}"
    echo ""
    echo "To run the image:"
    echo -e "  ${YELLOW}docker run -d -p 8080:8080 ${IMAGE_TAG}${NC}"
else
    echo ""
    echo -e "${RED}✗ Build failed!${NC}"
    exit 1
fi

