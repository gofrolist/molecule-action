# Ansible Molecule for GitHub Action
This action allows you to run `molecule` (https://molecule.readthedocs.io/).


## Usage
To use the action simply create an `molecule.yml` (or choose custom `*.yml` name) in the `.github/workflows/` directory.

For example:

```yaml
name: Ansible Molecule  # feel free to pick your own name

on: push

jobs:
  molecule:
    runs-on: ubuntu-latest
    name: Run Ansible Molecule
    steps:
      - name: Checkout
        uses: actions/checkout@v1
      - name: Ansible Molecule action step
        uses: gofrolist/molecule-action@master
        with:
          options: '--base-config molecule/_shared/base.yml'
          command: 'test'
          args: '--scenario-name centos-7'

```

> TIP: N.B. Use `gofrolist/molecule-action@v1.0.0` or any other valid tag, or branch, or commit SHA instead of `v1.0.0` to pin the action to use a specific version.

Alternatively, you can run the ansible molecule only on certain branches:

```yaml
on:
  push:
    branches:
    - stable
    - release/v*

```

or on various [events](https://help.github.com/en/articles/events-that-trigger-workflows):

```yaml
on: [push, pull_request]
```

<br>

## License
The Dockerfile and associated scripts and documentation in this project are released under the [MIT](license).
