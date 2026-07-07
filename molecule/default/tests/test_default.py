"""Testinfra tests for the CI fixture scenario.

Exercises the bundled pytest-testinfra verifier end-to-end
(see https://github.com/gofrolist/molecule-action/issues/245).
"""


def test_instance_is_reachable(host):
    assert host.run("true").rc == 0


def test_python_is_installed(host):
    assert host.exists("python3")
