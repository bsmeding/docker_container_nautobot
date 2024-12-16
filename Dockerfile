# Set base image
ARG BASE_IMAGE

# Define build arguments
ARG NB_MAIN_VER
ARG PYTHON_VER=3.11 # Default Python version

# ---------------------------------
# Stage: PreRequisites
# ---------------------------------
FROM ${BASE_IMAGE} as base
USER 0

RUN apt-get update -y && apt-get install -y libldap2-dev libsasl2-dev libssl-dev

# Root install SAML dependencies
RUN apt-get update -y && apt-get install -y libxmlsec1-openssl pkg-config

# Install network tools used by Jobs
RUN apt-get update -y && apt-get install -y net-tools iputils-ping dnsutils

# Extract Python version if "py" is in the base image tag
RUN if echo "$BASE_IMAGE" | grep -q 'py'; then \
        PYTHON_VER=$(echo "$BASE_IMAGE" | grep -o 'py[0-9]\+\.[0-9]\+' | sed 's/py//'); \
        echo "Detected Python version: $PYTHON_VER"; \
    else \
        echo "No Python version specified. Defaulting to: $PYTHON_VER"; \
    fi && \
    echo "PYTHON_VER=$PYTHON_VER" > /python_version.env

# ---------------------------------
# Stage: Builder
# ---------------------------------
FROM base as builder

# Load the extracted PYTHON_VER
COPY --from=base /python_version.env /python_version.env
RUN export $(cat /python_version.env) && echo "Using Python version: $PYTHON_VER"

# Install dependencies and clean APT cache
RUN apt-get install -y gcc && \
    apt-get autoremove -y && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# Install pip and Nautobot dependencies
RUN pip3 install --upgrade pip setuptools wheel

# Verify the Python path and dependencies
RUN export $(cat /python_version.env) && \
    echo "Verifying Python path: /usr/local/lib/python${PYTHON_VER}/site-packages" && \
    ls -l /usr/local/lib/python${PYTHON_VER}/site-packages || echo "Path not found!"

# ---------------------------------
# Stage: Final
# ---------------------------------
FROM base as final
USER 0

# Load the extracted PYTHON_VER
COPY --from=base /python_version.env /python_version.env
RUN export $(cat /python_version.env) && echo "Using Python version in final stage: $PYTHON_VER"

# Copy dependencies from the builder stage
COPY --from=builder /usr/local/lib/python${PYTHON_VER}/site-packages /usr/local/lib/python${PYTHON_VER}/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

USER nautobot
WORKDIR /opt/nautobot
