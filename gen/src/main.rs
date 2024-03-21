use axum::{body::Body, extract::Path, http::StatusCode, response::Response, routing::get, Router};
use pulldown_cmark::{html, Parser};
use std::{fs, fs::File, io::BufReader, io::Read, path};
use tower_http::trace::TraceLayer;
use tracing::info;

#[tokio::main]
async fn main() {
    // initialize tracing
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::DEBUG)
        .init();

    // build our application with a route
    let app = Router::new()
        .route("/", get(root))
        .route("/*rest", get(other))
        .layer(TraceLayer::new_for_http());

    let addr = "0.0.0.0:8080";

    info!("listen {}", addr);

    // run our app with hyper, listening globally on port
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

// basic handler that responds with a static string
async fn root() -> Response<Body> {
    other(Path("index.html".to_string())).await
}

// basic handler that responds with a static string
async fn other(Path(path): Path<String>) -> Response<Body> {
    let src_dir = path::Path::new("src");
    let mut src_path = src_dir.join(path);

    src_path.set_extension("md");

    if src_path.exists() {
        let f = File::open(src_path);
        let mut buf_reader = BufReader::new(f.unwrap());
        let mut content = String::new();
        buf_reader.read_to_string(&mut content).unwrap();

        let parser = Parser::new(&content);
        let mut html_output = String::new();
        html::push_html(&mut html_output, parser);

        return Response::builder()
            .header("content-type", "text/html")
            .status(StatusCode::OK)
            .body(Body::from(html_output))
            .unwrap();
    }

    let src = src_path.clone();

    match fs::metadata(src.clone()) {
        Ok(metadata) => {
            let f = File::open(src.clone());
            Response::builder()
                .status(StatusCode::OK)
                .body(Body::from(format!("file found: {:?}", metadata)))
                .unwrap()
        }
        Err(e) => Response::builder()
            .status(StatusCode::NOT_FOUND)
            .header("content-type", "text/plain")
            .body(Body::from(format!("failed to find {:?}: {}", src, e)))
            .unwrap(),
    }
}
