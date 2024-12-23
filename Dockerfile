# Define dynamic arguments
ARG NAUTOBOT_VER=2.3.15
ARG PYTHON_VER=3.11

# ---------------------------------
# Stage: PreRequistics
# ---------------------------------
FROM networktocode/nautobot:${NAUTOBOT_VER}-py${PYTHON_VER} as base
ARG NAUTOBOT_VER

USER 0
RUN apt-get update -y && apt-get install -y libldap2-dev libsasl2-dev libssl-dev

# Root install SAML dependencies # Removed llibxmlsec1-dev 17-09-23
RUN apt-get update -y && apt-get install -y libxmlsec1-openssl pkg-config

# Install network tools used by Jobs
# RUN apt-get update -y && apt-get install -y net-tools iputils-ping  dnsutils

# ---------------------------------
# Stage: Builder
# ---------------------------------
FROM base as builder
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


# Install Nautobot external authentication providers
RUN pip3 install --upgrade --no-warn-script-location social-auth-core[openidconnect]
RUN pip3 install --upgrade --no-warn-script-location social-auth-core[saml]
RUN pip3 install --upgrade --no-warn-script-location social-auth-core[azuread]
RUN pip3 install --upgrade --no-warn-script-location social-auth-core[google]

# Install custom packages used in Jobs
# RUN pip3 install --upgrade --no-warn-script-location napalm
RUN pip3 install --upgrade --no-warn-script-location pandas
RUN pip3 install --upgrade --no-warn-script-location xlrd
RUN pip3 install --upgrade --no-warn-script-location openpyxl
RUN pip3 install --upgrade --no-warn-script-location fuzzywuzzy
RUN pip3 install --upgrade --no-warn-script-location python-Levenshtein
RUN pip3 install --upgrade --no-warn-script-location hier-config
RUN pip3 install --upgrade --no-warn-script-location pyntc
RUN pip3 install --upgrade --no-warn-script-location pyats
RUN pip3 install --upgrade --no-warn-script-location scrapli scrapli[ssh2]
RUN pip3 install --upgrade --no-warn-script-location pysnmp

# Install Ansible core
RUN pip3 install --upgrade --no-warn-script-location ansible-core

# Check Ansible collections
RUN ansible-galaxy collection install ansible.netcommon
RUN ansible-galaxy collection install ansible.utils


RUN echo "NAUTOBOT_VER=$NAUTOBOT_VER"
# Copy the requirements files

COPY requirements-1.x.txt requirements-2.x.txt /opt/nautobot/
# Use the main version for conditional operations
# Install dependencies based on the Nautobot version
RUN pip3 install --upgrade pip --root-user-action=ignore && \
    bash -c ' \
    if [[ "$NAUTOBOT_VER" == 1.* ]]; then \
        pip3 install -r /opt/nautobot/requirements-1.x.txt; \
    elif [[ "$NAUTOBOT_VER" == 2.* ]] || [[ "${NAUTOBOT_VER}" = "stable" ]] || [[ "${NAUTOBOT_VER}" = "latest" ]]; then \
        pip3 install -r /opt/nautobot/requirements-2.x.txt; \
    else \
        echo "Unsupported Nautobot version"; \
        exit 1; \
    fi'

# ---------------------------------
# Stage: Final
# ---------------------------------
FROM base as final
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
RUN pyuwsgi --cflags | sed 's/ /\n/g' | grep -e "^-DUWSGI_SSL$"

# Switch back to the Nautobot user
USER nautobot

# Set working directory
WORKDIR /opt/nautobot

# Start Nautobot
CMD ["pyuwsgi", "--http", ":8080", "--module", "nautobot.core.wsgi", "--enable-threads", "--master", "--static-map", "/static=/opt/nautobot/static"]