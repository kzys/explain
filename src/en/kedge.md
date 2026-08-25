# Kedge

Kedge is a mixture of classic Heroku-era Fly.io, [Sprites](https://fly.io/sprites) and [exe.dev](https://exe.dev/). The founder, Will, was at Fly.io while I was there. At first, I didn't get why he built a competing product.

Turns out, it isn't a competing product.

While all of the platforms distance themselves from the application abstraction layer, Kedge doesn't.

From [Long Live Global Heroku](https://kedge.dev/blog/long-live-global-heroku):

> Every Kedge application instead gets a replicated SQLite database at /shared.db and a replicated file tree at /shared/, exposed as ordinary local paths. Reads and writes complete against a host-local copy; changes converge between cities and settle into object storage so the app can scale to zero.

Kedge even has its own [data-binding mechanism](https://kedge.dev/docs/html-apps)!

One worry I have about this AI agent era is that we let agents do whatever they've been trained on and don't really bother making new stuff in lower layers. Nobody ever got fired for buying IBM. Right?

So I'm happy Kedge isn't playing it safe. Excited to see where it goes!
