import React from 'react'
import PageList from './PageList'

export default function Index() {
    return <>
        <h1>explain.8-p.info</h1>
        <p>
            Explain stuff I know a bit about,
            not <a href="https://en.wiktionary.org/wiki/ELI5">like you are five</a> though.
        </p>
        <main>
            <h2>English</h2>
            <PageList pattern="src/en/**/*.md"/>

            <h2>日本語</h2>
            <PageList pattern="src/ja/**/*.md"/>
        </main>
    </>
}
