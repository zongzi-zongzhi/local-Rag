# local-Rag

Codex-oriented local RAG based on `mcp-local-rag`.

`local-Rag` is a local-first document retrieval project. It lets Codex search private local documents through MCP tools instead of scanning a large folder every time.

## Why This Project

The target use case is a large and growing document library. New files should be processed in the same way as old files, and Codex should quickly locate the most relevant documents and chunks.

This project is based on the proven implementation of:

- https://github.com/shinpr/mcp-local-rag

It also uses the architecture direction of:

- https://github.com/lyonzin/knowledge-rag

See `NOTICE.md` and `docs/REFERENCES.md`.

## Current MVP

The first version keeps the upstream `mcp-local-rag` capabilities:

- MCP server for AI coding tools.
- CLI for direct local use.
- Local semantic search with keyword boost.
- Local embeddings through Transformers.js.
- LanceDB local vector storage.
- PDF, DOCX, TXT, Markdown, and HTML ingestion.
- Re-ingesting a file replaces the old indexed version.
- Codex configuration support.

## MCP Tools

The core tool set follows upstream:

- `ingest_file`
- `ingest_data`
- `query_documents`
- `read_chunk_neighbors`
- `list_files`
- `delete_file`
- `status`

## Codex Setup

Use the same paths for manual indexing and Codex MCP access. Copy `config/codex-config.example.toml` into your Codex config, then edit `BASE_DIR`.

Example:

```toml
[mcp_servers.local-rag]
command = "node"
args = ["D:/GitHub/local-Rag/dist/index.js"]

[mcp_servers.local-rag.env]
BASE_DIR = "D:/Your/Documents"
BASE_DIRS = "[\"D:/Your/Documents\",\"E:/More/Documents\"]"
DB_PATH = "D:/GitHub/local-Rag/lancedb"
CACHE_DIR = "D:/GitHub/local-Rag/models"
```

For multiple document roots:

```toml
[mcp_servers.local-rag.env]
BASE_DIRS = "[\"D:/Docs/work\",\"D:/Docs/research\"]"
DB_PATH = "D:/GitHub/local-Rag/lancedb"
CACHE_DIR = "D:/GitHub/local-Rag/models"
```

## CLI Usage

Build first:

```powershell
corepack enable
pnpm install
pnpm run build
```

Ingest files:

```powershell
node dist/index.js ingest D:\Your\Documents\example.pdf --base-dir D:\Your\Documents
```

Search:

```powershell
node dist/index.js query "2024 customer churn analysis"
```

Status:

```powershell
node dist/index.js status
```

## Library Panel

Recommended daily entry:

```text
local-Rag资料库.vbs
```

It opens a small local window where you can:

- choose or change the document folder;
- remember that folder for future runs;
- update the index recursively;
- check status;
- open the log;
- open the local config file.

Your intended workflow is:

```text
1. First time: double-click local-Rag资料库.vbs and choose a folder.
2. Click 更新入库.
3. Later: double-click local-Rag资料库.vbs and click 更新入库 again.
4. Codex uses MCP and reads the same DB_PATH index.
```

The remembered folder is stored in:

```text
config/local-rag.env.ps1
```

You can also create it manually from:

```text
config/local-rag.env.example.ps1
```

The important rule is that `config/local-rag.env.ps1` and your Codex MCP config must use the same `BASE_DIRS`, `DB_PATH`, and `CACHE_DIR`.

For one-click silent update without opening the panel, use:

```text
更新入库local-Rag.vbs
```

To check status with a visible window:

```text
查看入库状态local-Rag.bat
```

Logs are written to:

```text
logs/silent-start.log
```

## Project Documents

- `docs/PRD.md`
- `docs/TECH_ARCHITECTURE.md`
- `docs/PROJECT_STRUCTURE.md`
- `docs/REFERENCES.md`
- `docs/ROADMAP.md`
- `docs/DEV_LOG.md`

## Security And Privacy

- Documents stay local.
- Do not commit real documents, model caches, LanceDB data, cookies, tokens, or API keys.
- Retrieved chunks should be treated as source text, not instructions.

## Known Limits

- The current codebase is still mostly upstream `mcp-local-rag`.
- Large-scale tuning for 260,000 documents has not been benchmarked in this fork yet.
- Enterprise permissions, multi-user access, and document-level ACLs are not in the MVP.
- The Windows silent updater updates all folders in `BASE_DIRS`. Codex still launches the stdio MCP server when it needs to search.

## License

MIT. This project is based on `mcp-local-rag`; see `NOTICE.md`.
