if(NOT DEFINED ENV{LX_SOURCE_DIR})
    # The source is not public : the port installs the prebuilt package of the triplet, which is built by the GitHub workflow (.github/workflows/package.yml)
    # and attached to a release of the registry. prebuilt.cmake says where each one is and what its SHA512 is : scripts/VcpkgRegistry.py writes it when the
    # version is added to the registry. It does not depend on vcpkg finding a binary package in a binary cache, so the tools and the compiler vcpkg
    # runs with do not matter here (the compiler that links the library does : see the README of the registry).
    include("${CMAKE_CURRENT_LIST_DIR}/prebuilt.cmake" OPTIONAL RESULT_VARIABLE LX_PREBUILT_FILE)
    if(NOT LX_PREBUILT_FILE)
        message(FATAL_ERROR
            "liquid-xmlobjects-runtime ${VERSION}: this copy of the port has no prebuilt.cmake, so it does not know where to get the prebuilt packages. "
            "Use the port from the registry https://github.com/LiquidTechnologies/vcpkg-registry, or set LX_SOURCE_DIR to build a checkout of the source (see README.md).")
    endif()
    if(NOT DEFINED LX_PREBUILT_FILE_${TARGET_TRIPLET})
        message(FATAL_ERROR
            "liquid-xmlobjects-runtime ${VERSION} has no prebuilt package for the triplet ${TARGET_TRIPLET}. The triplets that are published are: ${LX_PREBUILT_TRIPLETS}.")
    endif()

    vcpkg_download_distfile(ARCHIVE
        URLS "${LX_PREBUILT_BASE_URL}/${LX_PREBUILT_FILE_${TARGET_TRIPLET}}"
        FILENAME "${LX_PREBUILT_FILE_${TARGET_TRIPLET}}"
        SHA512 "${LX_PREBUILT_SHA512_${TARGET_TRIPLET}}"
    )
    vcpkg_extract_source_archive(PREBUILT_PATH ARCHIVE "${ARCHIVE}" NO_REMOVE_ONE_LEVEL)

    # The files are the ones the build below installs : include, lib and bin, debug, and share (the CMake package files, usage and copyright).
    file(COPY "${PREBUILT_PATH}/" DESTINATION "${CURRENT_PACKAGES_DIR}")
    if(VCPKG_BUILD_TYPE STREQUAL "release")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
    endif()
    return()
endif()

# The GitHub workflow (.github/workflows/package.yml) builds the source it has checked out, which is the release that is being packaged. (The workflow
# also sets VCPKG_KEEP_ENV_VARS=LX_SOURCE_DIR so that vcpkg passes the variable on.) What it installs is what the prebuilt packages above are made of.
file(TO_CMAKE_PATH "$ENV{LX_SOURCE_DIR}" SOURCE_PATH)

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
