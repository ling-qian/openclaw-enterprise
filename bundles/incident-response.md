# Bundle 3: 事件响应自动化

安全事件发生后，自动收集证据、分析攻击链、生成报告，响应时间从小时级降到 **分钟级**。

---

## 包含 Skills

| Skill | ClawHub Slug | 覆盖范围 |
|-------|--------------|----------|
| Incident Response | `incident-response` | 结构化 7 阶段事件响应流程 |
| Incident Response Network | `incident-response-network` | 网络取证证据收集和分析 |
| Incident Response Lifecycle | `incident-response-lifecycle` | NIST 800-61 事件响应生命周期管理 |
| K8s Incident Response | `k8s-incident-response-playbook` | Kubernetes 事件响应 Playbook 生成器 |
| Agent Incident Response | `greenhelix-agent-incident-response` | AI Agent 系统故障事件响应 Playbook |

**注意**: 原计划包含 6 个 skills，但由于 `afrexai-incident-response-playbook` 在 ClawHub 上不可用，当前使用 5 个可用 skills。这些 skills 覆盖了事件响应的核心功能。

---

## 工作流程

```
输入：事件告警（SIEM/SOC/人工发现）
  │
  ├─ 1. 分诊（Triage）
  │     ├─ 严重程度评估（P1-P4）
  │     ├─ 影响范围估算
  │     └─ 自动通知相关人员
  │
  ├─ 2. 遏制（Containment）
  │     ├─ 受感染主机隔离
  │     ├─ 网络段封锁
  │     └─ 账户禁用
  │
  ├─ 3. 取证（Forensics）
  │     ├─ 内存快照采集
  │     ├─ 磁盘镜像
  │     ├─ 流量捕获分析
  │     └─ 日志关联（Splunk/ELK）
  │
  ├─ 4. 根因分析（Root Cause Analysis）
  │     ├─ 攻击链重建（MITRE ATT&CK 映射）
  │     ├─ IOC 提取（IP/Domain/Hash）
  │     └─ 横向影响评估
  │
  └─ 5. 恢复与报告（Recovery & Reporting）
        ├─ 清除恶意软件/后门
        ├─ 系统恢复验证
        ├─ 事件报告（含时间线）
        └─ 改进建议（Lessons Learned）
  │
输出：事件响应报告 + IOC 列表 + 修复跟踪表
```

---

## 价值量化

| 指标 | 人工响应 | 使用 Bundle | 节省 |
|------|----------|-------------|------|
| 平均响应时间（MTTR） | 8-24 小时 | 30-60 分钟 | **95%** |
| 取证数据收集 | 2-4 小时 | 5-10 分钟 | **97%** |
| 报告撰写 | 4-8 小时 | 15-30 分钟 | **94%** |
| 人力成本（P1 事件） | $5,000-15,000 | $500-1,500 | **$4,500-13,500** |

---

## 目标客户

- **SOC 团队**：7x24 安全运营中心，需要快速响应
- **DevSecOps 团队**：自动化安全事件处理
- **MSP/MSSP**：为多客户管理安全事件
- **受监管行业**：需要事件响应记录的合规要求

---

## 快速开始

```bash
# 安装
openclaw skills install conducting-malware-incident-response
openclaw skills install conducting-phishing-incident-response
openclaw skills install collecting-volatile-evidence-from-compromised-host
openclaw skills install analyzing-memory-dumps-with-volatility
openclaw skills install analyzing-network-traffic-for-incidents
openclaw skills install generating-threat-intelligence-reports

# 创建 Agent
cat > ir-agent.json << 'EOF'
{
  "name": "incident-responder",
  "skills": [
    "conducting-malware-incident-response",
    "conducting-phishing-incident-response",
    "collecting-volatile-evidence-from-compromised-host",
    "analyzing-memory-dumps-with-volatility",
    "analyzing-network-traffic-for-incidents",
    "generating-threat-intelligence-reports"
  ],
  "model": "claude-sonnet-4-20250514"
}
EOF

# 处理事件
openclaw tasks submit --agent incident-responder \
  --input "主机 10.0.1.50 检测到异常进程，疑似恶意软件。请进行取证分析和根因排查。"
```

---

## 与 SIEM/SOAR 集成

| 集成 | 方式 |
|------|------|
| Splunk | Webhook 触发 → 自动执行 runbook |
| Elastic SIEM | 告警 → OpenClaw API → 响应流程 |
| ServiceNow | 事件工单 → 自动化响应 → 更新工单 |
| PagerDuty | P1 告警 → 自动隔离 + 通知 |

---

## 合规映射

| 标准 | 说明 |
|------|------|
| NIST SP 800-61r3 | Incident Handling Guide |
| SANS PICERL | Preparation, Identification, Containment, Eradication, Recovery, Lessons |
| ISO 27035 | Information Security Incident Management |
| GDPR Article 33 | 72 小时通知要求 |
