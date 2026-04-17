# Nautobot Docker Installation with Ansible

![Nautobot Logo](https://raw.githubusercontent.com/nautobot/nautobot/develop/nautobot/docs/nautobot_logo.svg)


# docker_container_nautobot
Nautobot Docker image extended with networking tools, Ansible, job-oriented Python packages, and pinned Nautobot apps.

**Published on Docker Hub:** [bsmeding/nautobot](https://hub.docker.com/r/bsmeding/nautobot) (linux/amd64 and linux/arm64).

**Tags:** patch releases use **`x.y.z-py3.nn`** (Nautobot version plus Python), for example `3.1.0-py3.12`, `2.4.31-py3.12`, `1.6.32-py3.11`. For each minor line (e.g. **3.1**), a floating tag like **`3.1-py3.12`** is published for the newest patch on the highest Python in that series (for **1.6**, the floating tag uses **3.11** as the highest Python in the matrix). Upstream-tracking **`stable`** and **`latest`** are published **without** a `-py…` suffix (built with Python 3.12); the pre-installed **app bundle** on those tags matches the **2.x** line (see notes below)—use an explicit **`3.x.y-py3.nn`** tag when you want Nautobot 3 and its app pins.

As of **May 2025**, **Python 3.9** images are discontinued. Use **3.10+** in the tag (e.g. `-py3.12`).

## Pull the image

```bash
docker pull bsmeding/nautobot:3.1.0-py3.12
docker pull bsmeding/nautobot:2.4.31-py3.12
docker pull bsmeding/nautobot:stable
```

Browse all tags on [Docker Hub](https://hub.docker.com/r/bsmeding/nautobot/tags).

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

## Extra Python packages (jobs and automation)
See [`requirements-extra.txt`](requirements-extra.txt) for the full list (pandas, pyATS, scrapli, napalm drivers, netutils, Ansible collections installed in the Dockerfile, and more).

## Nautobot plugins
Which apps and versions ship in an image follow the **Nautobot major** in your tag (1.x, 2.x, or 3.x). **Not every app is on every major**—use the table and notes. Pin files in this repo (`requirements-1.x.txt`, `requirements-2.x.txt`, `requirements-3.x.txt`) are the source of truth if you need exact versions.

* nornir-nautobot
* [nautobot-ssot](https://docs.nautobot.com/projects/ssot/en/latest/)
* [nautobot-plugin-nornir](https://docs.nautobot.com/projects/plugin-nornir/en/latest/)
* [nautobot-golden-config](https://docs.nautobot.com/projects/golden-config/en/latest/)
* [nautobot-device-lifecycle-mgmt](https://docs.nautobot.com/projects/device-lifecycle/en/latest/)
* [nautobot-bgp-models](https://docs.nautobot.com/projects/bgp-models/en/latest/)
* [nautobot-device-onboarding](https://docs.nautobot.com/projects/device-onboarding/en/latest/)
* [nautobot-data-validation-engine](https://docs.nautobot.com/projects/data-validation/en/latest/)
* [nautobot-floor-plan](https://docs.nautobot.com/projects/floor-plan/en/latest/)
* [nautobot-firewall-models](https://docs.nautobot.com/projects/firewall-models/en/latest/)
* [nautobot-chatops](https://docs.nautobot.com/projects/chatops/en/latest/) (bundled on **3.x** only in this image; see notes)
* [nautobot-secrets-providers](https://docs.nautobot.com/projects/secrets-providers/en/latest/)
* [nautobot-design-builder](https://docs.nautobot.com/projects/design-builder/en/latest/)

| Plugins for Nautobot 1.x               | Plugins for Nautobot 2.x               | Plugins for Nautobot 3.x               |
|----------------------------------------|----------------------------------------|----------------------------------------|
| nautobot-plugin-nornir>=1.0.0          | nautobot-plugin-nornir==2.3.0          | nautobot-plugin-nornir==3.2.0          |
| nautobot-device-lifecycle-mgmt==1.6.1  | nautobot-device-lifecycle-mgmt==3.2.0  | nautobot-device-lifecycle-mgmt==4.1.1  |
|                                        | nautobot-ssot[all]==3.11.0             | nautobot-ssot[all]==4.2.2              |
| nautobot-bgp-models==1.0.0             | nautobot-bgp-models==2.3.2             | nautobot-bgp-models==3.1.1             |
| nautobot-device-onboarding==1.2.0      | nautobot-device-onboarding==4.4.0      | nautobot-device-onboarding==5.3.0      |
| nautobot-data-validation-engine==2.2.0 | nautobot-data-validation-engine==3.4.0 |                                        |
| nautobot-golden-config==1.6.4          | nautobot-golden-config==2.6.0          | nautobot-golden-config==3.0.5          |
| nautobot-floor-plan==1.0.0             | nautobot-floor-plan==2.9.0             | nautobot-floor-plan==3.0.1             |
| nautobot-firewall-models==1.2.1        | nautobot-firewall-models==2.4.0        | nautobot-firewall-models==3.0.0        |
|                                        |                                        | nautobot-chatops[slack,teams,webex,ansible,arista]==4.0.0 |
| nautobot-ui-plugin==0.10.4             | nautobot-ui-plugin==1.0.0              |                                        |
| nautobot-design-builder==1.4.1         | nautobot-design-builder==2.3.0         | nautobot-design-builder==3.0.0          |
| nautobot-secrets-providers[all]==1.4.2 | nautobot-secrets-providers[all]==3.2.0 | nautobot-secrets-providers[all]==4.0.1 |


**Notes:**
- `nautobot-chatops` is removed in 1.x and 2.x due to dependency conflicts with other plugins. It is installed on **3.x** as `nautobot-chatops[slack,teams,webex,ansible,arista]==4.0.0` (Grafana extra omitted—conflicts with diffsync).
- `nautobot-ssot[all]` is removed from 1.x because of dependency conflicts. Available in 2.x and 3.x.
- `nautobot-data-validation-engine` is not available for 3.x (the published 3.4.0 line still declares compatibility only with Nautobot versions below 3.0).
- `nautobot-ui-plugin` is not included in 3.x requirements (commented out in `requirements-3.x.txt`).
- **`stable` / `latest`:** these tags use the **2.x** app bundle (same plugins as a `2.*` image). For Nautobot **3.x** plugins and versions, **pull an explicit `3.x.y-py3.nn` tag**.

Nautobot **3.x** images also pin **GraphQL** dependencies (`graphene`, `graphql-relay`) to avoid resolver clashes—details are in [`requirements-3.x.txt`](requirements-3.x.txt) in this repository.

## Docker Compose
To set up a working environment in Docker including database and Redis, see this [example docker-compose.yml for Nautobot](https://gist.github.com/bsmeding/d60cf4f23519c75ca2339148d6efd7fe).

## More flexibility needed?
If you need more flexibility, use the Ansible role to deploy Nautobot on Docker: [ansible_role_nautobot_docker](https://github.com/bsmeding/ansible_role_nautobot_docker) on GitHub or [Ansible Galaxy](https://galaxy.ansible.com/ui/standalone/roles/bsmeding/nautobot_docker/).

## Building the image yourself
Maintainers and contributors can follow [buildinfo.md](buildinfo.md) for local `docker build`, `build.sh`, and Makefile usage.