"""Setup script for galaxy-collision-refraction supporting optional native Cython compilation on install."""

from setuptools import setup, Extension
import sys

ext_modules = []

try:
    from Cython.Build import cythonize
    ext_modules = cythonize(
        [
            Extension(
                "galaxy_collision_refraction.physics_fast",
                ["src/galaxy_collision_refraction/physics_fast.pyx"],
                extra_compile_args=["-O3", "-ffast-math"],
            )
        ],
        compiler_directives={"language_level": "3"},
    )
except Exception:
    # If Cython or a C compiler is not available during installation,
    # continue installing the pure Python package cleanly.
    ext_modules = []

setup(
    ext_modules=ext_modules,
)
