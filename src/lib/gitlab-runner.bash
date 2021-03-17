#
# Auxillary functions for the gitlab-runner charm
#

function gitlab-runner-status () {
    # Figure out if gitlab runner is running
    if [[ $(sudo gitlab-runner status) ]]; then
        return 0
    else
	return 1
    fi
}

function gitlab-runner-register () {
    # Desc: This function registers a gitlab-runner
    #       with the hostname.
    #       ONLY if its not already registered.
    #       with the CLI.
    #
    # Args: 1: <string: gitlab-registration-token>
    #       2: <list: tag_one,tag_two,tag_three,tag_n>
    #
    
    _gitlabregistrationtoken="${1}"
    _taglist=$(config-get tag-list)

    _gitlabserver=$(config-get gitlab-server)
    _dockerimage=$(config-get docker-image)
    
    _https_proxy=$(config-get https_proxy)
    _http_proxy=$(config-get http_proxy)

    # Set proxy if supplied as non empty.
    if [[ ! -z "$_https_proxy" ]] || [[ ! -z $_http_proxy ]]; then     
	_proxyenv="--env https_proxy=$_https_proxy --env http_proxy=$_http_proxy"
	export HTTPS_PROXY="$_https_proxy"
	export HTTP_PROXY="$_https_proxy"
    else
	_proxyenv=""
    fi

    # DEBUG set -x shows what is executed in logs.
    # set -x
    
    if gitlab-runner register --non-interactive \
		  --name "$(hostname --fqdn)" \
                  -u "${_gitlabserver}" \
                  -r "${_gitlabregistrationtoken}" \
                  --tag-list "${_taglist}" \
                  --executor "docker" \
                  --docker-image "${_dockerimage}" \
		  $_proxyenv; then
	
	juju-log "gitlab-runner registration succeeded"
	return 0
    else
	juju-log "gitlab-runner registration failed"
	return 1
    fi
}


function set-gitlab-runner-version () {
    _v=$(gitlab-runner --version | grep Version: | awk \{'print $2'\})
    application-version-set "${_v}"
}
