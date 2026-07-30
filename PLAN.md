# PLAN.md — 專案脈絡與待辦（給接手的 session 讀）

本 repo 於 2026-07-31 由 PsyConseq 專案的討論中誕生。目標：
把作者的 Claude Code 工作環境做成「可安裝＋可教學」的 repo。

## 已定案的關鍵決策（不要重新開放）

1. **八站 pipeline**：/grill-me → /prototype* → /to-spec →
   /to-architecture* → /to-ticket → /implement → /code-review → /ship。
   兩個條件站必須「明講跳過」。
2. **vNext 四提案的裁決**：Architecture Layer 收（條件站）；Recovery
   Path 全收；Change Management 收一半（影響分析收、deprecation
   window 等第二消費端）；Closed Loop 收精神不收站（/ship 進站、
   Observe 前移為 spec 埋點小節、Improve＝research 回流路由）。
3. **to-architecture 與 codebase-design 的分工**：模組邊界的設計思考
   委派給 codebase-design，to-architecture 只負責記錄（ADR/contract）
   與非模組維度。不重造輪子。
4. **第三方不重新分發**：install.sh 只印 plugin 指令，不複製別人的
   skill（更新管道、授權、單一故障點三個理由）。
5. **雙軌安裝**：curl/clone＋install.sh（檔案層）＋「讓 Claude 讀
   SETUP.md 幫你裝」（AI-native，教學受眾主打）。
6. **教學語言**：正體中文。

## 已查證的事實（含出處，2026-07-31 由 claude-code-guide 驗證）

- 社群 marketplace 預設**不**自動更新；可per-marketplace 開啟。
- plugin.json 的 version 欄位控制更新推送節奏。
- `.claude/settings.json` 的 `extraKnownMarketplaces`＋`enabledPlugins`
  （v2.1.195+）可讓專案開啟時自動提示裝 plugin（starter-template 曾用此機制，
  2026-07-31 改版時整個刪除，僅在 README 第八節留一行進階備註）。
- manifest 格式範例已照官方文件寫入 .claude-plugin/。

## 待辦（下一個 session 從這裡接）

- [x] GitHub 帳號佔位符已全數替換為 `miki519`（2026-07-31，經 gh CLI 查證）
- [ ] 在乾淨機器（或新使用者帳號）實測一次完整安裝流程
- [ ] install.sh 實測：跑兩次驗證冪等（區塊替換、備份產生）
- [ ] 推上 GitHub 後：用另一台機器走一次「方法一（讓 Claude 裝）」
- [ ] 考慮：pilotfish 是否有公開安裝源可在 README 附上
- [ ] 初始 commit（作者按自己習慣的訊息風格）

註（2026-07-31 決策）：教學全部集中在 README，`docs/` 已刪除——
repo 內除 README 外全是安裝資產。作者的四篇元件文章不進本 repo，
README 只保留各元件的一段式介紹。

註（2026-07-31 決策二）：**放棄本 repo 的 plugin/marketplace 發佈路徑**
（作者暫無此需求）——`.claude-plugin/` 與 `plugins/` 已刪除，skills 搬到
頂層 `skills/`，install.sh 直接複製進 `~/.claude/skills/`，它就是唯一
發佈管道。CLAUDE.md 區塊已瘦身為 v1.2.0 薄指標（完整規則的唯一真相源
＝delivery-pipeline skill）。第三方（mattpocock 等）仍走各自的 marketplace。
若日後要恢復 plugin 路徑，manifest 格式見上方「已查證的事實」。

## 相關脈絡

- 作者的全域 `~/.claude/CLAUDE.md` 已裝 pipeline 區塊（v1.1.0，
  `workbench:delivery-pipeline` 標記同源同步）；個人 skill
  `~/.claude/skills/to-architecture/` 已就位。
- PsyConseq 專案是 pipeline 的第一個實戰場（重設計進行中，
  視覺基調已定案，見該專案記憶 project_redesign_2026-07）。
