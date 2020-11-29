# cloud-init helper

<img alt="cloud-init" src="assets/cloud-init.png?raw=true" width="15%" align="right" />


> [Cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html) is the industry standard multi-distribution method for cross-platform cloud 
> instance initialization. It is supported across all major public cloud providers, 
> provisioning systems for private cloud infrastructure, and bare-metal installations.

This repository provides an easy way to generate a `cloud-config`.

## [W]ork [i]n [p]rogress!
This is just an initial rough state. May change fundamentally.

## Install
```sh
# go to your git repo
cd your-project
# wherever you want the submodule
mkdir vendors
# add submodule - or just copy scripts you need
# or git clone https://github.com/lanisce/cloud-init.git vendors/cloud-init && sudo rm -r $_/.git
git submodule add https://github.com/lanisce/cloud-init.git vendors/cloud-init
```

## Configuration
```sh
# create a cloud-init folder containing all configuration
mkdir cloud-init
cd cloud-init
```

The `cloud-init` folder structure should look roughly like this
```
.
├── hetzner.json
├── nameservers
├── packages
├── README.md
├── source.list
│   └── docker.list
└── write_files
    ├── etc
    │   └── network
    │       └── interfaces.d
    │           ├── 60-floating-ip.cfg
    │           └── 60-floating-ip.cfg.stat
    └── var
        └── lib
            └── cloud
                └── files
                    ├── bootstrap.sh
                    └── bootstrap.sh.stat
```

### APT configuration
You can any cloud-init apt configuration into the `apt` file.

Also every file within `source.list` will be added as apt source.

```yaml
# example docker.list
source: "deb [arch=amd64] https://download.docker.com/linux/ubuntu $RELEASE stable"
# content of
# curl -s https://download.docker.com/linux/ubuntu/gpg | xclip -selection clipboard
key: | 
  -----BEGIN PGP PUBLIC KEY BLOCK-----

  mQINBFit2ioBEADhWpZ8/wvZ6hUTiXOwQHXMAlaFHcPH9hAtr4F1y2+OYdbtMuth
  [...]
  -----END PGP PUBLIC KEY BLOCK-----
```

### `write_files` folder
This folder will be completly synced over the target instance.
Every file _can_ (optional) have a companion file `*.stat` descibing the file

- `owner: <user name>:<group name>`: default is `${CLOUD_USER}:${CLOUD_GROUP}`
- `permissions: <octal permission>`: default is `0655`
- `execute: true`: this will execute the given file instead of fetching it's content
- `runcmd: true`: if set, the file will be executed on the first boot (! `permissions` has to be executable)
- `envsubst: true`: this will substitute environment variables within the file

## Environment variables
You can set options as environment variables.
- `CLOUD_USER`: default user
- `CLOUD_GROUP`: default group
- `CLOUD_SSH`: ssh public key to use (_default_: `${HOME}/.ssh/id_rsa.pub`)

All server parameters, within the `hetzner.json`, will be exposed within the `cloud-config` generater.

> e.g. `{ "name": "myserver", "location": "hel1" }` will be availible as `${NAME}` and `${LOCATION}`.

You can also expose envs into the `cloud-config` generater like `${CLOUD_ENV_*}`. `CLOUD_ENV_` will be stripped.

> e.g. `CLOUD_ENV_FOO=bar cloud-config` will be available as `${FOO}`.

## Sub configurations
If you have to generate different `cloud-config`'s you can create the following folder structure.

```
.
├── apt
├── hetzner.json
├── nameservers
├── packages
├── README.md
└── write_files
    ├── etc
    │   └── ...
    └── cloud.d
        └── <cloud.d name>
            ├── packages
            └── write_files
                └── etc
                    └── ...
```

You can add `<cloud.d name(s)>` either as environment variable 

> `CLOUD_PATHD="<cloud.d name 1>[:<cloud.d name 2>:<cloud.d name 3>]"`

or reference them within your `hetzner.json` with 

> `{ ..., "#cloud.d": "<cloud.d name 1>[:<cloud.d name 2>:<cloud.d name 3>]" }`

## Provider
Yet, another cloud provisioning tool.
Well yeah, but really minimalistic, to get started.

### Hetzner
You can configure your hetzner cloud environment simply by one json file (`hetzner.json`).
```json
{
  "ssh-key": [
    { "name": "user", "public-key-from-file": "${HOME}/.ssh/id_rsa.pub" }
  ],
  "floating-ip": [
    { "name": "rancher.lanisce.si", "type": "ipv4", "home-location": "nbg1" }
  ],
  "server": [
    { "name": "rancher", "type": "cx21", "image": "ubuntu-20.04", "location": "hel1", "ssh-key": 0, "network": 0, "#floating-ip": 0 }
  ],
  "volume": [
    { "name": "rancher", "size": "10", "server": 0 }
  ],
  "network": [
    { "name": "kubernetes", "ip-range": "10.98.0.0/16", "#subnets": [
      { "network-zone": "eu-central", "type": "server", "ip-range": "10.98.0.0/16" }
    ] }
  ]
}
```
You can reference resources by setting the row number of the given resource.
So e.g. `.volume` has a `.server` reference to `.server[0]`. This value will be replaced by the resource id.
All fields will just be handed over to hcloud. Only exception are fields beginning with `#`. These will be ignored.

When `deploy` (or directly `./provider/hetzner`) is executed it will try to create all resources.
```shell
$ deploy
👷 found hetzner.json

☁  fetching floating-ip...
☁  fetching network...
☁  fetching server...
☁  fetching ssh-key...
☁  fetching volume...

🦗 skip ssh-key user (2420225)
☁  fetching ssh-key...

🦗 skip floating-ip rancher.lanisce.si (369823)
☁  fetching floating-ip...

🦗 skip network kubernetes (459431)
☁  fetching network...

🦗 skip server rancher (8713152)
☁  fetching server...

📦 create volume rancher
   $ hcloud volume create --name rancher --size 10 --server 8713152

5s [=====================================] 100.00%
Waiting for volume 8168226 to have been attached to server 8713152
 ... done
Volume 8168226 created

☁  fetching volume...
```

## direnv
>>> https://direnv.net/

> direnv is an extension for your shell. It augments existing shells with a new feature that can load and unload environment variables depending on the current directory.

```bash
#!/bin/bash

set -euo pipefail

: "${PATH_BASE:="$(git rev-parse --show-toplevel)"}"

set::path() {
  # easy access to cloud-init scripts
  PATH_add "${PATH_BASE}/vendors/cloud-init"
  # easy access to needed binaries
  PATH_add "${PATH_BASE}/vendors/cloud-init/.bin"
}

main() {
  set::path
}

[ -z "${DIRENV_IN_ENVRC}" ] || main
```

## Usage
Just execute `deploy` or `cloud-config`.

## Referrences
- https://cloudinit.readthedocs.io/en/latest/index.html
- https://cloudinit.readthedocs.io/en/latest/topics/examples.html

## License
This project is licensed under the MIT license, see `LICENSE`.
