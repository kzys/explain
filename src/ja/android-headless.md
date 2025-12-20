# 画面が完全に死んでしまった Android をソフトウェア的に操作する方法

Pixel 6A の画面をこわしてしまった。物理的なひび割れは大きくないのだけど、画面がまったく映らない。

[画面をハードウェア的に直す](https://www.ifixit.com/Guide/Google+Pixel+6a+Screen+Replacement/152304)こともできるのだけど、分解に失敗して状況を悪化させても困るので、まずはソフトウェア的に必要最低限のデータ移行をすることにした。

ソフトウェア的になんとかする方法については、[How to use Android/Pixel with broken screen](https://www.reddit.com/r/AndroidQuestions/comments/1hui216/how_to_use_androidpixel_with_broken_screen/) がよくまとまっている。

1. TalkBack を有効化
2. USB でキーボードをつなぐ
3. Developer モードを有効化
4. [scrcpy](https://github.com/Genymobile/scrcpy/tree/master) をつかって、USB でつないだコンピュータに画面をうつす

新しい Pixel なら HDMI ケーブルをつなぐこともできるみたいけど、残念ながら Pixel 6A はできない。

## 画面の情報をテキストでとりだす

Okta Verify や Authy といった、セキュリティ系のアプリケーションは、scrcpy で画面が映らないように設定されている。TalkBack で読み上げはできるけど、音からスペルを類推しずらいこともある。

こういう場合は、`adb shell` で入って、`uiautomator dump` すると、画面のツリーが XML でとれる。

HTML の DOM とはちがって、長いリストビューとかだと画面に存在しない部分はそもそもツリーになかったりするので、それには注意が必要。
