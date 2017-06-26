#!/bin/bash

. "$(dirname $0)/prepare-shell.sh"

(
    set -o errexit
    echo "creating release..."

    cd $PROJECT_DIR

    dir="$(dirname $0)"

    if [ "Windows_NT" = "$OS" ]; then

        # package the zip file
        #python testdata/bin/make_archive.py -o $ARTIFACTS_DIR/release.zip --format zip --transform $build_dir/mongosqld=mongodb-bi-$PUSH_NAME-$PUSH_ARCH-$CURRENT_VERSION/bin/mongosqld.exe --transform $build_dir/mongodrdl=mongodb-bi-$PUSH_NAME-$PUSH_ARCH-$CURRENT_VERSION/bin/mongodrdl.exe --transform $build_dir/ssleay32.dll=mongodb-bi-$PUSH_NAME-$PUSH_ARCH-$CURRENT_VERSION/bin/ssleay32.dll --transform $build_dir/libeay32.dll=mongodb-bi-$PUSH_NAME-$PUSH_ARCH-$CURRENT_VERSION/bin/libeay32.dll --transform distsrc/README=mongodb-bi-$PUSH_NAME-$PUSH_ARCH-$CURRENT_VERSION/README --transform distsrc/THIRD-PARTY-NOTICES=mongodb-bi-$PUSH_NAME-$PUSH_ARCH-$CURRENT_VERSION/THIRD-PARTY-NOTICES --transform LICENSE=mongodb-bi-$PUSH_NAME-$PUSH_ARCH-$CURRENT_VERSION/LICENSE LICENSE distsrc\\README distsrc\\THIRD-PARTY-NOTICES $build_dir\\mongosqld $build_dir\\mongodrdl $build_dir\\libeay32.dll $build_dir\\ssleay32.dll

        # build the msi. Since this is windows only, we know powershell is installed.
        SEMVER=$(git describe --always --abbrev=0)
        powershell.exe \
            -NoProfile \
            -NoLogo \
            -NonInteractive \
            -File "$(cygpath -C ANSI -w "$dir/build-msi.ps1")" \
            -ProjectName "MongoSQL Auth Plugin" \
            -VersionLabel "$SEMVER" \
            -WixPath "$WIX\\bin"

    else

        #python testdata/bin/make_archive.py -o $ARTIFACTS_DIR/release.tgz --format tgz --transform $build_dir/mongosqld=mongodb-bi-$PUSH_NAME-$PUSH_ARCH-$CURRENT_VERSION/bin/mongosqld --transform $build_dir/mongodrdl=mongodb-bi-$PUSH_NAME-$PUSH_ARCH-$CURRENT_VERSION/bin/mongodrdl --transform distsrc/README=mongodb-bi-$PUSH_NAME-$PUSH_ARCH-$CURRENT_VERSION/README --transform distsrc/THIRD-PARTY-NOTICES=mongodb-bi-$PUSH_NAME-$PUSH_ARCH-$CURRENT_VERSION/THIRD-PARTY-NOTICES --transform LICENSE=mongodb-bi-$PUSH_NAME-$PUSH_ARCH-$CURRENT_VERSION/LICENSE LICENSE distsrc/README distsrc/THIRD-PARTY-NOTICES $build_dir/mongosqld $build_dir/mongodrdl

    fi

    echo "done creating release"

) > $LOG_FILE 2>&1

print_exit_msg
