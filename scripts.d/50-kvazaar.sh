#!/bin/bash

KVAZAAR_REPO="https://github.com/ultravideo/kvazaar.git"
KVAZAAR_COMMIT="8143ab971cbbdd78a3ac12cf7904209e1db659c6"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerstage() {
    to_df "ADD $SELF /stage.sh"
    to_df "RUN run_stage"
}

ffbuild_dockerbuild() {
    git-mini-clone "$KVAZAAR_REPO" "$KVAZAAR_COMMIT" kvazaar
    cd kvazaar

    --disable-shared

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    sh autogen.sh
    ./configure  "${myconf[@]}"
    make -j$(nproc)
    make install

    cd ..
    rm -rf kvazaar
}

ffbuild_configure() {
    echo --enable-kvazaar
}

ffbuild_unconfigure() {
    echo --disable-kvazaar
}
