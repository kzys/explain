import React from 'react'
import PageList from './PageList'

export default function Index() {
    return <>
        <h1>explain.8-p.info</h1>
        Explain stuff I know about, not <a href="https://en.wiktionary.org/wiki/ELI5">like you are five</a> though.

        <main>
            <div className="column">
                <h2>English<span className="ja">英語</span></h2>
                <PageList pattern="src/en/**.md"/>
            </div>
            <div className="column">
                <h2>Japanese<span className="ja">日本語</span></h2>
                <PageList pattern="src/ja/**.md"/>
            </div>
        </main>
    </>
}