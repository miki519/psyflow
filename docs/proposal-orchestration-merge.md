# 提案：把編排層收編進 psyflow（v2.2.0）

日期：2026-09-26
狀態：角色已拍板並落地（2026-09-26：scout＋Explore 合併為一隻 scout、
其餘六隻全留；`agents/` 七檔已建立，附 MIT 出處與 PILOTFISH-LICENSE）。
剩一個開放決策：政策注入方式 A / B。

## 背景

- pilotfish v1.3.8 舊版全域安裝已於 2026-09-25 完整移除（備份在
  `~/.claude/backups/pilotfish-global-20260925-204255/`），目前全域環境
  **沒有任何編排政策**，直到本提案落地並安裝 psyflow 新版。
- 決策：不安裝 upstream 的 1.4.1 plugin，改為按其思路把編排層直接寫進
  psyflow plugin，upstream repo 僅作參考。
- 授權：pilotfish 為 MIT（© 2026 Nanako0129），改作合法，需保留出處聲明。
- 依據：兩份 prompt audit 的結論——本 session 對 Orchestration 區塊的
  逐段分析，加上另一 session（boss-a9）對 `~/.claude` 的 audit 報告
  （發現 M1–M4、L1–L4）。

## 新增內容（全部隨 `/plugin install psyflow@psyflow` 散佈）

### 1. `agents/` — 八個角色定義

plugin 原生支援 agents 目錄。以 pilotfish v1.3.8 的八個檔為底
（scout、Explore、executor、mech-executor、verifier、plan-verifier、
security-reviewer、security-executor），套用 audit 已確認的修正：

| 檔案 | 修正 | 來源 |
|---|---|---|
| scout.md | 「under ~20 lines」數字上限 → 「只回 orchestrator 下一步決策需要的事實，不倒檔案」 | M4（數字上限截斷長答案） |
| security-executor.md | 刪掉寫給分派者看的 Opus 路由理由句（前提在新模型上可能已不成立） | M1 |
| Explore.md | 版本號決策紀錄（"since Claude Code v2.1.198…"）→ 搬到 frontmatter 的 YAML 註解 | M3（fossil） |
| scout.md / Explore.md | haiku 搭配 `effort: low` 是無效設定 → 刪 | L2（Haiku 4.5 不支援 effort） |

### 2. 編排政策的注入方式（待拍板）

| 方案 | 做法 | 取捨 |
|---|---|---|
| **A. SessionStart hook 注入**（推薦） | plugin 帶 hook，每個 session 自動注入政策；實作參考 upstream 1.4.1 | 裝了就生效、零手動步驟；hook 屬 plugin 一級機制 |
| B. claude-md block | 沿用 `claude-md-blocks/` 模式，SETUP 時寫進全域 CLAUDE.md | 機制簡單；但安裝回到手動核准合併的老路 |

### 3. 政策內容瘦身（不是照抄）

按 audit 結論重寫，估計比原版精簡三到四成：

**刪除**：
- baton-dispatch 整段（引用未安裝的 skill，每 session 白讀 ~115 字）
- 已被 harness 原生覆蓋的段落：背景 agent 完成通知與收結果規則、
  worktree 隔離機制說明、平行排程基本規則（Agent tool 說明已內建）
- 格式錯誤的 Markdown 表格分隔列（3 欄表頭配 2 欄分隔）

**保留（方法論骨幹，harness 沒有）**：
- 角色經濟學：便宜模型跑量、主 session 保留判斷、兩次失敗才升級
- Plan envelope + 可獨立核准的 slices
- 風險觸發的強制獨立驗證（plan-verifier readiness、verifier outcome）
- READY/REVISE 與 CONFIRMED/REFUTED/INCONCLUSIVE 輸出合約
- security 工作的專用通道（reviewer 先行、executor 後上）
- AUTO/ASK 長時自主模式宣告
- 五輪驗證預算與 PAUSED_VERIFICATION 機制

**保留但觀察**（L1：readiness epoch、候選指紋、五輪上限的細則疑似
patch accretion，先照搬、之後用實際使用回饋決定是否簡化）

### 4. 周邊同步

- README：第七節「安裝 pilotfish」整節改寫為「內建編排層」說明；
  版本表移除 pilotfish 列
- SETUP.md：移除 pilotfish 安裝步驟（line 19、65–87 一帶）與驗收清單項
- 出處聲明：衍生檔案標註 "Derived from pilotfish v1.3.8
  (https://github.com/Nanako0129/pilotfish), MIT License © 2026 Nanako0129"
- plugin.json：版本 2.1.0 → 2.2.0
- 記憶更新：「pilotfish 只走 upstream」規則作廢，改記
  「編排層已收編進 psyflow；upstream 僅供參考」

## 風險與回滾

- 風險：hook 注入（方案 A）是照 upstream 1.4.1 的思路自寫，需在本機
  實測一輪（裝 → 重啟 → 確認政策出現在 session、subagent 正常路由）
- 過渡期風險：提案落地前，全域無編排政策；主 session 會退回 harness
  預設行為（較自主、較少強制驗證）
- 回滾：uninstall psyflow 新版 → 從備份還原舊 CLAUDE.md 區塊與 agents/

## 待決事項

1. **注入方式選 A 還是 B**（唯一 blocking）
2. 八個 agent 的模型路由是否照舊（haiku/sonnet/opus 分層）——預設照舊
3. L1 細則（五輪預算等）v2.2.0 先照搬，簡化另開回合——預設照此
