# Development Log

## 2026-06-13 Initial Local RAG Setup

### Decision

The project should focus on local-first document retrieval: ingest private files, build a local index, and expose search through CLI and MCP tools.

### Completed

- Created the `local-Rag` project workspace.
- Added local project documentation and `NOTICE.md`.
- Updated package and server metadata to `local-rag`.
- Added support documents for product scope, architecture, roadmap, and structure.

### Verification

- `corepack pnpm install` completed successfully.
- `corepack pnpm run build` completed successfully after fixing a corrupted caption truncation string.
- `corepack pnpm run type-check` completed successfully.
- CLI help displays `Usage: local-rag [options] <command>`.
- Smoke test completed:
  - Ingested `scratch-smoke-2/docs/pricing.md`.
  - Queried `2024 channel pricing sales`.
  - Returned the expected `pricing.md` chunk.
  - `status` reported `documentCount: 1`, `chunkCount: 1`, and `searchMode: hybrid`.

### Test Gap

- `corepack pnpm test` was attempted but exceeded the 4-minute command timeout. Full test completion remains a follow-up verification task.

## 2026-06-13 Silent Index Update

### Decision

The manual silent updater workflow is useful for daily use. The user can double-click a hidden updater to ingest changed documents into a shared local `DB_PATH`; MCP clients can later query that same index.

### Completed

- Changed `scripts/silent_start.ps1` default mode to update the index.
- Added `更新入库local-Rag.vbs`.
- Added `查看入库状态local-Rag.bat`.
- Added `config/codex-config.example.toml`.
- Updated documentation to clarify that `BASE_DIRS`, `DB_PATH`, and `CACHE_DIR` must match between manual indexing and MCP config.

### Verification

- Ran `scripts/silent_start.ps1 -Mode update` against a temporary document folder.
- Queried the same `DB_PATH` afterward with `node dist/index.js query`.
- The query returned chunks from the manually indexed document, confirming the intended workflow.

## 2026-06-13 Library Panel

### Completed

- Added `scripts/library_panel.ps1`.
- Added `scripts/test_library_panel.ps1`.
- Added `local-Rag资料库.vbs` as the recommended double-click entry.
- Added `local-Rag资料库.bat` as the visible fallback entry.
- Removed older launch entries to avoid confusion.

### Behavior

- The panel remembers selected document folders in `config/local-rag.env.ps1`.
- The update button recursively indexes remembered folders.
- MCP clients can later query the same `DB_PATH`.

### Verification

- `scripts/test_library_panel.ps1` passed, confirming config save/load behavior.

## 2026-06-13 Multi-Folder Library Support

### Completed

- Upgraded `scripts/library_panel.ps1` from one remembered folder to a multi-folder list.
- Added `BASE_DIRS` support in `config/local-rag.env.ps1`.
- Updated `scripts/silent_start.ps1` to ingest each remembered folder while passing all folders as allowed base directories.
- Updated MCP config examples to use `BASE_DIRS`.

### Verification

- `scripts/test_library_panel.ps1` passed with two remembered folders.
