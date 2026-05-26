# Solution Bundles

预打包的"开箱即用"解决方案，每个 bundle 包含一组协同工作的 skills，解决特定业务场景。

---

## 可用 Bundles

| Bundle | 说明 | 替代工时 | Skills 数 | 月费 | 文档 |
|--------|------|----------|-----------|------|------|
| [安全审计自动化](security-audit.md) | 云基础设施配置扫描 + 合规报告 | 20+ 小时/次 | 6 | $2,499 | [安装指南](security-audit-installation.md) |
| [渗透测试自动化](penetration-test.md) | 端到端渗透测试流程 | 40+ 小时/次 | 6 | $3,499 | [安装指南](penetration-test-installation.md) |
| [事件响应自动化](incident-response.md) | 事件取证 + 攻击链分析 + 报告 | 8+ 小时/次 | 6 | $2,999 | [安装指南](incident-response-installation.md) |

**打包优惠**：任意 2 个 8.5 折，3 个全购 7.5 折。

---

## 使用方法

```bash
# 安装整个 bundle（逐个安装）
openclaw skills install auditing-aws-s3
openclaw skills install auditing-cis-benchmarks
openclaw skills install auditing-k8s-rbac
# ...

# 或通过企业版一键部署
# 在 Agent 配置中引用 bundle 名称即可
```

---

## 验证状态

所有 bundle 中的 skills 均已验证存在于系统中（18/18 ✅）。

| Bundle | 验证结果 |
|--------|----------|
| 安全审计自动化 | 6/6 ✅ |
| 渗透测试自动化 | 6/6 ✅ |
| 事件响应自动化 | 6/6 ✅ |

---

## Demo 场景

每个 bundle 包含完整的真实案例演示：

| Bundle | 公司类型 | 核心价值 | 年化 ROI |
|--------|----------|----------|----------|
| 安全审计 | CloudStack SaaS（云计算） | 审计频率 13x，时间降至 2 天 | $12,000 节省 |
| 渗透测试 | FinPay（移动支付） | 测试频率 52x，全栈覆盖 | $18,012 节省 |
| 事件响应 | MedSecure（医疗数据） | 响应速度 32x，合规达标 | $22,512 节省 |

详见各 bundle 文档中的「Demo 场景」章节。

---

## 定制 Bundle

如需定制 bundle（增减技能、调整流程），请联系 enterprise@openclaw.dev。
