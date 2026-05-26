# 技能开发指南

## 创建一个技能

### 1. 目录结构

```
my-skill/
├── SKILL.md        # 技能说明（必需）
├── engine.py       # 执行引擎（可选）
├── bin/
│   └── run         # CLI 入口（可选）
└── README.md       # 文档
```

### 2. SKILL.md 模板

```markdown
# My Skill

> 一句话描述

## 使用方法
\`\`\`bash
openclaw skills install my-skill
my-skill --help
\`\`\`

## 参数
- `--param1`：参数说明

## 示例
\`\`\`bash
my-skill --param1 value
\`\`\`
```

### 3. 发布到 ClawHub

```bash
clawhub login
clawhub skill publish ./my-skill \
  --slug my-skill \
  --name "My Skill" \
  --version 1.0.0 \
  --tags "category1,category2"
```

详见 [ClawHub 文档](https://docs.openclaw.ai/clawhub)
