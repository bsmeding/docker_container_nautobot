ARG PYTHON_VER
ARG NAUTOBOT_VER
ARG NB_MAIN_VER='v2'
# ---------------------------------
# Stage: PreRequistics
# ---------------------------------
FROM networktocode/nautobot:${NAUTOBOT_VER}-py${PYTHON_VER} as base
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

RUN pip3 install --upgrade pip wheel


#Ansible core
RUN pip3 install --upgrade --no-warn-script-location ansible-core==2.15.11

# Check extra pip packages to install
RUN pip3 install --upgrade --no-warn-script-location nautobot[napalm]
RUN pip3 install --upgrade --no-warn-script-location nautobot[sso]
RUN pip3 install --upgrade --no-warn-script-location social-auth-core[openidconnect]


# Check Ansible collections
RUN ansible-galaxy collection install ansible.netcommon
RUN ansible-galaxy collection install ansible.utils

# Check Nautobot plugins
RUN pip3 install --upgrade --no-warn-script-location nornir-nautobot
RUN if [ "$NB_MAIN_VER" = "v2" ]; then \
        pip3 install --upgrade --no-warn-script-location \
        nautobot-ssot==3.3.0 \
        nautobot-ssot[all] \
        nautobot-bgp-models==2.3.0 \
        nautobot-plugin-nornir==2.1.0 \
        nautobot-golden-config==2.2.1 \
        nautobot-device-lifecycle-mgmt==2.2.0 \
        nautobot-device-onboarding==4.1.0 \
        nautobot-data-validation-engine==3.2.0 \
        nautobot-plugin-floorplan==2.4.0; \
    else \
        pip3 install --upgrade --no-warn-script-location \
        nautobot-ssot==1.6.4 \
        nautobot-ssot[all] \
        nautobot-bgp-models==1.0.0 \
        nautobot-plugin-nornir==1.0.5 \
        nautobot-golden-config==1.6.4 \
        nautobot-device-lifecycle-mgmt==1.6.1 \
        nautobot-device-onboarding==1.2.0 \
        nautobot-data-validation-engine==2.2.0 \
        nautobot-plugin-floorplan==1.0.0; \
    fi

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