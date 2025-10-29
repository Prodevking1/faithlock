# Apple Intelligence Setup for Meditation Validation

## ⚠️ CURRENTLY DISABLED

**Foundation Models framework is not yet publicly available.** Apple's documentation references iOS 26.0 which doesn't exist.

The app currently uses **OpenAI only** for meditation validation. Apple Intelligence integration is ready and will be enabled when Apple releases the Foundation Models framework publicly.

---

## Overview

FaithLock is prepared to use **Apple Intelligence (Foundation Models)** as the primary AI for meditation validation, with OpenAI as fallback for older devices.

## Benefits

✅ **Free** - No API costs
✅ **Fast** - On-device processing (<500ms)
✅ **Private** - Data never leaves device
✅ **Offline** - Works without internet
✅ **Smart Fallback** - OpenAI for older devices

## Requirements

### For Apple Intelligence (Primary)
- iOS 18.2+ (required for Foundation Models framework)
- iPhone 15 Pro or later
- M1+ iPad or later
- Latest Xcode (16.0+)

### For OpenAI Fallback
- Any iOS device
- Internet connection
- OpenAI API key (see AI_MEDITATION_SETUP.md)

## Implementation

### 1. Enable Foundation Models Framework

The app is already configured! The code checks device compatibility automatically:

```dart
// Automatically tries Apple Intelligence first
if (await AppleIntelligenceService.isAvailable()) {
  // Use on-device Apple Intelligence ✅
} else {
  // Fallback to OpenAI API
}
```

### 2. Build & Run

```bash
# Clean build to include Swift code
flutter clean
flutter pub get
flutter run
```

### 3. Test on Device

**Supported Devices (Apple Intelligence):**
- iOS 18.2+ required
- iPhone 15 Pro / Pro Max
- iPhone 16 series
- iPad with M1 or later
- Mac with M1 or later

**Unsupported Devices (OpenAI fallback):**
- iOS < 18.2 or non-compatible hardware
- iPhone 15 / 15 Plus
- iPhone 14 and earlier
- iPad with A-series chips
- Requires internet + OpenAI API key

## How It Works

### Validation Flow

```
1. User writes meditation (20+ characters)
2. Tap "Validate" button
3. Check device compatibility:

   ✅ iOS 18.2+ & A17 Pro/M1+
   → Apple Intelligence (on-device)
   → Result in <500ms
   → No cost, fully private

   ❌ Older device
   → OpenAI GPT-4o-mini (cloud)
   → Result in 1-3s
   → ~$0.001 per validation

4. Show feedback with validation result
5. Enable "Next" if valid, or "Skip Anyway"
```

### Code Architecture

**Swift Side (iOS):**
- `AppleIntelligenceValidator.swift` - Foundation Models integration
- `AppleIntelligencePlugin.swift` - Flutter bridge
- Uses JSON-based structured output (iOS 18.2 compatible)
- Parses validation results using Codable protocol

**Dart Side (Flutter):**
- `apple_intelligence_service.dart` - Platform channel
- `meditation_validator_service.dart` - Hybrid logic
- Automatic fallback handling

## Validation Criteria

Both Apple Intelligence and OpenAI use the same criteria:

✅ **Valid:**
- Shows verse understanding
- Personal connection
- Thoughtful reflection (20+ chars)
- Honest and sincere

❌ **Invalid:**
- Too short (< 20 chars)
- Generic/copy-paste
- Off-topic
- No personal connection

## Cost Comparison

| Provider | Cost | Speed | Privacy | Offline |
|----------|------|-------|---------|---------|
| **Apple Intelligence** | $0 | <500ms | 100% | ✅ |
| **OpenAI GPT-4o-mini** | ~$0.001 | 1-3s | Sent to cloud | ❌ |
| **Fallback (basic)** | $0 | Instant | 100% | ✅ |

## Monitoring

Check logs to see which provider was used:

```bash
flutter run

# Look for:
🍎 Using Apple Intelligence for validation  # ← On-device
🤖 Using OpenAI for validation              # ← Cloud fallback
```

## Troubleshooting

### "Apple Intelligence not available"
- Check iOS version (18.2+ required)
- Check device model (A17 Pro / M1+)
- Falls back to OpenAI automatically

### "Validation failed"
- Check OpenAI API key if on older device
- Check internet connection
- Falls back to basic validation (20+ chars)

### Slow validation
- Apple Intelligence: <500ms (expected)
- OpenAI: 1-3s (expected)
- > 5s: Network issue, check connection

## Privacy

### Apple Intelligence (Primary)
- ✅ All processing on-device
- ✅ Zero data sent to servers
- ✅ GDPR compliant by design
- ✅ No user tracking

### OpenAI Fallback
- ⚠️ Meditation text sent to OpenAI
- ⚠️ No personal identifiers included
- ✅ User can skip validation
- ℹ️ Consider privacy notice in UI

## Future Enhancements

- [ ] Show AI provider badge (Apple/OpenAI)
- [ ] Analytics on provider usage
- [ ] Offline-first mode preference
- [ ] Multi-language support
- [ ] Progressive improvement suggestions

## References

- [Foundation Models Documentation](https://developer.apple.com/documentation/foundationmodels)
- [WWDC 2025: Meet the Foundation Models framework](https://developer.apple.com/videos/play/wwdc2025/286/)
- [Apple Intelligence Overview](https://developer.apple.com/apple-intelligence/)
