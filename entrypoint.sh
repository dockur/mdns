#!/usr/bin/env bash
set -Eeuo pipefail

: "${INTERFACES:=""}"
: "${LOG_LEVEL:="info"}"

echo "mDNS Reflector v$(</etc/version)..."

if [ "$#" -gt 0 ]; then
  exec "$@"
fi

INTERFACES=$(echo "$INTERFACES" | tr ',' ' ' | xargs)

if [ -z "$INTERFACES" ]; then
  echo "Error: set INTERFACES to a space-separated list of interfaces." >&2
  exit 1
fi

read -r -a IFACE_ARRAY <<< "$INTERFACES"

if [ "${#IFACE_ARRAY[@]}" -lt 2 ]; then
  echo "Error: at least two interfaces are required." >&2
  exit 1
fi

declare -A seen=()

for iface in "${IFACE_ARRAY[@]}"; do

  if [ -n "${seen[$iface]:-}" ]; then
    echo "Error: duplicate interface '$iface'." >&2
    exit 1
  fi

  seen[$iface]=1

  if [ ! -d "/sys/class/net/$iface" ]; then
    echo "Error: interface '$iface' does not exist." >&2
    echo >&2
    echo "Available interfaces:" >&2
    ls -1 /sys/class/net >&2
    exit 1
  fi

done

has_ipv6() {

  local count=0

  [ -e /proc/net/if_inet6 ] || return 1
  [ -s /proc/net/if_inet6 ] || return 1

  for iface in "${IFACE_ARRAY[@]}"; do

    if [ -r "/proc/sys/net/ipv6/conf/$iface/disable_ipv6" ]; then
      [ "$(cat "/proc/sys/net/ipv6/conf/$iface/disable_ipv6")" = "0" ] || continue
    fi

    if grep -qw "$iface" /proc/net/if_inet6; then
      count=$((count + 1))
    fi

    [ "$count" -ge 2 ] && return 0

  done

  return 1
}

IP_VERSION=""

if ! has_ipv6; then
  IP_VERSION="-4"
fi

echo "Interfaces selected: ${IFACE_ARRAY[*]}"
echo

# shellcheck disable=SC2086
exec mdns-reflector -fnl "$LOG_LEVEL" $IP_VERSION -- "${IFACE_ARRAY[@]}"
