# Bundle 2: 渗透测试自动化

端到端渗透测试流程，从侦察到报告，替代初级安全工程师重复工作 **40+ 小时/次**。

---

## 包含 Skills

| Skill | ClawHub Slug | 覆盖范围 |
|-------|--------------|----------|
| Pentest Workbench | `ah-penetration-tester` | 专业渗透测试专家，漏洞评估和安全测试 |
| Penetration Testing Setup | `pilot-penetration-testing-setup` | 部署自动化渗透测试流水线（4 个 agents） |
| SSH Penetration Testing | `fix-erlang-ssh-cve-ssh-penetration-testing` | SSH 服务渗透测试：枚举、暴力破解、漏洞利用 |
| Web App Pentest Methodology | `bookforge-web-application-penetration-testing-methodology` | 完整的 Web 应用渗透测试方法论（13 个测试领域） |
| Access Control Testing | `bookforge-access-control-vulnerability-testing` | 系统化测试 Web 应用访问控制漏洞 |
| Pentest Commands | `pentest-commands` | 渗透测试命令参考（nmap、Metasploit、hydra 等） |

---

## 工作流程

```
输入：目标范围（IP/URL/API 端点）+ 规则（RoE）
  │
  ├─ 1. 侦察（Reconnaissance）
  │     ├─ 端口扫描（nmap/masscan）
  │     ├─ 子域名枚举（amass/subfinder）
  │     └─ 技术栈识别（Wappalyzer/whatweb）
  │
  ├─ 2. 漏洞发现（Vulnerability Discovery）
  │     ├─ Web 应用扫描（Nikto/Burp）
  │     ├─ API 安全测试（Postman/OWASP ZAP）
  │     └─ SQL 注入检测（SQLMap）
  │
  ├─ 3. 漏洞利用（Exploitation）
  │     ├─ 手动验证（Metasploit/custom）
  │     ├─ 权限提升路径
  │     └─ 云元数据利用（AWS/GCP/Azure）
  │
  ├─ 4. 后渗透（Post-Exploitation）
  │     ├─ 横向移动
  │     ├─ 数据提取（脱敏）
  │     └─ 持久化检测
  │
  └─ 5. 报告（Reporting）
        ├─ 发现摘要（Executive Summary）
        ├─ 详细技术分析
        ├─ CVSS 评分 + 修复建议
        └─ PoC 截图/日志
  │
输出：渗透测试报告（PDF/Markdown）+ 修复跟踪表
```

---

## 价值量化

| 指标 | 人工渗透测试 | 使用 Bundle | 节省 |
|------|-------------|-------------|------|
| 项目周期 | 2-4 周 | 3-5 天 | **80%** |
| 人力成本（中级工程师 $120/h） | $20,000-40,000 | $3,000-6,000 | **$17,000-34,000** |
| 覆盖漏洞数量 | 依赖经验 | 系统化覆盖 | — |
| 报告一致性 | 每人风格不同 | 标准化输出 | — |

---

## 目标客户

- **SaaS 公司**：定期安全评估（季度/年度）
- **金融科技**：PCI-DSS 要求的渗透测试
- **大型企业**：红队演练、安全意识培训
- **安全服务商**：为客户提供渗透测试服务的 MSP/MSSP

---

## 快速开始

## 快速开始

```bash
# 安装渗透测试 skills
openclaw skills install ah-penetration-tester
openclaw skills install pilot-penetration-testing-setup
openclaw skills install bookforge-web-application-penetration-testing-methodology

# 创建 Agent
cat > pentest-agent.json << 'EOF'
{
  "name": "penetration-tester",
  "skills": [
    "ah-penetration-tester",
    "pilot-penetration-testing-setup",
    "fix-erlang-ssh-cve-ssh-penetration-testing",
    "bookforge-web-application-penetration-testing-methodology",
    "bookforge-access-control-vulnerability-testing",
    "pentest-commands"
  ],
  "model": "claude-sonnet-4-20250514"
}
EOF

# 执行渗透测试
openclaw tasks submit --agent penetration-tester \
  --input "对 staging.finpay.com 执行完整渗透测试，覆盖 Web + API，生成 PCI-DSS 合规报告"
```

---

## 合规与方法论

| 标准 | 说明 |
|------|------|
| PTES | Penetration Testing Execution Standard |
| OWASP Testing Guide v4 | Web 应用安全测试 |
| NIST SP 800-115 | Technical Guide to Information Security Testing |
| OSSTMM 3 | Open Source Security Testing Methodology |
