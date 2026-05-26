# Bundle 4: 客服自动化

用 AI Agent 自动处理客服工单，响应时间从小时级降到 **秒级**，人力成本降低 **60-80%**。

---

## 包含 Skills

| Skill | 用途 |
|-------|------|
| `self-improving-agent` | 持续学习，回复质量自动提升 |
| `vector-memory` | 知识库向量化存储与检索 |
| `workflow-templates` | 工单流转模板 |
| `vault-watcher` | 监控知识库更新，自动同步 |
| `performance-analyzer` | 分析客服数据，优化策略 |

---

## 工作流程

```
客户发起咨询（微信/网页/APP）
  │
  ├─ 1. 意图识别
  │     ├─ 分类：退款 / 技术问题 / 投诉 / 咨询 / 其他
  │     ├─ 紧急程度：P1（投诉）→ 直接转人工
  │     └─ 情绪分析：愤怒 → 优先处理
  │
  ├─ 2. 知识库检索（RAG）
  │     ├─ 从 FAQ / 产品文档 / 历史工单中检索相关答案
  │     ├─ 生成自然语言回复
  │     └─ 引用来源（方便人工审核）
  │
  ├─ 3. 自动回复 / 人工接管
  │     ├─ 置信度 > 80% → 自动发送
  │     ├─ 置信度 50-80% → 人工审核后发送
  │     └─ 置信度 < 50% → 直接转人工
  │
  └─ 4. 闭环与学习
        ├─ 客户满意度评价
        ├─ 差评工单 → 自动进入学习队列
        └─ 知识库自动更新
```

---

## 技术架构

```
┌─────────────────────────────────────────────┐
│                  客户触点                     │
│   微信公众号 │ 网页 Widget │ APP SDK │ 邮件   │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│              API Gateway                     │
│         (FastAPI / Nginx / ALB)              │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│           OpenClaw Agent 核心                 │
│  ┌─────────┐ ┌──────────┐ ┌──────────────┐  │
│  │意图分类器│ │知识库检索 │ │ 回复生成器   │  │
│  │(LLM)   │ │(RAG)    │ │ (LLM+模板)  │  │
│  └─────────┘ └──────────┘ └──────────────┘  │
│  ┌──────────────────────────────────────┐   │
│  │        工单流转引擎                    │   │
│  │  (状态机 + 超时 + 升级规则)            │   │
│  └──────────────────────────────────────┘   │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│              数据层                           │
│  ┌─────────┐ ┌──────────┐ ┌──────────────┐  │
│  │PostgreSQL│ │ ChromaDB │ │    Redis     │  │
│  │(工单)   │ │(向量库) │ │ (会话缓存)  │  │
│  └─────────┘ └──────────┘ └──────────────┘  │
└─────────────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│              监控 & 分析                      │
│  Grafana │ 数据看板 │ 告警 │ 日志            │
└─────────────────────────────────────────────┘
```

---

## 核心组件

| 组件 | 技术选型 | 说明 |
|------|----------|------|
| API Gateway | FastAPI + Nginx | 请求入口，负载均衡 |
| 意图分类器 | Claude / GPT-4 | 多轮对话意图识别 |
| 知识库 | ChromaDB + RAG | 向量检索，语义匹配 |
| 回复生成 | LLM + 模板 | 结合知识库和回复模板 |
| 工单系统 | PostgreSQL + 状态机 | 工单生命周期管理 |
| 缓存 | Redis | 会话状态、热数据 |
| 监控 | Grafana + Prometheus | 实时指标、告警 |
| 人工工作台 | React SPA | 客服人员操作界面 |

---

## 部署方案

### Docker Compose（推荐入门）

```yaml
# docker-compose.yml
version: '3.8'

services:
  api:
    image: openclaw/customer-service:latest
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/cs
      - REDIS_URL=redis://redis:6379
      - CHROMA_URL=http://chroma:8000
      - LLM_API_KEY=${LLM_API_KEY}
    depends_on:
      - db
      - redis
      - chroma

  db:
    image: postgres:16
    environment:
      POSTGRES_DB: cs
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine

  chroma:
    image: chromadb/chroma:latest
    volumes:
      - chroma_data:/chroma/chroma

  dashboard:
    image: openclaw/cs-dashboard:latest
    ports:
      - "3000:3000"

volumes:
  pgdata:
  chroma_data:
```

### Kubernetes（生产推荐）

```bash
# 部署
kubectl apply -f scripts/k8s/customer-service/

# 验证
kubectl get pods -n openclaw-cs
```

支持自动扩缩容：
- API Pod：根据 QPS 自动扩缩（2-10 replicas）
- 知识库：读写分离，3 副本

---

## 渠道接入

### 微信公众号

```python
# wechat_webhook.py
from fastapi import FastAPI, Request
import openclaw

app = FastAPI()

@app.post("/wechat")
async def wechat_webhook(request: Request):
    data = await request.json()
    user_msg = data["Content"]
    user_id = data["FromUserName"]

    # 调用 OpenClaw Agent
    response = await openclaw.chat(
        agent="customer-service",
        message=user_msg,
        session_id=user_id
    )

    return {"Content": response.text, "MsgType": "text"}
```

### 网页 Widget

```html
<!-- 嵌入到客户网站 -->
<script src="https://your-domain.com/widget.js"></script>
<script>
  OpenClawChat.init({
    apiUrl: 'https://your-domain.com/api',
    title: '在线客服',
    theme: 'blue'
  });
</script>
```

### 邮件

```yaml
# email_integration.yaml
imap:
  host: imap.example.com
  port: 993
  user: support@example.com
  password: ${EMAIL_PASSWORD}

smtp:
  host: smtp.example.com
  port: 587
  user: support@example.com
  password: ${EMAIL_PASSWORD}

rules:
  - match: { subject: "urgent" }
    action: escalate
  - match: { from: "@vip.com" }
    action: priority_high
```

---

## 数据看板

### 关键指标

| 指标 | 目标值 | 说明 |
|------|--------|------|
| 首次响应时间 | < 30 秒 | 客户发起咨询到收到第一条回复 |
| AI 自动解决率 | > 70% | 不需要人工介入的工单比例 |
| 平均处理时间 | < 5 分钟 | 从发起到关闭 |
| 客户满意度 | > 4.5/5 | 每次对话后评分 |
| 人工介入率 | < 30% | 需要人工接管的工单比例 |

### 看板示例

```
┌──────────────────────────────────────────────┐
│           客服数据看板 — 今日                  │
├──────────────┬──────────────┬────────────────┤
│ 总工单: 1,247 │ AI处理: 873  │ 人工: 374      │
│ 自动解决率: 70%│ 响应: 12秒   │ 满意度: 4.6    │
├──────────────┴──────────────┴────────────────┤
│ 热门问题 Top 5                               │
│ 1. 如何退款 (234)                             │
│ 2. 账号登录问题 (189)                         │
│ 3. 发货时间 (156)                             │
│ 4. 优惠券使用 (98)                            │
│ 5. 产品功能咨询 (87)                          │
├──────────────────────────────────────────────┤
│ 趋势图: [7天工单量折线图]                     │
└──────────────────────────────────────────────┘
```

---

## 价值量化

| 指标 | 传统客服 | 使用 Bundle | 节省 |
|------|----------|-------------|------|
| 响应时间 | 5-30 分钟 | < 30 秒 | **99%** |
| 人工客服需求 | 10 人 | 3 人 | **$42,000/月** |
| 夜间/周末覆盖 | 无或额外成本 | 24/7 自动 | **100%** |
| 客户满意度 | 3.8/5 | 4.5/5 | **+18%** |
| 工单处理量 | 500/天 | 2000/天 | **4x** |

**年度节省**：$500,000+（以 10 人客服团队为基准）

---

## 目标客户

| 客户类型 | 痛点 | 预算 |
|----------|------|------|
| 电商公司 | 大促期间工单暴涨，招人来不及 | $10k-20k/月 |
| SaaS 公户 | 用户增长快，客服跟不上 | $8k-15k/月 |
| 传统企业 | 客服团队老龄化，效率低 | $15k-30k/月 |
| 教育/培训机构 | 咨询量大但转化率低 | $5k-10k/月 |

---

## 快速开始

### 1. 准备知识库

```bash
# 导入 FAQ
openclaw knowledge import \
  --source faq.csv \
  --format csv \
  --columns "question,answer,category"

# 导入产品文档
openclaw knowledge import \
  --source ./docs/ \
  --format markdown
```

### 2. 创建 Agent

```bash
cat > cs-agent.json << 'EOF'
{
  "name": "customer-service",
  "model": "claude-sonnet-4-20250514",
  "system_prompt": "你是客服助手。根据知识库回答客户问题。如果不确定，转人工。",
  "skills": ["self-improving-agent", "vector-memory"],
  "config": {
    "confidence_threshold": 0.8,
    "auto_reply": true,
    "escalation_rules": [
      {"condition": "sentiment == 'angry'", "action": "transfer_human"},
      {"condition": "confidence < 0.5", "action": "transfer_human"}
    ]
  }
}
EOF
```

### 3. 启动服务

```bash
docker compose up -d
```

### 4. 接入渠道

```bash
# 微信公众号
openclaw channels add wechat \
  --token YOUR_TOKEN \
  --aes-key YOUR_AES_KEY

# 网页 Widget
openclaw channels add web-widget \
  --domain your-site.com
```

---

## 定制开发

| 需求 | 价格 | 周期 |
|------|------|------|
| 新渠道接入（钉钉/企微/飞书） | $3,000-5,000 | 1-2 周 |
| 定制意图分类模型 | $5,000-10,000 | 2-4 周 |
| 对接客户现有工单系统 | $5,000-8,000 | 2-3 周 |
| 多语言支持 | $3,000-5,000 | 1-2 周 |
| 数据看板定制 | $2,000-4,000 | 1-2 周 |

---

## 客户案例（模板）

- **某电商平台**：日均 3000+ 工单，AI 自动解决率 75%，客服团队从 15 人缩减到 5 人
- **某 SaaS 公司**：新用户咨询响应时间从 2 小时降到 10 秒，转化率提升 25%
- **某教育机构**：7x24 自动答疑，夜间咨询转化率从 0% 到 40%

> 以上为示例案例，实际合作后替换为真实数据。
