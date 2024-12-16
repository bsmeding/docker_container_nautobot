# Set base image
ARG BASE_IMAGE

# Define build arguments
ARG NB_MAIN_VER
ARG PYTHON_VER=3.11

# ---------------------------------
# Stage: PreRequistics
# ---------------------------------
FROM networktocode/${BASE_IMAGE} as base
USER 0
RUN apt-get update -y && apt-get install -y libldap2-dev libsasl2-dev libssl-dev

# Root install SAML dependencies # Removed llibxmlsec1-dev 17-09-23
RUN apt-get update -y && apt-get install -y libxmlsec1-openssl pkg-config

# Install network tools used by Jobs
RUN apt-get update -y && apt-get install -y net-tools iputils-ping  dnsutils

# ---------------------------------
# Stage: Builder
# ---------------------------------
FROM base as builder

RUN apt-get install -y gcc && \
    apt-get autoremove -y && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# Install pip and Nautobot dependencies
RUN pip3 install --upgrade pip setuptools wheel


# Install extra nautobot packages
RUN pip3 install --upgrade --no-warn-script-location nautobot[napalm]
RUN pip3 install --upgrade --no-warn-script-location nautobot[sso]
RUN pip3 install --upgrade --no-warn-script-location nautobot[ldap]
RUN pip3 install --upgrade --no-warn-script-location social-auth-core[openidconnect]
# Need to install napalm 4.0.0 to avoid conflicts with napalm-panos
RUN pip3 install --upgrade --no-warn-script-location napalm==4.0.0
RUN pip3 install --upgrade --no-warn-script-location pandas
RUN pip3 install --upgrade --no-warn-script-location xlrd
RUN pip3 install --upgrade --no-warn-script-location openpyxl
RUN pip3 install --upgrade --no-warn-script-location fuzzywuzzy
RUN pip3 install --upgrade --no-warn-script-location python-Levenshtein
RUN pip3 install --upgrade --no-warn-script-location hier-config
RUN pip3 install --upgrade --no-warn-script-location pyntc
RUN pip3 install --upgrade --no-warn-script-location pyats
# RUN pip3 install --upgrade --no-warn-script-location napalm-panos

# Install latest version of Ansible
RUN pip3 install --upgrade --no-warn-script-location ansible

# Check Ansible collections
RUN ansible-galaxy collection install ansible.netcommon
RUN ansible-galaxy collection install ansible.utils

# Check Nautobot plugins
RUN pip3 install --upgrade --no-warn-script-location nornir-nautobot
# Conditionally install plugins and dependencies based on NB_MAIN_VER
# RUN if [ "$NB_MAIN_VER" = "v2" ]; then \
#         pip3 install --upgrade --no-warn-script-location \
#         nautobot-ssot==3.3.0 \
#         nautobot-ssot[all] \
#         nautobot-bgp-models==2.3.0 \
#         nautobot-plugin-nornir==2.1.0 \
#         nautobot-golden-config==2.2.1 \
#         nautobot-device-lifecycle-mgmt==2.2.0 \
#         nautobot-device-onboarding==4.1.0 \
#         nautobot-data-validation-engine==3.2.0 \
#         nautobot-plugin-floorplan==2.4.0; \
#     else \
#         pip3 install --upgrade --no-warn-script-location \
#         nautobot-ssot==1.6.4 \
#         nautobot-ssot[all] \
#         nautobot-bgp-models==1.0.0 \
#         nautobot-plugin-nornir==1.0.5 \
#         nautobot-golden-config==1.6.4 \
#         nautobot-device-lifecycle-mgmt==1.6.1 \
#         nautobot-device-onboarding==1.2.0 \
#         nautobot-data-validation-engine==2.2.0 \
#         nautobot-plugin-floorplan==1.0.0; \
#     fi

# ---------------------------------
# Stage: Final
# ---------------------------------
FROM base as final
ARG PYTHON_VER
USER 0

COPY --from=builder /usr/local/lib/python${PYTHON_VER}/site-packages /usr/local/lib/python${PYTHON_VER}/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
USER nautobot

WORKDIR /opt/nautobot