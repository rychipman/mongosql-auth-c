echo "VARIANT=$VARIANT"

case $VARIANT in
ubuntu1404-64)
    export MONGOSQLD_BUILD_VARIANT='linux-x86_64-ubuntu-1404'
    CMAKE_PATH='/opt/cmake/bin'
    PUSH_ARCH='x86_64-ubuntu-1404'
    PUSH_NAME='linux'
    ICU_URL='http://download.icu-project.org/files/icu4c/62.1/icu4c-62_1-src.tgz'
    ICU_PLATFORM='Linux'
    EXTRACT='tar xzvf'
    ;;
ubuntu1604-64)
    export MONGOSQLD_BUILD_VARIANT='linux-x86_64-ubuntu-1604'
    CMAKE_PATH='/opt/cmake/bin'
    PUSH_ARCH='x86_64-ubuntu-1604'
    PUSH_NAME='linux'
    ICU_URL='http://download.icu-project.org/files/icu4c/62.1/icu4c-62_1-src.tgz'
    ICU_PLATFORM='Linux'
    EXTRACT='tar xzvf'
    ;;
rhel70)
    export MONGOSQLD_BUILD_VARIANT='linux-x86_64-rhel70'
    CMAKE_PATH='/opt/cmake/bin'
    PUSH_ARCH='x86_64-rhel70'
    PUSH_NAME='linux'
    ICU_URL='http://download.icu-project.org/files/icu4c/62.1/icu4c-62_1-src.tgz'
    ICU_PLATFORM='Linux'
    EXTRACT='tar xzvf'
    ;;
macos)
    export MONGOSQLD_BUILD_VARIANT='osx-x86_64'
    CMAKE_PATH='/Applications/Cmake.app/Contents/bin'
    PUSH_ARCH='x86_64'
    PUSH_NAME='osx'
    ICU_URL='http://download.icu-project.org/files/icu4c/62.1/icu4c-62_1-src.tgz'
    ICU_PLATFORM='MacOSX'
    EXTRACT='tar xzvf'
    ;;
windows-64)
    export MONGOSQLD_BUILD_VARIANT='win32-x86_64'
    CMAKE_PATH='/cygdrive/c/cmake/bin'
    CMAKE_GENERATOR='Visual Studio 14 2015 Win64'
    MSBUILD_PATH='/cygdrive/c/Program Files (x86)/MSBuild/14.0/Bin'
    PROGRAM_FILES_FOLDER='ProgramFiles64Folder'
    PUSH_ARCH='x86_64'
    PUSH_NAME='win32'
    ICU_URL='http://download.icu-project.org/files/icu4c/62.1/icu4c-62_1-src.zip'
    EXTRACT='unzip'
    ;;
windows-32)
    export MONGOSQLD_BUILD_VARIANT='win32-x86_64'
    CMAKE_PATH='/cygdrive/c/cmake/bin'
    CMAKE_GENERATOR='Visual Studio 14 2015'
    MSBUILD_PATH='/cygdrive/c/Program Files (x86)/MSBuild/14.0/Bin'
    PROGRAM_FILES_FOLDER='ProgramFilesFolder'
    PUSH_ARCH='x86'
    PUSH_NAME='win32'
    ICU_URL='http://download.icu-project.org/files/icu4c/62.1/icu4c-62_1-src.zip'
    EXTRACT='unzip'
    ;;
other) # on evergreen, but "variant" expansion not set
    ;;
esac
