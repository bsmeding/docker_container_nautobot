ARG PYTHON_VER=3.9
ARG NAUTOBOT_IMAGE=nautobot:latest
# ---------------------------------
# Stage: PreRequistics
# ---------------------------------
FROM networktocode/${NAUTOBOT_IMAGE}-py${PYTHON_VER} as base
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

RUN pip3 install --upgrade pip wheel && pip3 install django-auth-ldap
RUN pip3 install --upgrade ansible==8.2.0

# Check extra pip packages to install
RUN pip3 install --upgrade nautobot[napalm]
RUN pip3 install --upgrade nautobot[sso]
RUN pip3 install --upgrade social-auth-core[openidconnect]


# Check Ansible collections
RUN ansible-galaxy collection install ansible.netcommon
RUN ansible-galaxy collection install ansible.utils

# Check Nautobot plugins
RUN pip3 install --upgrade nornir-nautobot
RUN pip3 install --no-warn-script-location nautobot-ssot==2.5.0
RUN pip3 install --no-warn-script-location nautobot-plugin-nornir==2.0.1
RUN pip3 install --no-warn-script-location nautobot-golden-config==2.0.3
RUN pip3 install --no-warn-script-location nautobot-device-lifecycle-mgmt==2.0.1


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