## Deploy a single instance

```bash
juju deploy --constraints="mem=4G cores=2" ./builds/gitlab-runner --config runner-config.yaml
```

## Deploy runners for different projects with different speccs.

Create two files with separate configurations.

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

## Deploy with prometheus and grafana
```bash
juju deploy --constraints="mem=4G cores=2" ./builds/gitlab-runner --config runner-config.yaml
juju deploy prometheus2 --constraints="mem=4G cores=2"
juju deploy grafana
juju relate prometheus2 gitlab-runner
juju add-relation prometheus2:grafana-source grafana:grafana-source
juju expose prometheus2
juju expose grafana

# Get the admin password to login to grafana.
juju run-action --wait grafana/0 get-admin-password
```

Browse to http://grafana:3000/

One dashboard known to work with the metrics is: https://grafana.com/grafana/dashboards/8729
