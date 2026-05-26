# Bundle 1: 安全审计自动化

自动扫描云基础设施配置，生成合规报告，替代手动审计 **20+ 小时/次**。

---

## 包含 Skills

| Skill | ClawHub Slug | 覆盖范围 |
|-------|--------------|----------|
| AWS S3 Bucket Audit | `auditing-aws-s3` | S3 桶权限、ACL、加密、公开访问 |
| Sx Security Audit | `sx-security-audit-1-0-0` | 全方位安全审计：文件权限、环境变量、依赖漏洞等 |
| Cloud CIS Benchmarks | `auditing-cis-benchmarks` | AWS/Azure/GCP CIS 基准检查 |
| Security Audit | `security-audit` | 综合安全审计：凭证暴露、开放端口、弱配置、漏洞 |
| Kubernetes RBAC Audit | `auditing-k8s-rbac` | K8s 角色、绑定、权限路径 |
| Terraform Security Audit | `auditing-terraform-security` | IaC 安全扫描（Checkov/tfsec/OPA） |

---

## 工作流程

```
输入：云环境访问凭证或 Terraform 代码
  │
  ├─ 1. 资产发现 ─→ 扫描所有云资源
  ├─ 2. 配置检查 ─→ 对照 CIS/NIST 基准
  ├─ 3. 风险评级 ─→ 按严重程度分级（Critical/High/Medium/Low）
  ├─ 4. 修复建议 ─→ 生成可执行的修复命令
  └─ 5. 合规报告 ─→ 输出审计报告（PDF/Markdown/JSON）
  │
输出：结构化审计报告 + 修复脚本
```

---

## 价值量化

| 指标 | 手动审计 | 使用 Bundle | 节省 |
|------|----------|-------------|------|
| 单次审计耗时 | 20-40 小时 | 1-2 小时 | **90%** |
| 人力成本（$150/h） | $3,000-6,000 | $150-300 | **$2,700-5,700** |
| 遗漏配置风险 | 高（人工疲劳） | 低（自动化覆盖） | — |
| 报告一致性 | 依赖个人经验 | 标准化输出 | — |

---

## 目标客户

- **云原生团队**：拥有 AWS/Azure/GCP 基础设施，需要定期合规检查
- **安全团队**：人手不足，需要自动化审计能力
- **合规驱动行业**：金融、医疗、政府等需要 SOC2/ISO27001/HIPAA 合规

---

## 快速开始

```bash
# 安装所有审计 skills
openclaw skills install auditing-aws-s3
openclaw skills install auditing-cis-benchmarks
openclaw skills install auditing-k8s-rbac
openclaw skills install auditing-terraform-security

# 创建 Agent
cat > audit-agent.json << 'EOF'
{
  "name": "security-auditor",
  "skills": [
    "auditing-aws-s3",
    "auditing-cis-benchmarks",
    "auditing-k8s-rbac",
    "auditing-terraform-security"
  ],
  "model": "claude-sonnet-4-20250514"
}
EOF

# 执行审计任务
openclaw tasks submit --agent security-auditor \
  --input "扫描 production 环境 AWS S3 和 K8s RBAC，生成 CIS 合规报告"
```

---

## Demo 场景：CloudStack SaaS 云平台

### 背景
- 120 名工程师，安全团队 3 人
- 基础设施：AWS（200+ EC2、50+ S3、30+ RDS）+ Kubernetes（100+ Pods）
- 合规要求：SOC 2 Type II（年度审计）+ 客户要求的季度安全报告

### 痛点
- 手动审计耗时：每次 SOC 2 审计需要 2 名工程师 × 2 周 = 160 小时
- 配置漂移：每月新增 50+ 资源，无法实时监控
- 审计发现遗漏：上次审计漏掉 3 个公开 S3 桶
- 报告不一致：不同工程师的审计报告格式和深度不同

### 解决方案
部署安全审计自动化 bundle，集成到 CI/CD 和定期扫描。

### 执行流程

**定期扫描（每周一 02:00）**：
```bash
# Step 1: 扫描 AWS 资源
openclaw tasks submit --agent security-auditor \
  --input "扫描 production AWS 环境：S3 桶、EC2 安全组、IAM 策略、RDS 配置"

# Step 2: 扫描 Kubernetes 集群
openclaw tasks submit --agent security-auditor \
  --input "扫描 production K8s 集群：RBAC 绑定、Pod 安全策略、网络策略"

# Step 3: 扫描 Terraform 代码
openclaw tasks submit --agent security-auditor \
  --input "扫描 infra/ 目录下所有 Terraform 代码，检查安全配置"
```

**CI/CD 集成（每次发版）**：
```yaml
# .github/workflows/security-audit.yml
name: Pre-deployment Security Audit
on:
  push:
    branches: [main]
    paths: ['infra/**', 'k8s/**']

jobs:
  audit:
    runs-on: self-hosted
    steps:
      - name: Run Security Audit
        run: |
          openclaw tasks submit --agent security-auditor \
            --input "扫描本次变更涉及的 AWS 和 K8s 资源，生成 CIS 合规报告"
```

### 结果

| 指标 | 手动审计 | 使用 Bundle | 改进 |
|------|----------|-------------|------|
| 审计频率 | 2 次/年 | 52 次/年（每周） | **26x** |
| 单次审计耗时 | 160 小时 | 2 小时 | **98%** |
| 配置漂移检测 | 月度（手动） | 实时（自动化） | **30x** |
| 公开 S3 桶发现 | 审计时才发现 | 扫描后 15 分钟 | **即时** |
| SOC 2 准备时间 | 4 周 | 2 天 | **93%** |

**ROI**：年化节省 $12,000 + 审计频率提升 13 倍 + 配置漂移实时监控

---

## 合规映射

| 标准 | 覆盖控制项 |
|------|-----------|
| CIS Benchmark v5 | AWS: 60+ / Azure: 50+ / GCP: 40+ |
| SOC 2 Type II | CC6.1, CC6.3, CC6.6, CC6.7 |
| ISO 27001 | A.9, A.12, A.14 |
| NIST 800-53 | AC-2, AC-3, AC-6, SC-7, SC-12 |
