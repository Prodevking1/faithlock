# AI Meditation Validation Setup

## Overview

The prayer learning meditation step now includes AI-powered validation to ensure users engage meaningfully with scripture verses.

## Features

- ✅ Real-time meditation response validation
- ✅ Context-aware feedback (considers user goals & struggles)
- ✅ Visual feedback (green = valid, red = invalid, orange = validating)
- ✅ "Skip Anyway" option for flexibility
- ✅ Fallback to basic validation if AI unavailable

## Setup

### 1. Get OpenAI API Key

1. Go to [https://platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Create a new API key
3. Copy the key

### 2. Configure API Key

**Option A: Environment Variable (Recommended)**

Add to your `.env` file:
```bash
OPENAI_API_KEY=sk-...your-key-here
```

Then update `lib/services/ai/meditation_validator_service.dart`:
```dart
static const String _apiKey = Env.openAiApiKey;  // Use env variable
```

**Option B: Direct Configuration (Testing Only)**

Update `lib/services/ai/meditation_validator_service.dart`:
```dart
static const String _apiKey = 'sk-...your-key-here';
```

⚠️ **Never commit API keys to git!**

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Test

Run the app and navigate to the meditation step:
1. Write a meditation response (minimum 20 characters)
2. Tap "Validate"
3. See AI feedback and validation result
4. "Next" button appears if validated
5. "Skip Anyway" available if needed

## Cost Optimization

- Model: `gpt-4o-mini` (cost-effective)
- Temperature: 0.3 (consistent results)
- Max tokens: 200 (short responses)
- Estimated cost: ~$0.001 per validation

## Validation Criteria

AI checks for:
- ✅ Genuine engagement (not copy-paste)
- ✅ Personal connection to verse
- ✅ Thoughtful reflection (20+ characters)
- ✅ On-topic response

AI accepts:
- Simple but sincere reflections
- Personal struggles
- Questions about meaning
- Honest confusion

## Fallback Behavior

If AI unavailable:
- Basic length validation (20+ characters)
- Generic encouraging feedback
- User can still proceed

## User Experience Flow

```
1. User reads verse
2. User writes meditation (20+ chars required)
3. User taps "Validate" → AI analyzes
4. Feedback displayed:
   - ✅ Valid → "Next" button enabled
   - ❌ Invalid → Feedback + retry
   - ⏳ Validating → Loading state
5. "Skip Anyway" available if user has 10+ characters
```

## Customization

### Adjust Validation Strictness

Edit `lib/services/ai/meditation_validator_service.dart`:

```dart
// Make more lenient
if (response.length < 10) { // Was 20

// Make stricter
if (response.length < 50) { // Was 20
```

### Modify AI Prompt

Edit the system prompt in `_getSystemPrompt()` method.

### Change AI Provider

Replace OpenAI with Claude, Gemini, or any provider:

1. Update `_apiUrl` and headers
2. Modify request body format
3. Update response parsing

## Monitoring

Add analytics to track:
- Validation success rate
- Average response length
- Skip rate
- AI response time

## Troubleshooting

**Issue**: "Validation failed" always
- Check API key is correct
- Verify internet connection
- Check OpenAI API status

**Issue**: Slow validation
- Normal: 1-3 seconds
- Slow: >5 seconds → check network
- Use timeout and fallback

**Issue**: High costs
- Monitor usage at [https://platform.openai.com/usage](https://platform.openai.com/usage)
- Consider caching similar responses
- Implement rate limiting

## Privacy

- Meditation responses sent to OpenAI
- No personal identifiers included
- User can skip AI validation
- Consider adding privacy notice in UI

## Future Enhancements

- [ ] Cache similar validations
- [ ] Multi-language support
- [ ] Sentiment analysis
- [ ] Progressive improvement suggestions
- [ ] Offline mode with local validation
