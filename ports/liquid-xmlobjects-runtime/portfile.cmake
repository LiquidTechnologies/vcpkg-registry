if(DEFINED ENV{LX_SOURCE_DIR})
    # The GitHub workflow (.github/workflows/package.yml) builds the source it has checked out, which is the release that is being
    # packaged. This is the same portfile that is used by everyone else, so the binary packages it makes are the ones vcpkg finds
    # in the binary cache. (The workflow also sets VCPKG_KEEP_ENV_VARS=LX_SOURCE_DIR so that vcpkg passes the variable on.)
    file(TO_CMAKE_PATH "$ENV{LX_SOURCE_DIR}" SOURCE_PATH)
else()
    # The source is not public : the port is used through the binary packages that Liquid Technologies publishes. vcpkg finds one in the binary cache
    # (VCPKG_BINARY_SOURCES) when the port, the triplet and the compiler are the same as the ones it was built with, and then does not run this file.
    # When it does not find one it gets here.
    message(FATAL_ERROR
        "liquid-xmlobjects-runtime ${VERSION} is only available as a binary package, its source is not public so vcpkg can not build it.\n"
        "vcpkg did not find a binary package for this triplet and compiler in its binary sources. Add the Liquid Technologies binary cache to "
        "VCPKG_BINARY_SOURCES (see https://github.com/LiquidTechnologies/vcpkg-registry), and use a triplet that is published "
        "(x64-windows, x64-windows-static, x64-linux-dynamic, arm64-osx-dynamic, x64-osx-dynamic).")
endif()

# vcpkg builds one kind of library per triplet (static or dynamic), so the matching runtime is built: the static library
# with a static RTTR, the shared library with the RTTR dll. RTTR and pugixml come from vcpkg.
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LX_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LX_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLX_FETCH_DEPENDENCIES=OFF
        -DLX_BUILD_TESTS=OFF
        -DLX_BUILD_SAMPLES=OFF
        -DLX_INSTALL=ON
        -DLX_BUILD_STATIC=${LX_STATIC}
        -DLX_BUILD_SHARED=${LX_SHARED}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME LiquidXmlObjectsRuntime CONFIG_PATH lib/cmake/LiquidXmlObjectsRuntime)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
