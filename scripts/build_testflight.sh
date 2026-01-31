#!/bin/bash

# FaithLock - TestFlight Build Script
# Usage: ./scripts/build_testflight.sh

set -e  # Exit on error

echo "🚀 Building FaithLock for TestFlight..."
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 1. Clean
echo -e "${BLUE}📦 Cleaning previous builds...${NC}"
flutter clean

# 2. Get dependencies
echo -e "${BLUE}📥 Getting dependencies...${NC}"
flutter pub get

# 3. Run code generation if needed
if [ -f "build_runner" ]; then
    echo -e "${BLUE}⚙️  Running code generation...${NC}"
    flutter pub run build_runner build --delete-conflicting-outputs
fi

# 4. Build IPA for TestFlight (Development Export)
echo -e "${BLUE}🔨 Building IPA for TestFlight...${NC}"
echo -e "${BLUE}Using Development provisioning profile...${NC}"
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist

# 5. Locate the IPA
IPA_PATH="build/ios/ipa/faithlock.ipa"

echo ""
echo -e "${GREEN}✅ Build complete!${NC}"
echo ""
echo -e "${BLUE}📱 Your IPA is ready:${NC}"
echo -e "${GREEN}${IPA_PATH}${NC}"
echo ""
echo -e "${BLUE}📤 Next steps:${NC}"
echo "Option A - Xcode Organizer:"
echo "  1. Open Xcode → Window → Organizer"
echo "  2. Click 'Distribute App'"
echo "  3. Select 'TestFlight & App Store'"
echo "  4. Upload"
echo ""
echo "Option B - Transporter App:"
echo "  1. Open Transporter app"
echo "  2. Drag ${IPA_PATH}"
echo "  3. Click 'Deliver'"
echo ""
echo "Option C - Command Line:"
echo "  xcrun altool --upload-app --type ios --file ${IPA_PATH} \\"
echo "    --apiKey YOUR_KEY --apiIssuer YOUR_ISSUER"
echo ""
echo -e "${GREEN}🎉 Ready for TestFlight!${NC}"
