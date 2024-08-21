import React from 'react'
import fs from 'fs'

export default function Layout({
    title, children, machine, region, edge, bunVersion
}) {
    let style = fs.readFileSync('src/layout.css')

    return (
        <html>
            <head>
                <style>{style}</style>
                <title>{
                    title ? `${title} - explain.8-p.info` : 'explain.8-p.info'
                }</title>
            </head>
            <body>
                <main>{children}</main>
            </body>
            <footer>
            Powered by Bun v{bunVersion}&nbsp;
            {
            (machine && region && edge) &&
                <span>
                    and Fly.io.
                    Your request is accepted by {edge} and
                    forwaded to {machine} in {region}.
                </span>
            }
            </footer>
        </html>
    )
}
