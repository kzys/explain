# このサイトについて

## 著者について

- いまは [Baseten](https://www.baseten.co/) というスタートアップでエンジニアとして働いています。
- 以前は Fly.io (リモート), Amazon (シアトルと目黒), ミクシィ (原宿と渋谷) などで働いていました。
- Amazon 在職中から、アメリカのシアトルに住んでいます。

## 技術的なこと

いわゆる静的サイトジェネレーターを Ruby で自作しています。

- Markdown から HTML への変換は [CommonMark](https://commonmark.org/) 互換の [markly](https://rubygems.org/gems/markly)
- テンプレートは eRuby

いまのところテストふくめて200行くらいです。

```
% date; wc -l **/*.rb
Sat Aug 23 11:33:59 AM PDT 2025
 144 gen.rb
  67 test/test_gen.rb
 211 total
```
