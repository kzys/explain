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

## `make tidy` fights `src/ja/political.md`

`make tidy` strips trailing whitespace from every `.md` file. One line in
`src/ja/political.md` — the Hacker News guidelines blockquote — ends with a
trailing space in the committed file, so every `make tidy` run re-introduces a
diff there that then has to be reverted.

(Whether that space is wanted is itself undecided. Its removal was part of a
batch of content edits that got reverted wholesale, so the revert isn't
necessarily a judgement about this line specifically.)

Needs a decision either way: drop the trailing space, or narrow `tidy`'s scope
so it leaves content files alone.
