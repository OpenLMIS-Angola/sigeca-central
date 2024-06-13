# sigeca-central

This repository hosts dockerized setup for SIGECA Central database with all services.

## Initial configuration

Before first starting the server make sure to apply all configurations in this section.

#### Domain name
The domain name should be updated in 2 palces
- ``config/nginx/nifi.conf``, ``server_name`` parameter (in both port 80 and port 443 sections)
- ``.env`` file

#### Database Configuration

The following variables should be updated before starting the database
- ``DB_USER``
- ``DB_PASSWORD``
- ``DB_NAME``

#### NiFi Configuration

The following variables should be updated before starting the NiFi instance
- ``NIFI_USER``
- ``NIFI_PASSWORD``

After the instance is started these fields do not change the credentials. Instead refer to "Changing username and password to NiFi web UI" section

#### SSL Keys
To function properly, the instance requires a set of keys for secure communication.
- ``fullchain.pem`` - X509 public key certificate in PEM format
- ``privatekey.pem`` - corresponding private key in PEM format
- ``dhparams.pem`` - dhparam file in PEM format

These files should be copied to ``config/nginx/ssl/`` dir

Additionally the ``ssl-params.conf`` file contains SSL parameters for nginx server

## Apache NiFi configuration

#### Changing NiFi settings
- Run NiFi container ```docker compose up -d nifi```
- Modify file in host (i.e. nifi.properties)
    - Copy file into host ```docker compose cp nifi:/opt/nifi/nifi-current/conf/nifi.properties ./nifi.properties```
    - Edit the file
    - Copy the file back into container ```docker compose cp ./nifi.properties nifi:/opt/nifi/nifi-current/conf/nifi.properties```
    - Restart the container ```docker compose restart nifi```

Do not change the settings set by the ```.env``` variables, as these settings will get updated every time the container restarts.

#### Changing username and password to NiFi web UI
- Run NiFi container ```docker compose up -d nifi```
- Open shell in container ```docker compose exec nifi /bin/bash```
- Set username and password ```/opt/nifi/nifi-current/bin/nifi.sh set-single-user-credentials <username> <password>```
- Restart the container ```docker compose restart nifi```

#### Deploy NiFi Workflow
To upload current version of SIGECA Central Nifi flow:
- Access the NiFi UI
- Insert new ```Process Group```
- Click ```Upload``` button (right to ```Process Group Name```)
- Select the workflow file (```./config/nifi/SIGECA_Central.json```)
- Click ```Add```

The ```SIGECA_Central``` process group should appear in the workspace.

## Accessing NiFi synchrozization API

#### Generating Basic auth credentials
To generate the file required for accessing the NiFi API you will need a tool called ```htpasswd```
and generate the file ```config/nginx/.htpasswd```. The instructions on how to do that: [link](https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/). This file will be used as
auth source for API access by the NGINX.

#### Updating IP filter for NiFi API
In Addition to the BASIC auth NiFi API requires client IPs to be included in ```config/nginx/nifi.conf``` in the ```/api/``` location. The clients IP should be below the ```localhost``` group and above ```deny all``` clause.

## Create Test Dataset
Prerequisites: 
- Python3 and venv installed. 
- .env file created configured.
- Database is running

Steps:
- Go to utils directory ```cd utils```
- Create new venv ```python3 -m venv venv```
- Execute script creating demo data ```python add_demo_data.py```

## Mapa Sanitario Configuration
Mapa Sanitario is accessed through REST API and uses 3 actions to retrieve data
- ``POST /api/login_check`` - Login request responding with JWT
- ``GET /api/unidade`` - Retrieve full list of facilities (requires Bearer token)
- ``GET /api/unidade?codigo=<code>`` - Retrieve a facility with specified code (requires Bearer token)

#### Environment
For a proper connection, the following fields are required to be filled in ``.env``:
- ``MAPA_SANITARIO_URL`` - FQDN of the Mapa Sanitario API
- ``MAPA_SANITARIO_USERNAME`` - Username for the Mapa Sanitario API
- ``MAPA_SANITARIO_PASSWORD`` - Password for the Mapa Sanitario API
