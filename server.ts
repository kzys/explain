import * as fs from 'node:fs/promises';
import * as marked from 'marked';
import * as layout from './layout';
import * as react from 'react'
import * as dom from 'react-dom/server'
import {micromark} from 'micromark'
import {gfm, gfmHtml} from 'micromark-extension-gfm'
import {gfmFootnote, gfmFootnoteHtml} from 'micromark-extension-gfm-footnote'

async function fetch(req: Request) {
    let u = new URL(req.url);
    let path = u.pathname.slice(1);

    path = 'src/' + path;


    let exists = await fs.exists(path);
    if (! exists) {
        let res = new Response('not found', {status:404});
        return res;
    }

    let stat = await fs.stat(path);
    if (stat.isDirectory()) {
        path += '/index.html';
    }

    path = path.replace(/\.html$/, '.md');

    let source = await fs.readFile(path, {encoding: 'utf-8'})

    // ignore YAML front matters.
    if (source.indexOf('---\n') == 0) {
        source = source.split(/---\n/)[2]
    }
    
    let html = micromark(source, {
        allowDangerousHtml: true,
        extensions: [gfm()],
        htmlExtensions: [gfmHtml()]
      })

    let c = react.createElement('div', {dangerouslySetInnerHTML: {__html: html}});
    html = dom.renderToStaticMarkup(layout.Component({
        title: 'explain.8-p.info',
        children: c
    }));
    return new Response(html, {headers: {
        'content-type': 'text/html; charset=utf-8',
    }});
}

Bun.serve({
    fetch: function(req: Request) {
        return fetch(req);
    }
})
