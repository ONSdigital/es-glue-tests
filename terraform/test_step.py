import json
import pkg_resources
import requests

ws = pkg_resources.WorkingSet()
data = []
for pkg in ws:
    info = {
        "name": pkg.project_name,
        "version": pkg.version,
    }
    res = requests.get(
        f"https://pypi.org/pypi/{pkg.project_name}/json"
    ) 
    if res.ok:
        pypi_version = res.json()['info']['version'] 
        if pypi_version != pkg.version:
            info['upgrade_available'] = pypi_version
    data.append(info)
print(json.dumps(data, indent=2))
