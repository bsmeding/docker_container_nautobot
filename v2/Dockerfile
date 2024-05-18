ARG PYTHON_VER
ARG NAUTOBOT_VER
# ---------------------------------
# Stage: PreRequistics
# ---------------------------------
FROM networktocode/${NAUTOBOT_VER}-py${PYTHON_VER} as base
USER 0
RUN apt-get update -y && apt-get install -y libldap2-dev libsasl2-dev libssl-dev

# Root install SAML dependencies # Removed llibxmlsec1-dev 17-09-23
RUN apt-get update -y && apt-get install -y libxmlsec1-openssl pkg-config

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
RUN pip3 install --upgrade --no-warn-script-location ansible-core==2.16.15

# Check extra pip packages to install
RUN pip3 install --upgrade --no-warn-script-location nautobot[napalm]==${NAUTOBOT_VER}
RUN pip3 install --upgrade --no-warn-script-location nautobot[sso]==${NAUTOBOT_VER}
RUN pip3 install --upgrade --no-warn-script-location social-auth-core[openidconnect]==${NAUTOBOT_VER}


# Check Ansible collections
RUN ansible-galaxy collection install ansible.netcommon
RUN ansible-galaxy collection install ansible.utils

# Check Nautobot plugins
RUN pip3 install --upgrade --no-warn-script-location nornir-nautobot
RUN pip3 install --upgrade --no-warn-script-location nautobot-ssot==2.6.1
RUN pip3 install --upgrade --no-warn-script-location nautobot-plugin-nornir==2.0.1
RUN pip3 install --upgrade --no-warn-script-location nautobot-golden-config==2.0.4
RUN pip3 install --upgrade --no-warn-script-location nautobot-device-lifecycle-mgmt==2.1.1


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