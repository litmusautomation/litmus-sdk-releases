# Welcome to the Litmus SDK!

Python SDK for interfacing with [Litmus Edge](https://litmus.io) and [Litmus Edge Manager](https://litmus.io) APIs.

- See the [documentation](https://docs.litmus.io/sdk) for detailed usage guides and examples.

---

## Requirements

Python **3.12 or newer** is required.

---

## Supported Versions

| Product | Python SDK (`litmussdk`) | CLI (`litmus-cli`, from `cli-v1.0.0`) |
|---------|--------------------------|---------------------------------------|
| Litmus Edge | `4.0.x` (LTS), default and actively tested; `3.16.x` and `3.11.x` best-effort | `4.4.x` (LTS); `4.0.x` best-effort |
| Litmus Edge Manager | Supported, version not pinned | `3.0.x` (LTS); `2.31.x` best-effort |
| Litmus Unify | Supported, version not pinned | `2.0.x` |

Best-effort means not actively tested: functions added in the newer release are not available on the older one.

---

## Installing Python

### Python Releases
- Head to the [Python downloads page](https://www.python.org/downloads/)
- Select a version **>=3.12** and install for your OS
- Verify: `python --version`

### Microsoft Store (Windows)
- Search for **Python** in the Microsoft Store, select a version >=3.12 by **Python Software Foundation**
- Verify: `python --version`

---

## Installing the SDK

Each official release is available on the [releases page](https://github.com/litmusautomation/litmus-sdk-releases/releases) as a `.whl` file.

> Users are strongly encouraged to use [virtual environments](https://docs.python.org/3/library/venv.html).

1. Download the `.whl` for your target version from the releases page
2. Install it:
    ```bash
    pip install litmussdk-{version}.whl
    ```
3. Verify the installation:
    ```bash
    python -c "import litmussdk"
    ```

All runtime dependencies are bundled — no extra installs needed.

---

## CLI

`litmus-cli` exposes every SDK function (about 1,250) from the shell without writing code. Useful for AI agents, CI pipelines, and interactive exploration. It is a standalone binary, not installed with this package, and is released here under `cli-v*` tags (latest: `cli-v1.0.0`).

Supported product versions are in the [table above](#supported-versions). From `cli-v1.0.0` on, `run` paths and `--args` names stay stable within 1.x, so scripts written against one 1.x release keep working.

```bash
# macOS / Linux install (detects platform, verifies checksum, installs to ~/.local/bin)
curl -fsSL https://raw.githubusercontent.com/litmusautomation/litmus-sdk-releases/main/install.sh | sh

# Windows: download litmus-cli-windows-amd64.exe from the latest cli-v* release

# Update an installed CLI in place
litmus-cli update
```

```bash
# List all available packages and functions
litmus-cli list
litmus-cli list le.devicehub

# Configure a connection (stored in ~/.litmus/default.json)
litmus-cli config set \
  --EDGE_URL https://<device-ip> \
  --EDGE_API_CLIENT_ID <client-id> \
  --EDGE_API_CLIENT_SECRET <client-secret>

# Call any SDK function
litmus-cli run le.devicehub.ListDevices
litmus-cli run lem.ListIncidents --args '{"projectID": "my-project"}'
```

Run `litmus-cli -h` for full usage and connection options. See the **[CLI guide](https://api.litmus.io/cli.md)** for details. If you scripted the older pip-installed CLI, the [migration table](https://api.litmus.io/sdk-agents.md) lists what changed (the command name, function paths, and JSON argument keys).

---

## Quick Start

### 1 — Get credentials

In your Litmus Edge UI navigate to **System → Access Control → Tokens**, create an **OAuth 2.0 Client** with Admin permissions, and copy the Client ID and Client Secret.

### 2 — Configure

Set the three required environment variables (or place them in a `.env` file in your working directory):

```bash
export EDGE_URL=https://<your-edge-ip>
export EDGE_API_CLIENT_ID=<client-id>
export EDGE_API_CLIENT_SECRET=<client-secret>
```

If your device uses a self-signed certificate, also set:

```bash
export VALIDATE_CERTIFICATE=false
```

### 3 — Use the SDK

```python
from litmussdk.devicehub import devices

all_devices = devices.list_devices()
print(all_devices)
```

To use an explicit connection instead of environment variables:

```python
from litmussdk.utils.conn import new_le_connection
from litmussdk.devicehub import devices

conn = new_le_connection(
    edge_url="https://<your-edge-ip>",
    edge_client_id="<client-id>",
    edge_client_secret="<client-secret>",
)
all_devices = devices.list_devices(conn)
```

---

## Environment Variables Reference

| Variable | Required | Description |
|----------|----------|-------------|
| `EDGE_URL` | Yes (direct) | Full URL of your Litmus Edge instance |
| `EDGE_API_CLIENT_ID` | Yes (direct) | OAuth 2.0 Client ID |
| `EDGE_API_CLIENT_SECRET` | Yes (direct) | OAuth 2.0 Client Secret |
| `VALIDATE_CERTIFICATE` | No | Set to `false` to disable TLS verification (default: `true`) |
| `TIMEOUT_SECONDS` | No | Request timeout in seconds (default: `30`) |
| `EDGE_MANAGER_URL` | LEM only | URL of the Litmus Edge Manager instance |
| `EDGE_API_TOKEN` | LEM only | LEM API token |
| `EDGE_MANAGER_PROJECT_ID` | LEM only | Project ID of the target device in LEM |
| `EDGE_MANAGER_DEVICE_ID` | LEM only | Device ID of the target device in LEM |
| `USE_LEM_BRIDGE` | No | Set to `true` to connect via LEM bridge (default: `false`) |

---

## Feature Coverage

| Feature | Description |
|---------|-------------|
| Analytics | Processors, instances, groups, AI models |
| DeviceHub | Devices, tags, drivers, asset discovery/browse |
| Digital Twins | Models, instances, attributes, transformations, hierarchies, parameters |
| Flows | Create, manage, and deploy Node-RED flows |
| Integrations | Cloud connector instances and subscriptions |
| Marketplace | Container images, registries, running apps |
| OPC UA | Users, hierarchy, security modes and policies |
| System | Users, tokens, network, LDAP, certs, events, external storage |
| AirGap Templates | Programmatic builder for air-gap deployment configs |
| Litmus Edge Manager | Device lifecycle, applications, alerts, certificates |

---

## Connecting via LEM Bridge

If connecting through Litmus Edge Manager:

1. Generate an API token — see [LEM documentation](https://docs.litmus.io/edgemanager/lem-admin-console/product-features/admin-console-settings/tokens)
2. Find the project and device IDs from the LEM dashboard URL:
   `https://{LEM_URL}/#/{project_name}/{project_id}/device/{device_id}/`
3. Set:
    ```bash
    export EDGE_MANAGER_URL=https://<lem-url>
    export EDGE_API_TOKEN=<token>
    export EDGE_MANAGER_PROJECT_ID=<project-id>
    export EDGE_MANAGER_DEVICE_ID=<device-id>
    export USE_LEM_BRIDGE=true
    ```

---

## License

Copyright (c) Litmus Automation Inc.
