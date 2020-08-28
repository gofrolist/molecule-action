# Molecule for GitHub Action
This GitHub action allows you to run [Molecule](https://molecule.readthedocs.io/en/stable/) to test [Ansible](https://www.ansible.com/) role.

## Inputs

```yaml
  molecule_options:
    description: |
      Options:
        --debug / --no-debug    Enable or disable debug mode. Default is disabled.
        -c, --base-config TEXT  Path to a base config.  If provided Molecule will
                                load this config first, and deep merge each
                                scenario's molecule.yml on top.
                                (/home/gofrolist/.config/molecule/config.yml)
        -e, --env-file TEXT     The file to read variables from when rendering
                                molecule.yml. (.env.yml)
        --version               Show the version and exit.
        --help                  Show this message and exit.
    required: false

  molecule_command:
    description: |
      Commands:
        check        Use the provisioner to perform a Dry-Run...
        cleanup      Use the provisioner to cleanup any changes...
        converge     Use the provisioner to configure instances...
        create       Use the provisioner to start the instances.
        dependency   Manage the role's dependencies.
        destroy      Use the provisioner to destroy the instances.
        idempotence  Use the provisioner to configure the...
        init         Initialize a new role or scenario.
        lint         Lint the role.
        list         Lists status of instances.
        login        Log in to one instance.
        matrix       List matrix of steps used to test instances.
        prepare      Use the provisioner to prepare the instances...
        side-effect  Use the provisioner to perform side-effects...
        syntax       Use the provisioner to syntax check the role.
        test         Test (lint, cleanup, destroy, dependency,...
        verify       Run automated tests against instances.
    required: true
    default: 'test'

  molecule_args:
    description: |
      Arguments:
        --scenario-name foo  Targeting a specific scenario.
        --driver-name foo    Targeting a specific driver.
        --all                Target all scenarios.
        --destroy=always     Always destroy instances at the conclusion of a Molecule run.
    required: false

    molecule_working_dir:
    description: |
      Path to another directory in the repository, where molecule command will be issued from.
      Useful in those cases where Ansible roles are not in git repository root.
    required: false
    default: '${GITHUB_REPOSITORY}'
```

## Usage
To use the action simply create an `main.yml` (or choose custom `*.yml` name) in the `.github/workflows/` directory.

### Basic example:

```yaml
on: push

jobs:
  molecule:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          path: "${{ github.repository }}"
      - uses: gofrolist/molecule-action@v2
```

>NOTE: By default molecule is going to look for configuration at `molecule/*/molecule.yml`, so if option `molecule-working-dir` is not provided, 
>checkout action needs to place the file in ${{ github.repository }} in order for Molecule to find your role. If your role is placed somewhere else
>in the repository, ensure that `molecule-working-dir` is set up accordingly, in order to `cd` to that directory before issuing `molecule` command.

### Advanced example:

```yaml
name: Molecule

on:
  push:
    branches:
      - master
      - release/v*
  pull_request:
    branches:
      - master

jobs:
  molecule:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        scenario:
          - centos-7
          - debian-9
          - fedora-28
          - oraclelinux-7
          - ubuntu-18.04
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        with:
          path: "${{ github.repository }}"
      - name: Molecule
        uses: gofrolist/molecule-action@v2
        with:
          molecule_options: --debug --base-config molecule/_shared/base.yml
          molecule_command: test
          molecule_args: --scenario-name ${{ matrix.scenario }}
```

> TIP: N.B. Use `gofrolist/molecule-action@v1.0.0` or any other valid tag, or branch, or commit SHA instead of `v1.0.0` to pin the action to use a specific version.

If your role require some python modules (for example `netaddr`) you can install them in molecule prepare step

```yaml
---
- name: Prepare
  hosts: all

  tasks:
    - name: Install netaddr dependency on controlling host (virtualenv)
      pip:
        name: netaddr
      delegate_to: 127.0.0.1
```

## License
The Dockerfile and associated scripts and documentation in this project are released under the [MIT](license).
