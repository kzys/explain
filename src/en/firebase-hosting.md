# Firebase Hosting

This site is currently on [Firebase Hosting](https://firebase.google.com/docs/hosting).

Since 2013, shorly after joining Amazon,
I've been using S3 for hosting static websites, later combining it with CloudFront.
While this combination has been reliable, I wanted to explore alternatives outside of the AWS ecosystem.

I initally tried Cloudflare and Netlify. Both platforms offer a more "managed" experience, such as providing per-branch URLs, but impose certain conventions. For example, Netlify redirects URLs with uppercase letters to their lowercase counterparts. Cloudflare doesn't enforce this, but it does redirect URLs with extensions (e.g., `.html`) to extension-less versions.

Firebase Hosting is still "managed", but doesn't mess with URLs.

While the existence of Firebase *App* Hosting is [a bit worrisome](https://killedbygoogle.com/), I'd stick with Firebase Hosting for now.
