#!/bin/bash

source "${BASH_SOURCE[0]%/*}/github.sh"

# ensures that binary is installed
binary::ensure() {
  local -r name="${1}"
  local -r cmd="${2:-"$(type -P "${name}")"}"
  local -r version="${3}"
  local binary="${cmd:-"${CLOUD_PATH_BINARIES}/${name}"}"

  # check if binary exists else download
  if [ ! -f "${binary}" ]; then
    # create folder if not exists
    mkdir -p "$(dirname "${binary}")"

    # actual download and extract hcloud
    echo -e "\n🕐 Downloading ${name} (${version})" 1>&2
    binary::fetch

    # make executable
    chmod +x "${binary}"
  fi

  # absolute path to binary
  echo -n "${binary}"
}

# https://github.com/hetznercloud/cli
hcloud() {
  binary::fetch() {
    curl -Lo /dev/stdout \
      "https://github.com/hetznercloud/cli/releases/download/${CLOUD_HCLOUD_VERSION}/hcloud-linux-amd64.tar.gz" |
      tar xz --strip-components=0 -C "$(dirname "${binary}")" "hcloud"
  }
  "$(binary::ensure 'hcloud' \
    "${CLOUD_HCLOUD-}" \
    "${CLOUD_HCLOUD_VERSION:="$(github::latest hetznercloud/cli)"}")" "${@}"
}

# https://github.com/stedolan/jq
jq() {
  binary::fetch() {
    curl -Lo "${binary}" \
      "https://github.com/stedolan/jq/releases/download/${version}/jq-linux64"
  }
  "$(binary::ensure 'jq' \
    "${CLOUD_JQ-}" \
    "${CLOUD_JQ_VERSION:="$(github::latest stedolan/jq)"}")" "${@}"
}

