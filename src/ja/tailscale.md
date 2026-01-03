# Tailscale で日本の IP アドレスをつける

アメリカに住んでいるけれど、ときどき日本の IP アドレスがあると便利なことがある。

むかしは [NordVPN](https://nordvpn.com/) のような商用の VPN を使っていたけれど、2023年に日本に帰省したときに Beelink のミニ PC を実家において、それからは [Tailscale](https://tailscale.com/) を使っている。

## Android っぽい OS がはしる HDMI ドングル

Tailscale クライアントは結構いろいろなデバイスにインストールできて、携帯電話はもちろんのこと、Fire TV や Google Chromecast でも動くので便利。

なお、Amazon は Fire OS を Vega OS という新しい OS に置き換えはじめていて、Fire TV 4K Select などの新しい Fire TV では、[Tailscale は動かない](https://www.amazonforum.com/s/question/0D5at00000YibNsCAJ/jellyfin-and-tailscale-not-compatible-with-fire-tv-stick-4k-select)。Google には同様に Fuchsia があるのと、そもそも[小さくて安い Chromecast を作るのをやめてしまっている](https://www.theverge.com/2024/8/8/24215344/google-chromecast-discontinued-salute-great-hdmi-streaming-dongle)ので、いまから同じ環境をつくるときは注意が必要。

