#!/bin/bash

# fetches latest release from project
github::latest() {
  curl -fsSLI -o /dev/null -w "%{url_effective}" \
    "https://github.com/${1}/releases/latest" |
    rev | cut -d'/' -f1 | rev
}
