import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_controller.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_v2_controller.dart';
import 'package:faithlock/features/onboarding/controllers/scripture_onboarding_v3_controller.dart';
import 'package:faithlock/features/onboarding/screens/step6_final_encouragement.dart';
import 'package:faithlock/features/onboarding/screens/step7_screen_time_permission.dart';
import 'package:faithlock/features/onboarding/screens/v2_free_for_you.dart';
import 'package:faithlock/features/onboarding/screens/v3/v3_apps_and_rules.dart';
import 'package:faithlock/features/onboarding/screens/v3/v3_attribution.dart';
import 'package:faithlock/features/onboarding/screens/v3/v3_building_plan_loader.dart';
import 'package:faithlock/features/onboarding/screens/v3/v3_diagnostic_hours.dart';
import 'package:faithlock/features/onboarding/screens/v3/v3_diagnostic_question.dart';
import 'package:faithlock/features/onboarding/screens/v3/v3_dual_name_capture.dart';
import 'package:faithlock/features/onboarding/screens/v3/v3_fake_loader.dart';
import 'package:faithlock/features/onboarding/screens/v3/v3_personalization.dart';
import 'package:faithlock/features/onboarding/screens/v3/v3_prayer_intent.dart';
import 'package:faithlock/features/onboarding/screens/v3/v3_reveal_screen.dart';
import 'package:faithlock/features/onboarding/screens/v3/v3_social_proof.dart';
import 'package:faithlock/features/onboarding/screens/v3/v3_welcome_carousel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// V3 Onboarding - Laura's full vision (20 steps).
///
///   1. Welcome carousel (3 slides)
///   2. Diagnostic Q1 - peace/phone
///   3. Diagnostic Q2 - phone check frequency
///   4. Diagnostic Q3 - hours/day slider
///   5. Diagnostic Q4 - lonely → phone or faith
///   6. Diagnostic Q5 - silence
///   7. Diagnostic Q6 - missing self
///   8. Diagnostic Q7 - lost practice
///   9. Diagnostic Q8 - practice to build
///   10. Diagnostic Q9 - God seeing your week
///   11. Fake loader (anticipation)
///   12. Reveal (Opal-style)
///   13. Personalization (tradition + state + practices + moments)
///   14. Prayer intent (1×/2×/3×/More)
///   15. Apps & unblock rules
///   16. Dual name capture (Toby + before God)
///   17. Commitment seal (fingerprint, reused)
///   18. Screen Time permission (reused)
///   19. Social proof
///   20. Attribution → Building plan loader → V2FreeForYou paywall
class ScriptureOnboardingV3Screen extends StatefulWidget {
  const ScriptureOnboardingV3Screen({super.key});

  @override
  State<ScriptureOnboardingV3Screen> createState() =>
      _ScriptureOnboardingV3ScreenState();
}

class _ScriptureOnboardingV3ScreenState
    extends State<ScriptureOnboardingV3Screen> {
  late final ScriptureOnboardingV3Controller v3Controller;

  @override
  void initState() {
    super.initState();
    v3Controller = ScriptureOnboardingV3Controller();
    Get.put<ScriptureOnboardingController>(v3Controller);
    Get.put<ScriptureOnboardingV2Controller>(v3Controller);
    Get.put<ScriptureOnboardingV3Controller>(v3Controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final next = v3Controller.nextStep;
        switch (v3Controller.currentStep.value) {
          case 1:
            return V3WelcomeCarousel(onComplete: next);

          // ===== Diagnostic phase (Laura's 9 questions) =====
          case 2:
            return V3DiagnosticQuestion(
              onComplete: next,
              questionKey: 'peace_or_phone',
              question:
                  'The last time you felt truly at peace — were you on your phone, or away from it?',
              options: const [
                'On my phone',
                'Away from it',
                "I can't remember",
              ],
            );

          case 3:
            return V3DiagnosticQuestion(
              onComplete: next,
              questionKey: 'phone_checks_per_day',
              question: 'How many times do you check your phone daily?',
              options: const [
                'Less than 20',
                '20 to 50',
                '50 to 100',
                'More than 100',
                "I'd rather not know",
              ],
            );

          case 4:
            return V3DiagnosticHours(onComplete: next);

          case 5:
            return V3DiagnosticQuestion(
              onComplete: next,
              questionKey: 'lonely_reach',
              question:
                  'When you feel lonely or anxious — what do you reach for first?',
              options: const [
                'My phone',
                'My faith',
                'It depends on the day',
              ],
            );

          case 6:
            return V3DiagnosticQuestion(
              onComplete: next,
              questionKey: 'silence_last',
              question:
                  'When did you last spend more than 10 minutes in silence — no screen, no noise?',
              options: const [
                'Today',
                'This week',
                'This month',
                'Months ago',
                "I can't remember",
              ],
            );

          case 7:
            return V3DiagnosticQuestion(
              onComplete: next,
              questionKey: 'missing_self',
              question:
                  "Is there a version of yourself — more prayerful, more present — that you've been missing lately?",
              options: const [
                'Yes, deeply',
                'Yes, sometimes',
                'Not sure',
                "I'm content where I am",
              ],
            );

          case 8:
            return V3DiagnosticQuestion(
              onComplete: next,
              questionKey: 'lost_practice',
              question:
                  "What's one spiritual practice you used to have that slowly disappeared from your life?",
              options: const [
                'Daily prayer',
                'Reading Scripture',
                'Going to Mass / service',
                'Quiet reflection',
                'Confession or examination of conscience',
                'Something else',
              ],
            );

          case 9:
            return V3DiagnosticQuestion(
              onComplete: next,
              questionKey: 'practice_to_build',
              question: "What's one spiritual practice you'd like to build?",
              options: const [
                'Daily prayer',
                'Daily Scripture reading',
                'Returning to Mass / service',
                'A daily moment of silence',
                'Honest, regular confession',
                "I'm not sure yet",
              ],
            );

          case 10:
            return V3DiagnosticQuestion(
              onComplete: next,
              questionKey: 'god_sees_week',
              question:
                  'If God could see exactly how you spent your time this past week — how would that make you feel?',
              options: const [
                'Ashamed',
                'Indifferent',
                'A little proud',
                'Mostly proud',
                "I'd want to change it",
              ],
            );

          // ===== Reveal sequence =====
          case 11:
            return V3FakeLoader(onComplete: next);

          case 12:
            return V3RevealScreen(onComplete: next);

          // ===== Personalization phase =====
          case 13:
            return V3Personalization(onComplete: next);

          case 14:
            return V3PrayerIntent(onComplete: next);

          case 15:
            return V3AppsAndRules(onComplete: next);

          case 16:
            return V3DualNameCapture(onComplete: next);

          // ===== Commitment + permissions =====
          case 17:
            return Step6FinalEncouragement(onComplete: next);

          case 18:
            return Step7ScreenTimePermission(onComplete: next);

          // ===== Social proof + attribution + paywall =====
          case 19:
            return V3SocialProof(onComplete: next);

          case 20:
            return V3Attribution(onComplete: () {
              // After attribution: theatrical "Building plan" loader,
              // then mark complete and route to V2 paywall.
              Get.off(() => V3BuildingPlanLoader(
                    onComplete: () async {
                      await v3Controller.completeOnboarding();
                      Get.off(() => const V2FreeForYou());
                    },
                  ));
            });

          default:
            return const _ErrorScreen();
        }
      }),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'V3 Onboarding error',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
