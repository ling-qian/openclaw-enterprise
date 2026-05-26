# 部署指南

## Docker Compose（推荐入门）

```bash
# 克隆仓库
git clone git@github.com:ling-qian/openclaw-enterprise.git
cd openclaw-enterprise

# 启动
docker compose up -d

# 访问
open http://localhost:3000
```

## Kubernetes（生产推荐）

```bash
# 部署
kubectl apply -f scripts/k8s/

# 验证
kubectl get pods -n openclaw
```

## 私有云 / On-Premises

1. 下载离线安装包（联系 sales@openclaw.dev）
2. 解压到目标服务器
3. 运行 `./install.sh --offline`
4. 配置 SSO（SAML/OIDC）
5. 导入技能库

详细步骤见 [ENTERPRISE.md](../ENTERPRISE.md#部署选项)
