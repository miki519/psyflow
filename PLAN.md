# PLAN.md — 專案脈絡與待辦（給接手的 session 讀）

本 repo 於 2026-07-31 由 PsyConseq 專案的討論中誕生。目標：
把作者的 Claude Code 工作環境做成「可安裝＋可教學」的 repo。

## 已定案的關鍵決策（現行 v2.0.0，不要重新開放）

1. **八 stage 自有流程 workbench**（2026-08-01 定案，取代 v1 借用指令的
   八站，見決策沿革）：/setup → /discover → /design* → /spec →
   /tickets → /build → /accept → /release。站在「產品發想者＋PM＋
   全端工程師」視角設計，各 stage 內部調用成熟 skill（Matt＋ux-ui kit）
   當引擎。條件 stage（*）必須「明講跳過」，不得靜默。
2. **全手動駕駛，沒有自動模式**（初心＝新手有軌可循）。/discover 是
   唯一入口並負責路由宣告；**驗收與上線分離**（/accept 只驗收、
   /release 需驗收通過，staging → 確認 → production）。指令用
   `~/.claude/commands/` 薄檔實作（不然打 /discover 會 unknown command）；
   借用的指令（/grill-me 等）仍可直接打、不攔截，教學只教八個自有指令。
3. **Ownership rule／單一真相源**：CLAUDE.md 區塊只放薄指標，完整規則
   的唯一真相源＝workbench skill；workbench skill 只加、不重述引擎行為。
4. **to-architecture 與 codebase-design 的分工**：模組邊界的設計思考
   委派給 codebase-design，to-architecture 只負責記錄（ADR/contract）
   與非模組維度，在 /spec 內被調用。不重造輪子。
5. **第三方不重新分發**：install.sh 只印 plugin 指令，不複製別人的
   skill（更新管道、授權、單一故障點三個理由）。pilotfish 同理：
   走上游 runbook 安裝（含使用者核准閘門），不手抄檔案。
6. **雙軌安裝**：curl/clone＋install.sh（檔案層）＋「讓 Claude 讀
   SETUP.md 幫你裝」（AI-native，教學受眾主打）。
7. **放棄本 repo 的 plugin/marketplace 發佈路徑**（2026-07-31，作者暫無
   此需求）：`.claude-plugin/` 與 `plugins/` 已刪除，skills 在頂層
   `skills/`，install.sh 直接複製進 `~/.claude/skills/`，它就是唯一
   發佈管道。若日後要恢復，manifest 格式見「已查證的事實」。
8. **教學全部集中在 README**（2026-07-31）：`docs/` 已刪除，repo 內除
   README 外全是安裝資產；作者的四篇元件文章不進本 repo。
9. **教學語言**：正體中文。

## 決策沿革（已被取代，只供考古、不供遵循）

- **v1 八站 pipeline**（2026-07-31）：/grill-me → /prototype* →
  /to-spec → /to-architecture* → /to-ticket → /implement →
  /code-review → /ship。2026-08-01 整條被 v2 自有流程取代（上方
  決策 1）；舊 delivery-pipeline skill 與 CLAUDE.md 區塊已除役，
  install.sh 含 legacy 清除。
- **vNext 四提案的裁決**（2026-07-31，針對 v1）：Architecture Layer
  收（條件站）；Recovery Path 全收；Change Management 收一半（影響
  分析收、deprecation window 等第二消費端）；Closed Loop 收精神不收站。
  結論已吸收進 v2：架構決策在 /spec 內調用 to-architecture、影響分析
  ＝/spec 的 governance、Observe 前移為 spec 埋點小節、Improve＝
  /release 後 research 落檔回流 /discover。

## 已查證的事實（含出處，2026-07-31 由 claude-code-guide 驗證）

- 社群 marketplace 預設**不**自動更新；可 per-marketplace 開啟。
- plugin.json 的 version 欄位控制更新推送節奏。
- `.claude/settings.json` 的 `extraKnownMarketplaces`＋`enabledPlugins`
  （v2.1.195+）可讓專案開啟時自動提示裝 plugin（starter-template 曾用此機制，
  2026-07-31 改版時整個刪除，僅在 README 第八節留一行進階備註）。
- manifest 格式範例已照官方文件寫入 .claude-plugin/（該目錄現已刪除，
  格式記錄僅存於此）。
- pilotfish 有公開安裝源：`Nanako0129/pilotfish`（2026-08-01 查證，
  pin v1.3.5，安裝引導已寫入 SETUP.md §3）。

## 待辦（下一個 session 從這裡接）

- [ ] workbench skill 四個小修（2026-08-01 盤點「任務／限制／完成定義」後定案，
      使用者說先記著、尚未動工）：
      ① /tickets 補：每張票必含自己的驗收條件，沒有就不算切完
      ② /build 補完成定義：票完成＝驗收條件通過＋測試綠＋埋點已實作
      　（共用元件另加狀態 harness）
      ③ /setup 完成定義鎖緊：工具指令實際可執行才算裝好，不是「有回報」就好
      ④ /discover 刪掉轉述 grilling 內部做法的那句（one question at a time…
      　recommended answer…），只留「core engine: grilling」——違反 Ownership rule

- [ ] 外部 review 待修項（2026-08-01 裁定，逐項先提方案再動工）：
      版本 pin（`uv tool install 'code-review-graph==2.3.7'`、
      `npx ux-ui-agent-skills@2.4.0`＋code-review-graph 進版本表）、
      Windows 前置補裝 Git（README 缺這步，gh ≠ git）、LICENSE 檔、
      install.sh 改 `cp -R` 複製整個 skill 目錄
- [x] GitHub 帳號佔位符已全數替換為 `miki519`（2026-07-31，經 gh CLI 查證）
- [x] pilotfish 公開安裝源已查得並寫入 SETUP.md §3（2026-08-01，
      `Nanako0129/pilotfish` pin v1.3.5；Karpathy marketplace 指令同批補上）
- [x] 初始 commit 已完成（v1.0.0 起歷經 v2.0.0，見 git log）
- [ ] 在乾淨機器（或新使用者帳號）實測一次完整安裝流程
- [ ] install.sh 實測：跑兩次驗證冪等（區塊替換、備份產生）
- [ ] 推上 GitHub 後：用另一台機器走一次「方法一（讓 Claude 裝）」

## 相關脈絡

- 作者的全域 `~/.claude/CLAUDE.md` 已裝 v2 workbench 區塊
  （`workbench:pipeline` 標記，v1 的 `workbench:delivery-pipeline`
  已由 install.sh 清除）；個人 skills `~/.claude/skills/workbench/`、
  `~/.claude/skills/to-architecture/` 已就位。
- PsyConseq 專案是 pipeline 的第一個實戰場（重設計進行中，
  視覺基調已定案，見該專案記憶 project_redesign_2026-07）。
