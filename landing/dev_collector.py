#!/usr/bin/env python3
"""Local collector for landing form submissions and analytics events.

Serves static files from ./landing and exposes:
- POST /api/interest
- POST /api/events
- GET  /api/health
- GET  /api/stats
"""

from __future__ import annotations

import argparse
import json
from collections import Counter
from datetime import datetime, UTC
from http import HTTPStatus
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
from typing import Any


ALLOWED_EVENTS = {
    "landing_page_view",
    "hero_cta_clicked",
    "screenshot_gallery_viewed",
    "faq_expanded",
    "waitlist_started",
    "waitlist_submit_attempted",
    "waitlist_submitted",
    "waitlist_submit_failed",
    "demo_requested",
    "confirmation_state_viewed",
}

ALLOWED_INTEREST_TYPES = {"request_demo", "join_waitlist", "early_access"}


def read_jsonl(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        return []
    rows: list[dict[str, Any]] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        rows.append(json.loads(line))
    return rows


class CollectorHandler(SimpleHTTPRequestHandler):
    server_version = "NutriScanCollector/1.0"

    def end_headers(self) -> None:
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Access-Control-Allow-Methods", "GET,POST,OPTIONS")
        super().end_headers()

    @property
    def events_file(self) -> Path:
        return self.server.runtime_dir / "events.jsonl"  # type: ignore[attr-defined]

    @property
    def leads_file(self) -> Path:
        return self.server.runtime_dir / "interest-submissions.jsonl"  # type: ignore[attr-defined]

    def do_OPTIONS(self) -> None:  # noqa: N802
        self.send_response(HTTPStatus.NO_CONTENT)
        self.end_headers()

    def _read_json_body(self) -> dict[str, Any] | None:
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length).decode("utf-8") if length > 0 else "{}"
        try:
            return json.loads(raw)
        except json.JSONDecodeError:
            return None

    def _write_json(self, code: int, payload: dict[str, Any]) -> None:
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(payload).encode("utf-8"))

    def _append_jsonl(self, path: Path, payload: dict[str, Any]) -> None:
        line = json.dumps(payload, ensure_ascii=True) + "\n"
        with path.open("a", encoding="utf-8") as f:
            f.write(line)

    def do_GET(self) -> None:  # noqa: N802
        if self.path == "/api/health":
            self._write_json(200, {"ok": True, "time": datetime.now(UTC).isoformat()})
            return

        if self.path == "/api/stats":
            events = read_jsonl(self.events_file)
            leads = read_jsonl(self.leads_file)
            counts = Counter(row.get("event_name", "unknown") for row in events)
            self._write_json(
                200,
                {
                    "ok": True,
                    "event_count_total": len(events),
                    "lead_count_total": len(leads),
                    "event_counts": dict(counts),
                },
            )
            return

        super().do_GET()

    def do_POST(self) -> None:  # noqa: N802
        if self.path == "/api/events":
            payload = self._read_json_body()
            if not payload:
                self._write_json(400, {"accepted": False, "error": "invalid_json"})
                return
            if payload.get("event_name") not in ALLOWED_EVENTS:
                self._write_json(400, {"accepted": False, "error": "invalid_event_name"})
                return
            if not payload.get("event_time") or not payload.get("page_path"):
                self._write_json(400, {"accepted": False, "error": "missing_required_fields"})
                return
            self._append_jsonl(self.events_file, payload)
            self._write_json(202, {"accepted": True})
            return

        if self.path == "/api/interest":
            payload = self._read_json_body()
            if not payload:
                self._write_json(400, {"accepted": False, "error": "invalid_json"})
                return
            if not str(payload.get("full_name", "")).strip():
                self._write_json(400, {"accepted": False, "error": "full_name_required"})
                return
            if not str(payload.get("email", "")).strip():
                self._write_json(400, {"accepted": False, "error": "email_required"})
                return
            if payload.get("interest_type") not in ALLOWED_INTEREST_TYPES:
                self._write_json(400, {"accepted": False, "error": "invalid_interest_type"})
                return
            self._append_jsonl(self.leads_file, payload)
            self._write_json(201, {"accepted": True})
            return

        self._write_json(404, {"accepted": False, "error": "not_found"})


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8787)
    parser.add_argument(
        "--web-root",
        default=str(Path(__file__).resolve().parent),
        help="Directory to serve as static root",
    )
    parser.add_argument(
        "--runtime-dir",
        default=str(Path(__file__).resolve().parent / "runtime"),
        help="Directory to store JSONL outputs",
    )
    args = parser.parse_args()

    web_root = Path(args.web_root).resolve()
    runtime_dir = Path(args.runtime_dir).resolve()
    runtime_dir.mkdir(parents=True, exist_ok=True)

    handler = CollectorHandler
    httpd = ThreadingHTTPServer((args.host, args.port), handler)
    httpd.runtime_dir = runtime_dir  # type: ignore[attr-defined]

    print(f"Serving landing + collector on http://{args.host}:{args.port}")
    print(f"Static root: {web_root}")
    print(f"Runtime dir: {runtime_dir}")

    # Serve static files from landing dir.
    import os

    os.chdir(web_root)
    httpd.serve_forever()


if __name__ == "__main__":
    main()
