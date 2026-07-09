# About

## About the author

- I work for [Baseten](https://www.baseten.co), an AI startup in San Francisco, though I work remotely from Seattle.
- Previously, I worked for [Fly.io](https://fly.io/) (remote), [Amazon](https://www.amazon.com/) (Seattle and Tokyo), and [Mixi](https://mixi.co.jp/) (Tokyo).
- I was born and raised in Japan, and moved to Seattle while I was at Amazon.

## About this site

I wrote this static site generator in Ruby and it was under 200 lines for its first year, excluding empty lines and including tests.

I started using Claude Code in December 2025 and it made the scripts much longer -- though the latest refactoring, which cut them back down, was also done by Claude.

```
git log --reverse --format='%h %as' -- '*.rb' | while read h d; do echo "$d $(git grep -c '.' $h -- '*.rb' | awk -F: '{if ($2 ~ /^test\//) t+=$NF; else m+=$NF} END {print m+0, t+0, m+t}')"; done | tac | awk '!seen[substr($1,1,7)]++' | tac

            main test total
2025-01-30    19    0    19
2025-02-15    30    0    30
2025-05-06   119   35   154
2025-08-13   122   56   178
2025-09-05   125   56   181
2025-12-18   145   56   201
2026-01-26   281  308   589
2026-05-17   335  391   726
2026-06-27   339  391   730
2026-07-09   206  265   471
```
