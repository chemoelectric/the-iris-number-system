"""Optional Cython build setup for galaxy-collision-refraction."""

from setuptools import setup, Extension
import sys

ext_modules = []
cmdclass = {}

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
except ImportError:
    pass

setup(
    ext_modules=ext_modules,
)
