# Overview

A gitlab-runner charm.

The charm:

* Installs gitab-runner upstream repos as described here:
https://gitlab.com/gitlab-org/gitlab-runner/blob/master/docs/install/linux-repository.md

* Configures and registers a single docker runner using the configured <gitlab-registration-token>.

* Will expose prometheus metrics on port 

The runner registers with its hostname (fqdn) in gitlab (default with gitlab-runner) and any supplied tags. If none are given, "juju" will be added as a tag.

The runner removes itself and unregisters as part of a unit removal.

Actions exists to perform register/unregister and some more.

# Mandatory configuration details.

You need to:
* Extract a gitlab-registration-token from the gitlab project under "Settings -> CI/CD".
* Know the URL address to the gitlab-server for gitlab-runner registration.

# Example deploy, scale-up/down

Create a file with your configuration: runner-config.yaml:

```yaml
gitlab-runner:
  gitlab-server: "https://gitlab.example.com"
  gitlab-registration-token: tXwQuDAVmzxzzTtw2-ZL
  tag-list: "juju,docker,master"
```

Then deploy with your config and some instance constraints.

```bash
  juju deploy --constraints="mem=4G cores=2" ./builds/gitlab-runner --config runner-config.yaml
```
Scale up your deployment with 'juju add-unit' and you will get an identical new instance. serving your pipeline:
```bash
  juju add-unit gitlab-runner
```

Scale down with 'juju remove-unit' (will also unregister the instance in gitlab)
```bash
  juju remove-unit gitlab-runner/0
```

# Example deploy, multiple projects, different sizes

Create two files with your separate configurations.

runner-config-one.yaml
```yaml
gitlab-runner-one:
  gitlab-server: "https://gitlab.example.com"
  gitlab-registration-token: rXwQugergrzxzz32Fw3-44
  tag-list: "juju,docker,master"
```

runner-config-two.yaml
```yaml
gitlab-runner-two:
  gitlab-server: "https://gitlab.example.com"
  gitlab-registration-token: tXwQuDAVmzxzzTtw2-ZL
  tag-list: "juju,docker,daily"
```

Deploy the same charm, using two differnt configs and different constraints.

```bash
  juju deploy --constraints="mem=4G cores=2" ./builds/gitlab-runner gitlab-runner-one --config runner-config-one.yaml
  juju deploy --constraints="mem=2G cores=1" ./builds/gitlab-runner gitlab-runner-two --config runner-config-two.yaml
```

# Example deploy, relate to prometheus for monitoring

With any of the other examples, add in a prometheus instance:

```bash
  juju deploy prometheus2 --constraints="mem=4G cores=2"
  juju relate prometheus2 gitlab-runner
  juju expose prometheus2
```

When ready, the prometheus instance will be available on https://instance:9090/


# Actions

See "actions.yaml"

# Contact Information
Erik Lönroth: erik.lonroth@gmail.com
https://eriklonroth.com

# Upstream charm repo
Repo at https://github.com/erik78se/