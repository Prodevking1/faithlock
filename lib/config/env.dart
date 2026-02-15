import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'POSTHOG_API_KEY')
  static String postHogApiKey = _Env.postHogApiKey;

  @EnviedField(varName: 'POSTHOG_HOST', defaultValue: 'https://us.i.posthog.com')
  static String postHogHost = _Env.postHogHost;

  @EnviedField(varName: 'REVENUECAT_API_KEY')
  static String revenueCatApiKey = _Env.revenueCatApiKey;

   @EnviedField(varName: 'OPENAI_API_KEY')
  static String openAiApiKey = _Env.openAiApiKey;

  @EnviedField(varName: 'TIKTOK_IOS_APP_ID', defaultValue: 'YOUR_TIKTOK_IOS_APP_ID')
  static String tiktokIosAppId = _Env.tiktokIosAppId;

  @EnviedField(varName: 'TIKTOK_IOS_ID', defaultValue: 'YOUR_TIKTOK_IOS_ID')
  static String tiktokIosId = _Env.tiktokIosId;

  @EnviedField(varName: 'TIKTOK_ANDROID_APP_ID', defaultValue: 'YOUR_TIKTOK_ANDROID_APP_ID')
  static String tiktokAndroidAppId = _Env.tiktokAndroidAppId;

  @EnviedField(varName: 'TIKTOK_ANDROID_ID', defaultValue: 'YOUR_TIKTOK_ANDROID_ID')
  static String tiktokAndroidId = _Env.tiktokAndroidId;

}
