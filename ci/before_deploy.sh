# This script takes care of building your crate and packaging it for release

set -ex

main() {
    local src=$(pwd) \
          stage=

    case $TRAVIS_OS_NAME in
        linux)
            stage=$(mktemp -d)
            ;;
        osx)
            stage=$(mktemp -d -t tmp)
            ;;
    esac

    test -f Cargo.lock || cargo generate-lockfile

    # TODO Update this to build the artifacts that matter to you
    # MUSL (Alpine) requires some oddness
    if [[ $TARGET = *linux-musl* ]]
    then
        cross rustc --target $TARGET --release -- -C target-feature=-crt-static
    else
        cross rustc --target $TARGET --release
    fi

    # TODO Update this to package the right artifacts
    ls target/$TARGET/release

    # Windows
    [ -e target/$TARGET/release/remit_core.dll ] && cp target/$TARGET/release/remit_core.dll $stage/

    # Linux
    [ -e target/$TARGET/release/libremit_core.so ] && cp target/$TARGET/release/libremit_core.so $stage/

    # MacOS
    [ -e target/$TARGET/release/libremit_core.dylib ] && cp target/$TARGET/release/libremit_core.dylib $stage/

    cd $stage
    tar czf $src/$CRATE_NAME-$TRAVIS_TAG-$TARGET.tar.gz *
    cd $src

    rm -rf $stage
}

main
