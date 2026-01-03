# Tailscale で日本の IP アドレスをつける

アメリカに住んでいるけれど、ときどき日本の IP アドレスがあると便利なことがある。

むかしは [NordVPN](https://nordvpn.com/) などの有料 VPN を使っていたけれど、2023年から [Tailscale](https://tailscale.com/) を使っている。

Tailscale は [WireGuard](https://www.wireguard.com/) ベースの VPN だ。それ単体では IP アドレスの国を偽装することはできないけれど、日本国内にノードを置いて、それを出口のノードとして使うように設定できる。

私の場合、日本の実家に Beelink のミニ PC をおいて、Ubuntu 24.04 LTS をインストールし、その上で Tailscale を動かしている。

## いまのところ、Tailscale は Fire TV や Google Chromecast にもインストールできる

Tailscale は結構いろいろなデバイスにインストールできて、携帯電話はもちろんのこと、Fire TV や Google Chromecast でも動かせる。私は Fire TV Stick 4K Max をプロジェクターに、Google Chromecast with Google TV をテレビとプロジェクターにつなげるようにしていて、どちらにも Tailscale をインストールしている。

ただ、この安い HDMI スティックに Tailscale をいれるのは、今後ずっと続けられるかというと、ちょっと不透明なところがある。

Amazon は Fire OS を Vega OS という新しい OS に置き換えはじめていて、Fire TV 4K Select などの新しい Fire TV では、[Tailscale は動かない](https://www.amazonforum.com/s/question/0D5at00000YibNsCAJ/jellyfin-and-tailscale-not-compatible-with-fire-tv-stick-4k-select)。Google には同様に Fuchsia という新しい OS があるのと、そもそも、[小さくて安い Chromecast を作るのをやめてしまっている](https://www.theverge.com/2024/8/8/24215344/google-chromecast-discontinued-salute-great-hdmi-streaming-dongle)。


