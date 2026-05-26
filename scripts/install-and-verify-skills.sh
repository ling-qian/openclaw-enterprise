#!/bin/bash
# install-and-verify-skills.sh
# Phase 1: 安装和验证所有 bundle 所需的 skills

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

# 验证 skill 是否安装
verify_skill() {
    local skill_slug=$1
    
    if openclaw skills list | grep -q "$skill_slug"; then
        return 0
    else
        return 1
    fi
}

# 测试 skill 基本功能
test_skill() {
    local skill_name=$1
    local skill_slug=$2
    
    log_info "测试 $skill_name 基本功能..."
    
    # 这里可以添加具体的测试命令
    # 例如：openclaw skills test $skill_slug --quick
    
    # 暂时只检查 skill 是否可用
    if verify_skill "$skill_slug"; then
        log_info "✅ $skill_name 验证通过"
        return 0
    else
        log_error "❌ $skill_name 验证失败"
        return 1
    fi
}

# 主函数
main() {
    log_info "开始 Phase 1: 技能安装和验证"
    echo "=========================================="
    
    # 检查 OpenClaw CLI
    check_openclaw
    
    # 统计变量
    total_skills=0
    installed_skills=0
    failed_skills=0
    
    # 定义所有 skills
    declare -a security_audit_skills=(
        "AWS S3 Bucket Audit:auditing-aws-s3"
        "Azure AD Configuration:auditing-azure-ad"
        "Cloud CIS Benchmarks:auditing-cis-benchmarks"
        "GCP IAM Permissions:auditing-gcp-iam"
        "Kubernetes RBAC Audit:auditing-k8s-rbac"
        "Terraform Security Audit:auditing-terraform-security"
    )
    
    declare -a penetration_test_skills=(
        "Network Penetration Test:conducting-network-penetration-test"
        "API Security Testing:conducting-api-security-testing"
        "Cloud Penetration Testing:conducting-cloud-penetration-testing"
        "Mobile App Penetration Test:conducting-mobile-app-penetration-test"
        "Web Application Penetration Test:performing-web-application-penetration-test"
        "SQL Injection Exploitation:exploiting-sql-injection-with-sqlmap"
    )
    
    declare -a incident_response_skills=(
        "Malware Incident Response:conducting-malware-incident-response"
        "Phishing Incident Response:conducting-phishing-incident-response"
        "Volatile Evidence Collection:collecting-volatile-evidence-from-compromised-host"
        "Memory Dump Analysis:analyzing-memory-dumps-with-volatility"
        "Network Traffic Analysis:analyzing-network-traffic-for-incidents"
        "Threat Intelligence Report:generating-threat-intelligence-reports"
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
    openclaw skills list | grep -E "auditing|conducting|performing|exploiting|collecting|analyzing|generating" || true
    
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
