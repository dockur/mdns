#!/usr/bin/env bash
set -Eeuo pipefail

: "${INTERFACES:=""}"
: "${LOG_LEVEL:="warning"}"

if [ "$#" -gt 0 ]; then
  exec "$@"
fi

echo "mDNS Reflector v$(</etc/version)..."

normalizeInterfaces() {

  INTERFACES=$(printf '%s\n' "$INTERFACES" | tr ',' ' ' | xargs)

  if [ -z "$INTERFACES" ]; then
    echo "Error: set INTERFACES to a space-separated list of interfaces." >&2
    exit 1
  fi

  read -r -a INTERFACE_LIST <<< "$INTERFACES"

  if [ "${#INTERFACE_LIST[@]}" -lt 2 ]; then
    echo "Error: at least two interfaces are required." >&2
    exit 1
  fi
}

checkInterfaceExists() {

  local iface="$1"

  if [ ! -d "/sys/class/net/$iface" ]; then
    echo "Error: interface '$iface' does not exist." >&2
    echo >&2
    echo "Available interfaces:" >&2
    ls -1 /sys/class/net >&2
    exit 1
  fi
}

checkInterfaceMulticast() {

  local iface="$1"
  local flags

  if [ -r "/sys/class/net/$iface/flags" ]; then
    flags=$(<"/sys/class/net/$iface/flags")

    if (( (flags & 0x1000) == 0 )); then
      echo "Warning: interface '$iface' does not support multicast." >&2
    fi
  fi
}

checkInterfaceState() {

  local iface="$1"

  if [ -r "/sys/class/net/$iface/operstate" ] && [ "$(<"/sys/class/net/$iface/operstate")" = "down" ]; then
    echo "Warning: interface '$iface' appears to be down." >&2
  fi
}

validateInterfaces() {

  local iface
  declare -A seen=()

  for iface in "${INTERFACE_LIST[@]}"; do

    if [ -n "${seen[$iface]:-}" ]; then
      echo "Error: duplicate interface '$iface'." >&2
      exit 1
    fi

    seen[$iface]=1

    if [ "$iface" = "lo" ]; then
      echo "Error: loopback interface 'lo' cannot be used for reflection." >&2
      exit 1
    fi

    checkInterfaceExists "$iface"
    checkInterfaceMulticast "$iface"
    checkInterfaceState "$iface"

  done
}

normalizeInterfaces
validateInterfaces

echo "Interfaces selected: ${INTERFACE_LIST[*]}"
echo

# shellcheck disable=SC2086
exec mdns-reflector -fnl "$LOG_LEVEL" -- "${INTERFACE_LIST[@]}"
