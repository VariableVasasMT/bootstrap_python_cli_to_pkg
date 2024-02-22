# Mindtickle CLI

The Mindtickle CLI is a command-line interface tool designed to facilitate various tasks for Mindtickle developers, including Airflow project initialization, environment setup, and more.

## Installation

To install the Mindtickle CLI, you need to have Python installed on your system. It's recommended to use a virtual environment for Python projects to manage dependencies effectively.

### Using pip

You can install the latest version directly from GitLab using pip:

```bash
pip install git+https://gitlab.com/mindtickle/data-platform/ndp_cli.git
```

### Development Installation

If you are developing or contributing to the Mindtickle CLI, clone the repository and install the package in editable mode:

```bash
git clone https://gitlab.com/mindtickle/data-platform/ndp_cli.git
cd ndp_cli
pip install -e .
```

### Usage

After installation, you can use the mtcli command to access various functionalities. Here are some examples:

- To get help on the command-line interface: `mtcli --help`
- To initialize a new Airflow project: `mtcli airflow-helm --domain_name yourdomain.com`

More detailed usage instructions for specific commands can be found by using the --help flag with the command.

### Contributing

Contributions to the Mindtickle CLI are welcome! Please follow these steps to contribute:

### Fork the repository on GitLab.

1. Clone your forked repository to your local machine.
2. Create a new branch for your feature or fix.
3. Make your changes and test them thoroughly.
4. Commit your changes and push them to your fork.
5. Open a merge request against the main ndp_cli repository.
6. Please ensure your code adheres to the project's coding standards and include tests for new features or fixes.
