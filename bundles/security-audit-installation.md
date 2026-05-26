# 安全审计自动化 - 安装指南

## 系统要求

### 硬件要求
- CPU: 4 核心以上
- 内存: 8GB 以上
- 存储: 50GB 可用空间
- 网络: 稳定的互联网连接（用于访问云 API）

### 软件要求
- 操作系统: Ubuntu 20.04+ / CentOS 8+ / macOS 12+
- Docker: 20.10+
- Docker Compose: 2.0+
- OpenClaw CLI: 最新版本

### 云环境要求
- AWS: IAM 用户（只读权限）
- Azure: 服务主体（Reader 角色）
- GCP: 服务账号（Viewer 角色）
- Kubernetes: kubeconfig 文件

## 安装步骤

### 1. 安装 OpenClaw CLI

```bash
# 安装 Node.js（如果未安装）
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 安装 OpenClaw CLI
npm install -g openclaw

# 验证安装
openclaw --version
```

### 2. 安装安全审计 Skills

```bash
# 安装所有审计相关 skills
openclaw skills install auditing-aws-s3
openclaw skills install auditing-azure-ad
openclaw skills install auditing-cis-benchmarks
openclaw skills install auditing-gcp-iam
openclaw skills install auditing-k8s-rbac
openclaw skills install auditing-terraform-security

# 验证安装
openclaw skills list | grep auditing
```

### 3. 配置云环境凭证

#### AWS 配置

```bash
# 创建 AWS 凭证文件
mkdir -p ~/.aws
cat > ~/.aws/credentials << EOF
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
region = us-east-1
EOF

# 验证 AWS 连接
aws sts get-caller-identity
```

#### Azure 配置

```bash
# 创建 Azure 服务主体
az ad sp create-for-rbac --name "openclaw-auditor" --role reader

# 设置环境变量
export AZURE_CLIENT_ID="your-client-id"
export AZURE_CLIENT_SECRET="your-client-secret"
export AZURE_TENANT_ID="your-tenant-id"
export AZURE_SUBSCRIPTION_ID="your-subscription-id"

# 验证 Azure 连接
az account show
```

#### GCP 配置

```bash
# 创建服务账号
gcloud iam service-accounts create openclaw-auditor \
  --display-name="OpenClaw Auditor"

# 授予 Viewer 角色
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:openclaw-auditor@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/viewer"

# 创建密钥文件
gcloud iam service-accounts keys create ~/gcp-key.json \
  --iam-account=openclaw-auditor@YOUR_PROJECT_ID.iam.gserviceaccount.com

# 验证 GCP 连接
gcloud auth activate-service-account --key-file=~/gcp-key.json
gcloud projects list
```

#### Kubernetes 配置

```bash
# 复制 kubeconfig 文件
cp ~/.kube/config ~/.kube/config-openclaw

# 验证 Kubernetes 连接
kubectl --kubeconfig=~/.kube/config-openclaw cluster-info
```

### 4. 创建审计 Agent

```bash
# 创建 agent 配置文件
cat > audit-agent.json << EOF
{
  "name": "security-auditor",
  "description": "自动化安全审计代理",
  "skills": [
    "auditing-aws-s3",
    "auditing-azure-ad",
    "auditing-cis-benchmarks",
    "auditing-gcp-iam",
    "auditing-k8s-rbac",
    "auditing-terraform-security"
  ],
  "model": "claude-sonnet-4-20250514",
  "environment": {
    "AWS_PROFILE": "default",
    "AZURE_CLIENT_ID": "${AZURE_CLIENT_ID}",
    "GCP_KEY_FILE": "~/gcp-key.json",
    "KUBECONFIG": "~/.kube/config-openclaw"
  }
}
EOF

# 注册 agent
openclaw agents create --config audit-agent.json

# 验证 agent 创建
openclaw agents list
```

### 5. 验证安装

#### 运行测试审计

```bash
# 测试 AWS S3 审计
openclaw tasks submit --agent security-auditor \
  --input "扫描测试 S3 桶的安全配置" \
  --timeout 300

# 检查任务状态
openclaw tasks list --agent security-auditor

# 查看任务结果
openclaw tasks get <task-id>
```

#### 验证输出

成功的审计应该生成：
1. **结构化报告**（JSON 格式）
2. **风险评级**（Critical/High/Medium/Low）
3. **修复建议**（具体命令）
4. **合规映射**（CIS/SOC2/ISO 控制项）

### 6. 故障排除

#### 常见问题

**问题 1**: `openclaw: command not found`
```bash
# 解决方案：重新安装 OpenClaw CLI
npm uninstall -g openclaw
npm install -g openclaw
```

**问题 2**: `Permission denied` 错误
```bash
# 解决方案：检查云凭证权限
aws sts get-caller-identity  # AWS
az account show              # Azure
gcloud auth list             # GCP
```

**问题 3**: `Skill not found` 错误
```bash
# 解决方案：重新安装 skill
openclaw skills uninstall <skill-name>
openclaw skills install <skill-name>
```

**问题 4**: 任务执行超时
```bash
# 解决方案：增加超时时间
openclaw tasks submit --agent security-auditor \
  --input "扫描..." \
  --timeout 1800  # 30 分钟
```

### 7. 卸载

```bash
# 卸载 skills
openclaw skills uninstall auditing-aws-s3
openclaw skills uninstall auditing-azure-ad
openclaw skills uninstall auditing-cis-benchmarks
openclaw skills uninstall auditing-gcp-iam
openclaw skills uninstall auditing-k8s-rbac
openclaw skills uninstall auditing-terraform-security

# 删除 agent
openclaw agents delete security-auditor

# 清理配置文件
rm -f audit-agent.json
rm -f ~/.aws/credentials  # 如果不再需要
```

## 支持

如需帮助，请联系：
- 技术文档：https://docs.openclaw.dev/enterprise/security-audit
- 支持邮箱：enterprise@openclaw.dev
- 紧急支持：400-xxx-xxxx（Business 及以上套餐）
