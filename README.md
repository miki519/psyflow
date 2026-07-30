# Claude Workbench

從零開始建立一套完整、可複製的 Claude Code 工作環境——從訂閱、安裝，
到一條把需求做到上線的 **八個 stage 的 Delivery Pipeline**。
照著本文由上而下做一遍，你會得到跟作者一樣的工作環境。

## 為什麼要做這個工作流

直接對 AI 說「幫我做一個◯◯」（vibe coding）在小東西上很爽，
但專案一大就會反覆撞上同樣的牆：

- **需求靠猜**：AI 沒問清楚就開寫，寫完才發現不是你要的
- **看不到就定案**：UI 用文字討論、選了配色，實際渲染出來又說「太濃了」
  ——錯的答案被直接凍成規格
- **架構默默失控**：規格很漂亮，但 service 邊界、API 契約沒人決定，
  改到後面牽一髮動全身
- **品質憑感覺**：「對比度應該夠」「應該都測過了」——沒有實測數字的
  宣稱，缺陷一路活到上線
- **上線即結案**：沒人回頭看數據，同樣的錯下個功能再犯一次

這套工作流的答案是：**把交付切成固定的 stage，每個 stage 有明確的產出與關卡**
——需求用逐題訪談拍板、畫面先做可互動原型再定案、架構決策留下紀錄、
品質數字一律來自實測 gates、上線後的觀測回流成下一輪的證據。
AI 負責跑流程和產出，你只負責回答問題和拍板。

## 目錄

1. [訂閱 Claude Code](#一訂閱-claude-code)
2. [安裝 Claude Code CLI](#二安裝-claude-code-cli)
3. [申請 GitHub 帳號](#三申請-github-帳號)
4. [安裝 gh 並授權登入](#四安裝-gh-並授權登入)
5. [安裝 Node.js](#五安裝-nodejs)
6. [安裝 uv](#六安裝-uv)
7. [安裝 Docker](#七安裝-docker)
8. [安裝本 repo](#八安裝本-repo)
9. [開始新專案](#九開始新專案)
10. [工作流教學](#十工作流教學)

---

## 一、訂閱 Claude Code

Claude Code 需要付費訂閱（免費版 claude.ai 不含 Claude Code）。

到 [claude.com/pricing](https://claude.com/pricing) 訂閱：
**起步選 Pro（月費 20 美金）**；用起來覺得額度不夠
（本工作流的多模型編排較吃額度）再升級 Max。

## 二、安裝 Claude Code CLI

不需要先裝任何東西（含 Node.js），一行指令完成，之後會自動更新。

### macOS / Linux

打開終端機，執行：

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

### Windows

打開 **PowerShell**，執行：

```powershell
irm https://claude.ai/install.ps1 | iex
```

> Windows 使用者之後的所有指令都在 PowerShell 裡執行。

## 三、申請 GitHub 帳號

本工作流以 GitHub 為版本控制與發佈中心。

1. 到 <https://github.com/signup> 註冊（已有帳號跳過）
2. 建議開啟兩步驟驗證（Settings → Password and authentication）

## 四、安裝 gh 並授權登入

`gh` 是 GitHub 官方 CLI。裝了它，AI 才能替你建 repo、開 PR、查 issue。

### 安裝

```bash
brew install gh                 # macOS
winget install GitHub.cli       # Windows（PowerShell）
sudo apt install gh             # Ubuntu / Debian
```

### 授權登入

```bash
gh auth login
```

依序選：`GitHub.com` → `HTTPS` → `Login with a web browser`，
瀏覽器輸入畫面顯示的一次性代碼即可。驗證：

```bash
gh auth status   # 顯示 Logged in 即成功
```

## 五、安裝 Node.js

之後安裝專案工具會用到 `npx` 與 `npm`，它們跟著 Node.js 來。

```bash
brew install node                    # macOS
winget install OpenJS.NodeJS.LTS     # Windows（PowerShell）
sudo apt install nodejs npm          # Ubuntu / Debian
```

驗證：`node --version` 有輸出即成功。

## 六、安裝 uv

`uv` 是 Python 工具的管理器，之後安裝 `code-review-graph`（程式碼知識圖）
會用到。它自帶 Python，**不需要另外安裝 Python**。

### macOS / Linux

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Windows（PowerShell）

```powershell
irm https://astral.sh/uv/install.ps1 | iex
```

驗證：`uv --version` 有輸出即成功（裝完若找不到指令，關掉終端機重開一次）。

## 七、安裝 Docker

本工作流的部署慣例是 Docker（開發資料庫、正式環境都容器化）。

| OS | 方式 |
|---|---|
| macOS | [Docker Desktop for Mac](https://docs.docker.com/desktop/setup/install/mac-install/)（Apple Silicon／Intel 選對版本） |
| Windows | [Docker Desktop for Windows](https://docs.docker.com/desktop/setup/install/windows-install/) |
| Linux | [Docker Engine](https://docs.docker.com/engine/install/)（記得把使用者加入 `docker` 群組） |

## 八、安裝本 repo

前面備齊後，裝這套工作環境本體。

### 1. 首次啟動與登入

打開終端機（Windows 用 PowerShell），執行：

```bash
claude
```

第一次啟動會自動開瀏覽器做 OAuth 登入（登入第一節訂閱的帳號）；
瀏覽器沒開就按 `c` 複製登入網址。看到 `Login successful` 即完成。

### 2. 讓 Claude 幫你裝

登入後，把這句話貼進 Claude Code：

> 請讀取 https://github.com/miki519/claude-workbench 的 SETUP.md，照它配置我的環境。

你的 Claude 會自己下載 repo、執行安裝、引導你完成 plugin 步驟、
最後回報驗收清單。

### 驗證過的版本組合

社群 marketplace 預設**不自動更新**，你裝到的就是驗證過的環境：

| 元件 | 驗證版本 | 日期 |
|---|---|---|
| mattpocock-skills | 1.2.0 | 2026-07 |
| ux-ui-agent-skills | 2.4.0 | 2026-07 |
| pilotfish | 1.3.5 | 2026-07 |
| delivery-pipeline（本 repo） | 1.0.0 | 2026-07 |

### 更新這套環境

所有元件都**不會自動更新**——這是特性：你的環境保持在驗證過的
版本組合，不會一覺醒來行為變了。想更新時，把這句話貼進 Claude Code：

> 請讀取 https://github.com/miki519/claude-workbench 的 SETUP.md，照它更新我的環境。

AI 會拉最新版、重跑安裝、引導你完成 plugin 更新；動到你自訂的內容前
會先警告，完成後回報更新了什麼。

## 九、開始新專案

之後每次要開新專案，三步：

### 1. 開新資料夾

```bash
mkdir 我的新專案 && cd 我的新專案
```

### 2. 啟動 Claude Code

```bash
claude
```

### 3. 讓 AI 安裝專案工具

把這句話貼進去：

> 請初始化這個專案的工作環境：執行 `npx ux-ui-agent-skills init` 安裝設計知識庫，
> 再執行 `code-review-graph install --platform claude-code`（只安裝、不用 build，
> 專案還是空的）。開始前先確認 `node` 與 `npx` 可用，缺少就先安裝 Node.js LTS
> 再繼續；任何指令失敗請診斷並解決，不要跳過。完成後回報安裝結果。

裝完就可以直接開工（見下一節）。

## 十、工作流教學

### 第一部分：基礎用法

先記住一件事：**每個 stage 就是一個斜線指令，做完一個 stage 打下一個 stage**。
八個 stage 不用背，跟著四個情境操作一遍就會了。

```
/grill-me → /prototype* → /to-spec → /to-architecture* → /to-ticket
         → /implement → /code-review → /ship
```

`*`＝條件 stage，用不到時 AI 會明講「跳過」，你直接打下一個 stage 即可。

#### 情境一：「我想做一個官網」（大型、從零開始）

| 步驟 | 你打的指令 | 目的／會發生什麼 |
|---|---|---|
| 1 | `/grill-me 我想做一個公司官網` | AI 逐題訪談（受眾？頁面清單？品牌色？），每題附推薦答案，你逐項拍板。新領域它會先建**詞彙表**，讓之後的文案與程式碼用同一套名詞 |
| 2 | `/prototype` | 把首頁做成**可互動的 HTML** 給你玩。目的：「看得到之前，訪談問不出真需求」——「顏色太濃」「改大圓角」這種回饋就在這個 stage 發生，改到你滿意為止 |
| 3 | `/to-spec` | 把拍板的結果凍成規格＋design tokens（色彩、字體、間距的唯一真相源）。之後所有頁面都吃這份 tokens，不會頁頁長得不一樣 |
| 4 | `/to-architecture` | 決定跨頁面的邊界：部署方式、表單送到哪、要不要 CMS。每個決策留一份 ADR（含被否決的方案與理由） |
| 5 | `/to-ticket` | 把規格切成一張張可獨立完成的票（首頁、關於頁、聯絡表單…） |
| 6 | `/implement` | 逐票實作。UI 只准引用第 3 步的 tokens，不准另外發明顏色 |
| 7 | `/code-review` | 雙軸審查：程式碼品質＋是否符合規格；因為有 UI，加跑對比度等實測 gates |
| 8 | `/ship` | 上線前總關卡：測試、changelog、部署步驟 |

#### 情境二：「我想做一個 CRM」（大型、多模組）

| 步驟 | 你打的指令 | 目的／會發生什麼 |
|---|---|---|
| 1 | `/grill-me 我想做一個業務用的 CRM` | 訪談會先框範圍：有哪些模組（客戶、商機、報表）？誰在用？先做哪一塊？拍板出第一期範圍 |
| 2 | `/domain-modeling` | CRM 名詞最容易混亂（「客戶」是公司還是聯絡人？）。先把詞彙表定死，欄位命名、畫面文案、API 全部同源 |
| 3 | `/prototype` | 挑最核心的一兩個畫面（如商機看板）做互動原型，定調視覺與操作感 |
| 4 | `/to-spec` | 第一期範圍寫成規格：每個流程含成功／失敗／恢復三條路徑 |
| 5 | `/to-architecture` | 大專案的重頭戲：資料模型、模組邊界、API 契約。全部落成 ADR＋機器可驗的 schema——半年後問「當初為什麼這樣切」，答案在 `docs/decisions/` |
| 6 | `/to-ticket` | 切票，且票不得橫跨剛畫下的模組邊界 |
| 7 | `/implement` | 逐票實作，邏輯測試先行 |
| 8 | `/code-review` → `/ship` | 審查、上線第一期 |
| 9 | 回到 `/grill-me 第二期做報表模組` | 大專案就是這樣一輪一輪滾：一個模組一輪，上一輪的觀測是下一輪的證據 |

#### 情境三：小改動、會動到畫面

| 步驟 | 你打的指令 | 目的／會發生什麼 |
|---|---|---|
| 1 | `/grill-me 訂單列表加一個匯出按鈕` | 訪談只剩兩三題：放哪裡？匯什麼格式？一分鐘拍板完 |
| 2 | `/prototype` | 因為**動到畫面**，這個 stage 出場：按鈕位置、hover 效果做成 HTML 給你看過才定案 |
| 3 | `/to-spec` | 小票的規格也小：按鈕的狀態表（平常／滑過／按下／處理中）＋無障礙條件，幾行而已 |
| 4 | `/to-architecture` | AI 明講：「**此票不跨模組邊界，跳過**」。你直接打下一個 stage |
| 5 | `/to-ticket` → `/implement` | 一張票，直接做 |
| 6 | `/code-review` | 因為動了 UI，除了程式碼審查，加跑設計驗收：對比度實測、每個狀態檢查 |
| 7 | `/ship` | 上線 |

#### 情境四：小改動、不動畫面

| 步驟 | 你打的指令 | 目的／會發生什麼 |
|---|---|---|
| 1 | `/grill-me 匯出改成背景處理完寄 email` | 訪談重點在行為：多久算逾時？失敗要通知誰？ |
| 2 | `/prototype` | AI 明講：「**此票無畫面，跳過 prototype**」。直接下一個 stage |
| 3 | `/to-spec` | 規格寫清楚三條路徑：成功（信寄到）／失敗（寄不出去）／**恢復**（怎麼自動重試、使用者怎麼手動重寄） |
| 4 | `/to-architecture` | 這票**有**架構決策（背景任務用什麼佇列？），出 ADR。若判斷不用，AI 也會明講跳過 |
| 5 | `/to-ticket` → `/implement` | 切票實作，測試先行（/tdd） |
| 6 | `/code-review` | 只跑程式碼軸，設計項明講略過 |
| 7 | `/ship` | 上線 |

四個情境的共同點：**指令永遠是同樣八個、同樣順序**；差別只在每個 stage 的
份量——大專案每個 stage 都重，小票有些 stage 被明講跳過。所以不用背哪些情境
用哪些 stage，照順序打，AI 會告訴你這個 stage 要做事還是讓路。

### 第二部分：進階說明

#### 環境全貌：六個元件、三層分工

```
┌─ 全域層（裝一次，處處生效）──────────────────────────┐
│  pilotfish          多模型編排：規劃/執行/驗證分工      │
│  Delivery Pipeline  八個 stage 工作流（本 repo 原創）          │
├─ plugin 層（marketplace 安裝）───────────────────────┤
│  Matt Pocock skills TDD、除錯、code review、領域建模    │
│  Karpathy 準則      LLM 編程缺陷矯正                    │
├─ 專案層（每專案安裝）────────────────────────────────┤
│  code-review-graph  程式碼知識圖，AI 只讀相關檔案       │
│  ux-ui-agent-skills 設計系統知識庫＋WCAG 驗證 gates     │
└──────────────────────────────────────────────────────┘
```

核心哲學：**流程與知識分離**——Matt 的 skills 是工作方法（怎麼問、
怎麼驗證、怎麼審），ux-ui kit 是領域知識（設計怎麼做對），
pilotfish 決定誰來做（貴模型判斷、便宜模型跑量、獨立驗證把關），
Delivery Pipeline 是把三者接起來的那條線。

#### 協作地圖：UI/UX 與前後端怎麼交接

這條 pipeline 存在的目的：讓設計、前端、後端**靠契約產物協作**，
而不是靠記憶或聊天紀錄。每個工種交接處都有一份機器可驗的產物，
契約一旦成立，工作就能平行：

```
  UX／設計                        前端              後端
  /prototype（外觀手感）─┐
  flow 三段（行為）      ─┤
                         ├─ /to-spec ──→ tokens＋元件規格
                         │                  │ 前端消費
                         └─ /to-architecture ──→ API 契約（schema）
                                            │ 前後端都照它寫
  /implement：前端與後端對著契約「平行」開發，誰都不等誰的程式碼
  /code-review：任何一側偏離契約，審查直接擋下
```

四條交接規則：

- **設計 → 前端**：tokens 與元件規格就是介面。前端不准自己發明視覺值，
  缺了退回 /to-spec，不准硬編碼
- **後端 ↔ 前端**：API 契約就是介面。前端對著 schema 做假資料先開工，
  後端照 schema 實作；要改契約＝開新的架構決策（ADR 取代），
  不准在單邊程式碼裡偷改
- **UX → 前後端**：規格的 flow 三段（成功／失敗／恢復）同時約束
  畫面狀態與 API 錯誤語意——錯誤畫面和錯誤回應是同一條 flow 的
  兩面，不是兩個人各自發明
- **產品 → 所有人**：埋點小節把事件命名一次；前端發、後端收、
  審查驗它存在

#### 各 stage 規則

| Stage | 職責 | 關鍵規則 |
|---|---|---|
| **/grill-me** | 逐題訪談、每題附推薦答案、逐項拍板 | 新領域先跑 /domain-modeling 定詞彙表；上線觀測是下一輪的證據 |
| **/prototype*** | 可互動 HTML 原型，把玩後再定案 | 先宣告原型要回答什麼問題；數字一律實測；候選值還不是 token |
| **/to-spec** | 定案寫成規格 | **設計系統唯一寫入 stage**：tokens 與元件規格只在此出生；flow 三段（success/failure/recovery）；埋點小節；改既有 token 必附影響分析 |
| **/to-architecture*** | 架構決策 | 模組邊界委派 /codebase-design 思考，本 stage 記錄 ADR＋機器可驗 contract |
| **/to-ticket** | 切票 | 票不得橫跨剛畫下的架構邊界 |
| **/implement** | 實作 | 邏輯走 /tdd；UI 只消費既定 tokens、不硬編碼；共用元件附狀態 harness |
| **/code-review** | 雙軸審查 | Standards＋Spec；動過 UI 加跑 WCAG gates＋親眼渲染檢查 |
| **/ship** | 上線關卡 | 上線後觀測落檔 docs/research/ 回流 /grill-me——改善不是 stage，是路由 |

#### 三條常備規則

1. **元件晉升制**：pattern 第二次跨頁出現才晉升共用元件庫；
   禁猜測性抽象
2. **設計文件四層**：tokens（值）→ 元件規格（積木）→ foundations
   （怎麼砌）→ flows（怎麼連）；只有前兩層不算設計系統
3. **產物位置**：工具鏈可達的進 `packages/`；誰都不 import 的進 `docs/`

### 第三部分：Skill 總覽

環境裝好後你擁有的所有 skills，當索引查閱（主流程八個 stage 見上，不重列）：

#### Matt Pocock skills（工作方法）

| Skill | 用途 |
|---|---|
| `/grill-me`（grilling） | 逐題訪談拍板，主流程第一個 stage |
| `/tdd` | 測試先行的紅綠燈開發，/implement 掛載 |
| `/prototype` | 拋棄式原型答設計問題，主流程第二個 stage的思路來源 |
| `/domain-modeling` | 建立專案詞彙表（統一語言） |
| `/codebase-design` | 深模組設計：介面切分、seam 位置，被 /to-architecture 委派 |
| `/code-review` | Standards＋Spec 雙軸審查，主流程第七個 stage |
| `/research` | 對高信任來源做調查並落檔（事件驅動） |
| `/diagnosing-bugs` | 困難 bug 的診斷循環（事件驅動） |
| `/resolving-merge-conflicts` | 處理 merge/rebase 衝突（事件驅動） |

#### 本 repo（install.sh 裝進個人 skills）

| Skill | 用途 |
|---|---|
| `/delivery-pipeline` | 八個 stage 的完整規則所在——CLAUDE.md 只放指標，執行任何 stage 指令前 AI 會載入它 |
| `/to-architecture` | 架構決策 stage：記錄 ADR 與 contract，主流程第四個 stage |

#### Karpathy 準則

| Skill | 用途 |
|---|---|
| `karpathy-guidelines` | 寫碼時常駐：外科手術式修改、假設外顯、簡潔優先 |

#### ux-ui-agent-skills（設計知識，UI 專案）

| Skill | 用途 |
|---|---|
| `/design-tokens` | 生成／驗證 DTCG 三層 design tokens |
| `/brandkit` | 從品牌簡報生成整套可驗證的設計基礎 |
| `/design-component` | 元件規格書：anatomy、8 狀態、token 對照、a11y |
| `/design-code` | 元件規格轉任意框架的程式碼 |
| `/design-review` | 六維度設計評分＋Nielsen 十原則 |
| `/design-qa` | 設計品質 CI gates 與視覺回歸 |
| `/a11y-audit` | WCAG 2.2 稽核＋對比度實測 |
| `/apply-aesthetic` | 套用 138 套具名設計系統的視覺方向 |
| `/image-to-code` | 參考截圖轉成符合 tokens 的程式碼 |
| `/redesign` | 既有 UI 的審計式升級 |
| `/migrate-design-system` | 與 Material 3／HIG／shadcn 等互轉 |
| `/prototype` | 五階保真度的原型方法 |
| `/ux-writing` | 介面文案：錯誤訊息、空狀態、微文案 |
| `/token-build` | tokens 編譯成 CSS／Tailwind／iOS／Android |
| `/figma-integration` | tokens 與 Figma Variables 同步 |
| `/governance` | 設計系統版本治理（SemVer、晉升、棄用） |
| `/performance` | Core Web Vitals 與動畫效能 |
| `/gate` | 一鍵跑全部驗證 gates，回報真實 N/N |
| `/ship` | 上線前總關卡，主流程第八個 stage |

#### code-review-graph（MCP tools）

| 工具 | 用途 |
|---|---|
| explore-codebase | 按知識圖導航理解程式碼 |
| review-changes | 沿引用鏈精準審查變更影響面 |
| refactor-safely | 重構前掃出所有受影響點 |
| debug-issue | 循圖追蹤 bug 根因 |

---

## Repo 結構

```
├── README.md               ← 本文（教學＋入口）
├── SETUP.md                ← 給 AI 讀的安裝手冊
├── install.sh              ← 檔案層安裝（冪等、自動備份）
├── claude-md-blocks/       ← 全域 CLAUDE.md 區塊模板
├── skills/                 ← 八個 stage 總綱＋to-architecture（裝進 ~/.claude/skills/）
└── PLAN.md                 ← 維護者交接文件
```

## License

MIT（僅涵蓋本 repo 原創內容；第三方元件依其各自授權，本 repo 不重新分發）。
