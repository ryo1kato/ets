ets - an Easy Template System (Windows向けインストール手順書)

2009/05/08

■とりあえず試すには
  sample.ets ファイルを ets.bat にドラッグアンドドロップしてみて下さい。
  sample-out.txt が生成されます。

■はじめに
  Easy Template System (ets) はシェルスクリプト風の変数置換が可能な
  デスクトップユーザ向けの非常にシンプルなテンプレートエンジンです。

  二つの入力 変数設定ファイル(*.ets) と テンプレートファイル(*.template)
  を合成して出力ファイルを生成します。

   変数設定ファイル(sample.ets)
       | __TEMPLATE_FILE__ = "テンプレートファイル名"
       | __OUTPUT_FILE__ = "出力ファイル名"
       | WHO = brown fox
       | WHOM =    " the lazy dog"
       | HEREDOC =<< EOL
       | This is
       | multi line
       | definition using heredoc syntax.
       | EOL

   テンプレート(sample.template):
       | Quick ${WHO} jumped over${WHOM}.
       | Heredoc sample: ${HEREDOC}

   出力例:
       | Quick brown fox jumped over the lazy dog.
       | Heredoc sample: This is
       | multi line
       | definition using heredoc syntax.


■使用方法
  コマンドラインでの使用方法は README.TXT(英語) を参照して下さい。
  ここではインストール手順に従ってセットアップした後、ダブルクリック
  またはドラッグアンドドロップで使用する方法を説明します。

  <1> 変数設定ファイルを XXXX.ets という名前で作成します。このとき、
      必ず __TEMPLATE_FILE__ と __OUTPUT_FILE__ 変数を設定しておきます。

  <2> XXXX.ets を ets.bat にドラッグアンドドロップします。
      (インストール手順 A の場合)

      または XXXX.ets をダブルクリックします。
      (インストール手順 B の場合)

■日本語に関する注意
  文字コードの自動変換には対応していませんので
  変数設定ファイル(*.ets) と テンプレートファイルの文字コード
  (改行コードも)を一致させるようにして下さい。

■インストール手順(共通)
  Python 2.5 for Windows を下記からダウンロードしてインストールします

      http://www.python.org/ftp/python/2.5.4/python-2.5.4.msi

  (Python3000 は未サポートです)


■インストール手順 A: ets.bat を使用

  ets.py と ets.bat を好きな場所にコピーします。
  (二つのファイルを同じ場所に置いて下さい)
  使用する際は変数設定ファイルを ets.bat にドロップします。


■インストール手順 A: ファイル関連付け

  <1> ets.py を好きな場所へコピーします。ここでは仮に
      "C:\Programs\ets\ets.py" にコピーしたとします。

  <2> ファイルの関連付けで以下のコマンドラインを拡張子 ets に指定します。

        "C:\Python25\pythonw.exe" "C:\Programs\ets\ets.py" --gui
        --outfile-in-config --template-in-config "%1"
        (実際は一行で入力)

        ※コントロールパネル→フォルダオプション→ファイルの種類
          から「新規」で ETS を追加し、アクションを作成します。
        ※上書きを許可するには --overwrite を追加して下さい。
        ※Pythonw.exeの場所は実際のインストール場所に合せて下さい。

      sample.ets をダブルクリックするだけで sample-out.txt が
      生成されるようになれば成功です。

  <3> [任意] ファイルの関連付けで、「編集」アクションなども
      追加しておくと便利でしょう。
