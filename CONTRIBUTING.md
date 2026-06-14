# Contributing to local-Rag

Contributions welcome. This guide covers the local setup and quality checks for the project.

## Prerequisites

- Node.js >= 22
- [pnpm](https://pnpm.io/)

## Setup

```bash
git clone https://github.com/zongzi-zongzhi/local-Rag.git
cd local-Rag
corepack enable
pnpm install
```

The embedding model downloads on first test or run.

## Quality Checks

All PRs should pass the full quality check, which mirrors CI:

```bash
pnpm run check:all
```

This runs the following in order:

| Step | Command | What it checks |
|------|---------|----------------|
| Biome check | `pnpm run check` | Lint + format combined |
| Lint | `pnpm run lint` | Code quality rules |
| Format | `pnpm run format:check` | Code formatting |
| Unused exports | `pnpm run check:unused` | No dead exports |
| Circular deps | `pnpm run check:deps` | No circular dependencies |
| Build | `pnpm run build` | TypeScript compilation |
| Test | `pnpm run test` | All tests pass |

Fix lint and format issues automatically:

```bash
pnpm run check:fix
```

## PR Requirements

Before submitting a pull request:

1. Add tests for new features and bug fixes.
2. Run `pnpm run check:all` and ensure everything passes.
3. Update documentation if behavior changes.
4. Keep commits focused.
5. Do not commit private documents, local indexes, model caches, logs, tokens, cookies, or API keys.

## Writing Tests

`vitest.config.mjs` runs with `isolate: false`, `pool: 'forks'`, and `maxWorkers: 1` because native runtime dependencies keep process-level state that cannot always be reset safely between test files.

This affects `vi.mock`. A top-level `vi.mock(path, factory)` registers globally and applies to every other test file that imports the same path, including files that use the real module.

Rule of thumb:

- If the mocked path is touched only in one test file, top-level `vi.mock` is fine.
- Otherwise, scope the mock to the file with `vi.doMock` inside `beforeAll` and clear it in `afterAll`.
- Import the target dynamically after `doMock`, since `doMock` is not hoisted.

Example:

```ts
const parserFactory = () => ({ /* ... */ })
const MOCKED_PATHS = ['../../parser/index.js'] as const

let runIngest: typeof import('../../cli/ingest.js').runIngest

beforeAll(async () => {
  vi.resetModules()
  vi.doMock('../../parser/index.js', parserFactory)
  ;({ runIngest } = await import('../../cli/ingest.js'))
})

afterAll(() => {
  for (const p of MOCKED_PATHS) vi.doUnmock(p)
  vi.resetModules()
})
```

Live examples: `src/__tests__/cli/ingest-default-mode.test.ts`, `src/__tests__/server/handleIngestFile-side-effects.test.ts`.

## Project Structure

```text
src/
  index.ts        # Entry point
  server/         # MCP tool handlers
  parser/         # Document parsing
  chunker/        # Text chunking
  embedder/       # Local embeddings
  vectordb/       # LanceDB operations
  __tests__/      # Test suites
```

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
