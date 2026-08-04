# TODO

Design questions that were deliberately parked rather than forgotten. Each
records what was already measured, so the work doesn't have to be re-derived.

## Language hues

Currently blue `#1d4ed8` (Japanese) and emerald `#047857` (English), set as
`--lang-ja-color` / `--lang-en-color` in `src/style.css`. Changing them is a
two-line edit — they're used at full strength by both the ratio chart and the
per-post size bar.

The open problem is association, not legibility: blue beside green reads as the
Cascadia flag, and for a Seattle site it also lands on the local football
palette. Several alternatives were mocked up and none were an improvement worth
switching for.

Constraints learned along the way, all measured rather than guessed:

- **Purple and magenta are the reliable flag-free anchors.** National flags are
  drawn almost entirely from red, blue, green, yellow, white and black. Purple
  is effectively absent (the dye was historically ruinous), magenta entirely so.
  A pair anchored on either stops parsing as a flag whatever sits opposite.
- **Red + blue** reads as the Korean flag. **Forest + burgundy** fails
  colourblind separation outright (ΔE 1.0 under deuteranopia — indistinguishable).
  **Emerald + crimson** also fails at ΔE 6.0, the classic red-green trap.
- **Teal and cyan keep failing the chroma floor** at any darkness that clears
  contrast on the ground — they end up reading grey rather than coloured.
- Validate candidates with the dataviz skill's `validate_palette.js`, against
  surface `#fbfbfd`. Targets: CVD ΔE ≥ 8 between the two hues, ≥ 4.5:1 for a
  label on its own fill, and ≥ 3:1 for each fill on the ground.

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
