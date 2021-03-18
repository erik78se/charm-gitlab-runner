# helpers for rendering configs for this charm

# /etc/gitlab-runner/config.toml
function render-global-config-toml () {
  juju-log -l 'INFO' 'Rendering /etc/gitlab-runner/config.toml'
  concurrent=$(config-get concurrent)
  checkinterval=$(config-get check-interval)
  sentrydsn=$(config-get sentry-dsn)
  loglevel=$(config-get log-level)
  logformat=$(config-get log-format)
  export concurrent checkinterval sentrydsn loglevel logformat 
  eval "echo \"$(<templates/etc/gitlab-runner/config.toml)\"" 2> /dev/null > /etc/gitlab-runner/config.toml
}

#
# This function renders a runner-template
# used with the gitlab-runner register command.
# for advanced configurations
#
function render-docker-runner-template () {
    dockerimage=$(config-get docker-image)
    export dockerimage
    eval "echo \"$(<templates/runner-templates/docker-1.template)\"" 2> /dev/null > /tmp/runner-template-config.toml
}
