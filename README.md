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

## Nautobot plugins
* nornir-nautobot
* nautobot-ssot
* nautobot-plugin-nornir
* nautobot-golden-config
* nautobot-device-lifecycle-mgmt

# More flexibility needed?
If you need more flexibility, please take a look at my Ansible role to deploy Nautobot on Docker![here](https://github.com/bsmeding/ansible_role_nautobot_docker) or via [Ansible Galaxy](https://galaxy.ansible.com/ui/standalone/roles/bsmeding/nautobot_docker/)