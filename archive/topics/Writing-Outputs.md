# Writing Outputs

`tags: #writing`

_文本写作、论文草稿、输出内容归档于此。新内容置顶。_

---

## 2026-05-02: PFAS "Three-Hit" Research Proposal

**Tags:** #PFAS #research-proposal #cardiovascular #environmental-health #three-hit-model

完整研究提案文档已输出至 `C:\Users\LIU\Desktop\PFAS-Research-Proposal.md`，包含：研究课题、Three-Hit 假设（PFAS→血脂异常→泡沫细胞/斑块不稳定→肾功能损伤+恶性循环）、5篇文献系统综述、病例-对照研究方案（血-尿双基质PFAS检测+ML分析）、可行性评分9/10、5个创新点。

**核心结论：** 提出 PFAS 通过肾功能损伤介导高血脂患者心脑血管梗死风险的 Three-Hit 模型，将肾功能同时作为中介和放大器，形成正反馈恶性循环。这是该领域首次将三条独立证据链整合为统一理论框架。

### 本会话更新（2026-05-02）

**交叉验证与文献扩展：**

- 从 5 篇核心文献扩展至 **15 篇参考文献**，经 PMID/DOI 逐篇确认真实有效
- 新增 Section 3.4 (PFAS→血小板/凝血功能)：GPIbα 分子机制突破（Liu 2025, J Hazard Mater）
- 新增 Hit 1 文献：Ji 2025 荟萃分析（74 项）、Lin 2024 YOTA 队列、Faquih 2024 双队列等
- 新增 Hit 2 文献：Zhang 2025 ApoE-/- 内皮功能障碍模型
- 验证所有参考文献真实有效

**分析方法优化（Section 4.4）：**

- 经典分析：MICE 多重插补（m=20）、FDR 校正（Benjamini-Hochberg）、阴性对照分析、贝叶斯中介分析、高维中介分析（HIMA/JIVE）、监督 PCA、贝叶斯因子
- ML 分析：SMOTE 过采样、嵌套交叉验证（5×3）、Cumulative-vs-Risk 图、贝叶斯非参数中介模型
- 混杂控制：倾向性评分（PS/IPTW/PSM）+ E-value 分析
