import * as fs from 'node:fs/promises';
import Layout from './Layout.tsx';
import * as dom from 'react-dom/server'
import Index from './Index.tsx'
import react from 'react'
import yaml from 'yaml'
import rehypeStringify from 'rehype-stringify'
import remarkParse from 'remark-parse'
import remarkFrontmatter from 'remark-frontmatter'
import remarkGfm from 'remark-gfm'
import remarkRehype from 'remark-rehype'
import {unified} from 'unified'
import {remarkSidenote} from './sidenote'

class Page {
    fm: yaml.Document
    source: string;

    constructor(fm: any, source: string) {
        this.fm = fm;
        this.source = source;
    }

    static async fromFile(path: string) {
        let source = await fs.readFile(path, {encoding: 'utf-8'})
        let fm;
    
        // ignore YAML front matters.
        if (source.indexOf('---\n') == 0) {
            let xs = source.split(/---\n/, 3)
            fm = yaml.parse(xs[1])
            source = xs[2]
        }

        return new Page(fm, source);
    }

    async createComponent() {
        let parser = unified().use(remarkParse as any).use(remarkFrontmatter)
            .use(remarkGfm)
            .use(remarkSidenote)
            .use(remarkRehype, {allowDangerousHtml: true})
            .use(rehypeStringify, {allowDangerousHtml: true});
        let file = await parser.process(this.source);
        let html = String(file);
    
        return react.createElement('div', {dangerouslySetInnerHTML: {__html: html}});    
    }

    getTitle() {
        return this.fm['title'];
    }
}

async function findPage(path: string) {
    path = 'src/' + path.replace(/\.html$/, '.md');

    let exists = await fs.exists(path);
    if (! exists) {
        throw new Error(`failed to find ${path}`)
    }

    let stat = await fs.stat(path);
    if (stat.isDirectory()) {
        path += '/index.md';
    }

    return Page.fromFile(path);
}

async function fetch(req: Request) {
    let c: react.Component;

    let u = new URL(req.url);
    let path = u.pathname.slice(1);
    let page;
    if (path == '') {
        c = Index();
    } else {
        page = await findPage(path);
        if (page) {
            c = page.createComponent();
        }    
    }

    let region = process.env.FLY_REGION;
    let machine = process.env.FLY_MACHINE_ID;

    let stream = await dom.renderToReadableStream(
        Layout({ 
            bunVersion: Bun.version,
            children: [c],
            title: (page) ? page.getTitle() : '',
            machine, region,
            edge: req.headers.get('fly-region')
         })
    );
    return new Response(stream, {headers: {
        'content-type': 'text/html; charset=utf-8',
    }});
}

Bun.serve({
    fetch: function(req: Request) {
        return fetch(req);
    }
})
