# OpenClaw Enterprise

> 基于开源 Hermes Agent 的企业级 AI Agent 管理与编排平台

[![ClawHub](https://img.shields.io/badge/ClawHub-clawhub.ai-blue)](https://clawhub.ai)
[![License](https://img.shields.io/badge/License-Commercial-red)](LICENSE)

---

## 是什么

OpenClaw Enterprise 帮助中大型组织将 AI Agent 应用于安全运营、合规审计、渗透测试、威胁狩猎、云安全等场景。

**核心能力**：
- 🔐 私有部署 + 数据驻留（你的数据不出你的网络）
- 🛡️ SOC2 / ISO 27001 / NIST 800-53 合规就绪
- 🔧 30+ 预集成安全技能（渗透测试、云安全、威胁狩猎等）
- 📊 完整审计追踪（谁、什么、何时、结果）
- 🚀 SSO / RBAC / SLA 企业级功能

---

## 快速开始

### 社区版（免费）

```bash
# 安装 OpenClaw
npm i -g openclaw

# 搜索技能
openclaw skills search "security"

# 安装技能
openclaw skills install wechat-lead-generation

# 启动
openclaw gateway start
```

### 企业版（试用）

1. 访问 [enterprise.openclaw.dev](https://enterprise.openclaw.dev)
2. 申请 30 天 Business 套餐试用
3. 配置 SSO → 导入技能 → 创建 Agent → 开始任务

---

## 技能市场

在 [ClawHub](https://clawhub.ai) 发现和安装技能：

```bash
# 搜索
clawhub search "penetration testing"

# 安装
openclaw skills install <skill-slug>

# 发布你自己的技能
clawhub skill publish ./my-skill --slug my-skill --name "My Skill" --version 1.0.0
```

---

## 目录结构

```
openclaw-enterprise/
├── ENTERPRISE.md        # 企业版详细说明（定价、功能、架构）
├── README.md            # 本文件
├── docs/                # 文档
│   ├── deployment.md    # 部署指南
│   ├── api.md           # API 文档
│   └── skills-dev.md    # 技能开发指南
├── skills/              # 预置技能（示例）
│   └── README.md        # 技能索引
├── scripts/             # 部署与运维脚本
└── LICENSE              # 商业许可
```

---

## 定价概览

| 套餐 | Agents | Tasks/月 | 价格 |
|------|--------|----------|------|
| Starter | 5 | 10k | $299/月 |
| Business | 20 | 100k | $1,299/月 |
| Enterprise | 100 | 无限 | 定制报价 |

详见 [ENTERPRISE.md](ENTERPRISE.md)

---

## 安全与合规

- TLS 1.3 + AES-256 加密
- SAML 2.0 / OIDC 单点登录
- 结构化审计日志（JSON）→ SIEM 集成
- SOC 2 Type II 审计就绪文档包
- 数据删除支持（GDPR 7 天内完成）

---

## 联系

- 销售：enterprise@openclaw.dev
- 技术咨询：openclaw.dev/enterprise/contact
- 文档：docs.openclaw.dev

---

## 许可

企业版功能受商业许可保护，详见 [LICENSE](LICENSE)。
开源社区版遵循 MIT License。
