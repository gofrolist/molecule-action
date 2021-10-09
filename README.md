# Molecule for GitHub Action
[![Docker Pulls](https://img.shields.io/docker/pulls/gofrolist/molecule)](https://hub.docker.com/r/gofrolist/molecule)
[![License](https://img.shields.io/github/license/gofrolist/molecule-action)](LICENSE)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

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

## Troubleshooting
If you see this error while you executing `apt_key` task
```
FAILED! => {"changed": false, "msg": "Failed to find required executable gpg in paths: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"}
```
That means your docker image require some python modules `gpg` and you can install them in molecule prepare step or embed it in your dockerfile.
```yaml
---
- name: Prepare
  hosts: all

  tasks:
    - name: dependency for apt_key
      apt:
        name: python3-gpg
        state: present
        update_cache: true
```

If you see this error while you executing `pip` task
```
FAILED! => {"changed": false, "msg": "No package matching 'python-pip' is available"}
```
That means your docker image is missing `pip` and you can install them in molecule prepare step or embed it in your dockerfile.
```yaml
---
- name: Prepare
  hosts: all

  tasks:
    - name: dependency for pip
      apt:
        name: python3-pip
        state: present
        update_cache: true
```

## Maintenance

> Make the new release available to those binding to the major version tag: Move the major version
> tag (v1, v2, etc.) to point to the ref of the current release. This will act as the stable release
> for that major version. You should keep this tag updated to the most recent stable minor/patch
> release.

```sh
git tag -fa v2 -m "Update v2 tag" && git push origin v2 --force
```

**Reference**:
https://github.com/actions/toolkit/blob/master/docs/action-versioning.md#recommendations

## License
The Dockerfile and associated scripts and documentation in this project are released under the [MIT](license).
