# exo-overleaf
Files needed for deployment of Overleaf into the exo-docker environment.

> [!NOTE]  
> I was originally modifying the `docker-compose.yml` file directly, but when I recently wanted to install more LaTeX packeges, I realized I could just use `docker-compose.override.yml` and avoid modifying Overleaf's own docker-compose file.
>

Overleaf can be customized and launched via Docker. In this case I am deploying in a Docker environment that used Traefik to manage the *virtual hosts*
and automatically handle **Let's Encrypt** certificates, so I needed to modify the official **overleaf/overleaf** `docker-compose.yml`; to acomplish this I added a `docker-compose.override.yml`.

The `docker-compose.override.yml` is automatically applied when running `docker compose up`.

## Overrides for Traefik
If you are handling virtual hosts with a proxy like Traefik or Nginx, then you might need to reset the port binding of the sharrelatex container.

Port `80` is already bound by Traefik on my server, so I needed to override the ports for *sharelatex*. This can be done like so:
```
ports: !reset []
```

This is more or less the only needed change to run Overleaf in a Traefik environment.

## How to install LaTeX packeges.

When I first installed Overleaf and tried to use various packages, I was surprised to find they were missing.

Packages can be installed by running these commands once the Overleaf environment is running:
```
docker exec -it sharelatex bash
wget https://mirror.ctan.org/systems/texlive/tlnet/update-tlmgr-latest.sh
sh update-tlmgr-latest.sh
```
This may be needed to update the TeX Live environment, which is installed inside the container.

Now we can install missing packages like so:
```
tlmgr install titling
```

To make the changes persist between restarts, I created a custom dockerfile, `exooverleaf.dockerfile`, and added it to the `docker-compose.override.yml` file.

## Errors and solutions
Various errors I encountered while developing my `docker-compose.override.yml`.

> failed to set up container networking: driver failed programming external connectivity on endpoint sharelatex ...  Bind for 0.0.0.0:80 failed: port is already allocated

This happens because sharelatex is already bound to port 80, in order to fix it you can simply override the port in `docker-compose.override.yml`:
```
ports: !reset []
```
> [!NOTE]  
> It is not enough to simply write `ports: []`, and so, the `docker-compose.override.yml` actually does not work like you would intuitively expect it to. Instead we are forced to use YAML tags `!reset` and `!override`, as documented here: https://docs.docker.com/reference/compose-file/merge/#replace-value

After this, if you use Traefik, you should just use "Expose" instead, which will expose the port only internally.

>  Conflict. The container name "/redis" is already in use by container ...

This can happen when you already have a service that uses the `container_name` **redis**, and it can be easily fixed by overriding it in `docker-compose.override.yml`:
```
redis:
    networks:
        - overleaf_network_internal
    container_name: overleaf-redis
    volumes:
        - ~/redis_data:/data
```
