#!/usr/bin/env bash

set -e

boost_version="1.80.0"
boost_version_underscored="${boost_version//./_}"
boost_url="https://boostorg.jfrog.io/artifactory/main/release/${boost_version}/source/boost_${boost_version_underscored}.tar.gz"
boost_variant="debug,release"
project_dir=$(pwd)
primary='\033[1;34m'
secondary='\033[1;35m'
nc='\033[0m'

prettyprint() {
    printf "${primary}${1}${nc}${secondary}${2}${nc}\n"
}

get_os() {
    if [[ "${OSTYPE}" =~ ^darwin.* ]]; then
        echo "macos"
    elif [[ "${OSTYPE}" =~ ^linux.* ]]; then
        echo "linux"
    else
        echo "windows"
    fi
}
determined_os=$(get_os)

download_boost() {
    if [ ! -d "boost_${boost_version_underscored}" ]; then
        prettyprint "Downloading boost.tar.gz"
        curl "${boost_url}" --output "${TMPDIR:-"/tmp"}/boost.tar.gz" --silent --location

        prettyprint "Extracting boost.tar.gz..."
        tar -zxf "${TMPDIR:-"/tmp"}/boost.tar.gz" -C .
        (
            prettyprint "Applying boost-python-3.11.patch"
            cd "boost_${boost_version_underscored}/libs/python"
            git apply --ignore-space-change --ignore-whitespace "${project_dir}/boost-python-3.11.patch"
        )
    else
        prettyprint "Boost already found, re-using..."
    fi
}

install_boost () {
    cd "${project_dir}"
    download_boost
    cd "${project_dir}/boost_${boost_version_underscored}"
    python_version=$(python -c 'import sys; version=sys.version_info[:3]; print("{0}.{1}".format(*version))')
    python_include_dir=$(python -c 'from sysconfig import get_paths as gp; print(gp()["include"])')
    if [ "${determined_os}" = "windows" ]; then
        python_include_dir=$(cygpath -w "${python_include_dir}")
    fi
    echo "using python : ${python_version} : python : ${python_include_dir//\\/\\\\} ;" > user-config.jam
    cat user-config.jam
    prettyprint "Bootstrapping boost"
    if [ "${determined_os}" = "windows" ]; then
        ./bootstrap.bat
    else
        ./bootstrap.sh
    fi
    prettyprint "Compiling boost " "${BOOST_ADDRESS_MODEL:-"64"}-bit ${BOOST_ARCHITECTURE} for Python v${python_version}"
    ./b2 \
        ${OCL_CLEAN:+"-a"} \
        -j2 \
        --layout="tagged" \
        --with-python \
        --user-config="user-config.jam" \
        threading="multi" \
        variant="${boost_variant}" \
        link="static" \
        cxxflags="-fPIC" \
        address-model="${BOOST_ADDRESS_MODEL:-"64"}" \
        ${BOOST_ARCHITECTURE:+"architecture=${BOOST_ARCHITECTURE}"} \
        stage
}

install_boost

if [ "${determined_os}" == "linux" ]; then
    # on linux, we compile boost python in a container, so we have to
    # copy the compiled boost python out of the container and into the github runner
    cp --recursive --no-clobber "${project_dir}/boost_${boost_version_underscored}" /host/home/runner/work/boost-python-precompiled/boost-python-precompiled
fi