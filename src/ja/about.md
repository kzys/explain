# このサイトについて

- ふつうのブログよりは、ちょっとホームページっぽい感じを目指しています。具体的には、最初に投稿した日付があんまり全面に出ないようになっています。

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
