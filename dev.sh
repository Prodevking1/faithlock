#!/bin/bash

# FastBet Development Runner
# Launches Flutter with hot reload watcher

set -e

PID_FILE="/tmp/flutter.pid"
WATCHER_PID=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Cleanup on exit
cleanup() {
    echo ""
    echo -e "${YELLOW}🧹 Cleaning up...${NC}"

    # Kill watcher if running
    if [ -n "$WATCHER_PID" ] && kill -0 "$WATCHER_PID" 2>/dev/null; then
        kill "$WATCHER_PID" 2>/dev/null
        echo -e "${GREEN}✓ Watcher stopped${NC}"
    fi

    # Remove PID file
    rm -f "$PID_FILE"

    echo -e "${GREEN}✓ Done${NC}"
    exit 0
}

trap cleanup EXIT INT TERM

# Parse arguments
FLAVOR="development"
TARGET="lib/main_development.dart"
DEVICE=""
EXTRA_ARGS=""
NO_FLAVOR=""
RELEASE_MODE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --prod|--production)
            FLAVOR="production"
            TARGET="lib/main_production.dart"
            shift
            ;;
        --dev|--development)
            FLAVOR="development"
            TARGET="lib/main_development.dart"
            shift
            ;;
        --no-flavor)
            NO_FLAVOR=true
            TARGET="lib/main.dart"
            shift
            ;;
        --release)
            RELEASE_MODE=true
            shift
            ;;
        --profile)
            PROFILE_MODE=true
            shift
            ;;
        -d|--device)
            DEVICE="$2"
            shift 2
            ;;
        --no-watch)
            NO_WATCH=true
            shift
            ;;
        *)
            EXTRA_ARGS="$EXTRA_ARGS $1"
            shift
            ;;
    esac
done

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  🚀 FastBet Development Runner${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
[ -z "$NO_FLAVOR" ] && echo -e "  ${GREEN}Flavor:${NC}  $FLAVOR" || echo -e "  ${GREEN}Flavor:${NC}  (none)"
echo -e "  ${GREEN}Target:${NC}  $TARGET"
[ -n "$RELEASE_MODE" ] && echo -e "  ${GREEN}Mode:${NC}    release"
[ -n "$PROFILE_MODE" ] && echo -e "  ${GREEN}Mode:${NC}    profile"
[ -n "$DEVICE" ] && echo -e "  ${GREEN}Device:${NC}  $DEVICE"
echo ""

# Disable watcher in release/profile mode (hot reload not available)
if [ -n "$RELEASE_MODE" ] || [ -n "$PROFILE_MODE" ]; then
    NO_WATCH=true
    echo -e "${YELLOW}ℹ️  Hot reload disabled in release/profile mode${NC}"
    echo ""
fi

# Check watchfiles is installed
if [ -z "$NO_WATCH" ]; then
    if ! command -v watchfiles &> /dev/null; then
        echo -e "${RED}❌ watchfiles not installed${NC}"
        echo -e "   Install with: ${YELLOW}pip install watchfiles${NC}"
        echo ""
        exit 1
    fi
fi

# Build flutter command
if [ -z "$NO_FLAVOR" ]; then
    FLUTTER_CMD="flutter run --flavor $FLAVOR -t $TARGET --pid-file $PID_FILE"
else
    FLUTTER_CMD="flutter run -t $TARGET --pid-file $PID_FILE"
fi
[ -n "$RELEASE_MODE" ] && FLUTTER_CMD="$FLUTTER_CMD --release"
[ -n "$PROFILE_MODE" ] && FLUTTER_CMD="$FLUTTER_CMD --profile"
[ -n "$DEVICE" ] && FLUTTER_CMD="$FLUTTER_CMD -d $DEVICE"
[ -n "$EXTRA_ARGS" ] && FLUTTER_CMD="$FLUTTER_CMD $EXTRA_ARGS"

# Start watcher in background
if [ -z "$NO_WATCH" ]; then
    echo -e "${YELLOW}👀 Starting file watcher...${NC}"
    (
        # Wait for PID file to be created
        while [ ! -f "$PID_FILE" ]; do
            sleep 0.5
        done
        sleep 1

        PID=$(cat "$PID_FILE")
        echo -e "${GREEN}✓ Watcher active (Flutter PID: $PID)${NC}"
        echo ""

        # Watch and reload
        watchfiles "kill -USR1 $PID 2>/dev/null && echo -e '${GREEN}🔥 Hot reload triggered${NC}'" lib/ 2>/dev/null
    ) &
    WATCHER_PID=$!
fi

# Run Flutter
echo -e "${YELLOW}📱 Starting Flutter...${NC}"
echo -e "${CYAN}$FLUTTER_CMD${NC}"
echo ""

$FLUTTER_CMD
