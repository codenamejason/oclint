SET(CMAKE_DISABLE_SOURCE_CHANGES ON)
SET(CMAKE_DISABLE_IN_SOURCE_BUILD ON)
SET(CMAKE_BUILD_TYPE None)
IF (${CMAKE_SYSTEM_NAME} MATCHES "Win")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_LINKER_FLAGS} -fno-rtti")
ELSE()
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_LINKER_FLAGS} -fno-rtti -fcolor-diagnostics -Wno-c++11-extensions -fPIC")
ENDIF()
SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_CXX_LINKER_FLAGS} -fno-rtti")

IF(APPLE)
    SET(CMAKE_CXX_FLAGS "-std=c++11 -stdlib=libc++ ${CMAKE_CXX_FLAGS}")
    INCLUDE_DIRECTORIES(${OSX_DEVELOPER_ROOT}/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1)
ELSEIF(MINGW)
    SET(CMAKE_CXX_FLAGS "-std=gnu++11 ${CMAKE_CXX_FLAGS}")
ELSE()
    SET(CMAKE_CXX_FLAGS "-std=c++11 -stdlib=libstdc++ ${CMAKE_CXX_FLAGS}")
ENDIF()

IF(APPLE)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mmacosx-version-min=10.7")
    SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -mmacosx-version-min=10.7")
ENDIF()

IF(OCLINT_BUILD_TYPE STREQUAL "Release")
    SET(CMAKE_CXX_FLAGS "-O3 -DNDEBUG ${CMAKE_CXX_FLAGS}")
    SET(CMAKE_SHARED_LINKER_FLAGS "-s ${CMAKE_SHARED_LINKER_FLAGS}")
ELSE()
    SET(CMAKE_CXX_FLAGS "-O0 -g ${CMAKE_CXX_FLAGS}")
    SET(CMAKE_SHARED_LINKER_FLAGS "-g ${CMAKE_SHARED_LINKER_FLAGS}")
ENDIF()

SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)

SET(OCLINT_VERSION_MAJOR 0)
SET(OCLINT_VERSION_MINOR 9)

SET(OCLINT_VERSION_RELEASE "${OCLINT_VERSION_MAJOR}.${OCLINT_VERSION_MINOR}")

IF( NOT EXISTS ${LLVM_ROOT}/include/llvm )
    MESSAGE(FATAL_ERROR "LLVM_ROOT (${LLVM_ROOT}) is not a valid LLVM install. Could not find ${LLVM_ROOT}/include/llvm")
ENDIF()

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${LLVM_ROOT}/share/llvm/cmake")
INCLUDE(LLVMConfig)

STRING(REGEX MATCH "[0-9]+\\.[0-9]+(\\.[0-9]+)?" LLVM_VERSION_RELEASE ${LLVM_PACKAGE_VERSION})

INCLUDE_DIRECTORIES( ${LLVM_INCLUDE_DIRS} )
LINK_DIRECTORIES( ${LLVM_LIBRARY_DIRS} )
ADD_DEFINITIONS( ${LLVM_DEFINITIONS} )

LLVM_MAP_COMPONENTS_TO_LIBNAMES(REQ_LLVM_LIBRARIES asmparser bitreader instrumentation mcparser option)

SET(CLANG_LIBRARIES
    clangTooling
    clangFrontend
    clangDriver
    clangSerialization
    clangParse
    clangSema
    clangAnalysis
    clangEdit
    clangASTMatchers
    clangAST
    clangLex
    clangBasic)

IF(TEST_BUILD)
    ENABLE_TESTING()
    ADD_DEFINITIONS(
        --coverage
        )
    INCLUDE_DIRECTORIES(
        ${GOOGLETEST_SRC}/include
        ${GOOGLETEST_SRC}/gtest/include
        )
    LINK_DIRECTORIES(${GOOGLETEST_BUILD})

    # Setup the path for profile_rt library
    STRING(TOLOWER ${CMAKE_SYSTEM_NAME} COMPILER_RT_SYSTEM_NAME)
    LINK_DIRECTORIES(${LLVM_LIBRARY_DIRS}/clang/${LLVM_VERSION_RELEASE}/lib/${COMPILER_RT_SYSTEM_NAME})
    IF(APPLE)
        SET(PROFILE_RT_LIBS clang_rt.profile_osx)
    ELSE()
        IF(${CMAKE_SYSTEM_NAME} MATCHES "Win")
            SET(PROFILE_RT_LIBS --coverage)
        ELSE()
            IF(CMAKE_SIZEOF_VOID_P EQUAL 8)
                SET(PROFILE_RT_LIBS clang_rt.profile-x86_64)
            ELSE()
                SET(PROFILE_RT_LIBS clang_rt.profile-i386)
            ENDIF()
        ENDIF()
    ENDIF()
ENDIF()
