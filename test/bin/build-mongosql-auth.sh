#!/bin/bash

. "$(dirname $0)/prepare-shell.sh"

(
    set -o errexit

    if [ "$1" = "--no-clobber" ]; then
        CLOBBER="false"
    else
        CLOBBER="true"
    fi

    cd $ARTIFACTS_DIR
    if [ ! -d "mysql-server" ]; then
        # clone mysql-server and checkout the right commit
        echo "cloning mysql-server..."
        git clone -b mysql-5.7.23 --single-branch --depth=1 https://github.com/mysql/mysql-server
        echo "done cloning mysql-server"
    fi

    # go to the mysql dir and clean the working tree
    echo "cleaning mysql working tree..."
    cd mysql-server
    git checkout 913071c0b16cc03e703308250d795bc381627e37
    rm -rf plugin/auth/mongosql-auth
    echo "done cleaning mysql working tree"

    # move source and build files into mysql repo
    echo "moving plugin source into mysql repo..."
    cp -r $PROJECT_DIR/src/mongosql-auth plugin/auth/
    cat $PROJECT_DIR/src/CMakeLists.txt >> CMakeLists.txt
    cat $PROJECT_DIR/src/versioninfo.rc.in > cmake/versioninfo.rc.in
    cp $PROJECT_DIR/cmake/*.cmake cmake
    echo "done moving plugin source into mysql repo"

    # move testing source and build files into mysql repo
    echo "moving test source into mysql repo..."
    cp -r $PROJECT_DIR/test/unit/*.{c,h} plugin/auth/mongosql-auth
    cat $PROJECT_DIR/test/unit/CMakeLists.txt >> CMakeLists.txt
    echo "done moving test source into mysql repo"

    # setting mysql repo version to mongosql_auth plugin version
    echo "setting mysql repo version to mongosql_auth plugin version..."
    cat > VERSION <<EOF
MYSQL_VERSION_MAJOR=$MAJOR_VERSION
MYSQL_VERSION_MINOR=$MINOR_VERSION
MYSQL_VERSION_PATCH=$PATCH_VERSION
MYSQL_VERSION_EXTRA=
EOF
    echo "done setting mysql repo version to mongosql_auth plugin version"

    # clean the build directory if CLOBBER is true
    if [ "$CLOBBER" = "true" ]; then
        echo "clobbering build directory..."
        rm -rf bld
        echo "done clobbering build directory"
    fi

    cd $ARTIFACTS_DIR

    # download boost
    if [ ! -d $BOOST_DIR ]; then
        echo "downloading boost..."
        curl -S $BOOST_S3_URL > $BOOST_FILE
        tar xzf $BOOST_FILE
    fi

    cd $ARTIFACTS_DIR/mysql-server
    mkdir -p bld
    cd bld

    echo "running cmake..."
    if [ -n "$CMAKE_GENERATOR" ]; then
        # if there is a specific generator specified
        # for this platform, then use it
        cmake .. $CMAKE_ARGS -G "$CMAKE_GENERATOR"
    else
        cmake .. $CMAKE_ARGS
    fi
    echo "done running cmake"

    echo "building mongosql_auth..."
    eval $BUILD
    echo "done building mongosql_auth"

    echo "copying plugin to build dir..."
    mkdir -p $ARTIFACTS_DIR/build
    cp $PLUGIN_LIBRARY $ARTIFACTS_DIR/build/
    echo "copied plugin to build dir"
) 2>&1 | tee $LOG_FILE

print_exit_msg

