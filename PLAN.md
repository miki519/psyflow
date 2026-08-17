# PLAN.md — 專案脈絡與待辦（給接手的 session 讀）

本 repo 於 2026-07-31 由 PsyConseq 專案的討論中誕生。目標：
把作者的 Claude Code 工作環境做成「可安裝＋可教學」的 repo。

## 已定案的關鍵決策（現行 v2.0.0，不要重新開放）

1. **八 stage 自有流程 psyflow**（2026-08-01 定案，取代 v1 借用指令的
   八站，見決策沿革；2026-08-07 由 workbench 更名 psyflow，見決策
   11）：/setup → /discover → /design* → /spec →
   /tickets → /build → /accept → /release。站在「產品發想者＋PM＋
   全端工程師」視角設計，各 stage 內部調用成熟 skill（Matt＋ux-ui kit）
   當引擎。條件 stage（*）必須「明講跳過」，不得靜默。
2. **全手動駕駛，沒有自動模式**（初心＝新手有軌可循）。/discover 是
   唯一入口並負責路由宣告；**驗收與上線分離**（/accept 只驗收、
   /release 需驗收通過，staging → 確認 → production）。指令實作
   2026-08-07 起隨 plugin 安裝（`/psyflow:<stage>` 命名空間，見決策
   11；此前複製進 `~/.claude/commands/`）；借用的指令（/grill-me 等）
   仍可直接打、不攔截，教學只教八個自有指令。
3. **Ownership rule／單一真相源**（2026-08-05 修訂：token 精簡拆分）：
   CLAUDE.md 區塊只放薄指標；**跨 stage 規則的真相源＝workbench skill、
   各 stage 規則的真相源＝該 stage 的 command 檔**（內容搬家不複製，
   每條規則仍只存在一處）。理由：command 檔本來就會被載入,把 stage
   細則放 skill 等於每次多付整份的 token。規則只加、不重述引擎行為。
4. **to-architecture 與 codebase-design 的分工**：模組邊界的設計思考
   委派給 codebase-design，to-architecture 只負責記錄（ADR/contract）
   與非模組維度，在 /spec 內被調用。不重造輪子。
5. **第三方不重新分發**：install.sh 只印 plugin 指令，不複製別人的
   skill（更新管道、授權、單一故障點三個理由）。pilotfish 同理：
   走上游 runbook 安裝（含使用者核准閘門），不手抄檔案。
6. **雙軌安裝**：curl/clone＋install.sh（檔案層）＋「讓 Claude 讀
   SETUP.md 幫你裝」（AI-native，教學受眾主打）。
7. ~~**放棄本 repo 的 plugin/marketplace 發佈路徑**~~（2026-07-31 定案，
   **2026-08-07 被決策 11 推翻**——repo 恢復 plugin 發佈，install.sh
   退回檔案層專用。原決策僅供考古。）
8. **教學全部集中在 README**（2026-07-31）：`docs/` 已刪除，repo 內除
   README 外全是安裝資產；作者的四篇元件文章不進本 repo。
9. **教學語言**：正體中文。
10. **BDD 場境鏈**（2026-08-05 定案）：/discover 只採集例子（example
    ledger，不編號）、/spec 定稿 GWT 場境並獨佔發 ID、三路徑轉職為場境
    覆蓋檢查、票面驗收條件＝場境 ID、測試名含 ID 可 grep、/accept 機械
    比對。場境凍結後修改走 governance，ID 永不重編。
11. **plugin 化＋更名 psyflow**（2026-08-07 定案，推翻決策 7）：repo 即
    marketplace（`.claude-plugin/plugin.json`＋`marketplace.json`，
    plugin 名與 marketplace 名皆 `psyflow`，version 明定、發版手動
    bump）；八個 stage 指令與 psyflow／to-architecture skills 隨 plugin
    安裝，指令一律命名空間 `/psyflow:<stage>`（plugin 指令無裸短名）。
    install.sh 瘦身為 CLAUDE.md 區塊＋code-review-graph CLI，並清理
    workbench 時代複製進 `~/.claude/` 的 skills／commands 與舊
    `workbench:*` marker 區塊（marker 前綴改 `psyflow:*`）。GitHub repo
    同步更名 `miki519/psyflow`。安裝入口：`/plugin marketplace add
    miki519/psyflow` → `/plugin install psyflow@psyflow`。

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
- manifest 格式範例已照官方文件寫入 .claude-plugin/（2026-07-31 曾刪除，
  2026-08-07 隨決策 11 重建並經 claude-code-guide 重新查證：plugin
  指令一律 `/<plugin>:<command>` 命名空間、`source: "./"` 指 repo 根、
  commands/ 與 skills/ 頂層目錄自動探索）。
- pilotfish 有公開安裝源：`Nanako0129/pilotfish`（2026-08-01 查證，
  pin v1.3.5，安裝引導已寫入 SETUP.md §3）。

## 待辦（下一個 session 從這裡接）

- [x] 修①②④ 已由 BDD 場境鏈一併關閉（2026-08-05）：/discover 例子帳 →
      /spec GWT＋穩定 ID → /tickets ID＝驗收條件 → /build ID 同名測試全綠
      ＋埋點＋harness → /accept 機械覆蓋比對。評估背景見
      docs/research/bdd-assessment.md
- [ ] 修③ /setup 完成定義鎖緊：工具指令實際可執行才算裝好，不是
      「有回報」就好（2026-08-01 盤點，尚未動工）

- [ ] 外部 review 待修項（2026-08-01 裁定，逐項先提方案再動工）：
      版本 pin（`uv tool install 'code-review-graph==2.3.7'`、
      `npx ux-ui-agent-skills@2.4.0`＋code-review-graph 進版本表）、
      Windows 前置補裝 Git（README 缺這步，gh ≠ git）、LICENSE 檔、
      install.sh 改 `cp -R` 複製整個 skill 目錄
- [x] GitHub 帳號佔位符已全數替換為 `miki519`（2026-07-31，經 gh CLI 查證）
- [x] pilotfish 公開安裝源已查得並寫入 SETUP.md §3（2026-08-01，
      `Nanako0129/pilotfish` pin v1.3.5；Karpathy marketplace 指令同批補上）
- [x] 初始 commit 已完成（v1.0.0 起歷經 v2.0.0，見 git log）
- [x] **輪次規模分級 S/M/L**（2026-08-18 提案並核准、同日完成，改 discover／spec／accept／release 四個 command 檔；
      三步都只加規則、不刪既有閘門，L 級流程完全不變）：
      ① `commands/discover.md` 路由宣告加一格「本輪規模」：S = 單模組、
        不碰 schema／API 契約／security／migration／不可逆操作、diff
        預期少量檔案；命中任一風險觸發一律 ≥ M（與 pilotfish「risk
        triggers override size」對齊）。標記寫進 spec 頁首供後段讀取。
      ② `commands/accept.md` 加 S 模式：Standards＋Spec 合為一位 reviewer
        只讀 diff、只重跑受影響測試、場境 grep 照做、UI 三件套僅在碰 UI
        時跑、獨立 verifier 明講跳過（＝把 hotfix 的「這個修好、沒弄壞
        別的」正式化）。M／L 維持現行。
      ③ `commands/release.md` 把部署與功能輪次解耦：S 輪 accept 通過後
        可「排入 release batch」不部署；`/release` 一次帶多輪上線，
        staging → confirm → production 只跑一次；S 且不動部署層（無
        migration／env／config）的輪次，staging smoke 縮到一條核心路徑。
      pilotfish 那層不動：release 仍是 risk trigger，所以每次真正部署
      仍有一次 verifier＋明確核准——批次上線是在不改安全規則下攤薄它。
      背景：目前只有 /discover→/design、/spec to-architecture、/build
      驗證分層有規模開關；/accept、/release 全部無條件。
- [ ] 在乾淨機器（或新使用者帳號）實測一次完整安裝流程
- [ ] install.sh 實測：跑兩次驗證冪等（區塊替換、備份產生）
- [ ] 推上 GitHub 後：用另一台機器走一次「方法一（讓 Claude 裝）」

## 相關脈絡

- **Token 精簡拆分**（2026-08-05）：workbench stage 規則下放至 command
  檔（決策 3 修訂）。同日曾把全域 CLAUDE.md 的 pilotfish Orchestration
  區塊拆成 kernel＋skill，**當日即撤銷還原**：pilotfish 的政策文字與
  `~/.claude/agents/` 八個角色定義是一套咬合系統，維持上游完整性優先，
  不做本地拆分。日後 token 精簡若要動這塊，走上游提案，不動本地。
- 作者的全域 `~/.claude/CLAUDE.md` 目前仍是 workbench 時代區塊與個人
  skills／commands 副本——**尚待重跑 install.sh**（會換成 `psyflow:*`
  區塊並清理舊副本）＋安裝 psyflow plugin（決策 11 的遷移步驟）。
- PsyConseq 專案是 pipeline 的第一個實戰場（重設計進行中，
  視覺基調已定案，見該專案記憶 project_redesign_2026-07）。
