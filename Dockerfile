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

# Extract Python version dynamically if "py" is in the base image tag
RUN if echo "${BASE_IMAGE}" | grep -q 'py'; then \
        echo "Detected Python version based on BASE_IMAGE"; \
        echo $(echo "${BASE_IMAGE}" | grep -o 'py[0-9]\+\.[0-9]\+' | sed 's/py//') > /python_version.env; \
    else \
        echo "Defaulting to Python version: ${PYTHON_VER}"; \
        echo ${PYTHON_VER} > /python_version.env; \
    fi

# Debug: Show extracted Python version
RUN echo "PYTHON_VER=$(cat /python_version.env)" && cat /python_version.env

# ---------------------------------
# Stage: Final
# ---------------------------------
FROM base as final

USER 0

# Copy extracted Python version
COPY --from=base /python_version.env /python_version.env

# Load and use Python version in the final stage
RUN export PYTHON_VER=$(cat /python_version.env) && \
    echo "Using Python version in final stage: $PYTHON_VER"
