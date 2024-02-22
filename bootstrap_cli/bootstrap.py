def create_bootstrap_cmd(args):
    print("Creating bootstrap project")


def add_bootstrap_arg_parser(subparsers):
    parser_bootstrap = subparsers.add_parser(
        "bootstrap-project", help="help for bootstrapping a project"
    )
    parser_bootstrap.add_argument(
        "--arg1",
        type=str,
        help="arg1 help",
    )
    parser_bootstrap.add_argument("--arg2", type=str, required=True, help="arg2 help")

    parser_bootstrap.set_defaults(func=create_bootstrap_cmd)
