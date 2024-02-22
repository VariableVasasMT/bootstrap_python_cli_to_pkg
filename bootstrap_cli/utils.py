import os
import sys


def extract_repository_name(full_string):
    # Split the string by '/'
    parts = full_string.split("/")

    # The repository name is expected to be the last part
    repo_name = parts[-1] if parts else None

    return repo_name


def check_env_variables(required_vars):
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    if missing_vars:
        print(
            f"Error: Missing required environment variables: {', '.join(missing_vars)}"
        )
        print("Use 'mtcli set-env-help' for guidance on setting these variables.")
        sys.exit(1)
