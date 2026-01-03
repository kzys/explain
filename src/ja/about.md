# このサイトについて

## 著者について

- いまは [Baseten](https://www.baseten.co/) というスタートアップでエンジニアとして働いています。
- 以前は [Fly.io](https://fly.io/) (リモート), [Amazon](https://www.amazon.com/) (シアトルと目黒), [ミクシィ](https://mixi.co.jp/) (原宿と渋谷) などで働いていました。
- Amazon 在職中に、本社のあるアメリカのシアトルに引越しました。

## このサイト自体について

いわゆる静的サイトジェネレーターを Ruby で自作しています。

- Markdown から HTML への変換は [CommonMark](https://commonmark.org/) 互換の [markly](https://rubygems.org/gems/markly)
- テンプレートは eRuby

いまのところ、テストと空行をふくめても237行におさまっています。

```
% date; wc -l **/*.rb
Sat Jan  3 09:34:26 AM PST 2026
 170 gen.rb
  67 test/test_gen.rb
 237 total
```
