"""Executable entry point when invoked as python -m gravity_as_refraction."""

try:
    from .cli import main
except ImportError:
    from cli import main

if __name__ == "__main__":
    main()
