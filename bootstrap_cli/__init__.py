# __init__.py
from .cli import main

print("Initializing your_cli_tool package")

# You can also import specific modules to the package namespace

# This is optional; it defines what "from your_cli_tool import *" will import:
__all__ = ["main"]
