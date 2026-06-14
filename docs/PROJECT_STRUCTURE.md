# Project Structure

## `src/server`

MCP server implementation and tool definitions.

## `src/cli`

Command-line interface for ingesting, querying, listing, deleting, and checking status.

## `src/parser`

Document parsers for supported formats.

## `src/chunker`

Text splitting logic.

## `src/embedder`

Local embedding model integration.

## `src/vectordb`

LanceDB storage and search logic.

## `skills`

Instructions that help AI assistants use the RAG tools effectively.

## `docs`

Project-level product, architecture, structure, roadmap, and development notes.

## `scripts`

Build, test, local indexing, and maintenance scripts.

## `scripts/silent_start.ps1`

Windows helper used by `更新入库local-Rag.vbs` and `查看入库状态local-Rag.bat`. Its default mode updates the local index by ingesting configured folders.

## `scripts/library_panel.ps1`

Windows Forms panel for choosing document folders, remembering them in `config/local-rag.env.ps1`, running index updates, checking status, and opening logs.

## `local-Rag资料库.vbs`

Recommended double-click entry. Opens the local library panel without a terminal window.

## `local-Rag资料库.bat`

Visible fallback entry for debugging the panel.

## `config`

Local configuration examples. `config/local-rag.env.ps1` is ignored and should hold private local paths.
