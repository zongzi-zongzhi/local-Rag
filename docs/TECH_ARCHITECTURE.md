# Technical Architecture

## Overview

`local-Rag` indexes local documents, stores searchable chunks in a local vector database, and exposes retrieval through MCP tools and a command-line interface.

```text
local files
  -> parser
  -> chunker
  -> local embeddings
  -> LanceDB vector store
  -> MCP tools / CLI
  -> AI assistant
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

Only files inside configured base directories should be ingested or listed. Runtime data, model caches, logs, and private configuration are excluded from Git.

## Manual Index Update

The intended local workflow is:

```text
document folder
  -> double-click local-Rag资料库.vbs
  -> choose or reuse remembered BASE_DIRS
  -> click 更新入库
  -> scripts/silent_start.ps1 runs node dist/index.js ingest for each folder
  -> LanceDB at DB_PATH is updated
  -> MCP clients read the same DB_PATH
```

Indexing and querying are decoupled by the shared local database. This lets the user update the index manually while AI tools query the same prepared data later.

`scripts/library_panel.ps1` is a thin Windows Forms layer. It manages local paths and launches the updater/status commands; retrieval stays in the CLI and MCP server.

## Future Changes

- Add benchmark scripts for very large local libraries.
- Add stronger index health reporting.
- Add optional alternate vector backends for larger collections.
- Add metadata filters and document-level grouping tuned for large collections.
