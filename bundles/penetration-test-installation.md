# 渗透测试自动化 - 安装指南

## 系统要求

### 硬件要求
- CPU: 8 核心以上（推荐 16 核心）
- 内存: 16GB 以上（推荐 32GB）
- 存储: 100GB 可用空间（用于工具和字典）
- 网络: 稳定的互联网连接 + 目标网络访问权限

### 软件要求
- 操作系统: Ubuntu 20.04+ / Kali Linux 2023+
- Docker: 20.10+
- Docker Compose: 2.0+
- OpenClaw CLI: 最新版本

### 工具要求（自动安装）
- Nmap: 网络扫描
- SQLMap: SQL 注入测试
- Burp Suite: Web 应用测试（可选）
- Metasploit: 漏洞利用框架（可选）

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

### 2. 安装渗透测试 Skills

```bash
# 安装所有渗透测试相关 skills
openclaw skills install ah-penetration-tester
openclaw skills install pilot-penetration-testing-setup
openclaw skills install fix-erlang-ssh-cve-ssh-penetration-testing
openclaw skills install bookforge-web-application-penetration-testing-methodology
openclaw skills install bookforge-access-control-vulnerability-testing
openclaw skills install pentest-commands

# 验证安装
openclaw skills list | grep -E "penetration|pentest|bookforge|fix-erlang"
```

### 3. 安装渗透测试工具

#### 基础工具安装

```bash
# 更新包管理器
sudo apt update

# 安装基础工具
sudo apt install -y \
  nmap \
  sqlmap \
  nikto \
  dirb \
  wfuzz \
  hydra \
  john \
  hashcat \
  metasploit-framework

# 验证工具安装
nmap --version
sqlmap --version
nikto -Version
```

#### Docker 化工具（推荐）

```bash
# 创建工具目录
mkdir -p ~/pentest-tools
cd ~/pentest-tools

# 创建 docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # 漏洞扫描器
  nuclei:
    image: projectdiscovery/nuclei:latest
    volumes:
      - ./nuclei-templates:/root/nuclei-templates
    command: nuclei -u http://target.com

  # 目录扫描
  feroxbuster:
    image: ghcr.io/epi052/feroxbuster:latest
    command: -u http://target.com -w /wordlists/common.txt

  # 子域名枚举
  subfinder:
    image: projectdiscovery/subfinder:latest
    command: -d target.com

  # HTTP 探测
  httpx:
    image: projectdiscovery/httpx:latest
    command: -l targets.txt -status-code -title
EOF

# 启动工具容器
docker-compose up -d
```

### 4. 配置测试环境

#### 创建测试网络

```bash
# 创建隔离的测试网络
docker network create pentest-network

# 启动测试目标（DVWA）
docker run -d \
  --name dvwa \
  --network pentest-network \
  -p 8080:80 \
  vulnerables/web-dvwa:latest

# 启动测试 API（VAmPI）
docker run -d \
  --name vampi \
  --network pentest-network \
  -p 5000:5000 \
  erev0s/vampi:latest
```

#### 配置 OpenClaw 环境

```bash
# 创建渗透测试 agent 配置
cat > pentest-agent.json << EOF
{
  "name": "penetration-tester",
  "description": "自动化渗透测试代理",
  "skills": [
    "conducting-network-penetration-test",
    "conducting-api-security-testing",
    "conducting-cloud-penetration-testing",
    "conducting-mobile-app-penetration-test",
    "performing-web-application-penetration-test",
    "exploiting-sql-injection-with-sqlmap"
  ],
  "model": "claude-sonnet-4-20250514",
  "environment": {
    "PENTEST_NETWORK": "pentest-network",
    "WORDLIST_DIR": "/usr/share/wordlists",
    "REPORT_DIR": "./reports"
  },
  "permissions": {
    "network_access": true,
    "file_system": "read-write",
    "docker": true
  }
}
EOF

# 注册 agent
openclaw agents create --config pentest-agent.json
```

### 5. 配置安全设置

#### 创建安全策略

```bash
# 创建安全策略文件
cat > pentest-policy.yaml << 'EOF'
version: "1.0"
policy:
  # 允许的测试范围
  allowed_targets:
    - "*.testcompany.com"
    - "192.168.1.0/24"
    - "10.0.0.0/8"
  
  # 禁止的测试
  prohibited_tests:
    - "denial_of_service"
    - "social_engineering"
    - "physical_access"
  
  # 测试时间限制
  testing_hours:
    start: "22:00"
    end: "06:00"
    timezone: "UTC"
  
  # 报告要求
  reporting:
    format: ["pdf", "json", "html"]
    include_evidence: true
    include_remediation: true
EOF

# 应用安全策略
openclaw policy apply pentest-policy.yaml
```

#### 配置通知

```bash
# 创建通知配置
cat > notifications.yaml << 'EOF'
notifications:
  # 任务开始
  task_started:
    channels: ["email", "slack"]
    recipients: ["security@company.com"]
  
  # 发现关键漏洞
  critical_finding:
    channels: ["email", "slack", "sms"]
    recipients: ["security@company.com", "+1234567890"]
    immediate: true
  
  # 任务完成
  task_completed:
    channels: ["email", "slack"]
    recipients: ["security@company.com"]
EOF

# 应用通知配置
openclaw notifications apply notifications.yaml
```

### 6. 验证安装

#### 运行测试渗透测试

```bash
# 测试网络扫描
openclaw tasks submit --agent penetration-tester \
  --input "扫描 localhost 的前 1000 个端口" \
  --timeout 300

# 测试 Web 应用扫描
openclaw tasks submit --agent penetration-tester \
  --input "扫描 http://localhost:8080 的 OWASP Top 10 漏洞" \
  --timeout 600

# 测试 API 安全测试
openclaw tasks submit --agent penetration-tester \
  --input "测试 http://localhost:5000 的 API 安全漏洞" \
  --timeout 600
```

#### 验证输出

成功的渗透测试应该生成：
1. **漏洞报告**（PDF/JSON/HTML）
2. **风险评级**（Critical/High/Medium/Low/Informational）
3. **PoC 代码**（可重现的漏洞利用）
4. **修复建议**（具体步骤）
5. **合规映射**（PCI DSS/OWASP/MITRE ATT&CK）

### 7. 集成到 CI/CD

#### GitHub Actions 集成

```yaml
# .github/workflows/pentest.yml
name: Security Scan

on:
  push:
    branches: [main, release/*]
  pull_request:
    branches: [main]

jobs:
  pentest:
    runs-on: self-hosted
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Run Penetration Test
        run: |
          openclaw tasks submit --agent penetration-tester \
            --input "测试 ${{ github.repository }} 的最新部署" \
            --timeout 3600
      
      - name: Upload Report
        uses: actions/upload-artifact@v3
        with:
          name: pentest-report
          path: reports/
```

#### Jenkins 集成

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    stages {
        stage('Penetration Test') {
            steps {
                script {
                    sh '''
                        openclaw tasks submit --agent penetration-tester \
                          --input "测试 ${ENVIRONMENT} 环境" \
                          --timeout 3600
                    '''
                }
            }
        }
        
        stage('Archive Report') {
            steps {
                archiveArtifacts artifacts: 'reports/**', fingerprint: true
            }
        }
    }
    
    post {
        always {
            emailext (
                subject: "Penetration Test Report - ${env.JOB_NAME}",
                body: "渗透测试报告已生成，请查看附件。",
                to: "security@company.com",
                attachmentsPattern: 'reports/*.pdf'
            )
        }
    }
}
```

### 8. 故障排除

#### 常见问题

**问题 1**: `Permission denied` 网络访问错误
```bash
# 解决方案：检查网络权限
docker network ls
docker network inspect pentest-network
```

**问题 2**: 工具未找到错误
```bash
# 解决方案：重新安装工具
sudo apt install --reinstall nmap sqlmap nikto
```

**问题 3**: 任务执行超时
```bash
# 解决方案：增加超时时间
openclaw tasks submit --agent penetration-tester \
  --input "扫描..." \
  --timeout 7200  # 2 小时
```

**问题 4**: 报告生成失败
```bash
# 解决方案：检查磁盘空间
df -h
# 清理旧报告
rm -rf reports/*.pdf
```

### 9. 卸载

```bash
# 停止测试容器
docker stop dvwa vampi
docker rm dvwa vampi

# 卸载 skills
openclaw skills uninstall conducting-network-penetration-test
openclaw skills uninstall conducting-api-security-testing
openclaw skills uninstall conducting-cloud-penetration-testing
openclaw skills uninstall conducting-mobile-app-penetration-test
openclaw skills uninstall performing-web-application-penetration-test
openclaw skills uninstall exploiting-sql-injection-with-sqlmap

# 删除 agent
openclaw agents delete penetration-tester

# 清理配置文件
rm -f pentest-agent.json pentest-policy.yaml notifications.yaml
```

## 支持

如需帮助，请联系：
- 技术文档：https://docs.openclaw.dev/enterprise/penetration-test
- 支持邮箱：enterprise@openclaw.dev
- 紧急支持：400-xxx-xxxx（Business 及以上套餐）
