# 事件响应自动化 - 安装指南

## 系统要求

### 硬件要求
- CPU: 8 核心以上（推荐 16 核心）
- 内存: 32GB 以上（用于内存分析）
- 存储: 200GB 可用空间（用于证据存储）
- 网络: 稳定的互联网连接 + 内网访问权限

### 软件要求
- 操作系统: Ubuntu 20.04+ / CentOS 8+ / macOS 12+
- Docker: 20.10+
- Docker Compose: 2.0+
- OpenClaw CLI: 最新版本

### 工具要求（自动安装）
- Volatility 3: 内存分析
- Rekall: 内存取证（可选）
- Wireshark: 网络流量分析
- Sleuth Kit: 磁盘取证
- YARA: 恶意软件检测

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

### 2. 安装事件响应 Skills

```bash
# 安装所有事件响应相关 skills
openclaw skills install incident-response
openclaw skills install incident-response-network
openclaw skills install incident-response-lifecycle
openclaw skills install k8s-incident-response-playbook
openclaw skills install greenhelix-agent-incident-response

# 验证安装
openclaw skills list | grep -E "incident-response|k8s|greenhelix"
```

### 3. 安装取证工具

#### 基础工具安装

```bash
# 更新包管理器
sudo apt update

# 安装基础取证工具
sudo apt install -y \
  volatility3 \
  sleuthkit \
  autopsy \
  yara \
  tcpdump \
  tshark \
  binwalk \
  foremost \
  scalpel

# 安装 Python 依赖
pip3 install \
  volatility3 \
  pytsk3 \
  pyyara \
  scapy

# 验证工具安装
vol --version
yara --version
tshark --version
```

#### Docker 化工具（推荐）

```bash
# 创建工具目录
mkdir -p ~/incident-response-tools
cd ~/incident-response-tools

# 创建 docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # 内存分析
  volatility:
    image: remnux/volatility3:latest
    volumes:
      - ./memory-dumps:/data
    command: vol -f /data/memory.dump windows.info

  # 网络分析
  wireshark:
    image: linuxserver/wireshark:latest
    volumes:
      - ./pcap-files:/data
    ports:
      - "3000:3000"

  # 恶意软件分析
  cuckoo:
    image: blacktop/cuckoo:latest
    volumes:
      - ./malware-samples:/data
    ports:
      - "8080:8080"

  # 威胁情报
  misp:
    image: coolacid/misp-docker:latest
    ports:
      - "443:443"
EOF

# 启动工具容器
docker-compose up -d
```

### 4. 配置事件响应环境

#### 创建证据存储

```bash
# 创建证据存储目录
sudo mkdir -p /evidence/{memory, disk, network, malware, reports}
sudo chown -R $USER:$USER /evidence

# 设置权限
sudo chmod 750 /evidence
sudo chmod 750 /evidence/*

# 创建证据日志
sudo touch /evidence/evidence.log
sudo chown $USER:$USER /evidence/evidence.log
```

#### 配置 SIEM 集成

```bash
# 创建 SIEM 集成配置
cat > siem-integration.yaml << 'EOF'
version: "1.0"
siem:
  # Splunk 集成
  splunk:
    enabled: true
    host: "splunk.company.com"
    port: 8089
    username: "openclaw"
    password: "${SPLUNK_PASSWORD}"
    index: "security"
  
  # Elastic 集成
  elastic:
    enabled: false
    hosts: ["elastic.company.com:9200"]
    username: "elastic"
    password: "${ELASTIC_PASSWORD}"
  
  # QRadar 集成
  qradar:
    enabled: false
    host: "qradar.company.com"
    port: 443
    token: "${QRADAR_TOKEN}"
EOF

# 应用 SIEM 集成
openclaw siem apply siem-integration.yaml
```

#### 配置 EDR 集成

```bash
# 创建 EDR 集成配置
cat > edr-integration.yaml << 'EOF'
version: "1.0"
edr:
  # CrowdStrike 集成
  crowdstrike:
    enabled: true
    client_id: "${CROWDSTRIKE_CLIENT_ID}"
    client_secret: "${CROWDSTRIKE_CLIENT_SECRET}"
    base_url: "https://api.crowdstrike.com"
  
  # Carbon Black 集成
  carbonblack:
    enabled: false
    url: "https://carbonblack.company.com"
    api_token: "${CARBONBLACK_TOKEN}"
  
  # SentinelOne 集成
  sentinelone:
    enabled: false
    url: "https://sentinelone.company.com"
    api_token: "${SENTINELONE_TOKEN}"
EOF

# 应用 EDR 集成
openclaw edr apply edr-integration.yaml
```

### 5. 创建事件响应 Agent

```bash
# 创建 agent 配置文件
cat > incident-response-agent.json << EOF
{
  "name": "incident-responder",
  "description": "自动化事件响应代理",
  "skills": [
    "conducting-malware-incident-response",
    "conducting-phishing-incident-response",
    "collecting-volatile-evidence-from-compromised-host",
    "analyzing-memory-dumps-with-volatility",
    "analyzing-network-traffic-for-incidents",
    "generating-threat-intelligence-reports"
  ],
  "model": "claude-sonnet-4-20250514",
  "environment": {
    "EVIDENCE_DIR": "/evidence",
    "SIEM_INTEGRATION": "siem-integration.yaml",
    "EDR_INTEGRATION": "edr-integration.yaml",
    "REPORT_FORMAT": "pdf,json,html"
  },
  "permissions": {
    "network_access": true,
    "file_system": "read-write",
    "docker": true,
    "sudo": true
  }
}
EOF

# 注册 agent
openclaw agents create --config incident-response-agent.json
```

### 6. 配置自动化 Runbook

#### 创建事件响应 Runbook

```bash
# 创建 Runbook 目录
mkdir -p ~/runbooks

# 创建恶意软件事件 Runbook
cat > ~/runbooks/malware-incident.yaml << 'EOF'
version: "1.0"
runbook:
  name: "恶意软件事件响应"
  description: "检测到恶意软件时的自动化响应流程"
  
  triggers:
    - siem_alert: "malware_detected"
    - edr_alert: "malicious_process"
    - user_report: "suspicious_file"
  
  steps:
    # Step 1: 隔离受感染主机
    - name: "隔离主机"
      action: "isolate_host"
      timeout: 60
      conditions:
        - alert.severity == "critical"
    
    # Step 2: 收集易失性证据
    - name: "收集证据"
      action: "collect_volatile_evidence"
      timeout: 300
      parameters:
        memory_dump: true
        process_list: true
        network_connections: true
        registry_hives: true
    
    # Step 3: 内存分析
    - name: "内存分析"
      action: "analyze_memory"
      timeout: 1800
      parameters:
        plugins: ["windows.info", "windows.pslist", "windows.netscan"]
    
    # Step 4: 网络流量分析
    - name: "网络分析"
      action: "analyze_network"
      timeout: 900
      parameters:
        pcap_file: "network_capture.pcap"
        suspicious_ips: true
    
    # Step 5: 生成报告
    - name: "生成报告"
      action: "generate_report"
      timeout: 600
      parameters:
        format: ["pdf", "json"]
        include_iocs: true
        include_timeline: true
EOF

# 创建钓鱼事件 Runbook
cat > ~/runbooks/phishing-incident.yaml << 'EOF'
version: "1.0"
runbook:
  name: "钓鱼事件响应"
  description: "检测到钓鱼邮件时的自动化响应流程"
  
  triggers:
    - email_report: "phishing"
    - siem_alert: "suspicious_email"
    - user_report: "suspicious_link"
  
  steps:
    # Step 1: 分析邮件头
    - name: "分析邮件头"
      action: "analyze_email_header"
      timeout: 300
      parameters:
        extract_iocs: true
        check_spf_dkim: true
    
    # Step 2: 检查收件人
    - name: "检查收件人"
      action: "check_recipients"
      timeout: 600
      parameters:
        check_clicks: true
        check_downloads: true
    
    # Step 3: 隔离邮件
    - name: "隔离邮件"
      action: "quarantine_email"
      timeout: 120
      conditions:
        - analysis_result == "malicious"
    
    # Step 4: 阻断 URL
    - name: "阻断 URL"
      action: "block_urls"
      timeout: 180
      parameters:
        proxy_block: true
        firewall_block: true
    
    # Step 5: 生成报告
    - name: "生成报告"
      action: "generate_report"
      timeout: 600
      parameters:
        format: ["pdf", "json"]
        include_email_headers: true
        include_user_actions: true
EOF

# 应用 Runbook
openclaw runbooks apply ~/runbooks/*.yaml
```

### 7. 配置通知和升级

#### 创建通知策略

```bash
# 创建通知配置
cat > incident-notifications.yaml << 'EOF'
version: "1.0"
notifications:
  # 事件检测
  incident_detected:
    channels: ["email", "slack", "sms"]
    recipients: ["soc@company.com", "+1234567890"]
    immediate: true
    escalation: 
      - after: "15m"
        channels: ["phone"]
        recipients: ["soc-manager@company.com"]
  
  # 关键发现
  critical_finding:
    channels: ["email", "slack", "sms", "phone"]
    recipients: ["soc@company.com", "ciso@company.com"]
    immediate: true
  
  # 事件关闭
  incident_closed:
    channels: ["email", "slack"]
    recipients: ["soc@company.com", "management@company.com"]
  
  # 升级策略
  escalation_policy:
    - level: 1
      time: "15m"
      contacts: ["soc-engineer@company.com"]
    - level: 2
      time: "30m"
      contacts: ["soc-manager@company.com"]
    - level: 3
      time: "1h"
      contacts: ["ciso@company.com"]
EOF

# 应用通知策略
openclaw notifications apply incident-notifications.yaml
```

### 8. 验证安装

#### 运行测试事件响应

```bash
# 测试恶意软件事件响应
openclaw tasks submit --agent incident-responder \
  --input "模拟 Cobalt Strike beacon 检测事件" \
  --timeout 1800

# 测试钓鱼事件响应
openclaw tasks submit --agent incident-responder \
  --input "模拟钓鱼邮件事件" \
  --timeout 900

# 测试证据收集
openclaw tasks submit --agent incident-responder \
  --input "收集测试主机的易失性证据" \
  --timeout 600
```

#### 验证输出

成功的事件响应应该生成：
1. **事件报告**（PDF/JSON/HTML）
2. **证据链**（内存转储、网络捕获、日志）
3. **IOC 列表**（IP、域名、文件哈希）
4. **攻击时间线**（MITRE ATT&CK 映射）
5. **修复建议**（具体步骤）

### 9. 集成到 SIEM

#### Splunk 集成

```bash
# 创建 Splunk 集成脚本
cat > ~/scripts/splunk-integration.sh << 'EOF'
#!/bin/bash

# 从 Splunk 接收告警
ALERT_DATA=$1

# 解析告警
ALERT_TYPE=$(echo $ALERT_DATA | jq -r '.alert_type')
HOST=$(echo $ALERT_DATA | jq -r '.host')
SEVERITY=$(echo $ALERT_DATA | jq -r '.severity')

# 提交到 OpenClaw
openclaw tasks submit --agent incident-responder \
  --input "处理 $ALERT_TYPE 事件，主机: $HOST，严重性: $SEVERITY" \
  --timeout 3600

# 记录到日志
echo "$(date): 处理事件 $ALERT_TYPE 在主机 $HOST" >> /evidence/events.log
EOF

chmod +x ~/scripts/splunk-integration.sh

# 在 Splunk 中配置 webhook
# 在 Splunk 告警动作中添加 webhook:
# URL: https://openclaw.company.com/api/webhook/splunk
# Method: POST
# Payload: $result$
```

#### Elastic 集成

```bash
# 创建 Elastic 集成脚本
cat > ~/scripts/elastic-integration.sh << 'EOF'
#!/bin/bash

# 从 Elastic 接收告警
ALERT_DATA=$1

# 解析告警
ALERT_TYPE=$(echo $ALERT_DATA | jq -r '.alert_type')
HOST=$(echo $ALERT_DATA | jq -r '.host.name')
SEVERITY=$(echo $ALERT_DATA | jq -r '.kibana.alert.severity')

# 提交到 OpenClaw
openclaw tasks submit --agent incident-responder \
  --input "处理 $ALERT_TYPE 事件，主机: $HOST，严重性: $SEVERITY" \
  --timeout 3600

# 记录到日志
echo "$(date): 处理事件 $ALERT_TYPE 在主机 $HOST" >> /evidence/events.log
EOF

chmod +x ~/scripts/elastic-integration.sh

# 在 Elastic 中配置 webhook
# 在 Elastic 告警动作中添加 webhook:
# URL: https://openclaw.company.com/api/webhook/elastic
# Method: POST
# Body: {{context}}
```

### 10. 故障排除

#### 常见问题

**问题 1**: 内存转储失败
```bash
# 解决方案：检查权限和磁盘空间
sudo df -h /evidence
sudo chmod 755 /evidence/memory
```

**问题 2**: SIEM 集成失败
```bash
# 解决方案：检查网络连接
curl -k https://splunk.company.com:8089/services/search/jobs
# 检查凭证
openclaw siem test-connection
```

**问题 3**: 任务执行超时
```bash
# 解决方案：增加超时时间
openclaw tasks submit --agent incident-responder \
  --input "处理..." \
  --timeout 7200  # 2 小时
```

**问题 4**: 报告生成失败
```bash
# 解决方案：检查磁盘空间和权限
df -h /evidence
ls -la /evidence/reports
```

### 11. 卸载

```bash
# 停止工具容器
docker-compose down

# 卸载 skills
openclaw skills uninstall conducting-malware-incident-response
openclaw skills uninstall conducting-phishing-incident-response
openclaw skills uninstall collecting-volatile-evidence-from-compromised-host
openclaw skills uninstall analyzing-memory-dumps-with-volatility
openclaw skills uninstall analyzing-network-traffic-for-incidents
openclaw skills uninstall generating-threat-intelligence-reports

# 删除 agent
openclaw agents delete incident-responder

# 清理配置文件
rm -f incident-response-agent.json
rm -f siem-integration.yaml edr-integration.yaml
rm -f incident-notifications.yaml
rm -rf ~/runbooks
rm -rf ~/scripts

# 清理证据（谨慎操作）
sudo rm -rf /evidence/*
```

## 支持

如需帮助，请联系：
- 技术文档：https://docs.openclaw.dev/enterprise/incident-response
- 支持邮箱：enterprise@openclaw.dev
- 紧急支持：400-xxx-xxxx（Business 及以上套餐）
