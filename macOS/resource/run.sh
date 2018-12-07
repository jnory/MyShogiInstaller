#!/usr/bin/env bash

DIR=`dirname $0`
MONO=${MONO:-/Library/Frameworks/Mono.framework/Versions/Current/Commands/mono}
MONO_EXE_DIR=`dirname ${MONO}`
export PATH=${PATH}:${MONO_EXE_DIR}

${MONO} --arch=32 ${DIR}/MyShogi.exe
