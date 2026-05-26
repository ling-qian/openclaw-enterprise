#!/bin/bash
# install-adjusted-bundles.sh
# Phase 1: 安装调整后的 bundle skills（基于 ClawHub 实际可用性）

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 OpenClaw CLI 是否安装
check_openclaw() {
    if ! command -v openclaw &> /dev/null; then
        log_error "OpenClaw CLI 未安装，请先安装: npm install -g openclaw"
        exit 1
    fi
    log_info "OpenClaw CLI 已安装: $(openclaw --version)"
}

# 安装单个 skill
install_skill() {
    local skill_name=$1
    local skill_slug=$2
    
    log_info "安装 $skill_name ($skill_slug)..."
    
    if openclaw skills install "$skill_slug" 2>&1; then
        log_info "✅ $skill_name 安装成功"
        return 0
    else
        log_error "❌ $skill_name 安装失败"
        return 1
    fi
}

# 主函数
main() {
    log_info "开始 Phase 1: 安装调整后的 Bundle Skills"
    echo "=========================================="
    
    # 检查 OpenClaw CLI
    check_openclaw
    
    # 统计变量
    total_skills=0
    installed_skills=0
    failed_skills=0
    
    # 定义调整后的安全审计 skills
    declare -a security_audit_skills=(
        "AWS S3 Bucket Audit:auditing-aws-s3"
        "Sx Security Audit:sx-security-audit-1-0-0"
        "Cloud CIS Benchmarks:auditing-cis-benchmarks"
        "Security Audit:security-audit"
        "Kubernetes RBAC Audit:auditing-k8s-rbac"
        "Terraform Security Audit:auditing-terraform-security"
    )
    
    # 定义调整后的渗透测试 skills
    declare -a penetration_test_skills=(
        "Pentest Workbench:ah-penetration-tester"
        "Penetration Testing Setup:pilot-penetration-testing-setup"
        "SSH Penetration Testing:fix-erlang-ssh-cve-ssh-penetration-testing"
        "Web App Pentest Methodology:bookforge-web-application-penetration-testing-methodology"
        "Access Control Testing:bookforge-access-control-vulnerability-testing"
        "Pentest Commands:pentest-commands"
    )
    
    # 定义调整后的事件响应 skills
    declare -a incident_response_skills=(
        "Incident Response:incident-response"
        "Incident Response Playbook:afrexai-incident-response-playbook"
        "Incident Response Network:incident-response-network"
        "Incident Response Lifecycle:incident-response-lifecycle"
        "K8s Incident Response:k8s-incident-response-playbook"
        "Agent Incident Response:greenhelix-agent-incident-response"
    )
    
    # 安装安全审计 skills
    echo ""
    log_info "安装安全审计 Bundle Skills..."
    echo "------------------------------------------"
    
    for skill in "${security_audit_skills[@]}"; do
        IFS=':' read -r skill_name skill_slug <<< "$skill"
        ((total_skills++))
        
        if install_skill "$skill_name" "$skill_slug"; then
            ((installed_skills++))
        else
            ((failed_skills++))
        fi
    done
    
    # 安装渗透测试 skills
    echo ""
    log_info "安装渗透测试 Bundle Skills..."
    echo "------------------------------------------"
    
    for skill in "${penetration_test_skills[@]}"; do
        IFS=':' read -r skill_name skill_slug <<< "$skill"
        ((total_skills++))
        
        if install_skill "$skill_name" "$skill_slug"; then
            ((installed_skills++))
        else
            ((failed_skills++))
        fi
    done
    
    # 安装事件响应 skills
    echo ""
    log_info "安装事件响应 Bundle Skills..."
    echo "------------------------------------------"
    
    for skill in "${incident_response_skills[@]}"; do
        IFS=':' read -r skill_name skill_slug <<< "$skill"
        ((total_skills++))
        
        if install_skill "$skill_name" "$skill_slug"; then
            ((installed_skills++))
        else
            ((failed_skills++))
        fi
    done
    
    # 验证所有已安装的 skills
    echo ""
    log_info "验证所有已安装的 skills..."
    echo "------------------------------------------"
    
    # 列出所有已安装的 skills
    openclaw skills list | grep -E "auditing|sx-security|security-audit|pentest|penetration|incident-response" || true
    
    # 输出统计结果
    echo ""
    echo "=========================================="
    log_info "安装完成！统计结果："
    echo "总 skills 数: $total_skills"
    echo "安装成功: $installed_skills"
    echo "安装失败: $failed_skills"
    
    if [ $failed_skills -eq 0 ]; then
        log_info "🎉 所有 skills 安装成功！"
        exit 0
    else
        log_warn "⚠️  有 $failed_skills 个 skills 安装失败，请检查日志"
        exit 1
    fi
}

# 执行主函数
main "$@"
