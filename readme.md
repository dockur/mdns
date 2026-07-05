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

Docker container of [mDNS Reflector](https://github.com/vfreex/mdns-reflector), a lightweight and performant multicast DNS reflector.

It reflects mDNS queries and responses between multiple network interfaces, allowing devices in separate LANs to discover each other without placing them in the same broadcast domain.

This is useful when running IoT devices in a separate network while still allowing discovery from your main LAN.

## Features ✨

- Reflects mDNS traffic between multiple interfaces
- Supports both IPv4 and IPv6
- Lightweight Alpine-based image

## Usage 🐳

##### Docker Compose:

```yaml
services:
  mdns:
    image: dockurr/mdns
    container_name: mdns
    network_mode: host
    environment:
      INTERFACES: "eth0 vlan20"
    restart: always
```

##### Docker CLI:

```bash
docker run -it --rm --name mdns -e "INTERFACES=eth0 vlan20" --network host docker.io/dockurr/mdns
```

> [!IMPORTANT]
> This container requires host networking because the reflector needs access to the real network interfaces and multicast traffic.

## Configuration ⚙️

### How do I select the interfaces?

Set the `INTERFACES` environment variable to a space-separated list of interfaces that should participate in mDNS reflection.

```yaml
environment:
  INTERFACES: "eth0 vlan20"
```

At least two interfaces are required.

### How do I find my interface names?

On the host, run:

```bash
ip link
```

Common examples are `eth0`, `br0`, `vlan20`, `eno1`, or bridge/VLAN interfaces created by your router, firewall, or virtualization platform.

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
