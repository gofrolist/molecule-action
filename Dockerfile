FROM python:3.8-alpine AS builder

ARG BUILD_DEPS="\
    gcc=9.3.0-r2 \
    libc-dev=0.7.2-r3 \
    make=4.3-r0 \
    musl-dev=1.1.24-r10 \
    libffi-dev=3.3-r2 \
    openssl-dev=1.1.1i-r0 \
    "

ARG PIP_INSTALL_ARGS="\
    --no-cache-dir \
    "

ARG PIP_MODULES="\
    ansible-lint==4.3.7 \
    flake8==3.8.4 \
    molecule[docker]==3.2.1 \
    testinfra==6.0.0 \
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
    docker=19.03.12-r0 \
    git=2.26.2-r0 \
    openssh-client=8.3_p1-r1 \
    "

RUN apk add --update --no-cache ${PACKAGES} && \
    rm -rf /root/.cache

COPY --from=builder /usr/local/lib/python3.8/site-packages/ /usr/local/lib/python3.8/site-packages/
COPY --from=builder /usr/local/bin/ansible*  /usr/local/bin/
COPY --from=builder /usr/local/bin/flake8    /usr/local/bin/flake8
COPY --from=builder /usr/local/bin/molecule  /usr/local/bin/molecule
COPY --from=builder /usr/local/bin/pytest    /usr/local/bin/pytest
COPY --from=builder /usr/local/bin/yamllint  /usr/local/bin/yamllint

CMD cd ${INPUT_MOLECULE_WORKING_DIR}; molecule ${INPUT_MOLECULE_OPTIONS} ${INPUT_MOLECULE_COMMAND} ${INPUT_MOLECULE_ARGS}
