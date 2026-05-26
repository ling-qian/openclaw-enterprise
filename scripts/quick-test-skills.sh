#!/bin/bash
# quick-test-skills.sh
# 快速测试所有已安装的 skills

set -e

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "=========================================="
echo "Phase 1: 快速技能验证"
echo "=========================================="

# 定义所有 skills
declare -a all_skills=(
    "auditing-aws-s3"
    "sx-security-audit-1-0-0"
    "auditing-cis-benchmarks"
    "security-audit"
    "auditing-k8s-rbac"
    "auditing-terraform-security"
    "ah-penetration-tester"
    "pilot-penetration-testing-setup"
    "fix-erlang-ssh-cve-ssh-penetration-testing"
    "bookforge-web-application-penetration-testing-methodology"
    "bookforge-access-control-vulnerability-testing"
    "pentest-commands"
    "incident-response"
    "incident-response-network"
    "incident-response-lifecycle"
    "k8s-incident-response-playbook"
    "greenhelix-agent-incident-response"
)

# 统计
total=0
installed=0
missing=0

echo ""
echo "检查 skills 安装状态..."
echo "------------------------------------------"

for skill in "${all_skills[@]}"; do
    ((total++))
    
    if [ -d "$HOME/.openclaw/workspace/skills/$skill" ]; then
        echo -e "${GREEN}✓${NC} $skill"
        ((installed++))
    else
        echo -e "${RED}✗${NC} $skill"
        ((missing++))
    fi
done

echo ""
echo "=========================================="
echo "测试结果汇总"
echo "=========================================="
echo "总 skills 数: $total"
echo "已安装: $installed"
echo "缺失: $missing"
echo ""

if [ $missing -eq 0 ]; then
    echo -e "${GREEN}✓ 所有 skills 已安装！${NC}"
    exit 0
else
    echo -e "${RED}✗ 有 $missing 个 skills 缺失${NC}"
    exit 1
fi
