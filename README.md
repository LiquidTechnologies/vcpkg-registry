# Liquid Technologies vcpkg registry

A [vcpkg](https://vcpkg.io) registry for the Liquid Technologies libraries.

| Port | What it is |
|---|---|
| `liquid-xmlobjects-runtime` | The C++17 runtime of [Liquid XML Objects](https://www.liquid-technologies.com/) : reads and writes XML into the classes that Liquid XML Objects generates (`-L:Cpp`). |

The libraries are under the Liquid Technologies EULA (`LicenseRef-LiquidTechnologies-EULA`), which is in the package (`share/<port>/copyright`).

## Binary packages only

The source of the runtime is not public. This registry only describes the packages (the ports) : vcpkg installs them from the **binary packages** that Liquid
Technologies publishes, which it gets from a binary cache. You need both :

1. this registry, to know what the package is (`vcpkg-configuration.json`, below), and
2. the Liquid Technologies binary cache in `VCPKG_BINARY_SOURCES`, to get the binaries.

Without the binary cache vcpkg has nothing to build the port from, and stops with *"liquid-xmlobjects-runtime is only available as a binary package"*.

### The binary cache

```
set VCPKG_BINARY_SOURCES=clear;http,<the url of the binary cache>/{sha}.zip,read,Authorization: Basic <your credentials>
```

(Or `export VCPKG_BINARY_SOURCES=...` on Linux and macOS.) The url and credentials are given to licensed users by Liquid Technologies. vcpkg only uses a binary
package that was built with the same port, triplet and compiler (the packages are built on the GitHub runners : Visual Studio 2022 on Windows), so use one of the
triplets below with the same compiler, or vcpkg finds no package. Dependencies (RTTR, pugixml, rapidjson) are in the cache as well. They have to be the versions of the same vcpkg baseline as the packages were built
with, so use the `baseline` of microsoft/vcpkg that is given with the cache.

## Using it

Add the registry to the `vcpkg-configuration.json` next to the `vcpkg.json` of your project, and ask for the port in `vcpkg.json`.

`vcpkg-configuration.json`

```json
{
  "default-registry": {
    "kind": "git",
    "repository": "https://github.com/microsoft/vcpkg",
    "baseline": "<the baseline of microsoft/vcpkg that the binary packages were built with>"
  },
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/LiquidTechnologies/vcpkg-registry",
      "baseline": "<a commit of this repository>",
      "packages": [ "liquid-xmlobjects-runtime" ]
    }
  ]
}
```

`vcpkg.json`

```json
{
  "name": "my-app",
  "version": "1.0.0",
  "dependencies": [ "liquid-xmlobjects-runtime" ]
}
```

The `baseline` of this registry is a commit of this repository : the versions of the ports are the ones at that commit (a newer release needs a newer
baseline, or `"version>=": "21.6.8"` on the dependency in `vcpkg.json`). `git rev-parse HEAD` in a clone of this repository gives it.

CMake

```cmake
find_package(LiquidXmlObjectsRuntime CONFIG REQUIRED)
target_link_libraries(my-app PRIVATE Liquid::XmlObjectsRuntimeShared)   # dynamic triplets (x64-windows, x64-linux-dynamic, ...)
target_link_libraries(my-app PRIVATE Liquid::XmlObjectsRuntime)         # static triplets  (x64-windows-static)
```

Configure with the vcpkg toolchain file, `-DCMAKE_TOOLCHAIN_FILE=<vcpkg>/scripts/buildsystems/vcpkg.cmake`.

### Triplets

The RTTR library (a dependency) can not be built as a static library with the dynamic CRT, so the packages are for :

| Platform | Triplet |
|---|---|
| Windows | `x64-windows` (shared library), `x64-windows-static` (static library, static CRT) |
| Linux | `x64-linux-dynamic` (not `x64-linux`) |
| macOS | `arm64-osx-dynamic`, `x64-osx-dynamic` (not `arm64-osx`, `x64-osx`) |

## How a release gets here

Nothing in this repository is edited by hand. When a version is released in the (private) runtime repository (`scripts\PublishRelease.bat`, which tags the release),
its Package workflow builds and tests the vcpkg packages, pushes them to the binary cache, and then with `scripts/VcpkgRegistry.py` puts the port in
`ports/liquid-xmlobjects-runtime`, adds the version to `versions/l-/liquid-xmlobjects-runtime.json` and `versions/baseline.json`, and commits.

The port is the one the packages were built with : the files of a port are part of the hash vcpkg finds a binary package with, so they have to be the same.

A published version is never changed (the earlier ones are found in the history of this repository by the `git-tree` in the versions file) : a different port
with the same version is refused, the version has to go up. A pre-release (a tag with a suffix, `v21.4.3-rc1`) is not added.

## Layout

```
ports/liquid-xmlobjects-runtime/     the port of the latest version (vcpkg.json, portfile.cmake, usage)
versions/baseline.json               the version of each port that a project gets by default
versions/l-/liquid-xmlobjects-runtime.json   every version, newest first, each with the git tree of its port
```
