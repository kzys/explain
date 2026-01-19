# Ubuntu

Framework Laptop でも、サーバーとして使っているいろいろなミニ PC でも、基本的に Ubuntu を使っている。

## 句読点の位置を直す

[Ubuntu 24.10で日本語句読点が中央に表示される問題とその修正](https://hydrakecat.net/ubuntu/2025/08/09/cjk-punctuation-font-on-ubuntu.html) にあるように `~/.config/fontconfig/fonts.conf` を編集する。

## Firefox で日本語のグリフを優先する

`about:config` で `font.cjk_fallback_order` で `ja` を最初に持ってくると「直す」みたいな文字列をレンダリングするときに、日本語の字体が使われるようになる。

