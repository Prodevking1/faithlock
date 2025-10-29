import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'SUPABASE_URL')
  static String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static String supabaseAnonKey = _Env.supabaseAnonKey;

  @EnviedField(varName: 'POSTHOG_API_KEY')
  static String postHogApiKey = _Env.postHogApiKey;

  @EnviedField(varName: 'POSTHOG_HOST', defaultValue: 'https://us.i.posthog.com')
  static String postHogHost = _Env.postHogHost;

  @EnviedField(varName: 'REVENUECAT_API_KEY')
  static String revenueCatApiKey = _Env.revenueCatApiKey;

   @EnviedField(varName: 'OPENAI_API_KEY')
  static String openAiApiKey = _Env.openAiApiKey;

}
