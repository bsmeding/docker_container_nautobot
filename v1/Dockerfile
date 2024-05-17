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

# ---------------------------------
# Stage: Builder
# ---------------------------------
FROM base as builder

RUN apt-get install -y gcc && \
    apt-get autoremove -y && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# Setup pip
RUN pip3 install --upgrade pip wheel

#django-auth-ldap
# RUN pip3 install django-auth-ldap cd

# Check extra pip packages to install for working in jobs
RUN pip3 install --upgrade nautobot[napalm]
RUN pip3 install --upgrade nautobot[sso]==${NAUTOBOT_VER}
RUN pip3 install --upgrade nautobot[ldap]==${NAUTOBOT_VER}
RUN pip3 install --upgrade social-auth-core[openidconnect]
RUN pip3 install --upgrade pandas
RUN pip3 install --upgrade xlrd
RUN pip3 install --upgrade openpyxl
RUN pip3 install --upgrade fuzzywuzzy
RUN pip3 install --upgrade python-Levenshtein
RUN pip3 install --upgrade hier-config
RUN pip3 install --upgrade pyntc
RUN pip3 install --upgrade pyats
RUN pip3 install --upgrade nautobot-ssot==1.6.4
RUN pip3 install --upgrade napalm-panos

# Add / update Ansible
RUN pip3 install --upgrade ansible-core==2.15.5

# Check Ansible collections
RUN ansible-galaxy collection install ansible.netcommon
RUN ansible-galaxy collection install ansible.utils

# Check Nautobot plugins
RUN pip3 install --upgrade nornir-nautobot
RUN pip3 install --no-warn-script-location nautobot-ssot==1.6.4
RUN pip3 install --no-warn-script-location nautobot-plugin-nornir==1.0.5
RUN pip3 install --no-warn-script-location nautobot-golden-config==1.6.5
RUN pip3 install --no-warn-script-location nautobot-device-lifecycle-mgmt==1.6.1


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