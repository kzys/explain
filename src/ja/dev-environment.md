# 開発環境現状確認 (2026)

[開発環境現状確認](https://blog.handlena.me/entry/2025/01/development-tools/) (2025) からはじまった流れが、二年目で大きくなった感じみたい。わたしものってみる。

## OS

仕事は会社標準の MacBook Pro + macOS を使っている。まだ Tahoe にアップグレードしていない。あんまりカスタマイズはしていなくて、ドックを自動で隠すようにしているのと、Caps Lock を Ctrl にしているくらい。ウィンドウマネージャーの類もつかっていない。

個人的なことには2022年に買った Framework Laptop 13 + Ubuntu 22.04.3 LTS を使っている。当時の Framework Laptop は画面の解像度が中途半端で、私はピクセルは等倍で、文字サイズだけを大きくして、Fractional Scaling は避けて使っている。いまだったら、[2.8K のディスプレイ](https://frame.work/products/display-kit?v=FRANJF0001)を買ってしまえばいいと思う。

キーボードは xremap でちょっとカスタマイズして macOS によせている。

* CapsLock -> `Ctrl_R`
* Emacs や readline で使う C-f / C-n とかをカーソルキーにマップしてどこでも使えるようにする
* ターミナルでよく使う Cmd-c / Cmd-v / Cmd-v を `Ctrl_L` のほうにマップして、シフトを押さないですむようにする

CapsLock を `Ctrl_R` にして、そっち側に Unix っぽいショートカットを、`Ctrl_L` のほうに Cmd っぽい役割をあてるのはうまくいっている。

以前は Alt の場所を Cmd っぽい役割にしていたのだけど、これはどうしても漏れがでてしまって混乱するので、いまは止めている。ただ、最近 macOS 時間が増えた結果 (前職は仕事も Framework Laptop だった)、Cmd の気持ちで Alt を押していることがあるので、また挑戦するかもしれない。

## エディタ

メインは Visual Studio Code で、以前は [Awesome Emacs Keymap](https://marketplace.visualstudio.com/items?itemName=tuttieee.emacs-mcx) を使っていたのだけど、最近はあきらめて標準キーバインディングでがんばっている。

Emacs もいまだに、magit と細々としたファイルをいじるのに使う。

## コーディングエージェント

仕事も個人的なものも Claude Code を使っている。雑なスクリプト、例えば Linux の OOM killer が出すタスクリストが sort でソートできるかたちじゃないからソートして、ついでにバイト表示を MiB で出す Python スクリプト、とかはすぐ書いてくれるので便利。

もうちょっと慣れてきたら、オープンウェイトなモデルが使える [OpenCode](https://opencode.ai/) とかも試したいところ。

## ターミナルまわり

Terminal.app と GNOME Terminal で、本当にこだわりなし。

マルチプレクサは tmux を使っている。画面分割すらせず、ごく基本的な機能しか使わないまま10年くらいたつので、今年はもうちょっとがんばりたい。

シェルは zsh を使っている。[Oh My Zsh](https://ohmyz.sh/) みたいなものは使っていなくて、細々した設定も自分で書いている。最近 KUBECONFIG を RPROMPT に出すようにした。

## ランチャー

使っていなくて、macOS なら Spotlight くらい。

## ブラウザ

仕事は多数派で Chrome, 個人はブラウザの多様化を気にして Firefox を使っている。子どものアカウントを自分のアカウントの両方を操作するようなことが一年に数回はあり、そういうときは Multi-Account Containers を使うと便利。

## ノート

デジタルのものは Obsidian を使っている。以前は日記もつけていたのだけど、これは休止中。

ミーティング中とか、図をかいたりするノートは Lechtturm 1917 の A5 ドット方眼のノートを使っている。これは仕事もプライベートも全部まとめて一つのノートにして、出かけるときも持ち歩くようにしている。

## キーボード

Keychron V1 を使っている。むかしは Happy Hacking Keyboard などの小さいキーボードが好きだったのだけど、いまは `~` とかの位置をラップトップと揃えたくて、そうすると 75% がちょうどいい。

## トラックボール

人差し指トラックボールが好きな少数派なので、Elecom の Deft Pro を使っている。
