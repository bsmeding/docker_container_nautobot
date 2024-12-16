# Set base image
ARG BASE_IMAGE=networktocode/nautobot:latest # Default base image

FROM ${BASE_IMAGE} as base

# Define build arguments
ARG BASE_IMAGE
ARG PYTHON_VER=3.11 # Default Python version

# Extract Python version from BASE_IMAGE
RUN echo "Base image: ${BASE_IMAGE}" && \
    if echo "${BASE_IMAGE}" | grep -q 'py'; then \
        PYTHON_VER=$(echo "${BASE_IMAGE}" | grep -o 'py[0-9]\+\.[0-9]\+' | sed 's/py//'); \
        echo "Detected Python version: ${PYTHON_VER}"; \
    else \
        PYTHON_VER=3.11; \
        echo "No Python version specified. Defaulting to: ${PYTHON_VER}"; \
    fi && \
    echo "PYTHON_VER=${PYTHON_VER}" > /python_version.env

# Debug: Print the extracted Python version
RUN cat /python_version.env
