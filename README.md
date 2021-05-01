# A gitlab-runner juju-charm
This is a "hooks only" juju charm capable of deploying a gitlab-runner
instance.

Configure it with your remote gitlab server instance.

Full charm docs in charm [src/README.md](src/README.md)

## Build dependencies
Build on either ubuntu or focal with these deps installed:

    sudo apt install build-essential
    sudo snap install charm --classic
    sudo apt install shellcheck

## Building

    make build

The resulting charm ends up in the "builds" directory.

## Deploy
See some examples here: [examples/README.md](examples/README.md)
