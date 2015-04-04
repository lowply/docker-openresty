# docker-openresty

This is a Dockerfile for Openresty (ngx_openresty-1.7.10.1.tar.gz) on CenOS 7. redis2-nginx-module is configured for reverse proxy name resolving. Still in progress for minor improvements. Link to DockerHub:  [lowply/docker-openresty](https://registry.hub.docker.com/u/lowply/docker-openresty/)

## Why CentOS?

There's no official OpenResty docker image for now. I chose CentOS 7 as base OS because simply I like it more than Ubuntu/Debian like distros.

## Why Redis?

nginx tries to resolve hostname in proxy_pass directive, but it fails since it doesn't read /etc/hosts. Installing dnsmasq in the same host is one option for this problem, but redis is better for Docker use.

## Why OpenResty?

Becaues this is great.

> [OpenResty](http://openresty.org/) is a full-fledged web application server by bundling the standard Nginx core, lots of 3rd-party Nginx modules, as well as most of their external dependencies

## How to use

Prepare
```bash
$ brew install redis
```

Pull the image
```bash
docker pull lowply/docker-openresty
```

Run Redis container first, update redis.conf if necessary
```bash
$ cat redis.conf
port 6379
bind 0.0.0.0
loglevel verbose
logfile redis.log

$ docker run -d --name redis -p 6379:6379 -v $(pwd)/redis.conf:/etc/redis.conf -v $(pwd)/logs:/data redis redis-server /etc/redis.conf
```

Run your app container, named like DOMAIN.app (Used go made app in this example)
```
$ docker run -d --name example.com.app -v /go/src/app/public lowply/example.com:master
```

Run OpenResty container, linked to Redis and App container.
```bash
$ docker run -d --name openresty --link example.com.app:example.com --link redis:redis -p 80:80 -v $(pwd)/logs/:/usr/local/openresty/nginx/logs lowply/openresty
```

Add domain as key and ip as value to redis, like A record
```bash
DOMAIN="example.com"
IPADDR=$(docker inspect ${DOMAIN} | jq -r [.][0][0]."NetworkSettings"."IPAddress")
$ redis-cli -h $(boot2docker ip) SET ${DOMAIN} "${IPADDR}"
```

## Example docker ps output

```
$ docker ps
CONTAINER ID        IMAGE                                COMMAND                CREATED             STATUS              PORTS                    NAMES
664d093d2aa5        lowply/openresty:latest              "/bin/sh -c 'sbin/ng   40 minutes ago      Up 40 minutes       0.0.0.0:80->80/tcp       fixture.openresty
925decafaa26        lowply/example.com:master            "go-wrapper run"       About an hour ago   Up About an hour    3000/tcp                 example.com.app
b5d322a16eb4        lowply/example.com:development       "go-wrapper run"       2 hours ago         Up 2 hours          3000/tcp                 test.example.com.app
40c6de9d1573        redis:latest                         "/entrypoint.sh redi   3 hours ago         Up 3 hours          0.0.0.0:6379->6379/tcp   fixture.redis
```

## Todo

- Persistent data store for Redis container
- Improve nginx.conf
