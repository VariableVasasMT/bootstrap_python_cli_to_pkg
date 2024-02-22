import os


def set_env_help(args):
    print("How to Set Environment Variables:")
    print("1. To set the ENV_NAME_IN_SHELL, you need to get it from wherever!")
    print(
        "2. For GITLAB_TOKEN, you should get it from https://gitlab.com/-/profile/personal_access_tokens"
    )
    # Add more instructions as needed
    print(
        "\nYou can set these variables temporarily in your shell or permanently by adding them to your shell's configuration file (e.g., .bashrc or .zshrc)."
    )


def set_env_variables(args):
    home_dir = os.path.expanduser("~")
    shell = os.path.basename(os.environ.get("SHELL", "/bin/bash"))
    config_file = ".bashrc" if "bash" in shell else ".zshrc" if "zsh" in shell else None

    if not config_file:
        print("Unsupported shell.")
        return

    config_path = os.path.join(home_dir, config_file)
    env_vars = ""
    if args.env_var_1 is not None:
        os.environ["ENV_NAME_IN_SHELL"] = args.env_var_1
        env_vars += f'export ENV_NAME_IN_SHELL="{args.env_var_1}"\n'
    if args.gitlab_token is not None:
        os.environ["GITLAB_TOKEN"] = args.gitlab_token
        env_vars += f'export GITLAB_TOKEN="{args.gitlab_token}"\n'

    with open(config_path, "a") as file:
        file.write(f"\n# Set by mindtickle_cli\n{env_vars}")

    print(
        f"Environment variables added to {config_file}. Please restart your shell or source the file to apply changes."
    )


def add_arg_parser_to_cli(subparsers):
    # Subparser for setting environment variables
    parser_env = subparsers.add_parser(
        "set-env", help="Set and save environment variables"
    )

    existing_key = os.getenv("ENV_NAME_IN_SHELL")
    parser_env.add_argument(
        "--env-1",
        dest="env_var_1",
        type=str,
        help="Environment variable name in shell",
        default=existing_key,
    )

    ## for example, if you want to add gitlab token in environment variable
    parser_env.add_argument(
        "--gitlab_token",
        type=str,
        help="get gitlab token from https://gitlab.com/-/profile/personal_access_tokens",
    )
    parser_env.set_defaults(func=set_env_variables)
    parser_env_help = subparsers.add_parser(
        "set-env-help", help="Get help on setting environment variables"
    )
    parser_env_help.set_defaults(func=set_env_help)
