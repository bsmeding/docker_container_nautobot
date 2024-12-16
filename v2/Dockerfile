ARG PYTHON_VER
ARG NAUTOBOT_VER
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
RUN pip3 install --upgrade --no-warn-script-location nautobot-ssot==${NAUTOBOT_VER}
RUN pip3 install --upgrade --no-warn-script-location nautobot-plugin-nornir==${NAUTOBOT_VER}
RUN pip3 install --upgrade --no-warn-script-location nautobot-golden-config==${NAUTOBOT_VER}
RUN pip3 install --upgrade --no-warn-script-location nautobot-device-lifecycle-mgmt==${NAUTOBOT_VER}


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