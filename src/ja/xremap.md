# xremap

[xremap](https://github.com/xremap/xremap) は Linux で動くキーリマッパー。

## macOS 風に Cmd と Ctrl を使いわける

ながらく公私ともに macOS を使っていて、いまでも仕事は MacBook Pro をつかっていること、そもそも Cmd / Ctrl が別れているほうが macOS 由来のショートカットと Unix 由来のショートカットがかぶらなくて便利なので、Linux でも似たような使い勝手になるように設定している。


```
keypress_delay_ms: 5

modmap:
  # Mapping CapsLock to Ctrl where I don't use Cmd much
  - name: CapsLock -> Ctrl_R
    remap:
      CapsLock: Ctrl_R
      Alt_L: Win_R
    application:
      not: [Emacs, Code, firefox_firefox]
  # Mapping Alt to Ctrl where I use Cmd more than Ctrl such as Visual Studio Code.
  - name: CapsLock -> Win_R
    application:
      only: [Code, firefox_firefox]
    remap:
      CapsLock: Win_R
      Alt_L: Ctrl_R

keymap:
  - name: Terminal
    application:
      only: [gnome-terminal-server, Gnome-terminal]
    remap:
      Win_R-n: C-Shift-n
      Win_R-c: C-Shift-c
      Win_R-v: C-Shift-v
      Win_R-w: C-Shift-w
  - name: Emacs-like shortcuts for moving a cursor
    application:
      only: [Code, firefox_firefox]
    remap:
      Win_R-f: right
      Win_R-b: left
      Win_R-n: down
      Win_R-p: up
      Win_R-a: home
      Win_R-e: end
      Win_R-g: Esc
      Win_R-h: Backspace
```
