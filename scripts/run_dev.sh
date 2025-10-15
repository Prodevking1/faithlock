#!/bin/bash

# FastApp Development Environment Runner
# Usage: ./scripts/run_dev.sh [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT="dev"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

echo -e "${BLUE}🚀 FastApp Development Environment${NC}"
echo -e "${BLUE}===================================${NC}"

# Check Flutter installation
check_flutter() {
    echo -e "${YELLOW}📱 Checking Flutter installation...${NC}"
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
        echo -e "${YELLOW}💡 Please install Flutter: https://flutter.dev/docs/get-started/install${NC}"
        exit 1
    fi
    
    flutter --version
    echo -e "${GREEN}✅ Flutter is ready${NC}"
}

# Check dependencies
check_dependencies() {
    echo -e "${YELLOW}📦 Checking dependencies...${NC}"
    
    # Check if pubspec.lock exists
    if [ ! -f "$PROJECT_ROOT/pubspec.lock" ]; then
        echo -e "${YELLOW}📦 Installing dependencies...${NC}"
        cd "$PROJECT_ROOT"
        flutter pub get
    fi
    
    echo -e "${GREEN}✅ Dependencies are ready${NC}"
}

# Setup environment
setup_environment() {
    echo -e "${YELLOW}🔧 Setting up development environment...${NC}"
    
    # Check if .env file exists
    if [ ! -f "$ENV_FILE" ]; then
        echo -e "${YELLOW}📝 Creating .env file from template...${NC}"
        cat > "$ENV_FILE" << EOF
# FastApp Development Environment Variables
# Copy this file and update with your actual values

# Supabase Configuration
SUPABASE_URL=your-supabase-project-url
SUPABASE_ANON_KEY=your-supabase-anon-key

# Google Maps
GOOGLE_MAP_KEY=your-google-maps-api-key

# Development Settings
DEBUG_MODE=true
ENVIRONMENT=development

# Analytics (Optional)
AMPLITUDE_API_KEY=your-amplitude-key
POSTHOG_API_KEY=your-posthog-key

# OneSignal (Optional)
ONESIGNAL_APP_ID=your-onesignal-app-id

# Sentry (Optional)
SENTRY_DSN=your-sentry-dsn
EOF
        echo -e "${YELLOW}⚠️  Please update .env file with your actual values${NC}"
        echo -e "${BLUE}📖 Check CLAUDE.md for environment setup guide${NC}"
    fi
    
    echo -e "${GREEN}✅ Environment setup complete${NC}"
}

# Generate code
generate_code() {
    echo -e "${YELLOW}🔨 Generating code...${NC}"
    cd "$PROJECT_ROOT"
    
    # Generate environment files
    if [ -f "pubspec.yaml" ] && grep -q "envied" pubspec.yaml; then
        echo -e "${YELLOW}📝 Generating environment files...${NC}"
        flutter packages pub run build_runner build --delete-conflicting-outputs
    fi
    
    echo -e "${GREEN}✅ Code generation complete${NC}"
}

# Run the app
run_app() {
    echo -e "${YELLOW}🚀 Starting FastApp in development mode...${NC}"
    cd "$PROJECT_ROOT"
    
    # Run with development configuration
    flutter run \
        --dart-define=ENVIRONMENT=development \
        --dart-define=DEBUG_MODE=true \
        --hot-reload \
        --track-widget-creation \
        --verbose
}

# Help function
show_help() {
    echo -e "${BLUE}FastApp Development Runner${NC}"
    echo ""
    echo "Usage: ./scripts/run_dev.sh [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --check-only   Only run checks without starting the app"
    echo "  --no-gen       Skip code generation"
    echo "  --clean        Clean and rebuild everything"
    echo ""
    echo "Examples:"
    echo "  ./scripts/run_dev.sh                 # Run in development mode"
    echo "  ./scripts/run_dev.sh --check-only    # Only run checks"
    echo "  ./scripts/run_dev.sh --clean         # Clean rebuild"
}

# Parse command line arguments
CHECK_ONLY=false
NO_GEN=false
CLEAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --check-only)
            CHECK_ONLY=true
            shift
            ;;
        --no-gen)
            NO_GEN=true
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Main execution
main() {
    echo -e "${BLUE}🏁 Starting development workflow...${NC}"
    
    # Clean if requested
    if [ "$CLEAN" = true ]; then
        echo -e "${YELLOW}🧹 Cleaning project...${NC}"
        cd "$PROJECT_ROOT"
        flutter clean
        flutter pub get
    fi
    
    # Run checks
    check_flutter
    check_dependencies
    setup_environment
    
    # Generate code if not skipped
    if [ "$NO_GEN" = false ]; then
        generate_code
    fi
    
    # Exit if check-only mode
    if [ "$CHECK_ONLY" = true ]; then
        echo -e "${GREEN}✅ All checks passed! Ready for development.${NC}"
        exit 0
    fi
    
    # Run the app
    run_app
}

# Run main function
main "$@"