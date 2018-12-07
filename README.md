# MyShogiInstaller

## これは何？

MyShogi (https://github.com/yaneurao/MyShogi) の私家版インストーラーです。

## 対応環境

現在macOSのみの対応です。

## 使い方
  
以下のコマンドを実行すると./buildの中にMyShogi.appが完成します。

  > ./macOS/install.sh ./build
  
## 必要なコマンド類

おそらく以下のコマンドが入っていればビルドできるはずです。

* mono
* msbuild
* cmake
* make
* git
* g++
* curl
* unzip

入っていなければ事前にインストールしておいて下さい。
なお、homebrewに入っているmonoでは起動しませんので
monoは公式サイトからインストーラーを使ってインストールして下さい。

## engine_define.xmlについて

同梱してあるengine_define.xmlは、MyShogiのバイナリから生成させたサンプルXMLを元に改変しています。
生成コードは[ここ](https://github.com/yaneurao/MyShogi/blob/master/MyShogi/Model/Shogi/EngineDefine/Sample/EngineDefineSample.cs)にあります。
棋力設定の名前に段位がありますが、本家様と区別するため先頭に `F` をつけてあります(FreeのF)。
このファイルに記載の段位については実際の棋力と関係ありません。

## ライセンス

GPL v3  

## ありそうな質問

### どんな環境ができますか？

以下のものがインストールされます。

* MyShogi ( https://github.com/yaneurao/MyShogi )
* やねうら王 KPP_KKPT版 ( https://github.com/yaneurao/YaneuraOu )
* MyShogiSoundPlayer ( https://github.com/jnory/MyShogiSoundPlayer )
* フリーの画像データ ( https://github.com/jnory/MyShogiImages )
* フリーの音声データ ( https://github.com/matarillo/MyShogiSound )

### 商用ライセンスを持っているのですが、画像などはそちらを使えますか？

Windows版からそれらしきものをご自分でコピーして差し替えて下さい。
(差し替えの手間を考えるとこのインストーラーを使うメリットがどれほどあるかは微妙)

### アイコンないの？

Pull Requestお待ちしております。

### 不具合に気付きました

このリポジトリにIssueを立てるか、作者のTwitter( @arrow_elpis )までお知らせ下さい。
PRも大歓迎です。
なお、このインストーラーはあくまで非公式なものですので、
本家様へのお問い合わせはご遠慮ください。

以上
