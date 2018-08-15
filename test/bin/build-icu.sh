#!/bin/bash

. "$(dirname $0)/prepare-shell.sh"

(
    set -o errexit

    if [ "$OS" =  'Windows_NT' ]; then
        echo 'building ICU on windows is not supported yet, exiting'
        exit 0
    fi

    icu_archive="$ICU_DIR/icu.tgz"

    if [ ! -e "$ICU_SRC_DIR" ]; then
        echo 'no icu source found, need to download and extract'

        echo 'cleaning up existing icu build artifacts...'
        rm -rf "$ICU_DIR"
        mkdir "$ICU_DIR"
        mkdir "$ICU_BUILD_DIR"
        echo 'done cleaning up existing icu build artifacts'

        echo 'downloading icu...'
        cd "$ICU_DIR"
        curl "$ICU_URL" --output "$icu_archive"
        echo 'extracting icu...'
        $EXTRACT "$icu_archive"
        echo 'downloaded and extracted icu'
    else
        echo 'existing icu source found, no need to download'
        echo 'cleaning up existing icu build dir...'
        rm -rf "$ICU_BUILD_DIR"
        mkdir "$ICU_BUILD_DIR"
        echo 'cleaned up existing icu build dir'
    fi

    echo "configuring icu for platform '$ICU_PLATFORM'"
    cd "$ICU_BUILD_DIR"
    "$ICU_SRC_DIR/runConfigureICU" "$ICU_PLATFORM" --enable-static --disable-shared
    make

) > $LOG_FILE 2>&1

print_exit_msg
