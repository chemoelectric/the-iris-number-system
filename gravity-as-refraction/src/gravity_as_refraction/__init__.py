"""gravity-as-refraction

Visualizing gravitation as wave refraction in the universal electromagnetic field.
Interactive orbital simulator of circulating wave packet matter knots.
"""

__version__ = "0.2.0"
__author__ = "Barry Schwartz"
__license__ = "MIT"

from .physics import (
    MatterKnot,
    RefractionField,
    create_circular_orbit,
    create_elliptic_orbit,
    create_rosette_orbit,
    create_scattering_orbit,
    maxent_gravitational_constant,
)

__all__ = [
    "MatterKnot",
    "RefractionField",
    "create_circular_orbit",
    "create_elliptic_orbit",
    "create_rosette_orbit",
    "create_scattering_orbit",
    "maxent_gravitational_constant",
]
