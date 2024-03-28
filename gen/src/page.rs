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
}

pub fn page(path: &Path) -> Page {
    let f = File::open(path);
    let mut buf_reader = BufReader::new(f.unwrap());
    let mut content = String::new();
    buf_reader.read_to_string(&mut content).unwrap();

    let empty = vec![Yaml::Null];

    let (front_matter, md) = if content.starts_with("---") {
        let xs: Vec<&str> = content.split("---").collect();
        let doc = YamlLoader::load_from_str(xs[1]).unwrap();
        (doc, xs[2])
    } else {
        (empty, content.as_str())
    };

    let parser = Parser::new(md);
    let mut html_output = String::new();
    let title = front_matter[0]["title"].as_str().unwrap_or("???");
    html_output.push_str(format!("<title>{}</title>", title).as_str());
    html::push_html(&mut html_output, parser);
    return Page {
        front_matter,
        body_html: html_output,
    };
}
