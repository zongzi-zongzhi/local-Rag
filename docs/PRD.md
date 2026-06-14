# PRD

## Background

The user has a large local document collection and wants Codex to locate a few relevant documents quickly according to current goals and context.

## Goal

Create `local-Rag`, a local-first RAG project that Codex can call through MCP.

## Target User

- Primary: one user working locally with Codex.
- Later: small teams with shared local or private document collections.

## User Inputs

- Local files and folders.
- Natural language questions or search goals.
- Optional filters such as source folder, document type, and query intent.

## System Outputs

- Relevant chunks.
- Source document path and title.
- Search scores.
- Surrounding context.
- Index status.

## MVP Scope

- Use `mcp-local-rag` as the implementation base.
- Keep MCP and CLI access.
- Support local semantic search with keyword boost.
- Support incremental replacement through re-ingestion.
- Add Codex-focused documentation and project structure.

## Non-Goals

- Web UI.
- SaaS deployment.
- User accounts.
- Enterprise permission model.
- Immediate rewrite of the upstream implementation.

## Success Criteria

- The project builds locally.
- Codex can be configured to start the MCP server.
- Files under configured roots can be ingested and queried.
- The project documentation clearly explains why this fork exists and what comes next.
