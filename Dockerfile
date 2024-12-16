# Set base image
ARG BASE_IMAGE

# Define build arguments
ARG NB_MAIN_VER
ARG PYTHON_VER=3.11 # Default Python version

# ---------------------------------
# Stage: PreRequisites
# ---------------------------------
FROM ${BASE_IMAGE} as base
USER 0 # Ensure root for apt-get commands

# Extract Python version if "py" is in the base image tag
ARG BASE_IMAGE
RUN if echo "${BASE_IMAGE}" | grep -q 'py'; then \
        PYTHON_VER=$(echo "${BASE_IMAGE}" | grep -o 'py[0-9]\+\.[0-9]\+' | sed 's/py//'); \
        echo "Detected Python version: $PYTHON_VER"; \
    else \
        PYTHON_VER=3.11; \
        echo "No Python version specified. Defaulting to: $PYTHON_VER"; \
    fi && \
    echo "PYTHON_VER=$PYTHON_VER" > /python_version.env

## ---------------------------------
# Stage: Builder
# ---------------------------------
FROM ${BASE_IMAGE} as builder
USER 0 # Ensure root for apt-get commands

# Load the extracted PYTHON_VER
COPY --from=base /python_version.env /python_version.env
RUN export $(cat /python_version.env) && echo "Using Python version: $PYTHON_VER"

# Install Python and dependencies
RUN apt-get update && apt-get install -y python${PYTHON_VER} python${PYTHON_VER}-dev && apt-get clean
