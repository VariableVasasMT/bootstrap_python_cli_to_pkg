import argparse

from bootstrap_cli.bootstrap import add_bootstrap_arg_parser
from bootstrap_cli.setup_env import add_arg_parser_to_cli


# Define the function to handle the CLI logic
def main():
    parser = argparse.ArgumentParser(description="CLI tool for various tasks")
    subparsers = parser.add_subparsers(help="sub-command help")

    add_bootstrap_arg_parser(subparsers)
    add_arg_parser_to_cli(subparsers)

    args = parser.parse_args()
    if hasattr(args, "func"):
        args.func(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
