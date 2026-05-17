# OSC 8 にいたる経緯

Claude Code と Grafana を使って調べものをしていて「Explore ページへのリンクを」なんて頼むと、端末上なのに Web ブラウザのような、リンクの貼られた文字列を出してくることがある。この仕組みは「OSC 8 ハイパーリンク」などと呼ばれていて、端末によって対応状況にばらつきがある。私はこのために、重い腰を上げて macOS の Terminal.app から Ghostty に乗り換えた。

## Operating System Command

OSC というのは Operating System Command の頭字語で、[EMCA-48](https://ecma-international.org/publications-and-standards/standards/ecma-48/) として1976年に策定されている。ECMAScript が [ECMA-262](https://ecma-international.org/publications-and-standards/standards/ecma-262/) であることを考えると、二桁というのは中々ふるい。あまりに古くて、第一版の仕様書はダウンロードできないし、第二版、第三版もだれかの手持ちの (しかもパンチ穴つきの) 資料をスキャンしたような PDF しかダウンロードできない。

ECMA-48 は [ANSI X3.64](https://nvlpubs.nist.gov/nistpubs/Legacy/FIPS/fipspub86.pdf) (PDF) と同じもので、端末で文字に色をつけたり太字にしたりするエスケープシーケンスを、俗に「ANSI エスケープシーケンス」と呼ぶのはこれに由来している。

OSC が当時に何に使われていたかはよくわからなく、ANSI X3.64 では

> The interpretation of the conmand is subject to the particular operating system and is not, of itself, part of this standard.

とされている。現存する資料だと [XTerm Control Sequences](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html) は OSC 0 から OSC 6 までに色々な機能をわりあてていて、現代の端末エミュレータはこれを実装しているものが多い。

OSC 7 は現在のディレクトリを伝えるための手段として [Apple が Terminal.app に実装したのが起源](https://github.com/fish-shell/fish-shell/issues/12031)だといわれている。

## OSC 8

OSC 8 は起源がはっきりしていて、Gnome のバグトラッカーに [Escape sequence and UI to mark text as hyperlink with URL](https://bugzilla.gnome.org/show_bug.cgi?id=779734) と提案がある。

> I'd like to have a terminal escape sequence that marks subsequent text as a hyperlink with a specified URL, and a sequence based on the same escape that marks the end of the link.  That would allow programs running in the terminal to provide hyperlinks based on context that wouldn't work via general URL recognition.

OSC 8 については議論のなかで

> So I think you'd want to use "OSC Ps ; Pt BEL" with a new Ps value, such as 8, and the URL as Pt; that sequence with an empty Pt would act as an "end tag".  gnome-terminal already uses OSC 7 for "set current directory".  xterm and some other terminals already ignore that.  Current gnome-terminal doesn't, though.

と決まっていて、iTerm2 でも同時期に議論があり、[Feature Request: Escape code for HTML-like anchor tags.](https://gitlab.com/gnachman/iterm2/-/work_items/5158) のなかで、

> We've received this same feature request for gnome-terminal a few days ago, and I've quickly put together a proof of concept. Please see https://bugzilla.gnome.org/show_bug.cgi?id=779734 for details, a few possible use cases for this feature, some questions I had in my mind, some technical thoughts etc...
>
> Let's definitely coordinate on the escape sequence that we choose, I'd hate to see iTerm2 and gnome-terminal coming up with incompatible solutions!

と同じ OSC 8 を使うようにまとまっている。
