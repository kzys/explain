import React from 'react';
import {Glob} from 'bun'
import fs from 'fs/promises'
import yaml from 'yaml'

async function page(file) {
    let s = await fs.readFile(file, {encoding: 'utf-8'});
    let xs = s.split(/---/, 3)
    if (xs.length != 3) {
        return [{}, s]
    }

    let fm = yaml.parse(xs[1])
    return [fm, xs[2]]
}

export default async function PageList({pattern}) {
    let links: React.Component[] = []
    let glob = new Glob(pattern)
    for await (let file of glob.scan()) {
        if (file.endsWith('index.md')) {
            continue;
        }
        let href = file.replace(/^src\//, '').replace(/\.md$/, '.html');
        
        let [fm, source] = await page(file);
        if (fm['draft']) {
            continue;
        }
        if (! fm['title']) {
            continue;
        }
        links.push(<li key={href}><a href={href}>{fm['title']}</a></li>)
    }
    return <ul className="pageList">{links}</ul>
}
