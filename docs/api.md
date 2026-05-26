# API 文档

## 基础 URL

```
https://your-instance.openclaw.dev/api/v1
```

## 认证

所有 API 请求需要 Bearer Token：

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  https://your-instance.openclaw.dev/api/v1/agents
```

## 主要端点

### Agents

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/agents` | 列出所有 agent |
| POST | `/agents` | 创建 agent |
| GET | `/agents/:id` | 获取 agent 详情 |
| DELETE | `/agents/:id` | 删除 agent |

### Tasks

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/tasks` | 提交任务 |
| GET | `/tasks/:id` | 获取任务状态 |
| GET | `/tasks/:id/logs` | 获取任务日志 |

### Skills

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/skills` | 列出已安装技能 |
| POST | `/skills/install` | 安装技能 |
| DELETE | `/skills/:slug` | 卸载技能 |

完整 API 参考见 [docs.openclaw.dev/api](https://docs.openclaw.dev/api)
