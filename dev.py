import glob
import os
import subprocess
import threading
import time
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler

build_condition = threading.Condition()
build_version = 0

RELOAD_SCRIPT = b'<script>new EventSource("/~reload").onmessage=()=>location.reload()</script>'


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory="public", **kwargs)

    def do_GET(self):
        if self.path == "/~reload":
            self._sse()
            return
        path = self.translate_path(self.path)
        if os.path.isfile(path) and path.endswith(".html"):
            with open(path, "rb") as f:
                body = f.read()
            body = body.replace(b"</body>", RELOAD_SCRIPT + b"</body>", 1)
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        super().do_GET()

    def _sse(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-cache")
        self.end_headers()
        local_version = build_version
        try:
            while True:
                with build_condition:
                    build_condition.wait_for(lambda: build_version > local_version)
                    local_version = build_version
                self.wfile.write(b"data: reload\n\n")
                self.wfile.flush()
        except Exception:
            pass

    def log_message(self, format, *args):
        pass


def mtimes():
    paths = (
        glob.glob("src/**", recursive=True)
        + ["gen.rb"]
        + glob.glob("view/**", recursive=True)
    )
    return {p: os.path.getmtime(p) for p in paths if os.path.isfile(p)}


def watch():
    global build_version
    prev = mtimes()
    while True:
        time.sleep(1)
        curr = mtimes()
        if curr != prev:
            subprocess.run(["make", "build"])
            with build_condition:
                build_version += 1
                build_condition.notify_all()
            prev = mtimes()
        else:
            prev = curr


if __name__ == "__main__":
    threading.Thread(target=watch, daemon=True).start()
    server = ThreadingHTTPServer(("", 8000), Handler)
    print("Serving at http://localhost:8000")
    server.serve_forever()
