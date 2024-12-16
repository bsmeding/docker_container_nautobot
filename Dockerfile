# Set base image
ARG BASE_IMAGE

# Define build arguments
ARG PYTHON_VER=3.11 # Default Python version

FROM ${BASE_IMAGE} as base

# Ensure we're running as root
USER 0

# Install basic dependencies for debugging
RUN apt-get update -y && apt-get install -y \
    libldap2-dev libsasl2-dev libssl-dev \
    libxmlsec1-openssl pkg-config \
    net-tools iputils-ping dnsutils && \
    apt-get clean

# Debug: Show BASE_IMAGE value
RUN echo "Base image: ${BASE_IMAGE}"

# Extract Python version dynamically if "py" is in the base image tag
RUN if echo "${BASE_IMAGE}" | grep -q 'py'; then \
        PYTHON_VER=$(echo "${BASE_IMAGE}" | grep -o 'py[0-9]\+\.[0-9]\+' | sed 's/py//'); \
        echo "Detected Python version: ${PYTHON_VER}"; \
    else \
        echo "No Python version specified. Defaulting to: ${PYTHON_VER}"; \
    fi && \
    echo "PYTHON_VER=${PYTHON_VER}" > /python_version.env

# Debug: Show extracted Python version
RUN cat /python_version.env

# ---------------------------------
# Stage: Builder
# ---------------------------------
FROM base as builder

# Copy extracted PYTHON_VER
COPY --from=base /python_version.env /python_version.env
RUN export $(cat /python_version.env) && echo "Using Python version: $PYTHON_VER"

# Debug: Check Python version path
RUN export $(cat /python_version.env) && \
    echo "Checking Python version path: /usr/local/lib/python${PYTHON_VER}/site-packages" && \
    ls -ld /usr/local/lib/python${PYTHON_VER}/site-packages || echo "Path not found!"

# ---------------------------------
# Stage: Final
# ---------------------------------
FROM base as final

USER 0

# Copy extracted Python version
COPY --from=base /python_version.env /python_version.env
RUN export $(cat /python_version.env) && echo "Using Python version in final stage: $PYTHON_VER"
