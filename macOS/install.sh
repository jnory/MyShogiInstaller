#!/usr/bin/env bash

set -e

BASEDIR=`dirname $0`/..
pushd ${BASEDIR} >& /dev/null
BASEDIR=`pwd`
popd >& /dev/null

. ${BASEDIR}/common/config.sh
. ${BASEDIR}/common/build.sh
. ${BASEDIR}/common/download.sh
. ${BASEDIR}/common/util.sh

####### (macOS専用) 環境設定 #######
MONO_PATH=/Library/Frameworks/Mono.framework/Versions/Current/Commands/mono
MSBUILD_PATH=/Library/Frameworks/Mono.framework/Versions/Current/Commands/msbuild
##############

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

if [ ${START_FROM} -le 0 ]; then
    check_env
fi

if [ ${START_FROM} -le 1 ]; then 
    prepare_app
fi

if [ ${START_FROM} -le 2 ]; then 
    build_myshogi ${PREFIX} ${MYSHOGI_REPOS} ${MYSHOGI_VERSION} macOS ${ROOTDIR}/MacOS
fi

if [ ${START_FROM} -le 3 ]; then 
    build_yaneuraou ${PREFIX} ${YANEURAOU_REPOS} ${YANEURAOU_VERSION} ${ROOTDIR}/MacOS ${BASEDIR}/engine_defines ${BASEDIR}/common/YaneuraOu.patch
fi
exit

if [ ${START_FROM} -le 4 ]; then 
    build_soundplayer ${PREFIX} ${SOUNDPLAYER_REPOS} ${SOUNDPLAYER_VERSION} macos macOS ${ROOTDIR}/MacOS dylib
fi

if [ ${START_FROM} -le 5 ]; then
    download_images ${PREFIX} ${IMAGES_REPOS} ${IMAGES_VERSION} ${ROOTDIR}/MacOS
fi

if [ ${START_FROM} -le 6 ]; then 
    download_sounds ${PREFIX} ${SOUND_REPOS} ${SOUND_VERSION} ${ROOTDIR}/MacOS
fi

if [ ${START_FROM} -le 7 ]; then 
    download_models ${PREFIX} ${MODEL_PATH} ${BASEDIR}/checksums ${ROOTDIR}/MacOS
fi

if [ ${START_FROM} -le 8 ]; then 
    download_books ${PREFIX} ${BOOK_PATH_STANDARD} ${BOOK_PATH_YANEURA_BOOK1} ${BOOK_PATH_YANEURA_BOOK3} ${BASEDIR}/checksums ${ROOTDIR}/MacOS
fi
