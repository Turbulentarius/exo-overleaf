# exo-overleaf
Files needed for deployment of Overleaf into the exo-docker environment

Overleaf can be customized and launched via Docker. In this case I am deploying in a Docker environment that used Traefik to manage the *virtual hosts*
and automatically handle **Let's Encrypt** certificates, so I needed to modify the official **overleaf/overleaf** `docker-compose.yml`; to acomplish this I added a `docker-compose.override.yml`

Port `80` is already bound by Traefik on my server, so I needed to override the ports for *sharelatex*. This can be done like so:
```
        ports: !reset []
```

## Errors

> failed to set up container networking: driver failed programming external connectivity on endpoint sharelatex ...  Bind for 0.0.0.0:80 failed: port is already allocated

This happens because sharelatex is already bound to port 80, in order to fix it you can simply override the port in `docker-compose.override.yml`:
```
  ports: !reset []
```
**Note.** It is not enough to simply write `ports: []`, and so, the `docker-compose.override.yml` actually does not work like you would intuitively expect it to. Instead we are forced to use YAML tags `!reset` and `!override`, as documented here: https://docs.docker.com/reference/compose-file/merge/#replace-value

After this, if you use Traefik, you should just use "Expose" instead, which will expose the port only internally.

>  Conflict. The container name "/redis" is already in use by container ...

This can happen when you already have a service that uses the `container_name` **rredis**, and it can be easily fixed by overriding it in `docker-compose.override.yml`:
```
redis:
       networks:
           - overleaf_network_internal
       container_name: overleaf-redis
       volumes:
           - ~/redis_data:/data
```
