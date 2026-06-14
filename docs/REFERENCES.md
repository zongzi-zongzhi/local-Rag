# References

## Primary Base: mcp-local-rag

Repository: https://github.com/shinpr/mcp-local-rag

Local reference copy, if retained:

```text
references/upstream/mcp-local-rag
```

Reason for using it as the base:

- It is already a working local RAG MCP server.
- It supports Codex configuration.
- It has a clear CLI and MCP tool surface.
- It supports local embeddings and LanceDB.
- It supports the document formats needed for a practical first version.

## Secondary Reference: knowledge-rag

Repository: https://github.com/lyonzin/knowledge-rag

Local reference copy, if retained:

```text
references/upstream/knowledge-rag
```

Reason for using it as a future reference:

- It has a richer hybrid search architecture.
- It has more parser coverage.
- It has stronger large-project governance and benchmarking ideas.
- It is heavier than needed for the first fork.

## Decision

Use `mcp-local-rag` as the implementation base now. Use `knowledge-rag` as the roadmap reference for retrieval quality and scale.
