# Roadmap

## Phase 1: Public Local Tool

- Present the project clearly as `local-Rag`.
- Keep the README focused on user value and local privacy.
- Provide setup examples for CLI and MCP usage.
- Keep runtime data, private paths, logs, model caches, and vector databases out of Git.

## Phase 2: Large Library Readiness

- Add benchmark scripts for 10k, 50k, and 260k-document simulations.
- Add index health reporting.
- Add stronger source grouping for "find the best few documents" use cases.

## Phase 3: Retrieval Quality

- Add metadata filters.
- Add better Chinese and mixed-language embedding options.
- Add optional reranking.
- Add query rewriting guidance for AI assistant workflows.

## Phase 4: Continuous Updates

- Add file watcher or scheduled sync.
- Add document deletion and move detection reports.
- Add safe rebuild tooling.

## Phase 5: Optional Team Shape

- Optional alternate vector backend for larger deployments.
- Permissions and read-only mode.
- Shared service mode.
