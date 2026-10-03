#!/usr/bin/env python3
"""Build script for galaxy-collision-refraction distribution packages (sdist and wheel)."""

from __future__ import annotations

import hashlib
import sys
import tarfile
import zipfile
from pathlib import Path

PACKAGE_NAME = "galaxy_collision_refraction"
DIST_NAME = "galaxy-collision-refraction"
VERSION = "0.1.2"
AUTHOR = "Barry Schwartz"
AUTHOR_EMAIL = "150643+chemoelectric@users.noreply.github.com"
SUMMARY = "Realistic interactive simulation of colliding spiral galaxies modeled as energy density clouds in wave refraction theory"


def sha256_checksum(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def build_sdist(root_dir: Path, dist_dir: Path) -> Path:
    sdist_name = f"{DIST_NAME}-{VERSION}.tar.gz"
    sdist_path = dist_dir / sdist_name

    with tarfile.open(sdist_path, "w:gz") as tar:
        prefix = f"{DIST_NAME}-{VERSION}"

        for meta_file in ["pyproject.toml", "README.md", "LICENSE"]:
            p = root_dir / meta_file
            if p.exists():
                tar.add(p, arcname=f"{prefix}/{meta_file}")

        src_dir = root_dir / "src"
        if src_dir.exists():
            for p in sorted(src_dir.rglob("*")):
                if p.is_file() and p.suffix in (".py",):
                    rel_path = p.relative_to(root_dir)
                    tar.add(p, arcname=f"{prefix}/{rel_path}")

    print(f"Built sdist: {sdist_path.name} ({sdist_path.stat().st_size} bytes)")
    return sdist_path


def build_wheel(root_dir: Path, dist_dir: Path) -> Path:
    wheel_name = f"{PACKAGE_NAME}-{VERSION}-py3-none-any.whl"
    wheel_path = dist_dir / wheel_name
    dist_info = f"{PACKAGE_NAME}-{VERSION}.dist-info"

    readme_content = (root_dir / "README.md").read_text(encoding="utf-8")

    metadata_content = f"""Metadata-Version: 2.1
Name: {DIST_NAME}
Version: {VERSION}
Summary: {SUMMARY}
Home-page: https://github.com/chemoelectric/the-iris-number-system
Author: {AUTHOR}
Author-email: {AUTHOR_EMAIL}
License: MIT
Keywords: galaxy-collision,spiral-galaxies,astrophysics,tidal-tails,wave-refraction,optics,simulation,pyglet,dual-window
Classifier: Development Status :: 4 - Beta
Classifier: Intended Audience :: Science/Research
Classifier: Intended Audience :: Education
Classifier: License :: OSI Approved :: MIT License
Classifier: Operating System :: OS Independent
Classifier: Programming Language :: Python :: 3
Classifier: Topic :: Scientific/Engineering :: Astronomy
Classifier: Topic :: Scientific/Engineering :: Physics
Classifier: Topic :: Scientific/Engineering :: Visualization
Requires-Python: >=3.9
Description-Content-Type: text/markdown
Requires-Dist: pyglet>=2.0.0

{readme_content}
"""

    wheel_content = """Wheel-Version: 1.0
Generator: galaxy-collision-dist-builder 0.1.0
Root-Is-Purelib: true
Tag: py3-none-any
"""

    entry_points_content = f"""[console_scripts]
{DIST_NAME} = {PACKAGE_NAME}.app:main
"""

    record_entries = []

    with zipfile.ZipFile(wheel_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        src_pkg_dir = root_dir / "src" / PACKAGE_NAME
        for pkg_file in sorted(src_pkg_dir.iterdir()):
            if pkg_file.is_file() and pkg_file.suffix == ".py":
                rel_arc = f"{PACKAGE_NAME}/{pkg_file.name}"
                data = pkg_file.read_bytes()
                zf.writestr(rel_arc, data)
                chk = sha256_checksum(data)
                record_entries.append(f"{rel_arc},{chk},{len(data)}")

        meta_bytes = metadata_content.encode("utf-8")
        zf.writestr(f"{dist_info}/METADATA", meta_bytes)
        record_entries.append(f"{dist_info}/METADATA,{sha256_checksum(meta_bytes)},{len(meta_bytes)}")

        wheel_bytes = wheel_content.encode("utf-8")
        zf.writestr(f"{dist_info}/WHEEL", wheel_bytes)
        record_entries.append(f"{dist_info}/WHEEL,{sha256_checksum(wheel_bytes)},{len(wheel_bytes)}")

        ep_bytes = entry_points_content.encode("utf-8")
        zf.writestr(f"{dist_info}/entry_points.txt", ep_bytes)
        record_entries.append(f"{dist_info}/entry_points.txt,{sha256_checksum(ep_bytes)},{len(ep_bytes)}")

        record_entries.append(f"{dist_info}/RECORD,,")
        record_content = "\n".join(record_entries) + "\n"
        zf.writestr(f"{dist_info}/RECORD", record_content.encode("utf-8"))

    print(f"Built wheel: {wheel_path.name} ({wheel_path.stat().st_size} bytes)")
    return wheel_path


def main() -> None:
    root_dir = Path(__file__).resolve().parent
    dist_dir = root_dir / "dist"
    dist_dir.mkdir(exist_ok=True)

    print(f"Building distribution archives for {DIST_NAME}...")
    sdist = build_sdist(root_dir, dist_dir)
    wheel = build_wheel(root_dir, dist_dir)

    print("\nSuccess! Both sdist and wheel built in dist/:")
    print(f"  - {sdist}")
    print(f"  - {wheel}")


if __name__ == "__main__":
    main()
