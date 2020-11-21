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
├── nameservers
├── packages
├── README.md
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

### `write_files` folder
This folder will be completly synced over the target instance.
Every file _can_ (optional) have a companion file `*.stat` descibing the file

- `owner: <user name>:<group name>`: default is `${CLOUD_USER}:${CLOUD_GROUP}`
- `permissions: <octal permission>`: default is `0655`
- `execute: true`: this will execute the given file instead of fetching it's content
- `runcmd: true`: if set, the file will be executed on the first boot (! `permissions` has to be executable)

## Usage
Just execute `vendors/cloud-init/generate`.

## Environment variables
You can set options as environment variables.
- `CLOUD_USER`: default user
- `CLOUD_GROUP`: default group
- `CLOUD_SSH`: ssh public key to use (_default_: `${HOME}/.ssh/id_rsa.pub`)

## Referrences
- https://cloudinit.readthedocs.io/en/latest/index.html
- https://cloudinit.readthedocs.io/en/latest/topics/examples.html

## License
This project is licensed under the MIT license, see `LICENSE`.
