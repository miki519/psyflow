# Starter Template

把這個資料夾複製成你的新專案起點。內含 `.claude/settings.json`：
在 Claude Code（v2.1.195+）開啟並信任這個專案後，會**自動提示安裝**
claude-workbench marketplace 與 delivery-pipeline plugin——這是目前最接近
「開專案即裝好」的機制。

之後補上每專案步驟：

```bash
npx ux-ui-agent-skills init          # UI 專案才需要
code-review-graph install --platform claude-code && code-review-graph build
```

建議的專案結構（Delivery Pipeline 的 Artifact locations 約定）：

```
├── docs/
│   ├── domain-model.md     ← 詞彙表（/grill-me 首次）
│   ├── decisions/          ← 拍板紀錄＋ADR
│   ├── prototypes/         ← 拋棄式互動原型（留作證據）
│   ├── specs/              ← spec＋tickets（foundation spec 含 foundations.md）
│   └── research/           ← 調查＋上線後觀測（回流 /grill-me）
├── packages/
│   ├── design-tokens/src/  ← DTCG token 唯一真相源
│   ├── design-tokens/dist/ ← 生成物，永不手改
│   └── ui/                 ← 共用元件（元件＋規格＋harness＋測試同居）
├── apps/
└── design-kit/             ← ux-ui-agent-skills（唯讀參考）
```
