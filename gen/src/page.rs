use pulldown_cmark::{html, Parser};
use std::fs::File;
use std::io::{BufReader, Read};
use std::path::Path;
use yaml_rust::{yaml::Yaml, YamlLoader};

pub struct Page {
    front_matter: Vec<Yaml>,
    pub body_html: String,
}

impl Page {
    pub fn title(&self) -> &str {
        self.front_matter[0]["title"].as_str().unwrap_or("???")
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
        let mut html_output = String::new();
        html::push_html(&mut html_output, parser);
        return Page {
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
fn test_title() {
    let s = include_str!("testdata/hello.md");
    let p = Page::from_str(&s);
    assert_eq!(p.title(), "hello");
    assert_eq!(p.body_html, "<p>hello world</p>\n");
}
