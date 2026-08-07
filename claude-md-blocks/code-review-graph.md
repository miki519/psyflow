<!-- psyflow:code-review-graph:begin -->
<!-- psyflow v1.0.0 -->
## Code Review Graph (use in every project)

All projects use `code-review-graph` (a local code knowledge graph, MCP server + CLI) to aid comprehension and review of code:

- When entering a project that is not yet set up, first run `code-review-graph install --platform claude-code`, then run `code-review-graph build` to build the graph.
- For projects already set up, navigate the code preferentially through its MCP tools/skills (explore-codebase, review-changes, refactor-safely, debug-issue), reading only the relevant parts to reduce needless whole-file reading.
- After large changes, or when the graph is stale, run `code-review-graph build` to rebuild it (or use `code-review-graph watch` to update it automatically).
<!-- psyflow:code-review-graph:end -->
