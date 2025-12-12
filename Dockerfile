# Accept upstream tag + python version
ARG BASE_TAG=stable
ARG PYTHON_VER=3.12
ARG TARGETPLATFORM
ARG BUILDPLATFORM

# ---------------------------------
# Stage: Get upstream image
# ---------------------------------

FROM --platform=$TARGETPLATFORM networktocode/nautobot:${BASE_TAG}-py${PYTHON_VER} AS base
ARG BASE_TAG
ARG PYTHON_VER

USER 0
# Build deps for lxml/xmlsec (needed because of --no-binary=lxml,xmlsec)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      build-essential \
      python3-dev \
      libxml2-dev \
      libxslt1-dev \
      zlib1g-dev \
      libxmlsec1-dev \
      libxmlsec1-openssl \
      pkg-config \
      libffi-dev \
      libldap2-dev \
      libsasl2-dev \
      libssl-dev \
      net-tools \
      iputils-ping \
      dnsutils; \
    rm -rf /var/lib/apt/lists/*

# Make sure we have recent packaging tools (important on py3.12)
RUN pip3 install --upgrade pip setuptools wheel

# ---------------------------------
# Stage: Builder
# ---------------------------------
FROM base AS builder
# Define ARGs
ARG DEFAULT_NAUTOBOT_VER=2.3.15
ARG NAUTOBOT_VER=${DEFAULT_NAUTOBOT_VER}

RUN apt-get install -y gcc && \
    apt-get autoremove -y && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# Install pip and Nautobot dependencies
RUN pip3 install --upgrade pip setuptools wheel


# Install extra nautobot packages
# Set a default version if NAUTOBOT_VER is not provided
RUN if [ "${NAUTOBOT_VER}" = "latest" ] || [ "${NAUTOBOT_VER}" = "stable" ]; then \
        echo "Using unpinned Nautobot version: ${NAUTOBOT_VER}" && \
        pip3 install --upgrade --no-warn-script-location nautobot[napalm] && \
        pip3 install --upgrade --no-warn-script-location nautobot[ldap] && \
        pip3 install --upgrade --no-warn-script-location --no-binary=lxml,xmlsec nautobot[sso] && \
        pip3 install --upgrade --no-warn-script-location nornir-nautobot; \
    else \
        echo "Using pinned Nautobot version: ${NAUTOBOT_VER}" && \
        pip3 install --upgrade --no-warn-script-location nautobot[napalm]==${NAUTOBOT_VER} && \
        pip3 install --upgrade --no-warn-script-location nautobot[ldap]==${NAUTOBOT_VER} && \
        pip3 install --upgrade --no-warn-script-location --no-binary=lxml,xmlsec "nautobot[sso]==${NAUTOBOT_VER}" && \
        pip3 install --upgrade --no-warn-script-location nornir-nautobot; \
    fi


# Copy extra pip packages
COPY requirements-extra.txt /opt/nautobot/
RUN pip3 install --upgrade --no-warn-script-location -r /opt/nautobot/requirements-extra.txt
    

# Check Ansible collections
RUN ansible-galaxy collection install ansible.netcommon
RUN ansible-galaxy collection install ansible.utils


RUN echo "NAUTOBOT_VER=$NAUTOBOT_VER"
# Copy the requirements files

COPY requirements-1.x.txt requirements-2.x.txt requirements-3.x.txt /opt/nautobot/
# Use the main version for conditional operations
# Install dependencies based on the Nautobot version
RUN pip3 install --upgrade pip --root-user-action=ignore && \
    bash -c ' \
    if [[ "$NAUTOBOT_VER" == 1.* ]]; then \
        pip3 install -r /opt/nautobot/requirements-1.x.txt; \
    elif [[ "$NAUTOBOT_VER" == 2.* ]] || [[ "${NAUTOBOT_VER}" = "stable" ]] || [[ "${NAUTOBOT_VER}" = "latest" ]]; then \
        pip3 install -r /opt/nautobot/requirements-2.x.txt; \
    elif [[ "$NAUTOBOT_VER" == 3.* ]]; then \
        pip3 install -r /opt/nautobot/requirements-3.x.txt; \
    else \
        echo "Unsupported Nautobot version"; \
        exit 1; \
    fi'

# ---------------------------------
# Stage: Final
# ---------------------------------
FROM base AS final
ARG PYTHON_VER
USER 0

# Copy installed packages from builder
COPY --from=builder /usr/local/lib/python${PYTHON_VER}/site-packages /usr/local/lib/python${PYTHON_VER}/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy entry script - create config if not already present
COPY init-config.sh /usr/local/bin/init-config.sh
RUN chmod +x /usr/local/bin/init-config.sh

# Execute python uwsgi
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN if command -v pyuwsgi >/dev/null 2>&1; then \
      if pyuwsgi --cflags 2>/dev/null | tr ' ' '\n' | grep -q -- '^-DUWSGI_SSL$'; then \
        echo 'uWSGI built with SSL'; \
      else \
        echo 'WARNING: uWSGI not built with SSL'; \
      fi; \
    else \
      echo 'WARNING: pyuwsgi not found in PATH'; \
    fi

# Switch back to the Nautobot user
USER nautobot

# Set working directory
WORKDIR /opt/nautobot

# Start Nautobot
CMD ["pyuwsgi", "--http", ":8080", "--module", "nautobot.core.wsgi", "--enable-threads", "--master", "--static-map", "/static=/opt/nautobot/static"]