FROM ghcr.io/astral-sh/uv:0.11.32 AS uv

FROM python:3.14.6-slim-trixie AS builder

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    UV_LINK_MODE=copy

ARG BUILD_DEPS="\
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

COPY --from=uv /uv /usr/local/bin/uv

WORKDIR /app
COPY pyproject.toml uv.lock ./

RUN --mount=type=cache,mode=0755,target=/root/.cache/uv \
    uv sync --frozen --no-dev && \
    # seed pip into the venv so users can install extra packages
    # (pytest plugins, collection python deps) at runtime
    uv pip install pip

##################
# runtime
##################

FROM python:3.14.6-slim-trixie AS runtime

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
    docker-cli \
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
CMD ["/bin/sh", "-c", "cd \"${INPUT_MOLECULE_WORKING_DIR}\" && molecule ${INPUT_MOLECULE_OPTIONS} ${INPUT_MOLECULE_COMMAND} ${INPUT_MOLECULE_ARGS}"]
