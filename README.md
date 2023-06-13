# Kimai Dockers

We provide a set of docker images for the [Kimai v2](https://github.com/kevinpapst/kimai2) project.

The built images are available from [Kimai v2](https://hub.docker.com/r/kimai/kimai2) at Docker Hub.

## Deving and Contributing

We use commit linting to generate commits that we can auto generate changelogs from. To set these up, you will need node/nvm installed:

```bash
nvm use
npm install
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

## Quick start

Run the latest production build:

1. Start a DB

    ```bash
        docker run --rm --name kimai-mysql-testing \
            -e MYSQL_DATABASE=kimai \
            -e MYSQL_USER=kimai \
            -e MYSQL_PASSWORD=kimai \
            -e MYSQL_ROOT_PASSWORD=kimai \
            -p 3399:3306 -d mysql
    ```

2. Start Kimai

    ```bash
        docker run --rm --name kimai-test \
            -ti \
            -p 8001:8001 \
            -e DATABASE_URL=mysql://kimai:kimai@${HOSTNAME}:3399/kimai \
            kimai/kimai2:apache
    ```

3. Add a user using the terminal

    ```bash
        docker exec -ti kimai-test \
            /opt/kimai/bin/console kimai:create-user admin admin@example.com ROLE_SUPER_ADMIN
    ```

Now, you can access the Kimai instance at <http://localhost:8001>.

__Note:__
If you're using Docker for Windows or Docker for Mac, and you're getting "Connection refused" or other errors, you might need to change `${HOSTNAME}` to `host.docker.internal`.
This is because the Kimai Docker container can only communicate within its network boundaries. Alternatively, you can start the container with the flag `--network="host"`.
See [here](https://stackoverflow.com/questions/24319662/from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach) for more information.

Keep in mind that this Docker setup is transient and the data will disappear when you remove the containers.

```bash
    docker stop kimai-mysql-testing kimai-test
    docker rm kimai-mysql-testing kimai-test
```

## Using docker-compose

This will run the latest prod version using FPM with an nginx reverse proxy

See the [docker-compose.yml](docker-compose.yml) in the root of this repo.

## Documentation

[https://tobybatch.github.io/kimai2/](https://tobybatch.github.io/kimai2/)


## Other forked Repos for this project

Hopefully I found all repos of the Kimai project so the whole eco system is preserved now for further development

- https://github.com/openfnord/kimai-android  (android app for kimai, this one)
- https://github.com/openfnord/kimai (web based kimai server)
- https://github.com/openfnord/kimai-invoice-templates (templates for kimai server)
- https://github.com/openfnord/kimai-docker (dockerized kimai web based server)
- https://github.com/openfnord/kimai-api-php (api for web based server)

- https://github.com/openfnord/kimai-homepage (homepage of kimai project)
- https://github.com/openfnord/kimai-images (logos and images) 
