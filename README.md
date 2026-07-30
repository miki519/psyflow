# Claude Workbench

一套完整、可複製的 Claude Code 工作環境：多模型編排、工程流程 skills、
程式碼知識圖、設計系統知識庫，以及把它們串成一條線的 **八站 Delivery Pipeline**。

本 README 就是完整教學；repo 裡的其他檔案都是安裝用資產。

---

## 一、這套環境是什麼

六個元件、三層分工：

```
┌─ 全域層（裝一次，處處生效）──────────────────────────┐
│  pilotfish          多模型編排：規劃/執行/驗證分工      │
│  Delivery Pipeline  八站工作流（本 repo 原創）          │
│  to-architecture    架構決策站 skill（本 repo 原創）    │
├─ plugin 層（marketplace 安裝）───────────────────────┤
│  Matt Pocock skills TDD、除錯、code review、領域建模    │
│  Karpathy 準則      LLM 編程缺陷矯正                    │
├─ 專案層（每專案安裝）────────────────────────────────┤
│  code-review-graph  程式碼知識圖，AI 只讀相關檔案       │
│  ux-ui-agent-skills 設計系統知識庫＋WCAG 驗證 gates     │
└──────────────────────────────────────────────────────┘
```

各層職責：

- **pilotfish**：把「判斷」留給主 session 的貴模型，量大的搜尋與執行
  分派給便宜模型的具名角色（scout／executor），完工由全新上下文的
  verifier 獨立驗證。品質靠契約＋驗證，不靠處處用最大模型。
- **Matt Pocock skills**：工作方法——怎麼問（grilling）、怎麼驗證
  （tdd、prototype）、怎麼審（code-review）、怎麼定詞彙（domain-modeling）。
  刻意不含領域知識，所以能跟任何知識庫組合。
- **Karpathy 準則**：矯正 LLM 編程的系統性缺陷——外科手術式修改、
  假設外顯、簡潔優先、可驗證的成功條件。寫碼時常駐生效。
- **code-review-graph**：本地程式碼知識圖。AI 按圖導航、只讀命中片段，
  不整檔硬讀，token 消耗大幅下降。
- **ux-ui-agent-skills**：設計知識——DTCG tokens、元件 8 狀態規格、
  WCAG 2.2 檢查表、138 套設計系統參考，以及**可執行的驗證 gates**。
  鐵律：任何對比度數字必須來自實測，不憑感覺。

核心設計哲學：**流程與知識分離**。Matt 的 skills 當外殼（怎麼想），
ux-ui kit 當內容物（怎麼做對），Delivery Pipeline 是把它們接上的那條線。

---

## 二、Delivery Pipeline：八站工作流

### 演化由來

原始流程是四站：`/grill-me → /to-spec → /to-ticket → /implement`。
對純後端很完美，但在 UI 專案暴露兩個縫隙：

1. **「看得到之前，訪談問不出真需求」**——文字選項裡選了 A 方案，
   看到實際渲染後說「顏色太濃」，看了淡版又說「要加 hover」。
   純文字流程會把錯的答案直接凍成 spec。→ 加 **/prototype** 條件站
2. **spec 與 ticket 之間沒人管架構**——spec 很漂亮，但 service 邊界、
   API contract、事件流失控。→ 加 **/to-architecture** 條件站

再補上 review 之後的生命週期，成為八站閉環：

```
/grill-me → /prototype* → /to-spec → /to-architecture* → /to-ticket
         → /implement → /code-review → /ship
                                          │
        docs/research/ ←── 上線觀測、使用者回饋 ──┘
              └──→ 下一輪 /grill-me 的證據（閉環）
```

`*`＝條件站：無畫面／無架構決策時**明講跳過**，永不默默略過。
這是整套設計防儀式化的保險絲——日常小票實際只走四～五站。

### 各站要點

| 站 | 職責 | 關鍵規則 |
|---|---|---|
| **/grill-me** | 逐題訪談、每題附推薦答案、逐項拍板 | 新領域先跑 /domain-modeling 定詞彙表；上線觀測是下一輪的證據 |
| **/prototype*** | 可互動 HTML 原型，實際把玩再定案 | 先宣告原型要回答什麼問題；數字一律實測；候選值還不是 token |
| **/to-spec** | 定案寫成 spec | **設計系統唯一寫入站**：tokens 與元件規格只在此出生/修改；UI spec 必含 token 對照＋狀態表＋a11y 條件；flow 三段（success/failure/**recovery**）；instrumentation 埋點小節；改既有 token/元件必附影響分析 |
| **/to-architecture*** | 架構決策 | 模組邊界委派 /codebase-design 思考，本站只**記錄**：ADR（決策＋被拒方案＋理由）進 docs/decisions/、機器可驗 contract 進 packages/ |
| **/to-ticket** | 切票 | 票不得橫跨剛畫下的架構邊界 |
| **/implement** | 實作 | 邏輯走 /tdd；UI 只消費既定 tokens，缺了退回 /to-spec、**不硬編碼**；共用元件附 states harness；埋點跟功能一起做 |
| **/code-review** | 雙軸審查＋自動分級 | Standards＋Spec（含埋點查核）；動過 UI 加跑 /gate 真實 N/N＋六維度設計審＋**harness 親眼渲染**（gates 過了像素仍可能錯） |
| **/ship** | Pre-release gate | 上線後觀測落檔 docs/research/ 回流 /grill-me——**Improve 不是站，是這條路由規則** |

### 三條常備規則

1. **元件晉升制**：pattern 第一次出現長在頁面裡；第二次跨頁出現才
   晉升共用元件庫（完整 8 狀態規格、兩處收斂同一實作）。核心原語
   （按鈕、輸入框）隨基礎建設票首發。禁猜測性抽象。
2. **設計文件四層**：tokens（值）→ component specs（積木）→
   foundations（怎麼砌）→ flows（怎麼連）。只有前兩層不算設計系統。
3. **產物位置**：工具鏈可達的進 `packages/`／`apps/`；誰都不 import
   的進 `docs/`；文件跟著它描述的東西住（元件規格、harness 例外地
   與元件同居）。

### 刻意不收的東西（取捨即設計）

- **Deprecation window**：等設計系統有第二個消費端再立——單人專案
  管理不存在的利害關係人是純儀式
- **Observe／Improve 站**：觀測在 spec 埋點小節前移定義，改善靠產物
  路由回流。迴圈靠路由閉合，不靠沒人跑的站點
- **每票必經八站**：條件站自動讓路。站點多到跑不動，pipeline 就失去公信力

---

## 三、安裝

### 方法一：讓 Claude 幫你裝（推薦）

把這句話貼進你的 Claude Code：

> 請讀取 https://github.com/miki519/claude-workbench 的 SETUP.md，照它配置我的環境。

### 方法二：一行安裝

```bash
git clone https://github.com/miki519/claude-workbench && cd claude-workbench && ./install.sh
```

腳本處理檔案層（CLAUDE.md 區塊、個人 skill、CLI），冪等可重跑、
自動備份，結尾印出要在 Claude Code 內照貼的 plugin 指令：

```
/plugin marketplace add mattpocock/skills
/plugin marketplace add miki519/claude-workbench
/plugin install delivery-pipeline@claude-workbench
```

### 每專案步驟

```bash
npx ux-ui-agent-skills init          # UI 專案才需要
code-review-graph install --platform claude-code && code-review-graph build
```

或直接複製 `starter-template/`：開啟並信任專案後，Claude Code
（v2.1.195+）會自動提示安裝 marketplace 與 plugin。

### 裝完之後

在任何專案打 `/delivery-pipeline` 載入整套流程，或直接從 `/grill-me`
開始跑第一張票——各站會自動掛載當下專案有的配套 skills。

---

## 四、驗證過的版本組合

社群 marketplace **預設不自動更新**，你裝到的就是驗證過的環境。
出問題先對版本：

| 元件 | 驗證版本 | 日期 |
|---|---|---|
| mattpocock-skills | 1.2.0 | 2026-07 |
| ux-ui-agent-skills | 2.4.0 | 2026-07 |
| pilotfish | 1.3.5 | 2026-07 |
| delivery-pipeline（本 repo） | 1.0.0 | 2026-07 |

想跟進上游：`/plugin marketplace update <name>`，或在 `/plugin` →
Marketplaces 對單一 marketplace 開啟 auto-update。

---

## 五、Repo 結構（除 README 外全部是安裝資產）

```
├── README.md               ← 教學＋入口（你在這裡）
├── SETUP.md                ← 給 AI 讀的安裝手冊
├── install.sh              ← 檔案層安裝（冪等、標記式區塊、自動備份）
├── claude-md-blocks/       ← 全域 CLAUDE.md 區塊模板（升級時原地替換）
├── .claude-plugin/         ← plugin marketplace 清單
├── plugins/delivery-pipeline/  ← 八站總綱＋to-architecture skills
├── starter-template/       ← 範本專案（自動掛載 plugin）
└── PLAN.md                 ← 維護者交接文件
```

## License

MIT（僅涵蓋本 repo 原創內容；第三方元件依其各自授權，本 repo 不重新分發）。
