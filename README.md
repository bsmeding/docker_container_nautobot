# Nautobot Docker Image

![Nautobot Logo](https://raw.githubusercontent.com/nautobot/nautobot/develop/nautobot/docs/nautobot_logo.svg)

Building: ![Build](https://github.com/bsmeding/docker_container_nautobot/actions/workflows/build.yml/badge.svg)
Pulls: ![Docker Pulls](https://img.shields.io/docker/pulls/bsmeding/nautobot) 

# docker_container_nautobot
Nautobot Docker image extended with networking tools, Ansible, job-oriented Python packages, and pinned Nautobot apps.

**Published on Docker Hub:** [bsmeding/nautobot](https://hub.docker.com/r/bsmeding/nautobot) (linux/amd64 and linux/arm64).

**Tags:** patch releases use **`x.y.z-py3.nn`** (Nautobot version plus Python), for example `3.2.10-py3.12`, `3.2.10-py3.13`, `2.4.47-py3.12`. For each minor line (e.g. **3.2**), a floating tag like **`3.2-py3.12`** is published for the newest patch of that Python (also **`3.2-py3.13`** where upstream has it; **3.2** publishes 3.10–3.13 through 3.2.7; 3.2.8-py3.10 is skipped because nautobot-dns-models 3.0.0 needs Python >=3.11; 3.2.9+ are 3.11–3.13; **2.4** is 3.10–3.12 through 2.4.45, and 3.11–3.12 from 2.4.46; **1.6** uses **3.11** as its highest). Upstream-tracking **`stable`** and **`latest`** follow `networktocode/nautobot` of the same name (currently Nautobot **3.x**). The unsuffixed tags use Python **3.14**, matching upstream `stable`, `latest`, and `3.2`. **`stable-py3.13`** and **`latest-py3.13`** are also published. All of those install the **3.x** app bundle. Use an explicit **`2.x.y-py3.nn`** tag when you want the 2.x plugin pins.

**MCP flavor (`-mcp`):** same 3.x image plus [`nautobot-mcp`](https://pypi.org/project/nautobot-mcp/) from [`requirements-mcp.txt`](requirements-mcp.txt). Published as **`stable-mcp`**, **`latest-mcp`**, and the newest 3.x patch (**`3.2.10-py3.12-mcp`**, plus floating **`3.2-py3.12-mcp`**). Regular tags do **not** include this app. Enable it in Nautobot config (`PLUGINS` / `INSTALLED_APPS`) at runtime.

As of **May 2025**, **Python 3.9** images are discontinued. Use **3.10–3.13** (e.g. `-py3.12`). Nautobot **3.1** and **3.2** also publish **`-py3.13`**. **3.2** includes **`-py3.10`** through **3.2.7**. **3.2.8-py3.10** is not built (`nautobot-dns-models==3.0.0` needs Python >=3.11). **3.2.9** and later are **3.11–3.13** only. **2.4** stays on **3.10–3.12** through **2.4.45**; **2.4.46** and later are **3.11–3.12** only (upstream no longer publishes `-py3.10`). Unsuffixed **`stable`** and **`latest`** (and their `-mcp` tags) are Python **3.14**. Numbered 3.2 patch tags in this image are still **3.11–3.13**; upstream also publishes `-py3.14` for those patches.

## Pull the image

```bash
docker pull bsmeding/nautobot:3.1.0-py3.12
docker pull bsmeding/nautobot:2.4.31-py3.12
docker pull bsmeding/nautobot:stable
docker pull bsmeding/nautobot:stable-mcp
docker pull bsmeding/nautobot:3.2.10-py3.12-mcp
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
* [nautobot-dns-models](https://docs.nautobot.com/projects/dns-models/en/latest/) (bundled on **3.x** only in this image)

| Plugins for Nautobot 1.x               | Plugins for Nautobot 2.x               | Plugins for Nautobot 3.x               |
|----------------------------------------|----------------------------------------|----------------------------------------|
| nautobot-plugin-nornir>=1.0.0          | nautobot-plugin-nornir==2.3.0          | nautobot-plugin-nornir==3.4.0          |
| nautobot-device-lifecycle-mgmt==1.6.1  | nautobot-device-lifecycle-mgmt==3.2.0  | nautobot-device-lifecycle-mgmt==4.2.1  |
|                                        | nautobot-ssot[all]==3.11.0             | nautobot-ssot[all]==4.8.0              |
| nautobot-bgp-models==1.0.0             | nautobot-bgp-models==2.3.2             | nautobot-bgp-models==3.2.0             |
| nautobot-device-onboarding==1.2.0      | nautobot-device-onboarding==4.4.0      | nautobot-device-onboarding==5.6.0      |
| nautobot-data-validation-engine==2.2.0 | nautobot-data-validation-engine==3.4.0 |                                        |
| nautobot-golden-config==1.6.4          | nautobot-golden-config==2.6.0          | nautobot-golden-config==3.1.0          |
| nautobot-floor-plan==1.0.0             | nautobot-floor-plan==2.9.0             | nautobot-floor-plan==3.0.2             |
| nautobot-firewall-models==1.2.1        | nautobot-firewall-models==2.4.0        | nautobot-firewall-models==3.0.1        |
|                                        |                                        | nautobot-chatops[slack,teams,webex,ansible,arista]==4.1.0 |
| nautobot-ui-plugin==0.10.4             | nautobot-ui-plugin==1.0.0              |                                        |
| nautobot-design-builder==1.4.1         | nautobot-design-builder==2.3.0         | nautobot-design-builder==3.1.2          |
| nautobot-secrets-providers[all]==1.4.2 | nautobot-secrets-providers[all]==3.2.0 | nautobot-secrets-providers[all]==4.1.0 |
|                                        |                                        | nautobot-dns-models==3.0.0             |


**Notes:**
- `nautobot-chatops` is removed in 1.x and 2.x due to dependency conflicts with other plugins. It is installed on **3.x** as `nautobot-chatops[slack,teams,webex,ansible,arista]==4.1.0` (Grafana extra omitted—conflicts with diffsync).
- `nautobot-ssot[all]` is removed from 1.x because of dependency conflicts. Available in 2.x and 3.x.
- `nautobot-data-validation-engine` is not available for 3.x (3.4.1 still declares compatibility only with Nautobot versions below 3.0).
- `nautobot-dns-models==3.0.0` requires Python >=3.11, so it will not install on the py3.10 images.
- `nautobot-ui-plugin` is not included in 3.x requirements (commented out in `requirements-3.x.txt`).
- **`stable` / `latest`:** these tags track upstream `networktocode/nautobot:stable` and `:latest` and use the **3.x** app bundle (same plugins as a `3.*` image). For the 2.x plugin pins, **pull an explicit `2.x.y-py3.nn` tag**.
- **`-mcp` tags:** `stable-mcp`, `latest-mcp`, and the newest 3.x patch (`3.2.10-py3.12-mcp` / `3.2-py3.12-mcp`) add `nautobot-mcp` on top of the 3.x bundle. See [`requirements-mcp.txt`](requirements-mcp.txt).

Nautobot **3.x** images also pin **GraphQL** dependencies (`graphene`, `graphql-relay`) to avoid resolver clashes—details are in [`requirements-3.x.txt`](requirements-3.x.txt) in this repository.

## Docker Compose
To set up a working environment in Docker including database and Redis, see this [example docker-compose.yml for Nautobot](https://gist.github.com/bsmeding/d60cf4f23519c75ca2339148d6efd7fe).

## More flexibility needed?
If you need more flexibility, use the Ansible role to deploy Nautobot on Docker: [ansible_role_nautobot_docker](https://github.com/bsmeding/ansible_role_nautobot_docker) on GitHub or [Ansible Galaxy](https://galaxy.ansible.com/ui/standalone/roles/bsmeding/nautobot_docker/).

## Building the image yourself
Maintainers and contributors can follow [buildinfo.md](buildinfo.md) for local `docker build`, `build.sh`, and Makefile usage.