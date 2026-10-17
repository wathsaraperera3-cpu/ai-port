"""Local development proxy only; no operations simulation is implemented in Python.
All scenario state and planning are intended to run in Jac/Jaseci walkers.
This helper does not provide production authentication or authorization.
"""
import json
import os
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

ROOT = Path(__file__).parent / "web"
WALKER_URL = os.environ.get("PORTMIND_JAC_URL", "http://127.0.0.1:8000/walker/PortMindAPI")


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def do_POST(self):
        if self.path != "/api":
            self.send_error(404, "Unknown endpoint")
            return
        length = min(int(self.headers.get("Content-Length", 0)), 128_000)
        try:
            body = self.rfile.read(length)
            command = json.loads(body.decode("utf-8"))
            if command.get("action") not in {
                "state", "reset", "play", "pause", "speed", "tick", "step",
                "breakdown", "restore", "weather", "traffic", "absence",
                "delay", "reefer", "release", "negotiate", "approve",
                "reject", "ask", "container", "inspect_vessel", "inspect_crane",
                "inspect_berth", "inspect_truck", "report",
            }:
                raise ValueError("Unknown operation")
            upstream = Request(WALKER_URL, data=json.dumps(command).encode(),
                               headers={"Content-Type": "application/json"}, method="POST")
            with urlopen(upstream, timeout=12) as resp:
                raw = resp.read()
                status = resp.status
        except (HTTPError, URLError, TimeoutError) as error:
            status, raw = 502, json.dumps({"ok": False, "error":
                f"Jac backend unavailable or rejected request: {error}"}).encode()
        except (ValueError, json.JSONDecodeError) as error:
            status, raw = 400, json.dumps({"ok": False, "error": str(error)}).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)


if __name__ == "__main__":
    port = int(os.environ.get("PORTMIND_WEB_PORT", 5500))
    print(f"PortMind UI: http://127.0.0.1:{port}")
    print(f"Jac walker: {WALKER_URL}")
    ThreadingHTTPServer(("127.0.0.1", port), Handler).serve_forever()
