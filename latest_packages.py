import requests
from packaging.version import parse

packages = [
    "nautobot-plugin-nornir",
    "nautobot-device-lifecycle-mgmt",
    "nautobot-ssot",
    "nautobot-bgp-models",
    "nautobot-device-onboarding",
    "nautobot-data-validation-engine",
    "nautobot-golden-config",
    "nautobot-floor-plan",
    "nautobot-firewall-models",
    "nautobot-chatops",
    "nautobot-ui-plugin",
    "nautobot-design-builder",
    "nautobot-secrets-providers",
]

def get_latest(pkg):
    resp = requests.get(f"https://pypi.org/pypi/{pkg}/json")
    if resp.status_code != 200:
        return None
    data = resp.json()
    return max(data["releases"].keys(), key=parse)

print("# Auto-generated latest requirements")
for pkg in packages:
    latest = get_latest(pkg)
    if latest:
        print(f"{pkg}=={latest}")
    else:
        print(f"# {pkg} (not found on PyPI)")
