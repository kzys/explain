use minijinja::Environment;
use std::error::Error;
use std::fs::File;
use std::io::{BufReader, Read};
use std::result::Result;

pub fn register_template(
    env: &mut Environment,
    name: &str,
    path: &str,
) -> Result<(), Box<dyn Error>> {
    let f = File::open(path)?;
    let mut reader = BufReader::new(f);
    let mut content = String::new();
    reader.read_to_string(&mut content)?;

    env.add_template_owned(name.to_string(), content)?;

    Ok(())
}
