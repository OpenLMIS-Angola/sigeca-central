# sigeca-central

### Database Configuration

The following variables should be updated before starting the database
- ``DB_USER``
- ``DB_PASSWORD``
- ``DB_NAME``

### Nginx configuration

#### Domain name
The domain name should be updated in 2 palces
- ``config/nginx/sigeca.conf``, ``server_name`` parameter
- ``.env`` file

#### SSL Keys
To function properly, the instance requires a set of keys for secure communication.
- ``fullchain.pem`` - X509 public key certificate in PEM format
- ``privatekey.pem`` - corresponding private key in PEM format
- ``dhparams.pem`` - dhparam file in PEM format
These files should be copied to ``confif/nginx/ssl/`` dir

Additionally the ``ssl-params.conf`` file contains SSL parameters for nginx server

### Apache NiFi configuration

#### Changing NiFi settings
- Run NiFi container ```docker compose up -d nifi```
- Modify file in host (i.e. nifi.properties)
    - Copy file into host ```docker compose exec nifi /bin/bash -c "cat /opt/nifi/nifi-current/conf/nifi.properties" > ./nifi.properties```
    - Edit the file
    - Copy the file back into container (this ensures only the content of the file is copied, leaving the owner and permissions intact) ```docker compose exec nifi /bin/bash -c "cat > /opt/nifi/nifi-current/conf/nifi.properties" < ./nifi.properties```
    - Restart the container ```docker compose restart nifi```
- Modify file in container (i.e. nifi.properties)
    - Open shell inside container ```docker compose exec nifi /bin/bash```
    - Edit the file
    - Exit from the container ```exit```
    - Restart the container ```docker compose restart nifi```

#### Changing username and password to NiFi web UI
- Run NiFi container ```docker compose up -d nifi```
- Open shell inside container ```docker compose exec nifi /bin/bash```
- Set username and password (make sure you are in ``nifi-current`` dir) ```./bin/nifi.sh set-single-user-credentials <username> <password>```
- Restart the container ```docker compose restart nifi```
