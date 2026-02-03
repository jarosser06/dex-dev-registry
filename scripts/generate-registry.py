#!/usr/bin/env python3
"""
Generates a registry.json file from packaged dex tarballs.

Scans build/packages/*.tar.gz and extracts package names and versions
to create a dex registry index.
"""

import json
import re
from pathlib import Path


def parse_package_filename(filename):
    """
    Parse a dex package filename to extract name and version.

    Expected format: <package-name>-<version>.tar.gz
    Example: base-dev-1.0.0.tar.gz -> (base-dev, 1.0.0)
    """
    match = re.match(r'^(.+?)-(\d+\.\d+\.\d+.*?)\.tar\.gz$', filename)
    if match:
        return match.group(1), match.group(2)
    return None, None


def main():
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    build_dir = project_root / "build"

    if not build_dir.exists():
        print(json.dumps({"packages": {}}, indent=2))
        return

    packages = {}

    for tarball in sorted(build_dir.glob("*.tar.gz")):
        name, version = parse_package_filename(tarball.name)

        if name and version:
            if name not in packages:
                packages[name] = {
                    "versions": [],
                    "latest": version
                }

            packages[name]["versions"].append(version)
            # Update latest to the highest version (assumes sorted order)
            packages[name]["latest"] = version

    registry = {"packages": packages}
    print(json.dumps(registry, indent=2))


if __name__ == "__main__":
    main()
