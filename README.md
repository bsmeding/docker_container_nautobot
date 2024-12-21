# Nautobot Docker Installation with Ansible

![Nautobot Logo](https://raw.githubusercontent.com/nautobot/nautobot/develop/nautobot/docs/nautobot_logo.svg)


# docker_container_nautobot
Nautobot docker container including other networking tools

## OS packages
* net-tools 
* iputils-ping  
* dnsutils

## PIP Packages
* ansible-core==2.15.11
* nautobot[napalm]
* nautobot[sso]
* social-auth-core[openidconnect]
* social-auth-core[saml]
* social-auth-core[azuread]
* social-auth-core[google]

# Install custom packages used in Jobs
* pandas
* xlrd
* openpyxl
* fuzzywuzzy
* python-Levenshtein
* hier-config
* pyntc
* pyats
* scrapli scrapli[ssh2]
* pysnmp


## Nautobot plugins
* nornir-nautobot
* [nautobot-ssot](https://docs.nautobot.com/projects/ssot/en/latest/)
* [nautobot-plugin-nornir](https://docs.nautobot.com/projects/plugin-nornir/en/latest/)
* [nautobot-golden-config](https://docs.nautobot.com/projects/golden-config/en/latest/)
* [nautobot-device-lifecycle-mgmt](https://docs.nautobot.com/projects/device-lifecycle/en/latest/)
* [nautobot-bgp-models](https://docs.nautobot.com/projects/bgp-models/en/latest/)
* [nautobot-device-onboarding](https://docs.nautobot.com/projects/device-onboarding/en/latest/)
* [nautobot-data-validation-engine]()
* [nautobot-plugin-floorplan](https://docs.nautobot.com/projects/floor-plan/en/latest/)
* [nautobot-firewall-models](https://docs.nautobot.com/projects/firewall-models/en/latest/)
* [todo: chatops](https://docs.nautobot.com/projects/chatops/en/latest/)


# Docker-compose
To setup a working environment in Docker including database and redis, see an example of [docker-compose.yml for Nautobot here](https://gist.github.com/bsmeding/d60cf4f23519c75ca2339148d6efd7fe)

# More flexibility needed?
If you need more flexibility, please take a look at my Ansible role to deploy Nautobot on Docker![here](https://github.com/bsmeding/ansible_role_nautobot_docker) or via [Ansible Galaxy](https://galaxy.ansible.com/ui/standalone/roles/bsmeding/nautobot_docker/)