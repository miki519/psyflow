<!-- psyflow:conventions:begin -->
<!-- psyflow v1.0.0 -->
## Tooling Conventions

This section presets no language or framework for any project — stack
selection is always an open ADR decision made in each project's /spec
(to-architecture).

- If a project has chosen Python → manage it with `uv`, lint/format with
  `ruff`, test with `pytest` (conditional: does not imply Python by default).
- If a project has chosen Node.js/TypeScript → use `pnpm` as the package
  manager (conditional: does not imply Node by default).

## Deployment

- Deploy with Docker. (Global mandate: every project deploys containerized.)

## Coding Guidelines

- When writing code, apply the `andrej-karpathy-skills:karpathy-guidelines` skill.
<!-- psyflow:conventions:end -->
