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

| Plugins for Nautobot 1.x               | Plugins for Nautobot 2.x               | Plugins for Nautobot 3.x               |
|----------------------------------------|----------------------------------------|----------------------------------------|
| nautobot-plugin-nornir>=1.0.0          | nautobot-plugin-nornir==2.3.0          | nautobot-plugin-nornir==3.0.0          |
| nautobot-device-lifecycle-mgmt==1.6.1  | nautobot-device-lifecycle-mgmt==3.2.0  | nautobot-device-lifecycle-mgmt==4.0.0  |
|                                        | nautobot-ssot[all]==3.11.0             | nautobot-ssot[all]==4.0.0              |
| nautobot-bgp-models==1.0.0             | nautobot-bgp-models==2.3.2             | nautobot-bgp-models==3.0.0             |
| nautobot-device-onboarding==1.2.0      | nautobot-device-onboarding==4.4.0      | nautobot-device-onboarding==5.0.0      |
| nautobot-data-validation-engine==2.2.0 | nautobot-data-validation-engine==3.4.0 |                                        |
| nautobot-golden-config==1.6.4          | nautobot-golden-config==2.6.0          | nautobot-golden-config==3.0.0          |
| nautobot-floor-plan==1.0.0             | nautobot-floor-plan==2.9.0             | nautobot-floor-plan==3.0.0             |
| nautobot-firewall-models==1.2.1        | nautobot-firewall-models==2.4.0        | nautobot-firewall-models==3.0.0        |
|                                        |                                        | nautobot-chatops==4.0.0                |
| nautobot-ui-plugin==0.10.4             | nautobot-ui-plugin==1.0.0              |                                        |
| nautobot-design-builder==1.4.1         | nautobot-design-builder==2.3.0         | nautobot-design-builder==3.0.0          |
| nautobot-secrets-providers[all]==1.4.2 | nautobot-secrets-providers==3.2.0      | nautobot-secrets-providers==4.0.0      |


**Notes:**
- `nautobot-chatops` is removed in 1.x and 2.x due to dependency conflicts with other plugins. Available in 3.x (==4.0.0).
- `nautobot-ssot[all]` is removed from 1.x because of dependency conflicts. Available in 2.x and 3.x.
- `nautobot-data-validation-engine` is not available for 3.x (latest version 3.4.0 requires Nautobot <3.0.0).
- `nautobot-ui-plugin` is not included in 3.x requirements (commented out in requirements-3.x.txt).


# Building the Image

## Quick Build (Recommended)

Use the provided build script for easy building of any version:

```bash
# Build Nautobot 3.0.2 (default Python 3.12)
./build.sh 3.0.2

# Build Nautobot 2.4.19 with Python 3.11
./build.sh -p 3.11 2.4.19

# Build Nautobot 1.6.32
./build.sh 1.6.32

# List available versions
./build.sh --list
```

## Using Makefile

Alternatively, use the Makefile for even simpler commands:

```bash
# Build Nautobot 3.0.2
make build VERSION=3.0.2

# Build with specific Python version
make build-3x VERSION=3.0.2 PYTHON_VER=3.11

# Build Nautobot 2.x
make build-2x VERSION=2.4.19

# Build Nautobot 1.x
make build-1x VERSION=1.6.32

# Show help
make help
```

## Manual Docker Build

For manual builds, use docker build with the appropriate arguments:

```bash
# Build Nautobot 3.x
docker build \
  --build-arg BASE_TAG=3.0.2 \
  --build-arg NAUTOBOT_VER=3.0.2 \
  --build-arg PYTHON_VER=3.12 \
  -t bsmeding/nautobot:3.0.2 \
  .

# Build Nautobot 2.x
docker build \
  --build-arg BASE_TAG=2.4.19 \
  --build-arg NAUTOBOT_VER=2.4.19 \
  --build-arg PYTHON_VER=3.12 \
  -t bsmeding/nautobot:2.4.19 \
  .
```

The Dockerfile automatically selects the correct requirements file based on the `NAUTOBOT_VER`:
- `1.*` → uses `requirements-1.x.txt`
- `2.*`, `stable`, `latest` → uses `requirements-2.x.txt`
- `3.*` → uses `requirements-3.x.txt`

# Docker-compose
To setup a working environment in Docker including database and redis, see an example of [docker-compose.yml for Nautobot here](https://gist.github.com/bsmeding/d60cf4f23519c75ca2339148d6efd7fe)

# More flexibility needed?
If you need more flexibility, please take a look at my Ansible role to deploy Nautobot on Docker![here](https://github.com/bsmeding/ansible_role_nautobot_docker) or via [Ansible Galaxy](https://galaxy.ansible.com/ui/standalone/roles/bsmeding/nautobot_docker/)