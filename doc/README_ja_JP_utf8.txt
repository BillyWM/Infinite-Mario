Infinite Mario Bros! (Flash版)

これは Infinite Mario Bros!(Java版) を ActionScript3 に移植した Flash 
版です。

オリジナル(Java版)はこれです。Java版ソースもここから取得できます。
http://www.mojang.com/notch/mario/

次の二つはオリジナル(Java版)に含まれていたものです。
LICENSE.txt
README.txt

このFlash版のライセンスも上記Java版と同じとします。

ビルドには Flex 2 SDK が必要です。Flex 2 SDKをインストールしたディレク
トリを c:\usr\flex とすると、以下のコマンドでmario.swfができます。

> c:\usr\flex\bin\mxmlc -output mario.swf src\Root.as

antがあれば、build.xmlを使ってビルドできます。build.xmlのあるディレク
トリをカレントディレクトリにして以下のコマンドでwork/mario.swfができま
す。

> ant 

全ての*.asファイルのエンコードはutf-8、unix改行です。

mp3ファイル群はJava版に含まれるmidファイルとwavファイルを変換したもの
です。

*.mid を *.wav に変換するのは timidity を使って
> c:\usr\timidity\timidity-con.exe -s 11k -Ow *.mid

*.wav を *.mp3 に変換するのは lame を使って
> c:\usr\lame3.97\lame.exe 1-up.wav 1-up.mp3

遊び方
・最初にマウスでクリックしてキーボードフォーカスを与える
・矢印キーで上下左右
・[A]キーでダッシュなど
・[S]キーでジャンプなど

