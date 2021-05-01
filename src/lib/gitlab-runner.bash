#
# Auxillary functions for the gitlab-runner charm
#
source lib/render.bash

function check_mandatory_config_values () {
    juju-log DEBUG "${FUNCNAME[0]}"
  # Check that config values are OK
  _gitlabregistrationtoken=$(config-get gitlab-registration-token)
  _gitlabserver=$(config-get gitlab-server)
  _executor=$(config-get executor)

  if [[ -z "$_gitlabregistrationtoken" ]] || \
     [[ -z "$_gitlabserver" ]] || \
     [[ -z "$_executor" ]]; then
    return 1
  else
    return 0
  fi
}


function gitlab-runner-status () {
    juju-log DEBUG "${FUNCNAME[0]}"
    # Figure out if gitlab runner is running
    if [[ $(sudo gitlab-runner status) ]]; then
        return 0
    else
	return 1
    fi
}


function register-lxd () {
    juju-log DEBUG "${FUNCNAME[0]}"
# Register a custom runner (lxd)
    _gitlabregistrationtoken=$(config-get gitlab-registration-token)
    _taglist=$(config-get tag-list)
    _gitlabserver=$(config-get gitlab-server)
    _concurrent=$(config-get concurrent)
    
    _https_proxy=$(config-get https_proxy)
    _http_proxy=$(config-get http_proxy)
    # Set proxy if supplied as non empty.
    if [[ -n "$_https_proxy" ]] || [[ -n $_http_proxy ]]; then
	_proxyenv="--env https_proxy=$_https_proxy --env http_proxy=$_http_proxy"
	export HTTPS_PROXY="$_https_proxy"
	export HTTP_PROXY="$_https_proxy"
    else
	_proxyenv=""
    fi

    if [ -z "${_taglist}" ]; then
	rununtagged="true"
    else
	rununtagged="false"	
    fi
    
    
    if gitlab-runner register \
                     --non-interactive \
		     --request-concurrency "$_concurrent" \
                     --url "${_gitlabserver}" \
                     --tag-list "${_taglist}" \
		     --run-untagged="$rununtagged" \
                     --registration-token "${_gitlabregistrationtoken}" \
                     --name "$(hostname --fqdn)" \
                     --executor custom \
                     --builds-dir /builds \
                     --cache-dir /cache \
                     --custom-run-exec /opt/lxd-executor/run.sh \
                     --custom-prepare-exec /opt/lxd-executor/prepare.sh \
                     --custom-cleanup-exec /opt/lxd-executor/cleanup.sh ; then

	juju-log "gitlab-runner (lxd) registration succeeded"
	return 0
    else
	juju-log "gitlab-runner (lxd) registration failed"
	return 1
    fi
}


function register-docker () {
    juju-log DEBUG "${FUNCNAME[0]}"
    # Desc: This function registers a gitlab-runner docker
    #       with the hostname.
    #       ONLY if its not already registered.
    #       with the CLI.
    #
    # Args: 1: <string: gitlab-registration-token>
    
    _gitlabregistrationtoken=$(config-get gitlab-registration-token)
    _taglist=$(config-get tag-list)

    _gitlabserver=$(config-get gitlab-server)
    _dockerimage=$(config-get docker-image)
    _concurrent=$(config-get concurrent)
    
    _https_proxy=$(config-get https_proxy)
    _http_proxy=$(config-get http_proxy)

    # Set proxy if supplied as non empty.
    if [[ -n "$_https_proxy" ]] || [[ -n $_http_proxy ]]; then
	_proxyenv="--env https_proxy=$_https_proxy --env http_proxy=$_http_proxy"
	export HTTPS_PROXY="$_https_proxy"
	export HTTP_PROXY="$_https_proxy"
    else
	_proxyenv=""
    fi

    # DEBUG set -x shows what is executed in logs.
    # set -x

    # First render global configs
    render-global-config-toml

    # Second render runner template.
    render-docker-runner-template

    # Third, register...
    
    if [ -z "${_taglist}" ]; then
	rununtagged="true"
    else
	rununtagged="false"	
    fi

    # Perform registration with custom runner template.
    if gitlab-runner register \
		  --non-interactive \
	          --config /etc/gitlab-runner/config.toml \
		  --template-config /tmp/runner-template-config.toml \
		  --name "$(hostname --fqdn)" \
                  --url "${_gitlabserver}" \
                  --registration-token "${_gitlabregistrationtoken}" \
                  --tag-list "${_taglist}" \
		  --request-concurrency "$_concurrent" \
		  --run-untagged="$rununtagged" \
                  --executor "docker" \
                  --docker-image "${_dockerimage}" \
		  $_proxyenv; then
	
	juju-log "gitlab-runner (docker executor) registration succeeded"
	return 0
    else
	juju-log "gitlab-runner (docker executor) registration failed"
	return 1
    fi
}


function gitlab-runner-register () {
    juju-log DEBUG "${FUNCNAME[0]}"
    if ! check_mandatory_config_values; then
	juju ERROR "Trying to register with incomplete config."
	return 1
    fi
    
    _executor=$(config-get executor)
    if [ "$_executor" == "lxd" ]; then
	register-lxd
    elif [ "$_executor" == "docker" ]; then
	register-docker
    else
	juju-log ERROR "Unsupported executor configured, bailing out."
	exit 1
    fi
}


function set-gitlab-runner-version () {
    juju-log DEBUG "${FUNCNAME[0]}"
    # Sets version for the juju application
    _v=$(gitlab-runner --version | grep Version: | awk \{'print $2'\})
    application-version-set "${_v}"
}


function install-lxd-executor () {
    juju-log DEBUG "${FUNCNAME[0]}"
    # Installs lxd executor deps and mods
    useradd -g lxd gitlab-runner
    mkdir -p /opt/lxd-executor
    cp templates/lxd-executor/{base.sh,cleanup.sh,prepare.sh,run.sh} /opt/lxd-executor/
    chmod +x /opt/lxd-executor/{base.sh,cleanup.sh,prepare.sh,run.sh}
    lxd init --auto
}


function install-docker-executor () {
    juju-log DEBUG "${FUNCNAME[0]}"
    # Installs docker executor deps and mods
    sudo apt install -y docker.io
    systemctl start docker.service
}
