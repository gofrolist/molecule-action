FROM python:3.8-alpine AS builder

ARG BUILD_DEPS="\
    gcc \
    libc-dev \
    make \
    musl-dev \
    libffi-dev \
    openssl-dev \
    "

ARG PIP_INSTALL_ARGS="\
    --no-cache-dir \
    "

ARG PIP_MODULES="\
    ansible-lint \
    flake8 \
    molecule[docker] \
    pytest \
    "

RUN apk add --update --no-cache ${BUILD_DEPS} && \
    pip install ${PIP_INSTALL_ARGS} ${PIP_MODULES}

FROM python:3.8-alpine

LABEL "maintainer"="Eugene Vasilenko <gmrnsk@gmail.com>"
LABEL "repository"="https://github.com/gofrolist/molecule-action"

LABEL "com.github.actions.name"="molecule"
LABEL "com.github.actions.description"="Run Ansible Molecule"
LABEL "com.github.actions.icon"="upload"
LABEL "com.github.actions.color"="green"

ARG PACKAGES="\
    docker \
    git \
    openssh-client \
    "

RUN apk add --update --no-cache ${PACKAGES} && \
    rm -rf /root/.cache

COPY --from=builder /usr/local/lib/python3.8/site-packages/ /usr/local/lib/python3.8/site-packages/
COPY --from=builder /usr/local/bin/ansible* /usr/local/bin/
COPY --from=builder /usr/local/bin/flake8   /usr/local/bin/flake8
COPY --from=builder /usr/local/bin/molecule /usr/local/bin/molecule
COPY --from=builder /usr/local/bin/pytest   /usr/local/bin/pytest
COPY --from=builder /usr/local/bin/yamllint /usr/local/bin/yamllint

CMD cd ${INPUT_MOLECULE_WORKING_DIR}; molecule ${INPUT_MOLECULE_OPTIONS} ${INPUT_MOLECULE_COMMAND} ${INPUT_MOLECULE_ARGS}
