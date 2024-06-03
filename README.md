# sigeca-central

### Initial configuration

Before first starting the server make sure to apply all configurations in this section.

#### Domain name
The domain name should be updated in 2 palces
- ``config/nginx/sigeca.conf``, ``server_name`` parameter
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

### Apache NiFi configuration

#### Changing NiFi settings
- Run NiFi container ```docker compose up -d nifi```
- Modify file in host (i.e. nifi.properties)
    - Copy file into host ```docker compose cp nifi:/opt/nifi/nifi-current/conf/nifi.properties ./nifi.properties```
    - Edit the file
    - Copy the file back into container ```docker compose cp ./nifi.properties nifi:/opt/nifi/nifi-current/conf/nifi.properties```
    - Restart the container ```docker compose restart nifi```

#### Changing username and password to NiFi web UI
- Run NiFi container ```docker compose up -d nifi```
- Open shell in container ```docker compose exec nifi /bin/bash```
- Set username and password ```/opt/nifi/nifi-current/bin/nifi.sh set-single-user-credentials <username> <password>```
- Restart the container ```docker compose restart nifi```

#### Create Test Dataset 
Prerequisites: 
- Python3 and venv installed. 
- .env file created configured.
- Database is running

Steps:
- Go to utils directory ```cd utils```
- Create new venv ```python3 -m venv venv```
- Execute script creating demo data ```python add_demo_data.py```
