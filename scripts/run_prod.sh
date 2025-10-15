#!/bin/bash

# FastApp Production Environment Runner
# Usage: ./scripts/run_prod.sh [platform] [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT="production"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"

echo -e "${BLUE}🚀 FastApp Production Build${NC}"
echo -e "${BLUE}==========================${NC}"

# Platform detection
PLATFORM=""
CLEAN=false
ANALYZE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        android|ios|web|macos|windows|linux)
            PLATFORM="$1"
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --analyze)
            ANALYZE=true
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

# Help function
show_help() {
    echo -e "${BLUE}FastApp Production Builder${NC}"
    echo ""
    echo "Usage: ./scripts/run_prod.sh [platform] [options]"
    echo ""
    echo "Platforms:"
    echo "  android    Build APK/AAB for Android"
    echo "  ios        Build IPA for iOS"
    echo "  web        Build for web deployment"
    echo "  macos      Build for macOS"
    echo "  windows    Build for Windows"
    echo "  linux      Build for Linux"
    echo ""
    echo "Options:"
    echo "  --clean    Clean build before creating production build"
    echo "  --analyze  Run code analysis before build"
    echo "  -h, --help Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./scripts/run_prod.sh android          # Build Android APK"
    echo "  ./scripts/run_prod.sh ios --clean      # Clean build iOS"
    echo "  ./scripts/run_prod.sh web --analyze    # Build web with analysis"
}

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

# Pre-build checks
pre_build_checks() {
    echo -e "${YELLOW}🔍 Running pre-build checks...${NC}"
    cd "$PROJECT_ROOT"

    # Check dependencies
    if [ ! -f "pubspec.lock" ]; then
        echo -e "${YELLOW}📦 Installing dependencies...${NC}"
        flutter pub get
    fi

    # Run analysis if requested
    if [ "$ANALYZE" = true ]; then
        echo -e "${YELLOW}🔍 Running code analysis...${NC}"
        flutter analyze
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ Code analysis failed${NC}"
            exit 1
        fi
    fi

    # Generate code
    echo -e "${YELLOW}🔨 Generating code...${NC}"
    flutter packages pub run build_runner build --delete-conflicting-outputs

    echo -e "${GREEN}✅ Pre-build checks complete${NC}"
}

# Clean build
clean_build() {
    if [ "$CLEAN" = true ]; then
        echo -e "${YELLOW}🧹 Cleaning project...${NC}"
        cd "$PROJECT_ROOT"
        flutter clean
        flutter pub get
        echo -e "${GREEN}✅ Project cleaned${NC}"
    fi
}

# Build for Android
build_android() {
    echo -e "${YELLOW}🤖 Building for Android...${NC}"
    cd "$PROJECT_ROOT"

    # Build APK
    echo -e "${YELLOW}📦 Building APK...${NC}"
    flutter build apk --release \
        --dart-define=ENVIRONMENT=production \
        --dart-define=DEBUG_MODE=false

    # Build AAB (for Play Store)
    echo -e "${YELLOW}📦 Building AAB...${NC}"
    flutter build appbundle --release \
        --dart-define=ENVIRONMENT=production \
        --dart-define=DEBUG_MODE=false

    echo -e "${GREEN}✅ Android build complete${NC}"
    echo -e "${BLUE}📁 APK: build/app/outputs/flutter-apk/app-release.apk${NC}"
    echo -e "${BLUE}📁 AAB: build/app/outputs/bundle/release/app-release.aab${NC}"
}

# Build for iOS
build_ios() {
    echo -e "${YELLOW}🍎 Building for iOS...${NC}"
    cd "$PROJECT_ROOT"

    flutter build ios --release \
        --dart-define=ENVIRONMENT=production \
        --dart-define=DEBUG_MODE=false

    echo -e "${GREEN}✅ iOS build complete${NC}"
    echo -e "${BLUE}📁 iOS app: build/ios/iphoneos/Runner.app${NC}"
    echo -e "${YELLOW}💡 Use Xcode to create IPA for App Store${NC}"
}

# Build for Web
build_web() {
    echo -e "${YELLOW}🌐 Building for Web...${NC}"
    cd "$PROJECT_ROOT"

    flutter build web --release \
        --dart-define=ENVIRONMENT=production \
        --dart-define=DEBUG_MODE=false \
        --web-renderer canvaskit

    echo -e "${GREEN}✅ Web build complete${NC}"
    echo -e "${BLUE}📁 Web app: build/web/${NC}"
}

# Build for macOS
build_macos() {
    echo -e "${YELLOW}🖥️  Building for macOS...${NC}"
    cd "$PROJECT_ROOT"

    flutter build macos --release \
        --dart-define=ENVIRONMENT=production \
        --dart-define=DEBUG_MODE=false

    echo -e "${GREEN}✅ macOS build complete${NC}"
    echo -e "${BLUE}📁 macOS app: build/macos/Build/Products/Release/faithlock.app${NC}"
}

# Main execution
main() {
    if [ -z "$PLATFORM" ]; then
        echo -e "${RED}❌ Platform not specified${NC}"
        show_help
        exit 1
    fi

    check_flutter
    clean_build
    pre_build_checks

    case $PLATFORM in
        android)
            build_android
            ;;
        ios)
            build_ios
            ;;
        web)
            build_web
            ;;
        macos)
            build_macos
            ;;
        windows|linux)
            echo -e "${YELLOW}⚠️  $PLATFORM build not yet implemented${NC}"
            exit 1
            ;;
        *)
            echo -e "${RED}❌ Unknown platform: $PLATFORM${NC}"
            show_help
            exit 1
            ;;
    esac

    echo -e "${GREEN}🎉 Production build completed successfully!${NC}"
}

# Run main function
main "$@"
