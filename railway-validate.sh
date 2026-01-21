#!/bin/bash
# Railway Environment Validation Script
# Checks if all required environment variables are set before deployment

set -e

echo "================================================"
echo "  Railway Environment Validation"
echo "================================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

errors=0
warnings=0

check_required() {
    local var_name=$1
    local description=$2

    if railway variables get "$var_name" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $var_name - $description"
    else
        echo -e "${RED}✗${NC} $var_name - $description (MISSING)"
        ((errors++))
    fi
}

check_optional() {
    local var_name=$1
    local description=$2

    if railway variables get "$var_name" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $var_name - $description"
    else
        echo -e "${YELLOW}⚠${NC} $var_name - $description (optional, not set)"
        ((warnings++))
    fi
}

check_railway_cli() {
    if ! command -v railway &> /dev/null; then
        echo -e "${RED}ERROR: Railway CLI is not installed!${NC}"
        echo "Install with: npm install -g @railway/cli"
        exit 1
    fi
}

check_railway_login() {
    if ! railway whoami &> /dev/null; then
        echo -e "${RED}ERROR: Not logged in to Railway!${NC}"
        echo "Login with: railway login"
        exit 1
    fi
}

# Main validation
main() {
    echo "Checking prerequisites..."
    check_railway_cli
    check_railway_login

    echo ""
    echo "=== Required Variables ==="
    check_required "LLM_API_KEY" "LLM API key for AI functionality"
    check_required "LLM_MODEL" "LLM model name (e.g., gpt-4o)"
    check_required "JWT_SECRET" "Secret for JWT authentication"
    check_required "WORKSPACE_BASE" "Base directory for workspace"
    check_required "WORKSPACE_MOUNT_PATH" "Workspace mount path"
    check_required "FILE_STORE" "File storage type"
    check_required "FILE_STORE_PATH" "File storage path"
    check_required "RUNTIME" "Runtime environment (e2b, modal, docker)"

    # Check runtime-specific variables
    echo ""
    echo "=== Runtime-Specific Variables ==="
    runtime=$(railway variables get RUNTIME 2>/dev/null || echo "")

    case $runtime in
        "e2b")
            check_required "E2B_API_KEY" "E2B API key for sandbox runtime"
            ;;
        "modal")
            check_required "MODAL_API_KEY" "Modal API key"
            check_required "MODAL_SECRET" "Modal secret"
            ;;
        "docker")
            check_required "DOCKER_HOST" "Remote Docker host URL"
            echo -e "${YELLOW}⚠${NC} Warning: Railway doesn't support Docker socket. Consider using E2B or Modal instead."
            ;;
        *)
            echo -e "${RED}✗${NC} RUNTIME variable not set or invalid"
            ((errors++))
            ;;
    esac

    echo ""
    echo "=== Optional Variables ==="
    check_optional "DEBUG" "Debug mode flag"
    check_optional "MAX_ITERATIONS" "Maximum iterations per task"
    check_optional "MAX_BUDGET_PER_TASK" "Maximum budget per task"
    check_optional "CONFIRMATION_MODE" "Security confirmation mode"
    check_optional "ENABLE_SECURITY_ANALYZER" "Security analyzer flag"
    check_optional "SANDBOX_RUNTIME_CONTAINER_IMAGE" "Runtime container image"

    echo ""
    echo "=== Validation Summary ==="
    echo -e "Errors: ${RED}$errors${NC}"
    echo -e "Warnings: ${YELLOW}$warnings${NC}"
    echo ""

    if [ $errors -gt 0 ]; then
        echo -e "${RED}Validation FAILED!${NC}"
        echo "Please set the missing required variables before deploying."
        echo ""
        echo "Quick fix:"
        echo "  Run './railway-setup.sh' for interactive setup"
        echo "  Or manually set variables with 'railway variables set KEY=value'"
        exit 1
    else
        echo -e "${GREEN}Validation PASSED!${NC}"
        echo ""
        echo "Your environment is ready for deployment!"
        echo ""
        echo "Next steps:"
        echo "  1. Deploy: railway up"
        echo "  2. Monitor: railway logs --follow"
        echo "  3. Open app: railway open"
        echo ""

        if [ $warnings -gt 0 ]; then
            echo -e "${YELLOW}Note:${NC} You have $warnings optional variables not set."
            echo "These are not required but may enhance functionality."
        fi
    fi
}

# Check if railway CLI is available before running main
if ! command -v railway &> /dev/null; then
    echo -e "${RED}ERROR: Railway CLI is not installed!${NC}"
    echo ""
    echo "Install Railway CLI first:"
    echo "  npm install -g @railway/cli"
    echo "  brew install railway"
    echo "  curl -fsSL https://railway.app/install.sh | sh"
    exit 1
fi

main
