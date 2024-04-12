use axum::extract::{Path, State};
use axum::{body::Body, http::StatusCode, response::Response, routing::get, Router};
use minijinja::{value::Value, Environment};
use serde::Serialize;
use std::error::Error;
use std::result::Result;
use std::{fs, path};
use tower_http::trace::TraceLayer;
use tracing::info;

mod file;
mod layout;
mod page;

#[derive(Clone)]
struct AppState<'a> {
    env: Environment<'a>,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    // initialize tracing
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::DEBUG)
        .init();

    let mut env = Environment::new();
    layout::register_template(&mut env, "index.html", "layout/index.html")?;

    // build our application with a route
    let app = Router::new()
        .route("/", get(other))
        .route("/*rest", get(other))
        .route(
            "/favicon.ico",
            get(|| async {
                // To prevent 404.
                "".to_string()
            }),
        )
        .layer(TraceLayer::new_for_http())
        .with_state(AppState { env });

    let addr = "0.0.0.0:8080";

    info!("listen {}", addr);

    // run our app with hyper, listening globally on port
    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;
    Ok(())
}

// basic handler that responds with a static string
/*
async fn root() -> Response<Body> {
    other(Path("index.html".to_string())).await
}
*/

fn find_source(path: &str) -> path::PathBuf {
    let src_dir = path::Path::new("src");
    let mut src_path = src_dir.join(&path);

    if path.ends_with("/") {
        src_path.join("index.md")
    } else {
        src_path.set_extension("md");
        src_path
    }
}

#[test]
fn test_find_source() {
    assert_eq!(find_source("index.html"), path::Path::new("src/index.md"));
    assert_eq!(find_source("foo/"), path::Path::new("src/foo/index.md"));
}

#[derive(Serialize, Debug)]
struct PageData {
    title: String,
    main: minijinja::value::Value,
    files: minijinja::value::Value,
}

const UNTITLED: &str = "Untitled";

fn files_in_html(node: &file::Node) -> Result<String, Box<dyn Error>> {
    let mut s = String::new();

    match node {
        file::Node::Dir { path, children } => {
            for c in children {
                match c {
                    file::Node::Dir { path, children } => {
                        let href = path.strip_prefix("src")?;
                        s.push_str(&format!(
                            "<li><a href={}/>{}</a><ul>",
                            href.display(),
                            href.display()
                        ));
                        s.push_str(&files_in_html(&c)?);
                        s.push_str("</ul></li>");
                    }
                    file::Node::File { path } => {
                        if path.to_str().map(|s| s.ends_with("~")).unwrap_or(false) {
                            continue;
                        }
                        let mut href = path.strip_prefix("src")?.to_path_buf();
                        href.set_extension("html");
                        s.push_str(&format!(
                            "<li><a href={}>{}</a></li>",
                            href.display(),
                            href.display()
                        ));
                    }
                }
            }
        }
        file::Node::File { path } => {
            s.push_str(&format!(
                "<li><a href=\"{}\">{}</a></li>",
                path.display(),
                path.file_name().unwrap().to_str().unwrap()
            ));
        }
    }

    Ok(s)
}

// basic handler that responds with a static string
async fn other<'a>(path: Option<Path<String>>, state: State<AppState<'a>>) -> Response<Body> {
    let path = path.unwrap_or(Path("index.html".to_string()));

    let src_path = find_source(&path);
    let dir = file::find_files(src_path.parent().unwrap()).unwrap();

    if src_path.exists() {
        let p = page::page(&src_path);

        let pd = PageData {
            title: p.title().unwrap_or(UNTITLED).to_string(),
            main: minijinja::value::Value::from_safe_string(p.body_html.to_string()),
            files: Value::from_safe_string(files_in_html(&dir).unwrap()),
        };

        let t = state.env.get_template("index.html").unwrap();
        let s = t.render(&pd).unwrap();

        return Response::builder()
            .header("content-type", "text/html")
            .status(StatusCode::OK)
            .body(Body::from(s))
            .unwrap();
    }

    let src = src_path.clone();

    match fs::metadata(src.clone()) {
        Ok(metadata) => Response::builder()
            .status(StatusCode::OK)
            .body(Body::from(format!("file found: {:?}", metadata)))
            .unwrap(),
        Err(e) => Response::builder()
            .status(StatusCode::NOT_FOUND)
            .header("content-type", "text/plain")
            .body(Body::from(format!("failed to find {:?}: {}", src, e)))
            .unwrap(),
    }
}
