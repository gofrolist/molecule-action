import toml


def read_version_from_pyproject():
    """Read the current version from the pyproject.toml file."""
    with open("pyproject.toml", "r") as file:
        data = toml.load(file)
        return data["tool"]["poetry"]["version"]


def update_action_yml(tag_name, template_path="action.yml.tpl", output_path="action.yml"):
    """Update the action.yml file from a template."""
    with open(template_path, "r") as file:
        template_content = file.read()

    updated_content = template_content.replace("{TAG_NAME}", tag_name)

    with open(output_path, "w") as file:
        file.write(updated_content)


if __name__ == "__main__":
    version = read_version_from_pyproject()
    update_action_yml(version)
