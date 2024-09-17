---
title: mozc にパッチを送った
---
# mozc にパッチを送った

Ubuntu 22.04 を 24.04 にアップグレードしたら、Super + Space で Mozc をオフにできなくなってしまったので、直した。

- https://github.com/google/mozc/pull/1059

## Dockerfile は開発むけではない

Linux むけのビルド方法について、[Docker をつかったもの](https://github.com/google/mozc/blob/master/docs/build_mozc_in_docker.md)が書かれているけれど、これは開発むけではない。

具体的に言うと、Dockerfile のなかで `git clone https://github.com/google/mozc.git` しているので、手元の変更をビルドするのには使えない。

GitHub Actions では Docker なしで Bazel を動かしているので、それを参考にしながら開発環境をととのえると良い。

## ビルドしたバイナリを試す方法

src のなかで `bazel build package --config oss_linux` とすると `./bazel-out/k8-fastbuild/bin/unix/ibus/ibus_mozc` が出来るので、それを実行する。

## スタイルいろいろ

ふだん C++ を書かないからか、コードレビューではスタイル面の指摘が多かった。GitHub Actions もスタイルについてはみないので (gofmt みたいなものは走っていないので)、注意が必要。
