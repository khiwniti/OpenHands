#!/bin/bash
# Railway Deployment Setup Script for OpenHands
# This script helps you configure and deploy OpenHands to Railway

set -e

echo "================================================"
echo "  OpenHands Railway Deployment Setup"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Railway CLI is installed
check_railway_cli() {
    if ! command -v railway &> /dev/null; then
        print_error "Railway CLI is not installed!"
        echo ""
        echo "Install it with one of these methods:"
        echo "  npm install -g @railway/cli"
        echo "  brew install railway"
        echo "  curl -fsSL https://railway.app/install.sh | sh"
        echo ""
        exit 1
    fi
    print_info "Railway CLI is installed ✓"
}

# Check if logged in to Railway
check_railway_login() {
    if ! railway whoami &> /dev/null; then
        print_warn "Not logged in to Railway"
        echo ""
        read -p "Would you like to login now? (y/n): " login_choice
        if [[ "$login_choice" == "y" || "$login_choice" == "Y" ]]; then
            railway login
        else
            print_error "Please run 'railway login' first"
            exit 1
        fi
    fi
    print_info "Logged in to Railway ✓"
}

# Generate a secure JWT secret
generate_jwt_secret() {
    if command -v openssl &> /dev/null; then
        openssl rand -hex 32
    else
        # Fallback if openssl is not available
        cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1
    fi
}

# Main setup
main() {
    echo ""
    print_info "Step 1: Checking prerequisites..."
    check_railway_cli
    check_railway_login

    echo ""
    print_info "Step 2: Choose deployment method"
    echo ""
    echo "1) Initialize new Railway project (recommended for first-time setup)"
    echo "2) Link to existing Railway project"
    echo "3) Set environment variables only"
    echo ""
    read -p "Select option (1-3): " setup_option

    case $setup_option in
        1)
            print_info "Initializing new Railway project..."
            railway init
            ;;
        2)
            print_info "Linking to existing project..."
            railway link
            ;;
        3)
            print_info "Skipping project initialization..."
            ;;
        *)
            print_error "Invalid option"
            exit 1
            ;;
    esac

    echo ""
    print_info "Step 3: Configure environment variables"
    echo ""

    # LLM Configuration
    echo "=== LLM Configuration ==="
    read -p "Enter your LLM API key (OpenAI, Anthropic, etc.): " llm_api_key
    read -p "Enter LLM model name (default: gpt-4o): " llm_model
    llm_model=${llm_model:-gpt-4o}

    # Runtime Configuration
    echo ""
    echo "=== Runtime Configuration ==="
    echo "Railway doesn't support Docker socket access."
    echo "Available runtime options:"
    echo "  1) E2B (Recommended - https://e2b.dev)"
    echo "  2) Modal (https://modal.com)"
    echo "  3) Remote Docker (requires your own Docker host)"
    echo ""
    read -p "Select runtime option (1-3): " runtime_option

    case $runtime_option in
        1)
            runtime_type="e2b"
            read -p "Enter your E2B API key: " runtime_api_key
            ;;
        2)
            runtime_type="modal"
            read -p "Enter your Modal API key: " modal_api_key
            read -p "Enter your Modal secret: " modal_secret
            ;;
        3)
            runtime_type="docker"
            read -p "Enter your Docker host (e.g., tcp://host:2375): " docker_host
            ;;
        *)
            print_error "Invalid option"
            exit 1
            ;;
    esac

    # Generate JWT secret
    echo ""
    print_info "Generating secure JWT secret..."
    jwt_secret=$(generate_jwt_secret)

    # Optional: Database
    echo ""
    echo "=== Database Configuration (Optional) ==="
    read -p "Do you want to add PostgreSQL for persistence? (y/n): " add_db

    echo ""
    print_info "Step 4: Setting environment variables in Railway..."
    echo ""

    # Set required variables
    railway variables set LLM_API_KEY="$llm_api_key"
    railway variables set LLM_MODEL="$llm_model"
    railway variables set JWT_SECRET="$jwt_secret"
    railway variables set WORKSPACE_BASE="/opt/workspace_base"
    railway variables set WORKSPACE_MOUNT_PATH="/opt/workspace_base"
    railway variables set FILE_STORE="local"
    railway variables set FILE_STORE_PATH="/.openhands"
    railway variables set SANDBOX_RUNTIME_CONTAINER_IMAGE="docker.openhands.dev/openhands/runtime:1.2-nikolaik"

    # Set runtime-specific variables
    case $runtime_option in
        1)
            railway variables set RUNTIME="e2b"
            railway variables set E2B_API_KEY="$runtime_api_key"
            ;;
        2)
            railway variables set RUNTIME="modal"
            railway variables set MODAL_API_KEY="$modal_api_key"
            railway variables set MODAL_SECRET="$modal_secret"
            ;;
        3)
            railway variables set RUNTIME="docker"
            railway variables set DOCKER_HOST="$docker_host"
            ;;
    esac

    # Set optional variables
    railway variables set DEBUG="false"
    railway variables set MAX_ITERATIONS="500"
    railway variables set MAX_BUDGET_PER_TASK="0.0"

    # Add PostgreSQL if requested
    if [[ "$add_db" == "y" || "$add_db" == "Y" ]]; then
        print_info "Adding PostgreSQL service..."
        railway add -s postgres
        print_info "PostgreSQL added! Link it to your service in the Railway dashboard."
    fi

    echo ""
    print_info "Step 5: Deploy to Railway"
    echo ""
    read -p "Would you like to deploy now? (y/n): " deploy_now

    if [[ "$deploy_now" == "y" || "$deploy_now" == "Y" ]]; then
        print_info "Deploying to Railway..."
        railway up
        echo ""
        print_info "Deployment initiated! Check your Railway dashboard for progress."
    else
        print_info "Skipping deployment. Run 'railway up' when ready."
    fi

    echo ""
    echo "================================================"
    print_info "Setup Complete! 🎉"
    echo "================================================"
    echo ""
    echo "Next steps:"
    echo "  1. Monitor deployment: railway logs"
    echo "  2. Open your app: railway open"
    echo "  3. View variables: railway variables"
    echo "  4. Check status: railway status"
    echo ""
    echo "Documentation: See RAILWAY.md for more details"
    echo ""
}

# Run main function
main
