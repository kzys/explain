use axum::extract::{Path, State};
use axum::{body::Body, http::StatusCode, response::Response, routing::get, Router};
use minijinja::{value::Value, Environment};
use serde::Serialize;
use std::error::Error;
use std::result::Result;
use std::{fs, path};
use std::sync::Arc;
use tower_http::trace::TraceLayer;
use tracing::info;

mod file;
mod html;
mod layout;
mod page;

struct AppState {
    reloader: minijinja_autoreload::AutoReloader,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    // initialize tracing
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::DEBUG)
        .init();

    let reloader = minijinja_autoreload::AutoReloader::new(|notifier| {
        let mut env = Environment::new();
        notifier.watch_path("layout", true);
        layout::register_template(&mut env, "index.html", "layout/index.html").unwrap();
        Ok(env)
    });

    {
        let mut env: minijinja_autoreload::EnvironmentGuard<'_> = reloader.acquire_env()?;
    }

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
        .with_state(Arc::new(AppState { reloader }));

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

// basic handler that responds with a static string
async fn other<'a>(path: Option<Path<String>>, state: State<Arc<AppState>>) -> Response<Body> {
    let path = path.unwrap_or(Path("index.html".to_string()));

    let src_path = find_source(&path);
    let dir = file::find_files(src_path.parent().unwrap()).unwrap();

    if src_path.exists() {
        let p = page::page(&src_path);

        let pd = PageData {
            title: p.title().unwrap_or(UNTITLED).to_string(),
            main: minijinja::value::Value::from_safe_string(p.body_html.to_string()),
            files: Value::from_safe_string(file::files_in_html(&dir, &src_path).unwrap()),
        };

        let env = state.reloader.acquire_env().unwrap();
        let t = env.get_template("index.html").unwrap();
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
