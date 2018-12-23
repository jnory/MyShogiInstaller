#!/usr/bin/env bash

set -e

####### ダウンロード元の設定 #######
MYSHOGI_REPOS=https://github.com/yaneurao/MyShogi.git
MYSHOGI_VERSION=3a9e7b17b8a6daa809bfce391c68bec88c4302c4

YANEURAOU_REPOS=https://github.com/yaneurao/YaneuraOu.git
YANEURAOU_VERSION=6d6d503dd64b798ed474e5aca844b232e5682781

SOUNDPLAYER_REPOS=https://github.com/jnory/MyShogiSoundPlayer.git
SOUNDPLAYER_VERSION=2d3c08ef33a9f951aaef366aaa3cc7d5094aa8d7

IMAGES_REPOS=https://github.com/jnory/MyShogiImages.git
IMAGES_VERSION=2b53ec8653509c97e9717d1bf485b7e9027ce163

SOUND_REPOS=https://github.com/matarillo/MyShogiSound.git
SOUND_VERSION=3b192b0c6797e217ae3472196570071c19a25550

MODEL_PATH="https://drive.google.com/uc?export=download&id=0Bzbi5rbfN85NSk1qQ042U0RnUEU"
BOOK_PATH_STANDARD="https://github.com/yaneurao/YaneuraOu/releases/download/v4.73_book/standard_book.zip"
BOOK_PATH_YANEURA_BOOK1="https://github.com/yaneurao/YaneuraOu/releases/download/v4.73_book/yaneura_book1_V101.zip"
BOOK_PATH_YANEURA_BOOK3="https://github.com/yaneurao/YaneuraOu/releases/download/v4.73_book/yaneura_book3.zip"
##############

####### 環境設定 #######
MONO_PATH=/Library/Frameworks/Mono.framework/Versions/Current/Commands/mono
MSBUILD_PATH=/Library/Frameworks/Mono.framework/Versions/Current/Commands/msbuild
##############

if [[ $# -ne 1 ]]; then
    echo "使い方: " 1>&2
    echo "${0} [作業ディレクトリのパス]" 1>&2
    exit 1
fi

BASEDIR=`dirname $0`/..
pushd ${BASEDIR} >& /dev/null
BASEDIR=`pwd`
popd >& /dev/null

PREFIX=$1
mkdir -p ${PREFIX}
pushd ${PREFIX} >& /dev/null
PREFIX=`pwd`
popd >& /dev/null

ROOTDIR=${PREFIX}/MyShogi.app/Contents

function check_env() {
    echo "必要なコマンドがインストールされているか確認しています" 1>&2

    echo -n "mono ... " 1>&2
    if [[ ! -e ${MONO_PATH} ]]; then
        echo "NG" 1>&2
        exit 1
    fi
    echo "ok" 1>&2

    echo -n "msbuild ... " 1>&2
    if [[ ! -e ${MSBUILD_PATH} ]]; then
        echo "NG" 1>&2
        exit 1
    fi
    echo "ok" 1>&2

    echo -n "cmake ... " 1>&2
    if ! (cmake --version >& /dev/null); then
        echo "NG" 1>&2
        exit 1
    fi
    echo "ok" 1>&2

    echo -n "make ... " 1>&2
    if ! (make --version >& /dev/null); then
        echo "NG" 1>&2
        exit 1
    fi
    echo "ok" 1>&2

    echo -n "git ... " 1>&2
    if ! (git --version >& /dev/null); then
        echo "NG" 1>&2
        exit 1
    fi
    echo "ok" 1>&2

    echo -n "g++ ... " 1>&2
    if ! (g++ --version >& /dev/null); then
        echo "NG" 1>&2
        exit 1
    fi
    echo "ok" 1>&2

    echo -n "curl ... " 1>&2
    if ! (curl --version >& /dev/null); then
        echo "NG" 1>&2
        exit 1
    fi
    echo "ok" 1>&2

    echo -n "unzip ... " 1>&2
    if ! (unzip -v >& /dev/null); then
        echo "NG" 1>&2
        exit 1
    fi
    echo "ok" 1>&2

    echo "必要なコマンドは揃っているようです" 1>&2
}

function prepare_app() {
    echo -n "事前準備 ... " 1>&2

    # reference: https://qiita.com/h12o/items/1410707dd9e7135d207a
    mkdir -p ${ROOTDIR}/MacOS
    mkdir -p ${ROOTDIR}/Resources

    mkdir -p ${ROOTDIR}/MacOS/engine
    mkdir -p ${ROOTDIR}/MacOS/eval
    mkdir -p ${ROOTDIR}/MacOS/book
    cp -p ${BASEDIR}/macOS/resource/Info.plist ${ROOTDIR}
    cp -p ${BASEDIR}/macOS/resource/run.sh ${ROOTDIR}/MacOS

    echo "完了" 1>&2
}

function build_myshogi() {
    echo -n "MyShogiをビルドしています ... " 1>&2

    pushd ${PREFIX} >& /dev/null
    git clone ${MYSHOGI_REPOS} MyShogi >& MyShogi.build.log
    pushd MyShogi >& /dev/null

    (git checkout ${MYSHOGI_VERSION} 2>&1) >> ../MyShogi.build.log
    msbuild ./MyShogi.sln /p:Configuration=macOS 2>&1 >> ../MyShogi.build.log
    cp -p ./MyShogi/bin/macOS/MyShogi.exe ${ROOTDIR}/MacOS
    popd >& /dev/null
    popd >& /dev/null

    echo "完了" 1>&2
}

function compile_yaneuraou() {
    # reference: https://github.com/yaneurao/MyShogi/blob/master/MyShogi/docs/Mac%E3%80%81Linux%E3%81%A7%E5%8B%95%E4%BD%9C%E3%81%95%E3%81%9B%E3%82%8B%E3%81%AB%E3%81%AF.md#%E6%80%9D%E8%80%83%E3%82%A8%E3%83%B3%E3%82%B8%E3%83%B3%E3%81%AE%E3%82%B3%E3%83%B3%E3%83%91%E3%82%A4%E3%83%AB%E6%89%8B%E9%A0%86
    YANEURAOU_DIR=$1
    PACKAGE_NAME=$2
    YANEURAOU_EDITION=$3
    BASE=$4

    echo -n "${YANEURAOU_EDITION}( " 1>&2

    pushd ${YANEURAOU_DIR}/source >& /dev/null
    for ARCH in avx2 sse42 sse41 sse2; do
        echo -n "${ARCH} " 1>&2

        (make clean YANEURAOU_EDITION=${YANEURAOU_EDITION} 2>&1) >> ../YaneuraOu.build.log
        (make -j1 ${ARCH} COMPILER=g++ YANEURAOU_EDITION=${YANEURAOU_EDITION} 2>&1) >> ../YaneuraOu.build.log

        mkdir -p ${ROOTDIR}/MacOS/engine/${PACKAGE_NAME}
        OUT=${ROOTDIR}/MacOS/engine/${PACKAGE_NAME}/${BASE}_${ARCH}.exe
        cp YaneuraOu-by-gcc ${OUT}
        chmod 755 ${OUT}
    done
    popd >& /dev/null

    cp -p ${BASEDIR}/engine_defines/${PACKAGE_NAME}/engine_define.xml ${ROOTDIR}/MacOS/engine/${PACKAGE_NAME}/
    echo -n ")" 1>&2
}

function build_yaneuraou() {
    echo -n "やねうら王をビルドしています(少し時間がかかります) ... " 1>&2
    pushd ${PREFIX} >& /dev/null

    git clone ${YANEURAOU_REPOS} YaneuraOu >& YaneuraOu.build.log
    pushd YaneuraOu >& /dev/null
    (git checkout ${YANEURAOU_VERSION} 2>&1) >> ../YaneuraOu.build.log
    popd >& /dev/null

    # compile_yaneuraou YaneuraOu tanuki2018 YANEURAOU_2018_TNK_ENGINE YaneuraOu2018NNUE
    # compile_yaneuraou YaneuraOu yomita2018 YANEURAOU_2018_OTAFUKU_ENGINE_KPPT YaneuraOu2018KPPT
    compile_yaneuraou YaneuraOu yaneuraou2018 YANEURAOU_2018_OTAFUKU_ENGINE_KPP_KKPT yaneuraou2018_kpp_kkpt
    # compile_yaneuraou YaneuraOu tanuki_mate MATE_ENGINE tanuki_mate

    echo " ... 完了" 1>&2
    popd >& /dev/null
}

function build_soundplayer() {
    echo -n "SoundPlayerをビルドしています ... " 1>&2

    pushd ${PREFIX} >& /dev/null

    git clone --recursive ${SOUNDPLAYER_REPOS} SoundPlayer >& SoundPlayer.build.log
    pushd SoundPlayer >& /dev/null
    (git checkout ${SOUNDPLAYER_VERSION} 2>&1) >> ../SoundPlayer.build.log
    (make macos 2>&1) >> ../SoundPlayer.build.log
    cp -p SoundPlayer/bin/macOS/SoundPlayer.exe ${ROOTDIR}/MacOS
    cp -p SoundPlayer/bin/macOS/libwplay.dylib ${ROOTDIR}/MacOS
    popd >& /dev/null

    popd >& /dev/null

    echo "完了" 1>&2
}

function download_images() {
    echo -n "画像データをダウンロードしています ... " 1>&2

    pushd ${PREFIX} >& /dev/null

    git clone ${IMAGES_REPOS} images >& images.download.log
    pushd images >& /dev/null
    (git checkout ${IMAGES_VERSION} 2>&1) >> ../images.download.log
    popd >& /dev/null
    cp -pr images ${ROOTDIR}/MacOS/image

    popd >& /dev/null

    echo "完了" 1>&2
}

function download_sounds() {
    echo -n "音声データをダウンロードしています ... " 1>&2

    pushd ${PREFIX} >& /dev/null

    git clone ${SOUND_REPOS} Sound >& Sound.download.log
    pushd Sound >& /dev/null
    (git checkout ${SOUND_VERSION} 2>&1) >> ../Sound.download.log
    cp -pr Amazon_Polly_Mizuki_YouTube_AudioLibrary_SoundEffects/sound ${ROOTDIR}/MacOS/sound
    popd >& /dev/null

    popd >& /dev/null

    echo "完了" 1>&2
}

function download_models() {
    echo -n "モデルファイルをダウンロードしています ... " 1>&2

    pushd ${PREFIX} >& /dev/null

    # reference: https://qiita.com/namakemono/items/c963e75e0af3f7eed732
    curl -sc ${PREFIX}/model_download_cookie ${MODEL_PATH} >& /dev/null
    CONFIRMATION_CODE=`cat ${PREFIX}/model_download_cookie | grep '_warning_' | rev | cut -f1 | rev`
    curl -Lb ${PREFIX}/model_download_cookie ${MODEL_PATH}"&confirm=${CONFIRMATION_CODE}" -o rezero_kpp_kkpt_epoch4.zip >& /dev/null

    if ! (shasum -a 256 -c ${BASEDIR}/checksums/rezero_kpp_kkpt_epoch4.zip.sha256 >& /dev/null); then
        echo "ダウンロードしたモデルファイルが壊れています" 1>&2
        exit 1
    fi
    unzip rezero_kpp_kkpt_epoch4.zip >& /dev/null
    mv rezero_kpp_kkpt_epoch4/*.bin ${ROOTDIR}/MacOS/eval

    popd >& /dev/null

    echo "完了" 1>&2
}

function download_books() {
    echo -n "定跡ファイルをダウンロードしています ... " 1>&2

    pushd ${PREFIX} >& /dev/null

    curl -L ${BOOK_PATH_STANDARD} -O >& /dev/null
    if ! (shasum -a 256 -c ${BASEDIR}/checksums/standard_book.zip.sha256 >& /dev/null); then
        echo "ダウンロードした定跡ファイル(standard_book.zip)が壊れています" 1>&2
        exit 1
    fi
    unzip standard_book.zip >& /dev/null
    mv standard_book.db ${ROOTDIR}/MacOS/book

    curl -L ${BOOK_PATH_YANEURA_BOOK1} -O >& /dev/null
    if ! (shasum -a 256 -c ${BASEDIR}/checksums/yaneura_book1_V101.zip.sha256 >& /dev/null); then
        echo "ダウンロードした定跡ファイル(yaneura_book1_V101.zip)が壊れています" 1>&2
        exit 1
    fi
    unzip yaneura_book1_V101.zip >& /dev/null
    mv yaneura_book1.db ${ROOTDIR}/MacOS/book

    curl -L ${BOOK_PATH_YANEURA_BOOK3} -O >& /dev/null
    if ! (shasum -a 256 -c ${BASEDIR}/checksums/yaneura_book3.zip.sha256 >& /dev/null); then
        echo "ダウンロードした定跡ファイル(yaneura_book3.zip)が壊れています" 1>&2
        exit 1
    fi
    unzip yaneura_book3.zip >& /dev/null
    mv yaneura_book3.db ${ROOTDIR}/MacOS/book

    popd >& /dev/null

    echo "完了" 1>&2
}

check_env
prepare_app
build_myshogi
build_yaneuraou
build_soundplayer
download_images
download_sounds
download_models
download_books
