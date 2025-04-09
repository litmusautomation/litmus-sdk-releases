# Welcome to the Litmus SDK!
This repository contains an easy to use software development kit enabling you to leverage the power of our APIs in your applications.

- See this repository's [wiki](https://github.com/litmusautomation/litmus-sdk/wiki) for detailed documentation and example use cases

## Requirements
The Litmus SDK uses python version **>=3.12**

# Version Support
The SDK supports the LTS version of Litmus Edge: **3.16.x**. 
- Functionality in other versions is not guarenteed to work

## Beta Release
Currently the SDK is under a closed beta release meaning the repository is only accessible to authorized users. 

In order to access the repository remotely, or from the command line, each valid user account must set up authorization.
- For more information read the [github documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

# Installing the SDK
The SDK is released as a python package and can be installed using multiple methods. All installations assume that the user has installed python version >=3.12 and has basic familiarity with pip or other python package management tools.
- For more information see python's [official documentation](https://packaging.python.org/en/latest/tutorials/installing-packages/)
- Users are strongly encouraged to use [python's environment virtualization](https://docs.python.org/3/library/venv.html) when installing the package

## Installing Python
The SDK relies on Python >=3.12. You can install python using any of following methods:
### Python Releases
- Head to the python [downloads page](https://www.python.org/downloads/)
- Select a python version >=3.12
- Select the download for your OS
- Once python is installed, try running `python --version` in your command line to verify it is correctly installed
### Microsoft Store (Windows Specific)
- Open the **Microsoft Store** on your machine and search for 'python'
- Select a python version >=3.12 from the strore (e.g. "Python 3.12"). Verify the author of the application is "Python Software Foundation"
- Press 'Get' and install the application
- Verify the installion by running `python --version` in your command line (if this fails, try running the exact version e.g. `python3.12 --version`)

To install the SDK on your device use one of the following approaches:
## Installing from release
For each official release of the SDK there will be a tagged build accessible from the [releases page](https://github.com/litmusautomation/litmus-sdk/releases).
- Each release is distributed in the form of a *wheel file*

1. Download the wheel from the releases page. (Make sure to verify that the build is compatible with the Litmus Edge version you plan on running it with)
2. In your command line navigate to the directory with the wheel file.
    - e.g. `litmussdk-1.0.0.whl`
3. Install the module: 
    - `python -m pip install {file_name}.whl`

4. Verify the module is correctly installed by importing the module. If the command succeeds then the module is correctly installed.
    - `python -c "import litmussdk"`

## Installing from source
This method uses SSH authorization, ensure that you have correct SSH authorization setup for your github. For steps see the [github documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).

1. Install the module with one of the following:
    - Install **main** branch: `python -m pip install git+ssh://git@github.com/litmusautomation/litmus-sdk.git`
    - Install **specific** branch: `python -m pip install git+ssh//git@github.com/litmusautomation/litmus-sdk.git@{branch}`
2. Verify the module is correctly installed by importing the module. If the command succeeds then the module is correctly installed.
    - `python -c "import litmussdk"`

## Installing local build
This method requires you to clone the repo to your local instance. This is needed when you are modifying the source code of the SDK itself.

1. Clone the repo to your device. Run one of the following:
    - SSH: `git clone git@github.com:litmusautomation/litmus-sdk.git`
    - HTTPS (deprecated): `git clone https://github.com/litmusautomation/litmus-sdk.git`
    - GitHub CLI: `gh repo clone litmusautomation/litmus-sdk`
2. Navigate to the root of the SDK directory
    - `cd litmus-sdk`
3. Install or Build the module
    - Install from source: `python -m pip install -e .`
    - Build the module whl: `python -m pip install build && python -m bulid .`

# Configuring your installation
The SDK requires some configuration before you are able to properly connect to your Litmus Edge instance.

## Configuring System variables
The SDK relies on a series of system variables in order to control configuration.
| Variable Name | Type | Description | 
|---------------|------|-------------|
| `EDGE_URL` | string | URL of the edge device. Used if `USE_LEM_BRIDGE=false`|
| `EDGE_API_TOKEN` | string | API token to be used by the LEM bridge if `USE_LEM_BRIDGE=true` | 
| `EDGE_API_CLIENT_ID` | string | OAuth2 client ID to be used when directly connecting to the LE instance. Used if `USE_LEM_BRIDGE=false` |
| `EDGE_API_CLIENT_SECRET` | string | OAuth2 client secret used when directly connecting to the LE instance. Used if `USE_LEM_BRIDGE=false` |
| `EDGE_MANAGER_URL` | string | URL of edge manager device. Used if `USE_LEM_BRIDGE=true` | 
| `EDGE_MANAGER_PROJECT_ID` | string | Project id of edge device being connected to via the LEM bridge. Used if `USE_LEM_BRIDGE=false`.
| `EDGE_MANAGER_DEVICE_ID` | string | Device id of edge device being connected to via the LEM bridge. Used if `USE_LEM_BRIDGE=false`.
| `USE_LEM_BRIDGE` | boolean | Whether to directly connect to a device or connect via the Litmus Edge manager API bridge |
| `VALIDATE_CERTIFICATE` | boolean | Whether to validate target SSL certificates when making web requests to edge device. Is `true` by default |
| `TIMEOUT_SECONDS` | int | How many seconds for an API request times out. Defaults to 30 seconds |

In order to connect to your Litmus Edge device you can either connect directly to the device URL or using the Litmus Edge Manager bridge which can act as a proxy into your devices private networks.

### Configuring for direct connection
If connecting directly to the edge device, ensure the network where your python script is being run has access to the edge device's network.

1. Generate an OAuth2 token
    - In your Litmus Edge instance [create a an **OAuth2 token**](https://docs.litmus.io/litmusedge-v1/product-features/system/tokens/create-api-token)
    - Keep track of the `Client Secret` and `Client ID`
2. Configure the following variables
    - `EDGE_URL={device_url}`. ex. `EDGE_URL=127.0.0.1`
    - `EDGE_API_CLIENT_ID={oauth_client_id}`
    - `EDGE_API_CLIENT_SECRET={oauth_client_secret}`

### Configuring for LEM bridge
If connecting to the edge device via the LEM bridge, ensure that the API bridge is enabled in the target manager device. 
**Note** - before using the LEM bridge, ensure your Edge Device is correctly activated with Edge manager.

1. Generate an API token
    - Find process in our [documentation](https://docs.litmus.io/edgemanager/lem-admin-console/product-features/admin-console-settings/tokens)
2. Identify the project and device ids of your target edge device in Litmus edge manager.
    - Navigate to your device via the LEM dashboard
    - You can find the project and device ids in the URL `https://{LEM_URL}/#/{project_name}/{project_id}/device/{device_id}/`
3. Set the following variables
    - `EDGE_MANAGER_URL={manager_url}` ex. `EDGE_MANAGER_URL=127.0.0.1`
    - `EDGE_API_TOKEN={generated_token}`
    - `EDGE_PROJECT_ID={project_id}`
    - `EDGE_DEVICE_ID={device_id}`
    - `USE_LEM_BRIDGE=true`

There are 3 methods of setting configuration variables. Use any of the following.

### Using dotenv file
1. In your root directory create a file called `.env`.
2. Set your configuraiton variables using the following syntax `NAME=value` ex. `EDGE_URL=127.0.0.1`
3. Run the command `load_env` in the root of your project

### Using environment variables
1. Set your environment variables for your shell session
    - Linux/MACOS: `export NAME=value`
    - Windows: not supported
2. Run the command `load_env` in the root of your project

### Using `update_litmussdk_config`
1. In the root of your project run the following command for each environment variable: `update_litmussdk_config NAME value`
    - ex. `update_litmussdk_config EDGE_URL 127.0.0.1`

## Generating Driver Templates
In order to use most functionality of the devicehub module run the command `generate_driver_templates` **after** configuring the environment variables above.

The devicehub module uses a custom validation layer to ensure that devices objects are locally validated against the underlying drivers before any requests are made. This is an experimental feature which attempts to provide a better user experience and faster development.

# Package Structure
Each edge service is seperated into a different sub-module in the SDK package. They are as follows:
- analytics
    - processors
- devicehub* 
    - assert\_discovery
    - devices
    - drivers
    - general
    - tags
- digital\_twins
- flows
- integrations
- marketplace
- opc
- system
    - certificates
    - debugging\_params
    - device\_management
    - events
    - external\_storage
    - general
    - ldap
    - network
    - services
    - templates
    - tokens
    - users
    - wifi
- utils *(internal utilities - not directly related to any service)*
    - api
    - api\_paths
    - env
    - errors
    - gql\_queries

The encouraged convention is to import the lowest level module possible and using the module as a namespace. 
ex.
```python
from litmussdk.devicehub import devices
devices.list_devices()
```

# Contribution
Currently the project is developed internally, public forks and contributions to the project are not supported. 

Use of the github issues page to report bugs and requested features is highly encouraged.
