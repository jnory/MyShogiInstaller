#!/usr/bin/env bash

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
