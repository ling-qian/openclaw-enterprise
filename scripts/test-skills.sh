#!/bin/bash
# test-skills.sh
# Phase 1: 测试所有 bundle 所需的 skills 基本功能

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

# 创建测试目录
create_test_dir() {
    local test_dir="./test-results"
    mkdir -p "$test_dir"
    echo "$test_dir"
}

# 测试单个 skill
test_skill() {
    local skill_name=$1
    local skill_slug=$2
    local test_type=$3
    
    log_test "测试 $skill_name ($test_type)..."
    
    # 创建测试结果文件
    local test_dir=$(create_test_dir)
    local test_file="$test_dir/${skill_slug}-test.json"
    
    # 根据测试类型执行不同的测试
    case $test_type in
        "install")
            # 测试安装
            if openclaw skills list | grep -q "$skill_slug"; then
                echo '{"status": "pass", "test": "install", "message": "Skill 已安装"}' > "$test_file"
                return 0
            else
                echo '{"status": "fail", "test": "install", "message": "Skill 未安装"}' > "$test_file"
                return 1
            fi
            ;;
        "help")
            # 测试帮助命令
            if openclaw skills help "$skill_slug" &> /dev/null; then
                echo '{"status": "pass", "test": "help", "message": "帮助命令可用"}' > "$test_file"
                return 0
            else
                echo '{"status": "fail", "test": "help", "message": "帮助命令不可用"}' > "$test_file"
                return 1
            fi
            ;;
        "config")
            # 测试配置检查
            if openclaw skills config "$skill_slug" --check &> /dev/null; then
                echo '{"status": "pass", "test": "config", "message": "配置检查通过"}' > "$test_file"
                return 0
            else
                echo '{"status": "warn", "test": "config", "message": "配置检查失败或不可用"}' > "$test_file"
                return 0  # 配置检查失败不一定是错误
            fi
            ;;
        *)
            log_error "未知的测试类型: $test_type"
            return 1
            ;;
    esac
}

# 测试安全审计 bundle
test_security_audit_bundle() {
    log_info "测试安全审计 Bundle..."
    echo "------------------------------------------"
    
    local skills=(
        "AWS S3 Bucket Audit:auditing-aws-s3"
        "Azure AD Configuration:auditing-azure-ad"
        "Cloud CIS Benchmarks:auditing-cis-benchmarks"
        "GCP IAM Permissions:auditing-gcp-iam"
        "Kubernetes RBAC Audit:auditing-k8s-rbac"
        "Terraform Security Audit:auditing-terraform-security"
    )
    
    local passed=0
    local failed=0
    
    for skill in "${skills[@]}"; do
        IFS=':' read -r skill_name skill_slug <<< "$skill"
        
        if test_skill "$skill_name" "$skill_slug" "install"; then
            ((passed++))
        else
            ((failed++))
        fi
    done
    
    echo ""
    log_info "安全审计 Bundle 测试结果: $passed 通过, $failed 失败"
    return $failed
}

# 测试渗透测试 bundle
test_penetration_test_bundle() {
    log_info "测试渗透测试 Bundle..."
    echo "------------------------------------------"
    
    local skills=(
        "Network Penetration Test:conducting-network-penetration-test"
        "API Security Testing:conducting-api-security-testing"
        "Cloud Penetration Testing:conducting-cloud-penetration-testing"
        "Mobile App Penetration Test:conducting-mobile-app-penetration-test"
        "Web Application Penetration Test:performing-web-application-penetration-test"
        "SQL Injection Exploitation:exploiting-sql-injection-with-sqlmap"
    )
    
    local passed=0
    local failed=0
    
    for skill in "${skills[@]}"; do
        IFS=':' read -r skill_name skill_slug <<< "$skill"
        
        if test_skill "$skill_name" "$skill_slug" "install"; then
            ((passed++))
        else
            ((failed++))
        fi
    done
    
    echo ""
    log_info "渗透测试 Bundle 测试结果: $passed 通过, $failed 失败"
    return $failed
}

# 测试事件响应 bundle
test_incident_response_bundle() {
    log_info "测试事件响应 Bundle..."
    echo "------------------------------------------"
    
    local skills=(
        "Malware Incident Response:conducting-malware-incident-response"
        "Phishing Incident Response:conducting-phishing-incident-response"
        "Volatile Evidence Collection:collecting-volatile-evidence-from-compromised-host"
        "Memory Dump Analysis:analyzing-memory-dumps-with-volatility"
        "Network Traffic Analysis:analyzing-network-traffic-for-incidents"
        "Threat Intelligence Report:generating-threat-intelligence-reports"
    )
    
    local passed=0
    local failed=0
    
    for skill in "${skills[@]}"; do
        IFS=':' read -r skill_name skill_slug <<< "$skill"
        
        if test_skill "$skill_name" "$skill_slug" "install"; then
            ((passed++))
        else
            ((failed++))
        fi
    done
    
    echo ""
    log_info "事件响应 Bundle 测试结果: $passed 通过, $failed 失败"
    return $failed
}

# 生成测试报告
generate_report() {
    local test_dir="./test-results"
    local report_file="$test_dir/test-report-$(date +%Y%m%d-%H%M%S).md"
    
    log_info "生成测试报告: $report_file"
    
    cat > "$report_file" << EOF
# 技能测试报告

**生成时间**: $(date)
**测试环境**: $(uname -a)
**OpenClaw 版本**: $(openclaw --version 2>/dev/null || echo "未知")

## 测试概览

EOF
    
    # 统计测试结果
    local total_tests=$(find "$test_dir" -name "*.json" | wc -l)
    local passed_tests=$(find "$test_dir" -name "*.json" -exec grep -l '"status": "pass"' {} \; | wc -l)
    local failed_tests=$(find "$test_dir" -name "*.json" -exec grep -l '"status": "fail"' {} \; | wc -l)
    local warned_tests=$(find "$test_dir" -name "*.json" -exec grep -l '"status": "warn"' {} \; | wc -l)
    
    cat >> "$report_file" << EOF
| 指标 | 数量 |
|------|------|
| 总测试数 | $total_tests |
| 通过 | $passed_tests |
| 失败 | $failed_tests |
| 警告 | $warned_tests |

## 详细结果

EOF
    
    # 添加详细结果
    for result_file in "$test_dir"/*.json; do
        if [ -f "$result_file" ]; then
            local skill_slug=$(basename "$result_file" .json)
            local status=$(jq -r '.status' "$result_file" 2>/dev/null || echo "unknown")
            local test=$(jq -r '.test' "$result_file" 2>/dev/null || echo "unknown")
            local message=$(jq -r '.message' "$result_file" 2>/dev/null || echo "无消息")
            
            cat >> "$report_file" << EOF
### $skill_slug

- **状态**: $status
- **测试**: $test
- **消息**: $message

EOF
        fi
    done
    
    echo ""
    log_info "测试报告已生成: $report_file"
}

# 主函数
main() {
    log_info "开始 Phase 1: 技能功能测试"
    echo "=========================================="
    
    # 检查 OpenClaw CLI
    if ! command -v openclaw &> /dev/null; then
        log_error "OpenClaw CLI 未安装，请先安装: npm install -g openclaw"
        exit 1
    fi
    
    # 创建测试目录
    local test_dir=$(create_test_dir)
    log_info "测试结果将保存到: $test_dir"
    
    # 测试所有 bundles
    local total_failed=0
    
    test_security_audit_bundle
    total_failed=$((total_failed + $?))
    
    test_penetration_test_bundle
    total_failed=$((total_failed + $?))
    
    test_incident_response_bundle
    total_failed=$((total_failed + $?))
    
    # 生成测试报告
    generate_report
    
    # 输出最终结果
    echo ""
    echo "=========================================="
    if [ $total_failed -eq 0 ]; then
        log_info "🎉 所有测试通过！"
        exit 0
    else
        log_warn "⚠️  有 $total_failed 个测试失败，请检查测试报告"
        exit 1
    fi
}

# 执行主函数
main "$@"
