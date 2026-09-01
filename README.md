# Psyflow

從零開始建立一套完整、可複製的 Claude Code 工作環境——從訂閱、安裝，
到一條把需求做到上線的 **八個 stage 的 Psyflow 交付流程**
（裝成 plugin 後以 `/psyflow:discover` 這類命名空間指令驅動）。
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
8. [安裝 Orca](#八安裝-orca)
9. [安裝本 repo](#九安裝本-repo)
10. [開始新專案](#十開始新專案)
11. [工作流教學](#十一工作流教學)

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

## 八、安裝 Orca

[Orca](https://github.com/stablyai/orca)（MIT）是跑 coding agent 的桌面
駕駛艙：多個 agent 各自在獨立 git worktree 並行工作、集中追蹤，內建
終端機、瀏覽器與手機 companion。本工作流把它當預設工作環境——之後
每一節的終端機操作都直接在 Orca 裡做。

### 1. 安裝桌面 app

到 <https://onorca.dev/download> 下載安裝（macOS／Windows／Linux 都有）。
app 會自動更新，不用手動追版本。

### 2. 裝正體中文語言包

Orca 介面預設英文，裝
[orca-traditional-chinese](https://github.com/a-lang/orca-traditional-chinese)
語言包（台灣用語、人工審校，覆蓋率 99.98%）：

1. Settings → Plugins → **Add marketplace source**，貼上
   Git URL `https://github.com/a-lang/orca-traditional-chinese.git`
   （ref 填 `main`）
2. marketplace 清單出現 **Traditional Chinese Language Pack**，按安裝
3. Settings → Appearance → Language 選「**繁體中文（台灣）**」

### 驗證

開一個 Orca 終端機執行：

```bash
orca status
```

有正常輸出（不是 command not found）、且介面已是繁中，即完成。

## 九、安裝本 repo

前面備齊後，裝這套工作環境本體。

### 1. 首次啟動與登入

打開終端機（Windows 用 PowerShell，建議直接用 Orca 的終端機），執行：

```bash
claude
```

第一次啟動會自動開瀏覽器做 OAuth 登入（登入第一節訂閱的帳號）；
瀏覽器沒開就按 `c` 複製登入網址。看到 `Login successful` 即完成。

### 2. 讓 Claude 幫你裝

登入後，把這句話貼進 Claude Code：

> 請讀取 https://github.com/miki519/psyflow 的 SETUP.md，照它配置我的環境。

你的 Claude 會自己下載 repo、執行安裝、引導你完成 plugin 步驟
（psyflow 本體、Matt Pocock skills 與 Karpathy 準則，`/plugin` 是互動指令、要你自己貼）、
再帶你裝 pilotfish（它有自己的安裝流程：AI 讀上游 runbook、
列出要改哪些檔、**你核准後才寫入**），最後回報驗收清單。

### 驗證過的版本組合

社群 marketplace 預設**不自動更新**，你裝到的就是驗證過的環境：

| 元件 | 驗證版本 | 日期 |
|---|---|---|
| mattpocock-skills | 1.2.3 | 2026-08 |
| andrej-karpathy-skills | 1.0.0 | 2026-07 |
| ux-ui-agent-skills | 2.5.1 | 2026-08 |
| uipro-cli（ui-ux-pro-max，選配） | 2.2.3 | 2026-08 |
| pilotfish | 1.3.5 | 2026-07 |
| psyflow（本 repo，plugin） | 2.1.0 | 2026-08 |

### 更新這套環境

所有元件都**不會自動更新**——這是特性：你的環境保持在驗證過的
版本組合，不會一覺醒來行為變了。想更新時，把這句話貼進 Claude Code：

> 請讀取 https://github.com/miki519/psyflow 的 SETUP.md，照它更新我的環境。

AI 會拉最新版、重跑安裝、引導你完成 plugin 更新；動到你自訂的內容前
會先警告，完成後回報更新了什麼。

## 十、開始新專案

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

打工作流的第 0 個 stage：

```
/setup
```

AI 會安裝設計知識庫（UI 專案；選裝風格檢索引擎）與程式碼知識圖，
開始前先檢查 `node` 與 `npx`，缺什麼先補齊；任何指令失敗會診斷解決
而不是跳過，完成後回報結果。
裝完就可以直接開工（見下一節）。

## 十一、工作流教學

### 第一部分：基礎用法

先記住一件事：**每個 stage 就是一個斜線指令，做完一個 stage 打下一個**。
不用背，AI 每做完一個 stage 會告訴你下一個是什麼；跟著四個情境操作一遍就會了。

```
/setup → /discover → /design* → /spec → /tickets → /build → /accept → /release
```

- `/setup` 一個專案只做一次（第十節做過就不用再做）；之後每一輪功能
  都從 `/discover` 開始。
- `*`＝條件 stage：不動畫面時 AI 會在 `/discover` 結尾明講「跳過
  /design」，你直接打 `/spec` 即可。
- `/accept` 只驗收不部署；`/release` 一定要驗收通過才能跑。

這條流程存在的理由：讓 UI/UX、前端、後端透過**契約工件**協作,
而不是靠記憶或聊天紀錄——

```
  UX / design                      frontend            backend
  /design (look & feel)  ─┐
  scenario section (GWT) ─┤
                          ├─ /spec ──→ tokens + component specs
                          │              │ consumed by frontend
                          └─ /spec (to-architecture) ──→ API contract
                                         │ coded against by BOTH
  /build:  frontend and backend build IN PARALLEL against the contracts
  /accept: contract drift fails acceptance on either side
```

#### 情境一：「我想做一個官網」（大型、從零開始）

**流程：`/setup` → `/discover` → `/design` → `/spec` → `/tickets` → `/build` → `/accept` → `/release`（全程）**

| 步驟 | 你打的指令 | 目的／會發生什麼 |
|---|---|---|
| 1 | `/setup` | 初始化專案工具（設計知識庫＋程式碼知識圖）。一個專案只做一次 |
| 2 | `/discover 我想做一個公司官網` | AI 逐題訪談（受眾？頁面清單？品牌色？），每題附推薦答案，你逐項拍板。新領域它會先建**詞彙表**，讓之後的文案與程式碼用同一套名詞。結尾宣告：「這案子動畫面，下一步 /design」 |
| 3 | `/design` | 把首頁做成**可互動的 HTML** 給你玩。目的：「看得到之前，訪談問不出真需求」——「顏色太濃」「改大圓角」這種回饋就在這個 stage 發生；對比度等數字一律實測。改到你滿意為止 |
| 4 | `/spec` | 把前兩步的拍板彙整重述一次，你**再確認**後才凍成規格＋design tokens（色彩、字體、間距的唯一真相源）。跨邊界的架構決策（部署方式、表單送到哪、要不要 CMS）也在這一步落成 ADR |
| 5 | `/tickets` | 把規格切成一張張可獨立完成的票（首頁、關於頁、聯絡表單…） |
| 6 | `/build` | 逐票實作。UI 只准引用第 4 步的 tokens，不准另外發明顏色 |
| 7 | `/accept` | 驗收：程式碼雙軸審查＋因為有 UI 加跑對比度等實測 gates＋獨立驗證。**只驗收、不部署** |
| 8 | `/release` | 先部署**測試環境**（staging）→ 你在測試環境確認 → 再上**正式環境**（production） |

#### 情境二：「我想做一個 CRM」（大型、多模組）

**流程：全程八個 stage，一個模組一輪，做完回 `/discover` 滾下一輪**

| 步驟 | 你打的指令 | 目的／會發生什麼 |
|---|---|---|
| 1 | `/setup` | 初始化專案工具，一次 |
| 2 | `/discover 我想做一個業務用的 CRM` | 訪談先框範圍：有哪些模組（客戶、商機、報表）？誰在用？先做哪一塊？CRM 名詞最容易混亂（「客戶」是公司還是聯絡人？），訪談中會先把**詞彙表**定死，欄位命名、畫面文案、API 全部同源 |
| 3 | `/design` | 挑最核心的一兩個畫面（如商機看板）做互動原型，定調視覺與操作感 |
| 4 | `/spec` | 第一期範圍凍成規格：每個流程含成功／失敗／恢復三條路徑。大專案的重頭戲在這：資料模型、模組邊界、API 契約全部落成 ADR＋機器可驗的 schema——半年後問「當初為什麼這樣切」，答案在 `docs/decisions/` |
| 5 | `/tickets` | 切票，且票不得橫跨剛畫下的模組邊界；票一多（五張以上）會先做一次獨立的計畫審視再開工 |
| 6 | `/build` | 逐票實作，邏輯測試先行 |
| 7 | `/accept` → `/release` | 驗收通過後，staging → 確認 → production，上線第一期 |
| 8 | 回到 `/discover 第二期做報表模組` | 大專案就是這樣一輪一輪滾：一個模組一輪，上一輪的觀測是下一輪的證據 |

#### 情境三：小改動、會動到畫面

**流程：`/discover` → `/design` → `/spec` → `/tickets` → `/build` → `/accept` → `/release`（/setup 做過就不用）**

| 步驟 | 你打的指令 | 目的／會發生什麼 |
|---|---|---|
| 1 | `/discover 訂單列表加一個匯出按鈕` | 訪談只剩兩三題：放哪裡？匯什麼格式？一分鐘拍板完。結尾宣告：「動到畫面，下一步 /design」 |
| 2 | `/design` | 按鈕位置、hover 效果做成 HTML 給你看過才定案 |
| 3 | `/spec` | 小票的規格也小：按鈕的狀態表（平常／滑過／按下／處理中）＋無障礙條件，幾行而已。AI 判斷不跨模組邊界，架構決策明講跳過 |
| 4 | `/tickets` → `/build` | 一張票，直接做 |
| 5 | `/accept` | 因為動了 UI，除了程式碼審查，加跑設計驗收：對比度實測、每個狀態檢查 |
| 6 | `/release` | staging → 確認 → production |

#### 情境四：小改動、不動畫面

**流程：`/discover` → `/spec` → `/tickets` → `/build` → `/accept` → `/release`（明講跳過 /design）**

| 步驟 | 你打的指令 | 目的／會發生什麼 |
|---|---|---|
| 1 | `/discover 匯出改成背景處理完寄 email` | 訪談重點在行為：多久算逾時？失敗要通知誰？結尾宣告：「**此票無畫面，跳過 /design**，下一步 /spec」 |
| 2 | `/spec` | 規格寫清楚三條路徑：成功（信寄到）／失敗（寄不出去）／**恢復**（怎麼自動重試、使用者怎麼手動重寄）。這票**有**架構決策（背景任務用什麼佇列？），出 ADR |
| 3 | `/tickets` → `/build` | 切票實作，測試先行（tdd） |
| 4 | `/accept` | 只跑程式碼軸，設計項明講略過 |
| 5 | `/release` | staging → 確認 → production |

#### 情境五：把既有專案接上這套流程

**流程：`/setup` → `/discover`（之後照常）**

| 步驟 | 你打的指令 | 目的／會發生什麼 |
|---|---|---|
| 1 | 在專案根目錄 `claude` → `/setup` | 既有專案一樣只做一次：建程式碼知識圖（`code-review-graph build`），UI 專案加裝設計知識庫。之後 AI 讀碼走圖、只讀相關檔案 |
| 2 | `/discover 我想幫這個系統加會員等級` | 訪談會先用知識圖**摸清現況**（現在的會員模型長怎樣？哪些畫面會受影響？），問題釘在真實程式碼上，不是憑空發散 |
| 3 | 之後照常 | /design*（動畫面才有）→ /spec（改既有 token／元件要走 governance 影響分析）→ 照常往下 |

#### 情境六：線上出包，緊急修復（逃生門）

**流程：`/diagnosing-bugs` → 修好 → `/accept` → `/release`（明講跳過 /discover ～ /tickets）**

| 步驟 | 你打的指令 | 目的／會發生什麼 |
|---|---|---|
| 1 | `/diagnosing-bugs 結帳按鈕全部沒反應` | 事件驅動引擎直接進診斷循環：重現 → 定位根因 → 最小修復。**不走** /discover～/tickets——bug 不是新需求，沒東西好訪談 |
| 2 | `/accept` | 縮小版驗收：只驗「這個修復」——bug 不再重現＋沒改壞別的。仍然不准跳過：改壞別的東西上線更慘 |
| 3 | `/release` | 照常兩段式：staging 確認 → production。**再急也走 staging**，這正是最不能盲上的時刻 |
| 4 | 事後（可選） | 根因若暴露了設計缺陷（例如缺監控、錯誤處理缺路徑），開 `/discover` 補一輪正式的——逃生門解決火災，不解決火源 |

#### 情境七：做到一半，需求要改

**流程：小改回 `/spec` 重凍結；大改中止本輪、開新的 `/discover`**

| 狀況 | 你打的指令 | 目的／會發生什麼 |
|---|---|---|
| 小改（不跨架構邊界）：/build 做到一半想把匯出格式從 CSV 換成 Excel | `/spec 匯出格式改成 xlsx` | 回唯一有權改規格的 stage：更新凍結內容（動到既有 token／元件走 governance），受影響的票重切，沒受影響的照做。**不准**在 /build 裡口頭改——凍結的意義就是不讓「聊天中順口改的」變成規格 |
| 大改（範圍或邊界變了）：做官網做到一半決定要加會員系統 | `/discover 官網要加會員系統` | 這不是修改、是新需求：開新一輪。上一輪已凍結的規格與 ADR 是這一輪的既有事實，訪談會在其上發問 |

#### 情境八：還沒決定要不要做，先調研

**流程：`/research`（事件驅動）→ 有結論才進 `/discover`**

| 步驟 | 你打的指令 | 目的／會發生什麼 |
|---|---|---|
| 1 | `/research 比較 LINE Pay 和綠界的金流手續費與串接難度` | 對高信任來源調查、落檔進 `docs/research/`。**還不進 pipeline**——沒有要交付的東西，就不啟動交付流程 |
| 2 | 決定要做了 | `/discover 串綠界金流`——調研落的檔就是訪談的現成證據，不用重查 |
| 2' | 決定不做 | 什麼都不用打。調研檔留著，半年後重提時證據還在 |

八個情境的共同點：**做新東西永遠從 /discover 進；規格要變永遠回
/spec；緊急修復走逃生門，但 /accept → /release 的關卡誰都不跳**。
指令同樣八個、同樣順序、永遠由你打下一個；差別只在每個 stage 的
份量——大專案每個 stage 都重，小票有些 stage 被明講跳過。不確定該打
什麼的時候，打 `/discover` 永遠不會錯——它會替你路由。

### 第二部分：進階說明

#### 環境全貌：六個元件、三層分工

```
┌─ 全域層（裝一次，處處生效）──────────────────────────┐
│  pilotfish          多模型編排：規劃/執行/驗證分工      │
│  psyflow 指標塊     CLAUDE.md 薄指標＋工具慣例          │
├─ plugin 層（marketplace 安裝）───────────────────────┤
│  Psyflow 流程       八個 stage 交付流（本 repo 原創）   │
│  Matt Pocock skills TDD、除錯、code review、領域建模    │
│  Karpathy 準則      LLM 編程缺陷矯正                    │
├─ 專案層（每專案安裝）────────────────────────────────┤
│  code-review-graph  程式碼知識圖，AI 只讀相關檔案       │
│  ux-ui-agent-skills 設計系統知識庫＋WCAG 驗證 gates     │
│  ui-ux-pro-max      風格／配色檢索引擎（選配）           │
└──────────────────────────────────────────────────────┘
```

核心哲學：**流程與知識分離**——Matt 的 skills 是工作方法（怎麼問、
怎麼驗證、怎麼審），ux-ui kit 是領域知識（設計怎麼做對），
pilotfish 決定誰來做（貴模型判斷、便宜模型跑量、獨立驗證把關），
Psyflow 流程是把三者接起來的那條線：它站在「產品發想者＋PM＋
全端工程師」的視角定義每個 stage 要產出什麼、該調用哪些成熟 skill
當引擎。

#### 協作地圖：UI/UX 與前後端怎麼交接

這條 pipeline 存在的目的：讓設計、前端、後端**靠契約產物協作**，
而不是靠記憶或聊天紀錄。每個工種交接處都有一份機器可驗的產物，
契約一旦成立，工作就能平行：

```
  UX／設計                        前端              後端
  /design（外觀手感）  ─┐
  flow 三段（行為）     ─┤
                        ├─ /spec ──→ tokens＋元件規格
                        │              │ 前端消費
                        └─ /spec（架構決策）──→ API 契約（schema）
                                       │ 前後端都照它寫
  /build：前端與後端對著契約「平行」開發，誰都不等誰的程式碼
  /accept：任何一側偏離契約，驗收直接擋下
```

四條交接規則：

- **設計 → 前端**：tokens 與元件規格就是介面。前端不准自己發明視覺值，
  缺了退回 /spec，不准硬編碼
- **後端 ↔ 前端**：API 契約就是介面。前端對著 schema 做假資料先開工，
  後端照 schema 實作；要改契約＝開新的架構決策（ADR 取代），
  不准在單邊程式碼裡偷改
- **UX → 前後端**：規格的 flow 三段（成功／失敗／恢復）同時約束
  畫面狀態與 API 錯誤語意——錯誤畫面和錯誤回應是同一條 flow 的
  兩面，不是兩個人各自發明
- **產品 → 所有人**：埋點小節把事件命名一次；前端發、後端收、
  審查驗它存在

#### 各 stage 規則與引擎

每個 stage 由 psyflow 流程定義「產出什麼」，實際做事時調用成熟的
skill 當**引擎**（怎麼問、怎麼驗、怎麼審都歸引擎的 skill 管）：

| Stage | 職責 | 主要引擎 | 關鍵規則 |
|---|---|---|---|
| **/setup** | 專案初始化（一次） | ux-ui kit、code-review-graph | 設計品質 CI（design-qa）是基礎設施，開成流程外的 infra 票 |
| **/discover** | 需求拷問：發散→收斂、逐項拍板 | grilling；domain-modeling（新領域）；research（要證據）；explore-codebase（既有專案） | 唯一入口；丟參考圖時 AI 判斷是「功能參考」還是「畫面參考」；結尾宣告下一步（動畫面→/design；純邏輯→跳過 /design） |
| **/design*** | 可互動 HTML 原型，把玩後定稿 | ui-ux-pro-max（選配，先檢索風格／配色候選）→ apply-aesthetic 收斂方向；prototype（Matt 命題＋kit 保真度階梯）；design-tokens 試值；條件：brandkit／redesign／ux-writing／a11y-audit | 數字一律實測（gates）；候選值還不是 token；design-review 只用在大畫面 |
| **/spec** | 彙整前兩步→再確認→凍結 | design-tokens 固化；design-component（8 狀態規格）；to-architecture（跨邊界時，委派 codebase-design 出 ADR＋contract）；ux-writing 吃詞彙表；governance（改既有 token／元件） | **設計系統唯一寫入 stage**；flow 三段（success/failure/recovery）；埋點小節；改既有 token 必附影響分析 |
| **/tickets** | 切票 | explore-codebase（影響面） | 票不得橫跨剛畫下的架構邊界；五張以上先做獨立計畫審視 |
| **/build** | 逐票實作 | tdd（邏輯）；design-code（UI）；karpathy 準則常駐；token-build；refactor-safely | UI 只消費既定 tokens、缺了退回 /spec、不硬編碼；埋點跟功能一起做；共用元件附狀態 harness |
| **/accept** | 驗收（不部署） | code-review（雙軸）；review-changes；動過 UI：gates＋design-review＋親眼渲染檢查；條件：a11y-audit／performance | 產出驗收報告；最後做一次獨立驗證；通過才准 /release |
| **/release** | 兩段式上線 | Docker；上線前 checklist | 前置條件＝驗收通過；先 staging → 你確認 → 才 production；上線後觀測落檔 docs/research/ 回流 /discover——改善不是 stage，是路由 |

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
| `/grill-me`（grilling） | 逐題訪談拍板，/discover 的核心引擎 |
| `/tdd` | 測試先行的紅綠燈開發，/build 掛載 |
| `/prototype` | 拋棄式原型答設計問題，/design 的命題引擎 |
| `/domain-modeling` | 建立專案詞彙表（統一語言），/discover 在新領域時調用 |
| `/codebase-design` | 深模組設計：介面切分、seam 位置，在 /spec 內被 to-architecture 委派 |
| `/code-review` | Standards＋Spec 雙軸審查，/accept 的核心引擎 |
| `/research` | 對高信任來源做調查並落檔（事件驅動） |
| `/diagnosing-bugs` | 困難 bug 的診斷循環（事件驅動） |
| `/resolving-merge-conflicts` | 處理 merge/rebase 衝突（事件驅動） |
| `/wizard` | 遇到只有人能做的步驟（憑證、CI secrets、dashboard 操作）時，生成互動式精靈腳本帶人完成，秘密值不經過對話（事件驅動，任何 stage 都可能觸發） |
| `/to-questionnaire` | 答案在第三方（客戶、領域專家）手上的 open question，轉成問卷文件落在 `docs/research/`，/discover 掛載（僅手動） |

#### 本 repo（psyflow plugin）

| Skill／指令 | 用途 |
|---|---|
| `psyflow`（skill） | 八個 stage 的完整規則所在——CLAUDE.md 只放指標，執行任何 stage 指令時 AI 會先載入它 |
| 八個 stage 指令 | `/psyflow:setup` `/psyflow:discover` `/psyflow:design` `/psyflow:spec` `/psyflow:tickets` `/psyflow:build` `/psyflow:accept` `/psyflow:release`——plugin 帶入的薄指令，各自載入 psyflow skill 執行對應 stage |
| `to-architecture`（skill） | 架構決策引擎：記錄 ADR 與 contract，在 /spec 內被調用 |

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
| `/prototype` | 五階保真度的原型方法，/design 的保真度引擎 |
| `/ux-writing` | 介面文案：錯誤訊息、空狀態、微文案 |
| `/token-build` | tokens 編譯成 CSS／Tailwind／iOS／Android |
| `/figma-integration` | tokens 與 Figma Variables 同步 |
| `/governance` | 設計系統版本治理（SemVer、晉升、棄用） |
| `/performance` | Core Web Vitals 與動畫效能 |
| `/gate` | 一鍵跑全部驗證 gates，回報真實 N/N，/accept 掛載 |
| `/ship` | 上線前總關卡 checklist，/release 部署前調用 |

#### ui-ux-pro-max（風格檢索，UI 專案選配）

| Skill | 用途 |
|---|---|
| `ui-ux-pro-max` | 可查詢的設計方向資料庫（styles／palettes／字型配對／UX 準則），/design 開頭先檢索候選再交 apply-aesthetic 收斂；`--persist` 落檔 `design-system/<slug>/MASTER.md`。無 QA gates——驗證仍歸 ux-ui kit |

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
├── install.sh              ← 檔案層安裝：CLAUDE.md 區塊＋CLI（冪等、自動備份）
├── .claude-plugin/         ← plugin.json＋marketplace.json（repo 即 marketplace）
├── claude-md-blocks/       ← 全域 CLAUDE.md 區塊模板
├── skills/                 ← psyflow 流程總綱＋to-architecture（隨 plugin 安裝）
├── commands/               ← 八個 stage 指令（隨 plugin 安裝，帶 psyflow: 命名空間）
└── PLAN.md                 ← 維護者交接文件
```

## License

MIT（僅涵蓋本 repo 原創內容；第三方元件依其各自授權，本 repo 不重新分發）。
