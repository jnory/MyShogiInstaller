#!/usr/bin/env bash
# TODO: macOS/install.sh との共通部分をリファクタ

set -e

BASEDIR=`dirname $0`/..
pushd ${BASEDIR} >& /dev/null
BASEDIR=`pwd`
popd >& /dev/null

. ${BASEDIR}/common/config.sh
. ${BASEDIR}/common/build.sh
. ${BASEDIR}/common/download.sh
. ${BASEDIR}/common/util.sh


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

    mkdir -p ${ROOTDIR}

    mkdir -p ${ROOTDIR}/engine
    mkdir -p ${ROOTDIR}/eval
    mkdir -p ${ROOTDIR}/book
    cp -p ${BASEDIR}/ubuntu/resource/run.sh ${ROOTDIR}

    echo "完了" 1>&2
}

if [ ${START_FROM} -le 0 ]; then
    check_env
fi

if [ ${START_FROM} -le 1 ]; then
    prepare_app
fi

if [ ${START_FROM} -le 2 ]; then
    build_myshogi ${PREFIX} ${MYSHOGI_REPOS} ${MYSHOGI_VERSION} Linux ${ROOTDIR}
fi

if [ ${START_FROM} -le 3 ]; then
    build_yaneuraou ${PREFIX} ${YANEURAOU_REPOS} ${YANEURAOU_VERSION} ${ROOTDIR} ${BASEDIR}/engine_defines ${BASEDIR}/common/YaneuraOu.patch
fi

if [ ${START_FROM} -le 4 ]; then
    build_soundplayer ${PREFIX} ${SOUNDPLAYER_REPOS} ${SOUNDPLAYER_VERSION} linux Linux ${ROOTDIR} so
fi

if [ ${START_FROM} -le 5 ]; then
    download_images ${PREFIX} ${IMAGES_REPOS} ${IMAGES_VERSION} ${ROOTDIR}
fi

if [ ${START_FROM} -le 6 ]; then
    download_sounds ${PREFIX} ${SOUND_REPOS} ${SOUND_VERSION} ${ROOTDIR}
fi

if [ ${START_FROM} -le 7 ]; then
    download_models ${PREFIX} ${MODEL_PATH} ${BASEDIR}/checksums ${ROOTDIR}
fi

if [ ${START_FROM} -le 8 ]; then
    download_books ${PREFIX} ${BOOK_PATH_STANDARD} ${BOOK_PATH_YANEURA_BOOK1} ${BOOK_PATH_YANEURA_BOOK3} ${BASEDIR}/checksums ${ROOTDIR}
fi
