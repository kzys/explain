import React from 'react';

export function Component({title, children}) {
    let style = `
    body {
        padding: 1rem;
        background: #eee;
        color: #000;
        font-family: sans-serif;
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


    .column {
        flex-grow: 1;
    }

    @media (min-width: 50rem) {
        main {
            display: flex;
        }
        .column + .column {
            margin-left: 1rem;
            padding-left: 1rem;
            border-left: 1px solid #000;
        }
    }

    footer {
        padding-top: 1rem;
        font-size: 90%;
    }
    `
    return (
        <html>
            <head>
                <style>{style}</style>
                <title>{title}</title>
            </head>
            <body>{children}</body>
        </html>
    )
}
