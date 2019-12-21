#!/bin/bash -x

# : "${GITHUB_WORKSPACE?GITHUB_WORKSPACE has to be set. Did you use the actions/checkout action?}"
# pushd ${GITHUB_WORKSPACE}

molecule ${INPUT_OPTIONS} ${INPUT_COMMAND} ${INPUT_ARGS}
