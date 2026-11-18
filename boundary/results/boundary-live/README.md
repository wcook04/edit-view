# Live run, 18 November 2026

36 decisions from `boundary_replay.py` with `openai/gpt-6.2-sol`.

- `manifest.json`: the design, package versions, source hashes and counts.
- `decisions.jsonl`: one line per decision with the final classification.
- `calls.jsonl`: one line per model call with the model's full output.
- `requests/<sha256>.json`: the messages sent at each stage. The file name is the hash of
  the request as sent. The system message, which is the released policy prompt, has been
  replaced here by its SHA-256 and length, because that prompt belongs to the upstream
  repository and carries its canary. Run `boundary_replay.py --dry-run` against the
  pinned commit to regenerate the full requests.
