# Technical Architecture

## Base Project

`local-Rag` is based on `shinpr/mcp-local-rag`.

The upstream architecture is already close to the target MVP:

```text
local files
  -> parser
  -> semantic chunker
  -> Transformers.js embedder
  -> LanceDB vector store
  -> MCP tools / CLI
  -> Codex
```

## Key Modules

- `src/server`: MCP tool handlers.
- `src/cli`: CLI subcommands.
- `src/parser`: PDF, DOCX, TXT, Markdown, and HTML parsing.
- `src/chunker`: semantic chunking and sentence splitting.
- `src/embedder`: local embedding generation.
- `src/vectordb`: LanceDB operations and search filtering.
- `skills`: assistant-facing usage guidance.

## Tool Surface

- `ingest_file`
- `ingest_data`
- `query_documents`
- `read_chunk_neighbors`
- `list_files`
- `delete_file`
- `status`

## Data Storage

- Vector data: `DB_PATH`, default `./lancedb`.
- Model cache: `CACHE_DIR`, default `./models`.
- Source documents remain in the user-selected `BASE_DIR` or `BASE_DIRS`.

## Security Boundary

Only files inside configured base directories should be ingested or listed.

## Manual Silent Index Update

The intended local workflow is:

```text
document folder
  -> double-click local-Rag资料库.vbs
  -> choose or reuse remembered BASE_DIRS
  -> click 更新入库
  -> scripts/silent_start.ps1 runs node dist/index.js ingest for each folder
  -> LanceDB at DB_PATH is updated
  -> Codex later starts MCP and reads the same DB_PATH
```

This is feasible because indexing and querying are decoupled by the shared local database. It is also stricter than starting a hidden stdio MCP server manually, because stdio MCP servers should normally be started by the MCP client.

`scripts/library_panel.ps1` is a thin Windows Forms layer. It does not implement retrieval itself; it only manages local paths and launches the existing updater/status commands.

## Future Changes

- Add benchmark scripts for very large local libraries.
- Add preset configuration for Codex.
- Add optional Qdrant backend if LanceDB is not enough for the target corpus.
- Add metadata filters and document-level grouping tuned for large collections.
