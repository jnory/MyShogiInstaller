#!/usr/bin/env bash

function download_images() {
    BUILD_DIR=$1
    REPOS=$2
    VERSION=$3
    TARGET_DIR=$4

    echo -n "画像データをダウンロードしています ... " 1>&2

    pushd ${BUILD_DIR} >& /dev/null

    git clone ${REPOS} images >& images.download.log
    pushd images >& /dev/null
    (git checkout ${VERSION} 2>&1) >> ../images.download.log
    popd >& /dev/null
    cp -pr images ${TARGET_DIR}/image

    popd >& /dev/null

    echo "完了" 1>&2
}

function download_sounds() {
    BUILD_DIR=$1
    REPOS=$2
    VERSION=$3
    TARGET_DIR=$4

    echo -n "音声データをダウンロードしています ... " 1>&2

    pushd ${BUILD_DIR} >& /dev/null

    git clone ${REPOS} Sound >& Sound.download.log
    pushd Sound >& /dev/null
    (git checkout ${VERSION} 2>&1) >> ../Sound.download.log
    cp -pr Amazon_Polly_Mizuki_YouTube_AudioLibrary_SoundEffects/sound ${TARGET_DIR}/sound
    popd >& /dev/null

    popd >& /dev/null

    echo "完了" 1>&2
}

function download_models() {
    BUILD_DIR=$1
    URL=$2
    CHECKSUMS=$3
    TARGET_DIR=$4

    echo -n "モデルファイルをダウンロードしています ... " 1>&2

    pushd ${BUILD_DIR} >& /dev/null

    curl -L ${URL} -o tanuki-wcsc29-2019-05-06.7z >& /dev/null

    if ! (shasum -a 256 -c ${CHECKSUMS}/tanuki-wcsc29-2019-05-06.7z.sha256 >& /dev/null); then
        echo "ダウンロードしたモデルファイルが壊れています" 1>&2
        exit 1
    fi
    unar tanuki-wcsc29-2019-05-06.7z >& /dev/null
    mkdir -p ${TARGET_DIR}/eval/tanuki_wcsc29
    mv tanuki-wcsc29-2019-05-06/eval/*.bin ${TARGET_DIR}/eval/tanuki_wcsc29
    mv tanuki-wcsc29-2019-05-06/book/user_book2.db ${TARGET_DIR}/book/user_book2.db

    popd >& /dev/null

    echo "完了" 1>&2
}

function download_books() {
    BUILD_DIR=$1
    URL_STANDARD=$2
    URL_BOOK1=$3
    URL_BOOK3=$4
    URL_700T_SHOCK=$5
    CHECKSUMS=$6
    TARGET_DIR=$7

    echo -n "定跡ファイルをダウンロードしています ... " 1>&2

    pushd ${BUILD_DIR} >& /dev/null

    curl -L ${URL_STANDARD} -O >& /dev/null
    if ! (shasum -a 256 -c ${CHECKSUMS}/standard_book.zip.sha256 >& /dev/null); then
        echo "ダウンロードした定跡ファイル(standard_book.zip)が壊れています" 1>&2
        exit 1
    fi
    unzip standard_book.zip >& /dev/null
    mv standard_book.db ${TARGET_DIR}/book

    curl -L ${URL_BOOK1} -O >& /dev/null
    if ! (shasum -a 256 -c ${CHECKSUMS}/yaneura_book1_V101.zip.sha256 >& /dev/null); then
        echo "ダウンロードした定跡ファイル(yaneura_book1_V101.zip)が壊れています" 1>&2
        exit 1
    fi
    unzip yaneura_book1_V101.zip >& /dev/null
    mv yaneura_book1.db ${TARGET_DIR}/book

    curl -L ${URL_BOOK3} -O >& /dev/null
    if ! (shasum -a 256 -c ${CHECKSUMS}/yaneura_book3.zip.sha256 >& /dev/null); then
        echo "ダウンロードした定跡ファイル(yaneura_book3.zip)が壊れています" 1>&2
        exit 1
    fi
    unzip yaneura_book3.zip >& /dev/null
    mv yaneura_book3.db ${TARGET_DIR}/book

    curl -L ${URL_700T_SHOCK} -O >& /dev/null
    if ! (shasum -a 256 -c ${CHECKSUMS}/700T-shock-book.zip.sha256 >& /dev/null); then
        echo "ダウンロードした定跡ファイル(700T-shock-book.zip)が壊れています" 1>&2
        exit 1
    fi
    (LC_ALL=C unzip 700T-shock-book.zip >& /dev/null) || true
    mv user_book1.db ${TARGET_DIR}/book/user_book1.db


    popd >& /dev/null

    echo "完了" 1>&2
}

