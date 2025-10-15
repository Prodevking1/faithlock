#!/bin/bash

# FastApp Staging Environment Runner
# Usage: ./scripts/run_staging.sh [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT="staging"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env.staging"

echo -e "${BLUE}🚀 FastApp Staging Environment${NC}"
echo -e "${BLUE}==============================${NC}"

# Check Flutter installation
check_flutter() {
    echo -e "${YELLOW}📱 Checking Flutter installation...${NC}"
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
        exit 1
    fi
    
    flutter --version
    echo -e "${GREEN}✅ Flutter is ready${NC}"
}

# Setup staging environment
setup_staging_environment() {
    echo -e "${YELLOW}🔧 Setting up staging environment...${NC}"
    
    # Check if staging .env file exists
    if [ ! -f "$ENV_FILE" ]; then
        echo -e "${YELLOW}📝 Creating staging .env file...${NC}"
        cat > "$ENV_FILE" << EOF
# FastApp Staging Environment Variables
# These should point to your staging/test environment

# Supabase Staging Configuration
SUPABASE_URL=your-staging-supabase-url
SUPABASE_ANON_KEY=your-staging-supabase-anon-key

# Google Maps (can be same as dev)
GOOGLE_MAP_KEY=your-google-maps-api-key

# Staging Settings
DEBUG_MODE=false
ENVIRONMENT=staging

# Analytics Staging
AMPLITUDE_API_KEY=your-staging-amplitude-key
POSTHOG_API_KEY=your-staging-posthog-key

# OneSignal Staging
ONESIGNAL_APP_ID=your-staging-onesignal-app-id

# Sentry Staging
SENTRY_DSN=your-staging-sentry-dsn
EOF
        echo -e "${YELLOW}⚠️  Please update .env.staging file with your staging values${NC}"
    fi
    
    echo -e "${GREEN}✅ Staging environment setup complete${NC}"
}

# Check dependencies
check_dependencies() {
    echo -e "${YELLOW}📦 Checking dependencies...${NC}"
    cd "$PROJECT_ROOT"
    
    if [ ! -f "pubspec.lock" ]; then
        echo -e "${YELLOW}📦 Installing dependencies...${NC}"
        flutter pub get
    fi
    
    echo -e "${GREEN}✅ Dependencies are ready${NC}"
}

# Generate code
generate_code() {
    echo -e "${YELLOW}🔨 Generating code...${NC}"
    cd "$PROJECT_ROOT"
    
    # Generate environment files with staging config
    if [ -f "pubspec.yaml" ] && grep -q "envied" pubspec.yaml; then
        echo -e "${YELLOW}📝 Generating staging environment files...${NC}"
        flutter packages pub run build_runner build --delete-conflicting-outputs
    fi
    
    echo -e "${GREEN}✅ Code generation complete${NC}"
}

# Run tests
run_tests() {
    echo -e "${YELLOW}🧪 Running tests...${NC}"
    cd "$PROJECT_ROOT"
    
    # Run unit tests
    flutter test
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ All tests passed${NC}"
    else
        echo -e "${RED}❌ Some tests failed${NC}"
        exit 1
    fi
}

# Run app in staging mode
run_staging() {
    echo -e "${YELLOW}🚀 Starting FastApp in staging mode...${NC}"
    cd "$PROJECT_ROOT"
    
    # Run with staging configuration
    flutter run \
        --dart-define=ENVIRONMENT=staging \
        --dart-define=DEBUG_MODE=false \
        --dart-define-from-file=.env.staging \
        --release \
        --verbose
}

# Build for staging
build_staging() {
    echo -e "${YELLOW}🔨 Building staging version...${NC}"
    cd "$PROJECT_ROOT"
    
    # Build APK with staging configuration
    flutter build apk \
        --dart-define=ENVIRONMENT=staging \
        --dart-define=DEBUG_MODE=false \
        --dart-define-from-file=.env.staging \
        --release
    
    echo -e "${GREEN}✅ Staging build complete${NC}"
    echo -e "${BLUE}📁 APK: build/app/outputs/flutter-apk/app-release.apk${NC}"
}

# Help function
show_help() {
    echo -e "${BLUE}FastApp Staging Runner${NC}"
    echo ""
    echo "Usage: ./scripts/run_staging.sh [options]"
    echo ""
    echo "Options:"
    echo "  --run      Run app in staging mode"
    echo "  --build    Build staging APK"
    echo "  --test     Run tests before staging"
    echo "  --clean    Clean and rebuild everything"
    echo "  -h, --help Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./scripts/run_staging.sh --run     # Run in staging mode"
    echo "  ./scripts/run_staging.sh --build   # Build staging APK"
    echo "  ./scripts/run_staging.sh --test    # Run tests"
}

# Parse command line arguments
RUN_APP=false
BUILD_APP=false
RUN_TESTS=false
CLEAN=false

# Default action if no args
if [ $# -eq 0 ]; then
    RUN_APP=true
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --run)
            RUN_APP=true
            shift
            ;;
        --build)
            BUILD_APP=true
            shift
            ;;
        --test)
            RUN_TESTS=true
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
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
    echo -e "${BLUE}🏁 Starting staging workflow...${NC}"
    
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
    setup_staging_environment
    generate_code
    
    # Run tests if requested
    if [ "$RUN_TESTS" = true ]; then
        run_tests
    fi
    
    # Build if requested
    if [ "$BUILD_APP" = true ]; then
        build_staging
    fi
    
    # Run app if requested
    if [ "$RUN_APP" = true ]; then
        run_staging
    fi
    
    echo -e "${GREEN}✅ Staging workflow completed!${NC}"
}

# Run main function
main "$@"