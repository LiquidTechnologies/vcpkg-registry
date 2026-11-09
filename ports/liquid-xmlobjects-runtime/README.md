The vcpkg port of the runtime. Releases are published to the vcpkg registry https://github.com/LiquidTechnologies/vcpkg-registry (see its README to use
it) by .github/workflows/package.yml with scripts/VcpkgRegistry.py, and the copy in the registry is this one. The source of the runtime is not public, so the
port can not download it : it is installed from the binary packages that the workflow builds (with LX_SOURCE_DIR, below) and publishes to the binary cache.

To build this copy of the port from a checkout of the source, set LX_SOURCE_DIR to it :

    set LX_SOURCE_DIR=<this repo>
    set VCPKG_KEEP_ENV_VARS=LX_SOURCE_DIR
    vcpkg install liquid-xmlobjects-runtime --overlay-ports=<this repo>/ports

The license is the Liquid Technologies EULA in LICENSE.txt : vcpkg.json names it LicenseRef-LiquidTechnologies-EULA, and the portfile installs
LICENSE.txt as the package's copyright file.
