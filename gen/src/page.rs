use pulldown_cmark::{html, Event, HeadingLevel, Parser, Tag, TagEnd};
use std::fs::File;
use std::io::{BufReader, Read};
use std::path::Path;
use yaml_rust::{yaml::Yaml, YamlLoader};

pub struct Page {
    front_matter: Vec<Yaml>,
    title_from_md: Option<String>,
    pub body_html: String,
}

impl Page {
    pub fn title(&self) -> Option<&str> {
        self.front_matter[0]["title"]
            .as_str()
            .or(self.title_from_md.as_ref().map(|s| s.as_str()))
    }

    pub fn from_str(content: &str) -> Page {
        let empty = vec![Yaml::Null];

        let (front_matter, md) = if content.starts_with("---") {
            let xs: Vec<&str> = content.split("---").collect();
            let doc = YamlLoader::load_from_str(xs[1]).unwrap();
            (doc, xs[2])
        } else {
            (empty, content)
        };

        let parser = Parser::new(md);
        let events: Vec<Event> = parser.collect();

        let mut heading_level: Option<HeadingLevel> = None;
        let mut title_from_md: Option<String> = None;

        for ev in events.clone() {
            match ev {
                Event::Start(Tag::Heading { level: lv, .. }) => {
                    heading_level = Some(lv);
                }
                Event::End(TagEnd::Heading(..)) => {
                    heading_level = None;
                }
                Event::Text(s) if heading_level != None => {
                    title_from_md = Some(s.to_string());
                }
                _ => {}
            }
        }

        let mut html_output = String::new();
        html::push_html(&mut html_output, events.into_iter());
        return Page {
            title_from_md,
            front_matter,
            body_html: html_output,
        };
    }
}

pub fn page(path: &Path) -> Page {
    let f = File::open(path);
    let mut buf_reader = BufReader::new(f.unwrap());
    let mut content = String::new();
    buf_reader.read_to_string(&mut content).unwrap();

    return Page::from_str(&content);
}

#[test]
fn test_empty() {
    let p = Page::from_str("");
    assert_eq!(p.title(), None);
    assert_eq!(p.body_html, "");
}

#[test]
fn test_hello() {
    let s = include_str!("testdata/hello.md");
    let p = Page::from_str(&s);
    assert_eq!(p.title(), Some("hello"));
    assert_eq!(p.body_html, "<p>hello world</p>\n");
}

#[test]
fn test_markdown_only() {
    let p = Page::from_str("# hello");
    assert_eq!(p.title(), Some("hello"));
    assert_eq!(p.body_html, "<h1>hello</h1>\n");
}
