# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

- `make` - Build the site (runs `bundle exec ruby gen.rb`)
- `make test` - Run all tests
- `bundle exec ruby -Itest test/test_gen.rb --name '/TestClassName/'` - Run specific test class
- `make tidy` - Remove trailing whitespace from source files

## Architecture

This is a custom static site generator for https://explain.8-p.info, a bilingual (English/Japanese) personal website.

### Core Components

- **gen.rb** - Main generator script. Parses markdown files, extracts metadata from YAML front matter and git history, converts to HTML using Markly (CommonMark), and applies ERB templates.
- **view/layout.html.erb** - Base HTML template wrapping all pages
- **src/** - Source content: markdown files (`.md`), ERB templates (`.erb`), CSS, and static assets
- **public/** - Generated output (not in git)

### Content Processing

1. Markdown files support YAML front matter for `title` and `draft` flags
2. H1 headers are extracted as titles and rendered separately in the layout
3. Relative `.md` links are automatically rewritten to `.html` in output
4. Static assets (CSS, JS, fonts) get cache-busting hashes in filenames
5. Page timestamps come from git history, not filesystem

### URL Structure

- `src/en/*.md` → `public/en/*.html` (English content)
- `src/ja/*.md` → `public/ja/*.html` (Japanese content)
- Subdirectories preserved: `src/en/homelab/tailscale.md` → `public/en/homelab/tailscale.html`
