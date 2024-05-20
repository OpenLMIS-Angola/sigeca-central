# sigeca-central

### Apache NiFi configuration

#### Change NiFi settings
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

#### Setting username and password to NiFi web UI
- Run NiFi container ```docker compose up -d nifi```
- Open shell inside container ```docker compose exec nifi /bin/bash```
- Set username and password (make sure you are in ``nifi-current`` dir) ```./bin/nifi.sh set-single-user-credentials <username> <password>```
- Restart the container ```docker compose restart nifi```
