---
description: "Proofread new and updated posts"

on:
  schedule: weekly on monday
  pull_request:
    paths:
      - "src/en/**.md"
      - "src/ja/**.md"
      - ".github/workflows/proofread.md"
  workflow_dispatch:

permissions:
  contents: read
  copilot-requests: write

engine: copilot

checkout:
  fetch-depth: 0

tools:
  bash: ["git diff:*", "git log:*", "git fetch:*"]

safe-outputs:
  add-comment:
    max: 1
  create-issue:
    max: 5
    title-prefix: "[proofread] "
    labels: [proofread]

timeout-minutes: 10
---

# Proofread

このサイトは英語と日本語の記事を書いています。追加・変更された記事を読んで、感想を書いてください。

## 読む範囲

`src/en/` と `src/ja/` 以下の `.md` ファイルのうち、追加・変更されたものだけを読んでください。

- プルリクエストで起動されたとき:

  ```
  git diff --name-only origin/main...HEAD -- src/en src/ja
  ```

- それ以外のとき:

  ```
  git log --since='7 days ago' --name-only --pretty=format: -- src/en src/ja
  ```

プルリクエストがこのワークフロー自身 (`.github/workflows/proofread.md`) だけを変更している
ときは、後者の `git log` のほうを使ってください。ワークフローの動作を試すためです。

該当するファイルがなければ、何も書かずに終了してください。

## 書きかた

- 英語・日本語をとわず、良い部分をほめてください。文章のどこが良かったのか、具体的に書いてください。
- 英語の文法の誤りは、教師のように、丁寧に**日本語で**指摘してください。誤った文をそのまま引用し、直した文を示し、なぜそう直すのかを説明してください。
- 表記ゆれや誤字も指摘してかまいませんが、文体の好みを押しつけないでください。
- 指摘がないファイルについては、ほめるだけで十分です。

## 出力

- `pull_request` で起動されたときは、そのプルリクエストにコメントを 1 つ書いてください。ファイルごとに見出しを分けてください。
- それ以外のときは、ファイルごとに issue を 1 つ立ててください。タイトルにはファイルのパスを入れてください。
