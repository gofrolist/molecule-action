#!/bin/bash

set -x

: "${COMMAND?No command given. Nothing to do.}"
: "${GITHUB_WORKSPACE?GITHUB_WORKSPACE has to be set. Did you use the actions/checkout action?}"
pushd ${GITHUB_WORKSPACE}

molecule ${OPTIONS} ${COMMAND} ${ARGS}
