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

    # reference: https://qiita.com/namakemono/items/c963e75e0af3f7eed732
    curl -sc ${BUILD_DIR}/model_download_cookie ${URL} >& /dev/null
    CONFIRMATION_CODE=`cat ${BUILD_DIR}/model_download_cookie | grep '_warning_' | rev | cut -f1 | rev`
    curl -Lb ${BUILD_DIR}/model_download_cookie ${URL}"&confirm=${CONFIRMATION_CODE}" -o rezero_kpp_kkpt_epoch4.zip >& /dev/null

    if ! (shasum -a 256 -c ${CHECKSUMS}/rezero_kpp_kkpt_epoch4.zip.sha256 >& /dev/null); then
        echo "ダウンロードしたモデルファイルが壊れています" 1>&2
        exit 1
    fi
    unzip rezero_kpp_kkpt_epoch4.zip >& /dev/null
    mv rezero_kpp_kkpt_epoch4/*.bin ${TARGET_DIR}/eval

    popd >& /dev/null

    echo "完了" 1>&2
}

function download_books() {
    BUILD_DIR=$1
    URL_STANDARD=$2
    URL_BOOK1=$3
    URL_BOOK3=$4
    CHECKSUMS=$5
    TARGET_DIR=$6

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

    popd >& /dev/null

    echo "完了" 1>&2
}

