use axum::{body::Body, extract::Path, http::StatusCode, response::Response, routing::get, Router};
use std::fs;
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
    let src = path.strip_suffix(".html").map(|x| format!("src/{}.md", x));

    match fs::metadata(src.unwrap()) {
        Ok(metadata) => Response::builder()
            .status(StatusCode::OK)
            .body(Body::from(format!("file found: {:?}", metadata)))
            .unwrap(),
        Err(e) => Response::builder()
            .status(StatusCode::NOT_FOUND)
            .header("content-type", "text/plain")
            .body(Body::from(format!("failed to find {}: {}", path, e)))
            .unwrap(),
    }
}
