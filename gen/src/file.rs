use path::{Path, PathBuf};
use serde::Serialize;
use std::error::Error;
use std::fs;
use std::path;

use crate::page;

#[derive(Debug, Serialize)]
#[serde(untagged)]
pub enum Node {
    Dir { path: PathBuf, children: Vec<Node> },
    File { path: PathBuf },
}

pub fn find_files(dir: &Path) -> Result<Node, Box<dyn Error>> {
    let mut children: Vec<Node> = Vec::new();

    let it = fs::read_dir(dir)?;

    for entry in it {
        let entry = entry?;
        if entry.file_type()?.is_dir() {
            children.push(find_files(&entry.path())?);
        } else {
            children.push(Node::File { path: entry.path() });
        }
    }

    Ok(Node::Dir {
        path: dir.to_path_buf(),
        children,
    })
}

pub fn files_in_html(node: &Node, current: &path::Path) -> Result<String, Box<dyn Error>> {
    match node {
        Node::Dir { path, children } => {
            let href = path.strip_prefix("src")?;
            let index = path.clone().join("index.md");
            let title = if index.exists() {
                let page = page::Page2::from_file(index.to_str().unwrap());
                page.title
            } else {
                format!("{}/", href.display())
            };
            let mut s = String::new();
            s.push_str(&format!(
                "<li><a href=/{}/>{}</a><ul>",
                href.display(),
                title,
            ));
            for c in children {
                s.push_str(&files_in_html(&c, current)?);
            }
            s.push_str("</ul></li>");
            Ok(s)
        }
        Node::File { path } => {
            if path.to_str().map(|s| s.ends_with("~")).unwrap_or(false) {
                return Ok("".to_string());
            }
            if path.ends_with("index.md") {
                return Ok("".to_string());
            }

            let page = page::Page2::from_file(path.to_str().unwrap());
            let title = page.title.as_str();

            let mut href = path.strip_prefix("src")?.to_path_buf();
            href.set_extension("html");
            let s = format!("<li><a href=/{}>{}</a></li>", href.display(), title,);
            Ok(s)
        }
    }
}

#[test]
fn test_find_files() -> Result<(), Box<dyn Error>> {
    let dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("src/testdata");
    let root = find_files(&dir)?;
    if let Node::Dir { path: _, children } = root {
        assert_eq!(children.len(), 3);
    }
    Ok(())
}
