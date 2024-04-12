use path::{Path, PathBuf};
use serde::Serialize;
use std::error::Error;
use std::fs;
use std::path;

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

#[test]
fn test_find_files() -> Result<(), Box<dyn Error>> {
    let dir = Path::new(env!("CARGO_MANIFEST_DIR")).join("src/testdata");
    let root = find_files(&dir)?;
    if let Node::Dir { path: _, children } = root {
        assert_eq!(children.len(), 3);
    }
    Ok(())
}
