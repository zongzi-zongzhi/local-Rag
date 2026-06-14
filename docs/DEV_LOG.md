# Development Log

## 2026-06-13

### Decision

The user asked whether building directly on a reference GitHub project would be more rigorous and feasible.

Judgment: yes. The target is to reach mature local RAG effects quickly. Starting from `mcp-local-rag` is more rigorous than keeping a scratch MVP because it already implements MCP, CLI, local embeddings, LanceDB, parser support, Codex setup, and tests.

### Action

- Downloaded reference projects into `D:\GitHub\_rag-references`.
- Backed up the scratch MVP as `D:\GitHub\local-Rag-scratch-mvp`.
- Created `D:\GitHub\local-Rag` from `shinpr/mcp-local-rag`.
- Added local fork documentation and `NOTICE.md`.
- Updated package and server metadata to `local-rag`.

### Next

- Install dependencies.
- Build the TypeScript project.
- Run the upstream test suite or a focused smoke test.
- Add Codex-specific config examples if needed.

### Verification

- `corepack pnpm install` completed successfully.
- `corepack pnpm run build` completed successfully after fixing a corrupted caption truncation string.
- `corepack pnpm run type-check` completed successfully.
- CLI help now displays `Usage: local-rag [options] <command>`.
- Smoke test completed:
  - Ingested `scratch-smoke-2/docs/pricing.md`.
  - Queried `2024 channel pricing sales`.
  - Returned the expected `pricing.md` chunk.
  - `status` reported `documentCount: 1`, `chunkCount: 1`, and `searchMode: hybrid`.

### Test Gap

- `corepack pnpm test` was attempted but exceeded the 4-minute command timeout. Full upstream test completion remains a follow-up verification task.

## 2026-06-13 Silent Index Update

### Decision

The manual silent updater workflow is rigorous and feasible. The user can double-click a hidden updater to ingest changed documents into a shared local `DB_PATH`; Codex can later launch the MCP server and query that same index.

### Completed

- Changed `scripts/silent_start.ps1` default mode to update the index.
- Added `更新入库local-Rag.vbs`.
- Added `查看入库状态local-Rag.bat`.
- Added `config/codex-config.example.toml`.
- Updated documentation to clarify that `BASE_DIR`, `DB_PATH`, and `CACHE_DIR` must match between manual indexing and Codex MCP config.

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
- Removed the older `启动local-Rag.vbs` and `启动local-Rag.bat` entries to avoid confusion.

### Behavior

- The panel remembers the selected document folder in `config/local-rag.env.ps1`.
- The update button recursively indexes the remembered folder.
- Codex can later query the same `DB_PATH` through MCP.

### Verification

- `scripts/test_library_panel.ps1` passed, confirming config save/load behavior.

## 2026-06-13 Multi-Folder Library Support

### Completed

- Upgraded `scripts/library_panel.ps1` from one remembered folder to a multi-folder list.
- Added `BASE_DIRS` support in `config/local-rag.env.ps1`.
- Updated `scripts/silent_start.ps1` to ingest each remembered folder while passing all folders as allowed base directories.
- Updated Codex config examples to use `BASE_DIRS`.

### Verification

- `scripts/test_library_panel.ps1` passed with two remembered folders.
