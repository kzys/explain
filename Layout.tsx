import React from 'react';

export default function Layout({
    title, children, machine, region, edge, bunVersion
}) {
    let style = `
    body {
        padding: 1rem;
        background: #fff;
        color: #000;
        font-family: sans-serif;
        line-height: 1.5;
    }

    a {
        color: #30f;
    }

    a:visited {
        color: #90f;
    }

    h1 {
        font-size: 2rem;
        font-weight: normal;
    }

    h2 {
        display: flex;
        align-items: baseline;
        font-weight: normal;
        justify-content: space-between;
    }

    .ja {
        color: #f90;
    }


    small.sidenote {
        display: block;
        margin: 1rem;
    }

    main {
      max-width: 60rem;
    }

    @media (min-width: 60rem) {
        main {
            margin-right: 20rem;
        }

        small.sidenote {
            display: inline;
            float: right;
            font-size: 90%;
            margin: 0 -20rem 0 0;
            position: relative;
            width: 20rem;
        }
    }

    footer {
        margin-top: 1rem;
        padding-top: 1rem;
        border-top: 1px solid #000;
        font-size: 90%;
    }

    `
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
