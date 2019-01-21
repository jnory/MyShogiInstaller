#!/usr/bin/env bash
# TODO: macOS/install.sh との共通部分をリファクタ

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

function print_usage() {
    echo "使い方: " 1>&2
    echo "${0} [options...] [作業ディレクトリのパス]" 1>&2
    echo "options:" 1>&2
    echo "-s n" 1>&2
    echo "  第nステップ目からインストールを開始します。実行を中断した後続きから再開したいときのために用意されています。" 1>&2
    echo "  0: 実行環境の確認" 1>&2
    echo "  1: MyShogi.appの置き場作り" 1>&2
    echo "  2: MyShogiのビルド" 1>&2
    echo "  3: やねうら王のビルド" 1>&2
    echo "  4: SoundPlayerのビルド" 1>&2
    echo "  5: 画像データのダウンロード" 1>&2
    echo "  6: 音声データのダウンロード" 1>&2
    echo "  7: モデルデータのダウンロード" 1>&2
    echo "  8: 定跡データのダウンロード" 1>&2
}

####### 引数のパース #######
# reference: https://shellscript.sunone.me/parameter.html
START_FROM=0
while getopts s: OPT; do
	case ${OPT} in
	"s" ) START_FROM=${OPTARG};;
	* ) print_usage
	    echo ${OPT}
	    exit 1;;
	esac
done

shift `expr ${OPTIND} - 1`

if [[ $# -ne 1 ]]; then
	print_usage
	exit 1
fi
##############

BASEDIR=`dirname $0`/..
pushd ${BASEDIR} >& /dev/null
BASEDIR=`pwd`
popd >& /dev/null

PREFIX=$1
mkdir -p ${PREFIX}
pushd ${PREFIX} >& /dev/null
PREFIX=`pwd`
popd >& /dev/null

ROOTDIR=${PREFIX}/Linux


function check_env() {
    echo "必要なコマンドがインストールされているか確認しています" 1>&2

    echo -n "mono ... " 1>&2
    if [[ ! `which mono` ]]; then
        echo "NG" 1>&2
        exit 1
    fi
    echo "ok" 1>&2

    echo -n "msbuild ... " 1>&2
    if [[ ! `which msbuild` ]]; then
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
    mkdir -p ${ROOTDIR}

    mkdir -p ${ROOTDIR}/engine
    mkdir -p ${ROOTDIR}/eval
    mkdir -p ${ROOTDIR}/book
    cp -p ${BASEDIR}/ubuntu/resource/run.sh ${ROOTDIR}

    echo "完了" 1>&2
}

function build_myshogi() {
    echo -n "MyShogiをビルドしています ... " 1>&2

    pushd ${PREFIX} >& /dev/null
    git clone ${MYSHOGI_REPOS} MyShogi >& MyShogi.build.log
    pushd MyShogi >& /dev/null

    (git checkout ${MYSHOGI_VERSION} 2>&1) >> ../MyShogi.build.log
    msbuild ./MyShogi.sln /p:Configuration=LINUX 2>&1 >> ../MyShogi.build.log
    cp -p ./MyShogi/bin/Linux/MyShogi.exe ${ROOTDIR}
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
    # grep flags /proc/cpuinfo | head -1 | grep -E '(avx2|sse4_2|sse4_1|sse2)'
    for ARCH in avx2 # sse42 sse41 sse2
    do
        echo -n "${ARCH} " 1>&2

        (make clean YANEURAOU_EDITION=${YANEURAOU_EDITION} 2>&1) >> ../YaneuraOu.build.log
        (make -j1 ${ARCH} COMPILER=g++ YANEURAOU_EDITION=${YANEURAOU_EDITION} 2>&1) >> ../YaneuraOu.build.log

        mkdir -p ${ROOTDIR}/engine/${PACKAGE_NAME}
        OUT=${ROOTDIR}/engine/${PACKAGE_NAME}/${BASE}_${ARCH}.exe
        cp YaneuraOu-by-gcc ${OUT}
        chmod 755 ${OUT}
    done
    popd >& /dev/null

    cp -p ${BASEDIR}/engine_defines/${PACKAGE_NAME}/engine_define.xml ${ROOTDIR}/engine/${PACKAGE_NAME}/
    cp -p ${BASEDIR}/engine_defines/${PACKAGE_NAME}/engine_options.txt ${ROOTDIR}/engine/${PACKAGE_NAME}/
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
    compile_yaneuraou YaneuraOu yaneuraou2018 YANEURAOU_2018_OTAFUKU_ENGINE_KPP_KKPT Yaneuraou2018_kpp_kkpt
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
    (make linux 2>&1) >> ../SoundPlayer.build.log
    cp -p SoundPlayer/bin/Linux/SoundPlayer.exe ${ROOTDIR}
    cp -p SoundPlayer/bin/Linux/libwplay.so ${ROOTDIR}
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
    cp -pr images ${ROOTDIR}/image

    popd >& /dev/null

    echo "完了" 1>&2
}

function download_sounds() {
    echo -n "音声データをダウンロードしています ... " 1>&2

    pushd ${PREFIX} >& /dev/null

    git clone ${SOUND_REPOS} Sound >& Sound.download.log
    pushd Sound >& /dev/null
    (git checkout ${SOUND_VERSION} 2>&1) >> ../Sound.download.log
    cp -pr Amazon_Polly_Mizuki_YouTube_AudioLibrary_SoundEffects/sound ${ROOTDIR}/sound
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
    mv rezero_kpp_kkpt_epoch4/*.bin ${ROOTDIR}/eval

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
    mv standard_book.db ${ROOTDIR}/book

    curl -L ${BOOK_PATH_YANEURA_BOOK1} -O >& /dev/null
    if ! (shasum -a 256 -c ${BASEDIR}/checksums/yaneura_book1_V101.zip.sha256 >& /dev/null); then
        echo "ダウンロードした定跡ファイル(yaneura_book1_V101.zip)が壊れています" 1>&2
        exit 1
    fi
    unzip yaneura_book1_V101.zip >& /dev/null
    mv yaneura_book1.db ${ROOTDIR}/book

    curl -L ${BOOK_PATH_YANEURA_BOOK3} -O >& /dev/null
    if ! (shasum -a 256 -c ${BASEDIR}/checksums/yaneura_book3.zip.sha256 >& /dev/null); then
        echo "ダウンロードした定跡ファイル(yaneura_book3.zip)が壊れています" 1>&2
        exit 1
    fi
    unzip yaneura_book3.zip >& /dev/null
    mv yaneura_book3.db ${ROOTDIR}/book

    popd >& /dev/null

    echo "完了" 1>&2
}

if [ ${START_FROM} -le 0 ]; then
    check_env
fi

if [ ${START_FROM} -le 1 ]; then
    prepare_app
fi

if [ ${START_FROM} -le 2 ]; then
    build_myshogi
fi

if [ ${START_FROM} -le 3 ]; then
    build_yaneuraou
fi

if [ ${START_FROM} -le 4 ]; then
    build_soundplayer
fi

if [ ${START_FROM} -le 5 ]; then
    download_images
fi

if [ ${START_FROM} -le 6 ]; then
    download_sounds
fi

if [ ${START_FROM} -le 7 ]; then
    download_models
fi

if [ ${START_FROM} -le 8 ]; then
    download_books
fi
