# PRD

## Background

Users often keep research notes, PDFs, project documents, meeting materials, and exported web pages across many local folders. As the library grows, keyword search becomes limited and AI assistants spend too much time reading broad folders instead of finding the few useful passages.

## Goal

Create `local-Rag`, a local-first document retrieval project that turns private files into a searchable local index for semantic search and AI-assisted workflows.

## Target User

- Primary: one user working with a private local document library.
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

- Keep MCP and CLI access.
- Support local semantic search with keyword boost.
- Support PDF, DOCX, TXT, Markdown, and HTML ingestion.
- Support incremental replacement through re-ingestion.
- Provide Windows-friendly local indexing helpers.
- Keep private documents, indexes, model caches, and logs out of Git.

## Non-Goals

- Hosted SaaS deployment.
- User accounts.
- Enterprise permission model.
- Public cloud document storage.

## Success Criteria

- The project builds locally.
- Local files under configured roots can be ingested and queried.
- AI tools can connect through MCP and search the same local index.
- Documentation clearly explains setup, privacy boundaries, and daily usage.
