<h1 align="center">mDNS Reflector<br />
<div align="center">
<a href="https://github.com/dockur/mdns"><img src="https://raw.githubusercontent.com/dockur/mdns/master/.github/logo.png" title="Logo" style="max-width:100%;" width="128" /></a>
</div>
<div align="center">

[![Build]][build_url]
[![Version]][tag_url]
[![Size]][tag_url]
[![Package]][pkg_url]
[![Pulls]][hub_url]

</div></h1>

Docker container of [mDNS Reflector](https://github.com/vfreex/mdns-reflector), a lightweight and performant multicast DNS reflector with a modern design.

It reflects mDNS queries and responses among multiple LANs, which allows you to run untrusted IoT devices in a separate LAN but those devices can still be discovered in other LANs.

## Features ✨

- Repeats all mDNS traffic
- Supports both IPv4 and IPv6
- Supports zone based reflection

## Usage  🐳

##### Docker Compose:

```yaml
services:
  mdns:
    hostname: mdns
    image: dockurr/mdns
    container_name: mdns
    environment:
      INTERFACE1: "eth0"
      INTERFACE2: "vlan"
    network_mode: host
    restart: always
```

##### Docker CLI:

```bash
docker run -it --rm --name stunnel -p 853:853 -e "LISTEN_PORT=853" -e "CONNECT_PORT=53" -e "CONNECT_HOST=1.1.1.1" -v "${PWD:-.}/privkey.pem:/private.pem" -v "${PWD:-.}/certificate.pem:/cert.pem" docker.io/dockurr/stunnel
```

## Configuration ⚙️

### How do I select the interfaces?

Stunnel can operate in two modes. The __server mode__ works as a transparent proxy in front of a server, so that clients that connect negotiate an TLS connection while the traffic forwarded to the destination server will be unencrypted.

The __client mode__ does the opposite thing. Clients connecting to stunnel running in client mode can establish a plain text connection and stunnel will create an encrypted TLS tunnel to the destination server.

By default it will run in server mode, but to switch modes you can set the `CLIENT` variable like this:

```yaml
environment:
  CLIENT: "yes"
```

### How do I select the certificate?

When running in server mode, a certificate is needed. By default, a self-signed certificate will be generated, but you can supply your own `.pem` certificates by adding:

```yaml
volumes:
  - ./privkey.pem:/private.pem
  - ./certificate.pem:/cert.pem
```

Instead of `.pem` files you can also use `.crt`/`.key` files:

```yaml
volumes:
  - ./privkey.key:/private.key
  - ./certificate.crt:/cert.crt
```

### How do I modify the permissions?

You can set `UID` and `GID` environment variables to change the user and group ID.

```yaml
environment:
  UID: "1002"
  GID: "1005"
```

### How do I modify other settings?

If you need more advanced features, you can completely override the default configuration by binding your custom config to the container like this:

```yaml
volumes:
  - ./custom.conf:/stunnel.conf
```

## Stars 🌟
[![Stargazers](https://raw.githubusercontent.com/star-stats/stars/refs/heads/data/charts/dockur-mdns.svg)](https://github.com/dockur/mdns/stargazers)

[build_url]: https://github.com/dockur/mdns
[hub_url]: https://hub.docker.com/r/dockurr/mdns
[tag_url]: https://hub.docker.com/r/dockurr/mdns/tags
[pkg_url]: https://github.com/dockur/mdns/pkgs/container/mdns

[Build]: https://github.com/dockur/mdns/actions/workflows/build.yml/badge.svg
[Size]: https://img.shields.io/docker/image-size/dockurr/mdns/latest?color=066da5&label=size
[Pulls]: https://img.shields.io/docker/pulls/dockurr/mdns.svg?style=flat&label=pulls&logo=docker
[Version]: https://img.shields.io/docker/v/dockurr/mdns/latest?arch=amd64&sort=semver&color=066da5
[Package]: https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fipitio.github.io%2Fbackage%2Fdockur%2Fmdns%2Fmdns.json&query=%24.downloads&logo=github&style=flat&color=066da5&label=pulls
