ARG PYTHON_VERSION=3.11.7-slim-bookworm

FROM python:${PYTHON_VERSION} AS builder

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=true \
    POETRY_VIRTUALENVS_IN_PROJECT=true

ARG BUILD_DEPS="\
    docker \
    gcc \
    libc-dev \
    libffi-dev \
    make \
    musl-dev \
    openssh-client \
    "

RUN apt-get update && \
    apt-get install --no-install-recommends -y ${BUILD_DEPS} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN --mount=type=cache,mode=0755,target=/root/.cache/pip \
    pip install \
        --upgrade \
        pip \
        poetry \
        setuptools \
        wheel

RUN --mount=type=cache,mode=0755,target=/root/.cache/pypoetry \
    poetry install \
        --without dev \
        --no-root

##################
# runtime
##################

FROM python:${PYTHON_VERSION} AS runtime

LABEL "maintainer"="Evgenii Vasilenko <gmrnsk@gmail.com>"
LABEL "repository"="https://github.com/gofrolist/molecule-action"
LABEL "com.github.actions.name"="molecule"
LABEL "com.github.actions.description"="Run Ansible Molecule"
LABEL "com.github.actions.icon"="upload"
LABEL "com.github.actions.color"="green"

ENV PATH="/app/.venv/bin:$PATH"

WORKDIR /app
COPY --from=builder /app/.venv /app/.venv

ARG PACKAGES="\
    docker.io \
    git \
    openssh-client \
    podman \
    rsync \
    tini \
    "

RUN apt-get update && \
    apt-get install --no-install-recommends -y ${PACKAGES} && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD cd ${INPUT_MOLECULE_WORKING_DIR}; molecule ${INPUT_MOLECULE_OPTIONS} ${INPUT_MOLECULE_COMMAND} ${INPUT_MOLECULE_ARGS}
