#!/bin/bash

# lookup current git repository folder
git::base() {
  git rev-parse --show-toplevel
}

# lookup git top (if submodule) folder
git::top() {
  local base
  # get super working dir if it's submodule
  base="$(git rev-parse --show-superproject-working-tree)"
  # otherwise get default working dir
  echo "${base:-"$(git::base)"}"
}
