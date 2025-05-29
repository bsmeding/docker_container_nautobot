# Nautobot Docker Installation with Ansible

![Nautobot Logo](https://raw.githubusercontent.com/nautobot/nautobot/develop/nautobot/docs/nautobot_logo.svg)


# docker_container_nautobot
Nautobot docker container including other networking tools

Only the latest major versions for 1.x and 2 latest for 2.x will be maintained! So `currently` 1.6.x and 2.3.x and 2.4.x

Note that of may 2025 the versions with Python 3.9 are discontinued, this because of added plugins / nautobot apps! 
Please use higher versions.

## OS packages
* net-tools 
* iputils-ping  
* dnsutils

## PIP Packages
* ansible-core
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
* pan-os-python


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
* [nautobot-chatops](https://docs.nautobot.com/projects/chatops/en/latest/)
* [nautobot-secrets-providers](https://docs.nautobot.com/projects/secrets-providers/en/latest/)
* [nautobot-design-builder](https://docs.nautobot.com/projects/design-builder/en/latest/)

| Plugins for Nautobot 1.x               | Plugins for Nautobot 2.x               |
|----------------------------------------|----------------------------------------|
| nautobot-plugin-nornir==1.0.5          | nautobot-plugin-nornir==3.3.1          |
| nautobot-device-lifecycle-mgmt==1.6.1  | nautobot-device-lifecycle-mgmt==3.1.0  |
| nautobot-ssot[all]==1.6.5              | nautobot-ssot[all]==3.8.1              |
| nautobot-bgp-models==1.0.0             | nautobot-bgp-models==2.3.1             |
| nautobot-device-onboarding==1.2.0      | nautobot-device-onboarding==4.2.5      |
| nautobot-data-validation-engine==2.2.0 | nautobot-data-validation-engine==3.2.0 | 
| nautobot-golden-config==1.6.4          | nautobot-golden-config==2.2.1          | 
|                                        | nautobot-plugin-floorplan==0.7.0       | 
| nautobot-firewall-models==1.2.1        | nautobot-firewall-models==2.2.2        | 
| nautobot-chatops[all]==2.1.0           | nautobot-chatops[all]==3.1.1           | 
| nautobot-ui-plugin==0.10.4             | nautobot-ui-plugin==1.0.0              | 
| nautobot-design-builder==1.4.1         | nautobot-design-builder==2.2.0         | 
| nautobot-secrets-providers[all]==1.4.2 | nautobot-secrets-providers[all]==3.2.0 |











# Docker-compose
To setup a working environment in Docker including database and redis, see an example of [docker-compose.yml for Nautobot here](https://gist.github.com/bsmeding/d60cf4f23519c75ca2339148d6efd7fe)

# More flexibility needed?
If you need more flexibility, please take a look at my Ansible role to deploy Nautobot on Docker![here](https://github.com/bsmeding/ansible_role_nautobot_docker) or via [Ansible Galaxy](https://galaxy.ansible.com/ui/standalone/roles/bsmeding/nautobot_docker/)