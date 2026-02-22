---
name: crank
description: Run and interpret Crank comparison tests. Use when asking to "run crank", "compare endpoints", "test against simulcast", "check parity", "benchmark", or "refresh token". Only relevant in stream-starter.
---

# Crank — Endpoint Comparison Testing

Crank compares playlist responses between baseline (simulcast) and target
(stream-starter) across client/device/DRM variants. Three modes: TUI, headless,
benchmark.

## Modes

### Interactive TUI (default)

```bash
go run ./cmd/crank
```

Opens a tree of all request variants. Key bindings: `r` run all, `f` re-run
failed, `enter` run/open, `/` filter, `y` copy curl, `c` clear cache, `q` quit.

### Headless (CI / scripted)

```bash
go run ./cmd/crank --headless \
  --baseline "https://simulcast.itv.com/playlist/itvonline" \
  --target   "https://stream-starter.fastly.ottstream.itv.com/playlist/itvonline"
```

Outputs JSON to stdout. Check `summary.mismatch` for failures (exit code is
always 0).

### Benchmark

```bash
go run ./cmd/crank --benchmark                    # stream-starter prod, 100 reqs
go run ./cmd/crank --benchmark --target simulcast  # compare against simulcast
go run ./cmd/crank --benchmark --target local      # local dev
go run ./cmd/crank --benchmark -n 500 -c 50        # custom load
```

Named targets: `stream-starter` (default), `stage`, `simulcast`, `local`.

## Common Flags

| Flag             | Description                              |
|------------------|------------------------------------------|
| `--filter <str>` | Substring match on variant names         |
| `--clear-cache`  | Wipe cached baseline responses           |
| `--variants`     | Path to JSONL file (default: `cmd/crank/request_variants.jsonl`) |
| `--refresh-token`| Extract fresh token from Chrome cookies  |
| `--dry-run`      | Print token without writing .env         |

## Workflow: Verify a Change

1. Run headless comparison filtered to relevant variants:
   ```bash
   go run ./cmd/crank --headless \
     --baseline "https://simulcast.itv.com/playlist/itvonline" \
     --target   "http://127.0.0.1:8080/playlist/itvonline" \
     --filter "<relevant-filter>"
   ```
2. Parse the JSON output — look at `summary` first, then drill into
   `results[].diffs` for mismatches.
3. Diffs show field paths with `baseline_value` vs `target_value`.
4. Volatile fields (timestamps, UUIDs, JWTs) are normalized out automatically.

## Workflow: Refresh Expired Token

```bash
go run ./cmd/crank --refresh-token
```

Requires Chrome logged into itv.com. Updates `ITV_USER_TOKEN` and
`ITV_CLIENT_IP` in `.env`.

## Interpreting Results

- **match**: Normalized responses are identical.
- **mismatch**: Structural or value differences found after normalization.
- **error**: One or both requests failed (check HTTP status, auth).
- **flaky**: Inconsistent between retries.

When investigating mismatches, the diff output includes the JSON path to the
differing field and both values. Focus on the path to determine which part of
stream-starter is responsible.

## Request Variants

Defined in `cmd/crank/request_variants.jsonl` (JSONL, `#` comments). Each line
is a JSON object with: `name`, `channel`, `client`, `featureset`, `drm`,
`player`, `device`, `browser`, etc.

Useful filters: `region`, `samsung`, `itv4`, `nodar`, `fairplay`, `widevine`.

## Code Layout

| Path | What |
|------|------|
| `cmd/crank/main.go` | Entry point, flag parsing |
| `cmd/crank/internal/compare/runner.go` | Comparison orchestration |
| `cmd/crank/internal/compare/normalize.go` | Response normalization |
| `cmd/crank/internal/compare/diff.go` | Deep JSON diff |
| `cmd/crank/internal/compare/request.go` | HTTP request building |
| `cmd/crank/internal/compare/variant.go` | Variant loading/filtering |
| `cmd/crank/internal/compare/cache.go` | Baseline response cache |
| `cmd/crank/request_variants.jsonl` | Test variant definitions |
