# TODO

Design questions that were deliberately parked rather than forgotten. Each
records what was already measured, so the work doesn't have to be re-derived.

## Index row affordance

Index titles compute to `rgb(21,21,27)` with `text-decoration: none` — identical
to body text. Nothing marks a row as tappable until you hover it, so on touch
there is no affordance at all. The chevron that used to serve this was removed
on the reasoning that "the row is already a link and already hover-highlights",
which only holds for pointer devices.

Two jobs worth keeping separate here: **affordance** is persistent and must
survive with no pointer; **feedback** is transient and pointer-only. The current
design has feedback and no affordance.

Options considered:

- Underline the title. Reuses the site's existing link language — links are
  ink-coloured and underlined by default, and `.article-link` explicitly opts
  out with `text-decoration: none !important`.
- Bring back a mark such as the chevron. Works, but adds an element the rest of
  the design doesn't use.

## The grouping rail on narrow screens

`#index article:has(.language-section)::before` sits at `left: -12px`, inside
the bleed margin the hover surface already uses. On desktop it reads as a
bracket. At 390px the body margin is only 16px, so the rail lands 4px from the
screen edge and reads as an edge marker instead.

Nothing is broken — proximity carries the grouping on its own there (16px inside
a pair against 33px between posts) — but for the rail to actually read at that
width, the pair needs a small indent to give it somewhere to sit.

## The date cascade overflows below ~390px

`.page-metadata .changes-items li` is rotated `-20deg` about its bottom-left
corner with `white-space: nowrap`, and the labels are pulled together with
`margin-right: -6rem`. Rotation doesn't change an element's layout box, so the
row occupies its pre-rotation width but *paints* well to the right of it — and
`scrollWidth` counts the painted extent, so the page scrolls sideways.

Measured on the built index:

- The cascade is anchored to the column's left edge and its length is set by how
  many change entries a post has, **not** by the viewport. The worst post on the
  index has 6 entries and ends at x=389 at both a 360px and a 390px viewport —
  the same absolute x.
- So it overflows any viewport narrower than about 390px, by exactly
  `389 − viewport`: 29px at 360px, 23px at 320px. A post with more entries would
  raise that threshold.
- Widening the body margin to `1.75rem` (done for the rail) *reduced* the
  overflow rather than causing it — at 320px it went from 57px to 23px, because
  the narrower column changes where the labels wrap.

Not yet investigated: whether to clip `.page-metadata`, shorten the cascade at
narrow widths, or drop the rotation below some breakpoint. Note the existing
comment on `margin-right` — it's tuned so consecutive labels sit about one
line-height apart, and loosening it makes the row wrap, which breaks the
cascade entirely.

## Drafts in a public repository

The repository is public as of 2026-08-20. An audit of all 341 commits and 12
remote branches found no credentials, no addresses, and no private hostnames.

The 18 remaining `draft: true` files are exposed. The earlier worry about
`src/en/homelab/*` was misplaced: `src/ja/tailscale.md` is published and already
says more — the 実家 in Japan, the Beelink mini PC, the exit node, and why a
residential IP beats a paid VPN — and `src/ja/about.md` names every employer.

What history does add, contrary to what this file used to claim, is the three
drafts deleted in `3735b85`, which now exist nowhere else:
`src/ja/opinion-is-my-own.md` (superseded by the published
`opinions-are-my-own.md`), `src/ja/run/forerunner-165.md` (superseded by
`garmin-forerunner-165.md`), and `src/ja/youtube.md`, a two-sentence fragment.
Accepted rather than rewritten, since each is superseded or trivial.

## No LICENSE

The repository has no LICENSE, which matters now that it is public. The default
is all rights reserved for everything, including the generator, which readers
will reasonably assume is theirs to copy.

The two halves want different answers: the posts are the kind of thing to keep,
the generator is the kind of thing to give away. So a split — a permissive
license for `gen.rb`, `dev.rb`, `view/` and `test/`, and something explicit for
`src/` — rather than one license for the whole tree.

Undecided: which permissive license, and whether `src/` should be
all-rights-reserved or a Creative Commons variant.
