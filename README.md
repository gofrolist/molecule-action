# Molecule for GitHub Action
This GitHub action allows you to run [Molecule](https://molecule.readthedocs.io/en/stable/) to test [Ansible](https://www.ansible.com/) role.

## Inputs

```yaml
  molecule_options:
    description: |
      Options:
        --debug / --no-debug    Enable or disable debug mode. Default is disabled.
        -v, --verbose           Increase Ansible verbosity level. Default is 0.  [x>=0]
        -c, --base-config TEXT  Path to a base config (can be specified multiple times). If provided, Molecule will first load and deep merge the configurations in the specified order, and deep merge each scenario's molecule.yml on top. By default Molecule is looking for
                                '.config/molecule/config.yml' in current VCS repository and if not found it will look in user home. (None).
        -e, --env-file TEXT     The file to read variables from when rendering molecule.yml. (.env.yml)
        --version
        --help                  Show this message and exit.
    required: false

  molecule_command:
    description: |
      Commands:
        check        Use the provisioner to perform a Dry-Run (destroy, dependency, create, prepare, converge).
        cleanup      Use the provisioner to cleanup any changes made to external systems during the stages of testing.
        converge     Use the provisioner to configure instances (dependency, create, prepare converge).
        create       Use the provisioner to start the instances.
        dependency   Manage the role's dependencies.
        destroy      Use the provisioner to destroy the instances.
        drivers      List drivers.
        idempotence  Use the provisioner to configure the instances and parse the output to determine idempotence.
        init         Initialize a new role or scenario.
        lint         Lint the role (dependency, lint).
        list         List status of instances.
        login        Log in to one instance.
        matrix       List matrix of steps used to test instances.
        prepare      Use the provisioner to prepare the instances into a particular starting state.
        reset        Reset molecule temporary folders.
        side-effect  Use the provisioner to perform side-effects to the instances.
        syntax       Use the provisioner to syntax check the role.
        test         Test (dependency, lint, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy).
        verify       Run automated tests against instances.
    required: true
    default: 'test'

  molecule_args:
    description: |
      Arguments:
        -s, --scenario-name TEXT        Name of the scenario to target. (default)
        -d, --driver-name [delegated|docker]
                                        Name of driver to use. (delegated)
        --all / --no-all                Test all scenarios. Default is False.
        --destroy [always|never]        The destroy strategy used at the conclusion of a Molecule run (always).
        --parallel / --no-parallel      Enable or disable parallel mode. Default is disabled.
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
          - centos-8
          - debian-10
          - fedora-34
          - oraclelinux-8
          - ubuntu-20.04
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

> TIP: N.B. Use `gofrolist/molecule-action@v2` or any other valid tag, or branch, or commit SHA instead of `v2` to pin the action to use a specific version.

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
