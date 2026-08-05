# BDD 符合度評估報告

- 日期:2026-08-05
- 評估對象:workbench 八階段流程(`skills/workbench/SKILL.md` + `commands/*.md` + `claude-md-blocks/`)
- 評估基準:雙軸並列 —— (A) 嚴格 BDD(Discovery + Formulation + Automation 三環節完整)、(B) 原則式 BDD(行為語言、例子驅動、活文件精神)
- 來源:本輪 /discover 裁決 —— 只評估、不改流程;雙軸基準;報告歸檔 docs/research/

## 1. BDD 是什麼

BDD(Behavior-Driven Development,行為驅動開發)是 Dan North 於 2000 年代中期
從 TDD 演化出的方法。核心主張:用「系統應有的行為」而非「測試」作為團隊溝通
與驗證的單位。由三個環節組成:

1. **Discovery(探索)**:開發前由「三個朋友」(業務、開發、測試)透過結構化
   對話(常用 Example Mapping)把需求拆成規則與具體例子,揪出隱藏假設與邊界
   情況。
2. **Formulation(規格化)**:把例子改寫成業務語言的結構化情境,最常見格式為
   Gherkin(Given / When / Then)。全隊共用同一套詞彙(ubiquitous language),
   描述行為而非實作。
3. **Automation(自動化)**:用 Cucumber、Behave、pytest-bdd 等工具把每個
   scenario 綁定 step definitions,由外而內驅動實作。scenario 成為
   **活文件(living documentation)**:跑得過即符合規格,跑不過即規格與實作
   脫節。

一句話:對話產生例子 → 例子寫成業務語言的可執行規格 → 規格驅動實作並永久
作為驗收與文件。

## 2. 事實基礎

- 全 repo(commands、skills、docs、claude-md-blocks)無任何 BDD、Gherkin、
  Cucumber、Given/When/Then 字眼。
- /discover 以 grilling(一次一題、使用者裁決)+ domain-modeling(共用詞彙)
  進行需求探索。
- /spec 要求每個 feature spec 含 flow section(success / failure / recovery
  三路徑)與 instrumentation section,規格經確認後凍結。
- /build 以 TDD 為邏輯實作引擎;/accept 以 code-review 的 Spec 軸(人工比對
  規格)+ 獨立 verifier 驗收。

## 3. 逐環節對照

| BDD 環節 | workbench 現況 | 對照 |
|---|---|---|
| Discovery | /discover grilling + domain-modeling;產出 rulings + scope | **高度吻合**。結構化對話、逐題裁決、共用詞彙,等價於 BDD 探索工作坊;差異在產出是「裁決」而非「規則 + 例子」的例子地圖 |
| Formulation | /spec flow section 強制 success / failure / recovery | **部分吻合**。三路徑即 scenario 思維的雛形,但為散文式規格,無 Given/When/Then 結構,scenario 未與測試綁定 |
| Automation | /build 用 TDD;/accept 人工 Spec 軸 review + verifier | **不吻合**。TDD 是開發者視角的單元測試;凍結的 spec 不會成為可執行活文件;驗收靠人工比對而非跑 scenario |

## 4. 雙軸結論

### 軸 A:嚴格 BDD —— **不符合**

缺少 BDD 的定義性特徵:業務語言的可執行規格。具體差距:

1. 無 Formulation 格式:flow section 未以 Given/When/Then 結構化。
2. 無 Automation 工具鏈:無 Cucumber / pytest-bdd 等 step-definition 綁定,
   spec 凍結後與程式碼無機械連結。
3. 驗收非 scenario 驅動:/accept 的 Spec 軸是人工 review,不是「規格跑過即
   通過」。

### 軸 B:原則式 BDD —— **大致符合,有明確缺口**

符合的精神:

- 例子驅動的對話探索(grilling 逐題裁決)。
- Ubiquitous language(domain-modeling:文案與程式識別字共用一套詞彙)。
- 行為三路徑思維(success / failure / recovery)綁定前後端同一語意。
- 規格作為跨職能契約(tokens、component specs、API contract),而非口頭記憶。

缺口:

- spec 是「凍結文件」而非「活文件」——實作漂移只能靠 /accept 人工攔截。
- 探索產出未保留「具體例子」形態,進 /build 前例子已被抽象化為裁決。

## 5. 若日後要導入(僅供未來 /discover 參考,本輪不執行)

- 最小步:/spec 的 flow section 改用 Given/When/Then 結構化寫法,不引入
  工具鏈(成本低,立即改善規格精確度)。
- 完整步:/build 增加 scenario automation(依專案 stack 選 pytest-bdd 等,
  屬各專案 ADR 決策)、/accept 增加「scenario 全綠」為驗收條件。
- 風險:workbench 為單人三帽流程,BDD 的「三個朋友」協作價值部分已由
  grilling 的角色切換承擔,導入完整工具鏈的邊際效益需再評估。

## 6. 結論

workbench 是「BDD 近親」:探索與詞彙環節即 BDD 精神,規格環節有 scenario
雛形,但缺可執行規格與活文件機制。對外描述宜稱「規格驅動 + TDD,含 BDD 式
探索」,不宜宣稱符合 BDD 規範。
