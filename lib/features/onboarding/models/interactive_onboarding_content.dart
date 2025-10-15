import 'package:faithlock/features/onboarding/models/interactive_action_model.dart';
import 'package:faithlock/features/onboarding/models/onboarding_step_model.dart';
import 'package:flutter/material.dart';

/// Interactive onboarding content for AI Music Generation App
class InteractiveOnboardingContent {
  static List<OnboardingStep> get steps => [
        // Étape 1: Accueil et découverte magique
        OnboardingStep(
          title: '🎵 Welcome to SoundForge',
          description:
              'Where your imagination becomes music.\nLet\'s create something magical together!',
          icon: Icons.music_note,
          color: Colors.deepPurple,
          trustIndicator: TrustIndicator(
            icon: Icons.auto_awesome,
            text: 'AI-Powered Music Creation',
            color: Colors.deepPurple,
          ),
          actions: [
            InteractiveAction(
              id: 'demo_generation',
              type: InteractiveActionType.demo,
              title: 'Experience the Magic ✨',
              subtitle: 'Hear what SoundForge can create in seconds',
              icon: Icons.play_circle_filled,
              color: Colors.purple,
              demoDescription:
                  'Tap below to generate a sample track and feel the power of AI music creation',
              isRequired: false,
            ),
          ],
          continueLabel: 'Let\'s Start Creating',
        ),

        // Étape 2: Goûts musicaux - Personnalisation émotionnelle
        OnboardingStep(
          title: '🎸 What moves your soul?',
          description:
              'Tell us your musical preferences so we can craft the perfect sounds for you',
          icon: Icons.library_music,
          color: Colors.indigo,
          trustIndicator: TrustIndicator(
            icon: Icons.favorite,
            text: 'Personalized AI Music',
            color: Colors.indigo,
          ),
          actions: [
            InteractiveAction(
              id: 'favorite_genres',
              type: InteractiveActionType.selection,
              title: 'Choose your favorite genres',
              subtitle: 'Select 2-4 genres that resonate with you',
              icon: Icons.library_music,
              color: Colors.deepPurple,
              multiSelect: true,
              minSelection: 1,
              maxSelection: 4,
              isRequired: true,
              options: [
                ActionOption(
                  id: 'electronic',
                  label: 'Electronic',
                  icon: Icons.electrical_services,
                  color: Colors.cyan,
                ),
                ActionOption(
                  id: 'rock',
                  label: 'Rock',
                  icon: Icons.music_note,
                  color: Colors.red,
                ),
                ActionOption(
                  id: 'pop',
                  label: 'Pop',
                  icon: Icons.star,
                  color: Colors.pink,
                ),
                ActionOption(
                  id: 'hip_hop',
                  label: 'Hip-Hop',
                  icon: Icons.mic,
                  color: Colors.orange,
                ),
                ActionOption(
                  id: 'classical',
                  label: 'Classical',
                  icon: Icons.piano,
                  color: Colors.brown,
                ),
                ActionOption(
                  id: 'jazz',
                  label: 'Jazz',
                  icon: Icons.music_note,
                  color: Colors.amber,
                ),
                ActionOption(
                  id: 'ambient',
                  label: 'Ambient',
                  icon: Icons.cloud,
                  color: Colors.blueGrey,
                ),
                ActionOption(
                  id: 'trap',
                  label: 'Trap',
                  icon: Icons.graphic_eq,
                  color: Colors.deepOrange,
                ),
                ActionOption(
                  id: 'house',
                  label: 'House',
                  icon: Icons.nightlife,
                  color: Colors.purple,
                ),
                ActionOption(
                  id: 'lofi',
                  label: 'Lo-Fi',
                  icon: Icons.headphones,
                  color: Colors.teal,
                ),
              ],
              validationError: 'Please select at least one genre',
            ),
          ],
          requiresActions: true,
          canSkip: false,
          continueLabel: 'Next',
        ),

        // Étape 3: Profil utilisateur et intentions
        OnboardingStep(
          title: '👤 Tell us about yourself',
          description:
              'This helps us tailor the perfect music creation experience',
          icon: Icons.person,
          color: Colors.teal,
          trustIndicator: TrustIndicator(
            icon: Icons.psychology,
            text: 'Smart Personalization',
            color: Colors.teal,
          ),
          actions: [
            InteractiveAction(
              id: 'music_experience',
              type: InteractiveActionType.selection,
              title: 'What\'s your music background?',
              subtitle: 'No judgment - we\'re here to help everyone create!',
              icon: Icons.timeline,
              color: Colors.indigo,
              multiSelect: false,
              isRequired: true,
              options: [
                ActionOption(
                  id: 'beginner',
                  label: 'Complete beginner - just love music! 🎵',
                  icon: Icons.favorite,
                  color: Colors.green,
                ),
                ActionOption(
                  id: 'hobbyist',
                  label: 'Hobbyist - I play around with music 🎹',
                  icon: Icons.music_note,
                  color: Colors.blue,
                ),
                ActionOption(
                  id: 'intermediate',
                  label: 'Some experience with music production 🎛️',
                  icon: Icons.equalizer,
                  color: Colors.orange,
                ),
                ActionOption(
                  id: 'advanced',
                  label: 'Producer/Musician looking for AI tools 🎯',
                  icon: Icons.piano,
                  color: Colors.purple,
                ),
              ],
              validationError: 'Please tell us about your background',
            ),
            InteractiveAction(
              id: 'creation_goal',
              type: InteractiveActionType.selection,
              title: 'What do you want to create?',
              subtitle: 'This helps us suggest the best tools and features',
              icon: Icons.track_changes,
              color: Colors.teal,
              multiSelect: true,
              maxSelection: 3,
              isRequired: true,
              options: [
                ActionOption(
                  id: 'beats',
                  label: 'Beats & Instrumentals',
                  icon: Icons.graphic_eq,
                  color: Colors.deepOrange,
                ),
                ActionOption(
                  id: 'melodies',
                  label: 'Catchy Melodies',
                  icon: Icons.music_note,
                  color: Colors.pink,
                ),
                ActionOption(
                  id: 'full_songs',
                  label: 'Complete Songs',
                  icon: Icons.album,
                  color: Colors.purple,
                ),
                ActionOption(
                  id: 'background',
                  label: 'Background Music',
                  icon: Icons.volume_down,
                  color: Colors.blueGrey,
                ),
                ActionOption(
                  id: 'experimental',
                  label: 'Experimental Sounds',
                  icon: Icons.science,
                  color: Colors.cyan,
                ),
                ActionOption(
                  id: 'remixes',
                  label: 'Remixes & Variations',
                  icon: Icons.repeat,
                  color: Colors.amber,
                ),
              ],
              validationError: 'Please select what you want to create',
            ),
          ],
          requiresActions: true,
          canSkip: false,
          continueLabel: 'Continue',
        ),

        // Étape 4: Permissions essentielles
        OnboardingStep(
          title: '🔊 Unlock Full Experience',
          description:
              'Enable key permissions for seamless music creation and sharing',
          icon: Icons.settings,
          color: Colors.orange,
          trustIndicator: TrustIndicator(
            icon: Icons.security,
            text: 'Private & Secure',
            color: Colors.orange,
          ),
          actions: [
            InteractiveAction(
              id: 'push_notifications_permission',
              type: InteractiveActionType.permission,
              title: '🔔 Push Notifications',
              subtitle: 'Get notified of new beats, challenges, and updates',
              icon: Icons.notifications_active,
              color: Colors.deepPurple,
              permissionRationale:
                  'Stay connected with the music community! Get notified when new beats drop, daily creative challenges are available, and when friends share their latest creations.',
              permissionTypes: [PermissionType.pushNotifications],
              isRequired: false,
            ),
            InteractiveAction(
              id: 'microphone_permission',
              type: InteractiveActionType.permission,
              title: '🎤 Microphone Access',
              subtitle: 'Record vocals, instruments, and audio samples',
              icon: Icons.mic,
              color: Colors.red,
              permissionRationale:
                  'Essential for music creation! Record your voice for lyrics, capture instrument sounds, analyze environmental audio for inspiration, and create voice notes for your creative process.',
              permissionTypes: [PermissionType.microphone],
              isRequired: true,
            ),
            InteractiveAction(
              id: 'storage_permission',
              type: InteractiveActionType.permission,
              title: '💾 Storage Access',
              subtitle: 'Save and import your musical creations',
              icon: Icons.folder,
              color: Colors.blue,
              permissionRationale:
                  'Manage your music library! Save your AI-generated tracks, import existing audio files for remixing, export final creations, and backup your musical projects.',
              permissionTypes: [PermissionType.storage],
              isRequired: true,
            ),
            InteractiveAction(
              id: 'camera_permission',
              type: InteractiveActionType.permission,
              title: '📷 Camera Access',
              subtitle: 'Capture photos for album artwork and visual content',
              icon: Icons.camera_alt,
              color: Colors.green,
              permissionRationale:
                  'Express your creativity visually! Take photos for album covers, create visual stories of your music-making process, and capture inspiration from your surroundings.',
              permissionTypes: [PermissionType.camera],
              isRequired: false,
            ),
            InteractiveAction(
              id: 'photos_permission',
              type: InteractiveActionType.permission,
              title: '🖼️ Photos Access',
              subtitle: 'Use your existing photos for album artwork',
              icon: Icons.photo_library,
              color: Colors.purple,
              permissionRationale:
                  'Personalize your music! Access your photo library to create custom album artwork, use existing images for visual inspiration, and create complete multimedia experiences.',
              permissionTypes: [PermissionType.photos],
              isRequired: false,
            ),
          ],
          requiresActions: true,
          canSkip: true,
          skipLabel: 'Skip permissions',
          continueLabel: 'Grant Permissions',
        ),

        // Étape 5: Permissions optionnelles avancées
        OnboardingStep(
          title: '🌟 Advanced Features',
          description:
              'Optional permissions to enhance your music creation experience',
          icon: Icons.auto_awesome,
          color: Colors.teal,
          trustIndicator: TrustIndicator(
            icon: Icons.privacy_tip,
            text: 'Always Optional',
            color: Colors.teal,
          ),
          actions: [
            InteractiveAction(
              id: 'location_permission',
              type: InteractiveActionType.permission,
              title: '📍 Location Access',
              subtitle: 'Discover local music events and venues',
              icon: Icons.location_on,
              color: Colors.orange,
              permissionRationale:
                  'Connect with your local music scene! Discover nearby concerts, open mic nights, music venues, and collaborate with artists in your area.',
              permissionTypes: [PermissionType.location],
              isRequired: false,
            ),
            InteractiveAction(
              id: 'contacts_permission',
              type: InteractiveActionType.permission,
              title: '👥 Contacts Access',
              subtitle: 'Easily share your music with friends',
              icon: Icons.contacts,
              color: Colors.indigo,
              permissionRationale:
                  'Share your musical creations effortlessly! Quickly send your tracks to friends, invite collaborators, and build your music network.',
              permissionTypes: [PermissionType.contacts],
              isRequired: false,
            ),
            InteractiveAction(
              id: 'calendar_permission',
              type: InteractiveActionType.permission,
              title: '📅 Calendar Access',
              subtitle: 'Schedule creative sessions and music events',
              icon: Icons.calendar_today,
              color: Colors.brown,
              permissionRationale:
                  'Organize your creative life! Schedule dedicated music creation time, set reminders for practice sessions, and never miss important music events.',
              permissionTypes: [PermissionType.calendar],
              isRequired: false,
            ),
            InteractiveAction(
              id: 'creation_reminders',
              type: InteractiveActionType.toggle,
              title: '💡 Daily Creative Challenges',
              subtitle: 'Get inspired with personalized music prompts',
              icon: Icons.lightbulb,
              color: Colors.amber,
              toggleDescription:
                  'Receive daily creative challenges tailored to your musical style and goals',
              defaultValue: true,
              isRequired: false,
            ),
            InteractiveAction(
              id: 'analytics_sharing',
              type: InteractiveActionType.toggle,
              title: '📊 Usage Analytics',
              subtitle: 'Help us improve the app with anonymous usage data',
              icon: Icons.analytics,
              color: Colors.blueGrey,
              toggleDescription:
                  'Share anonymous usage patterns to help us create better music generation algorithms',
              defaultValue: false,
              isRequired: false,
            ),
          ],
          requiresActions: false,
          canSkip: true,
          skipLabel: 'Skip advanced features',
          continueLabel: 'Configure Features',
        ),

        // Étape 6: Première création guidée
        OnboardingStep(
          title: '🎹 Create your first masterpiece',
          description:
              'Let\'s walk through creating your first AI-generated track together',
          icon: Icons.create,
          color: Colors.green,
          trustIndicator: TrustIndicator(
            icon: Icons.auto_awesome,
            text: 'AI-Powered Creation',
            color: Colors.green,
          ),
          actions: [
            InteractiveAction(
              id: 'first_track_creation',
              type: InteractiveActionType.demo,
              title: 'Create Your First Track 🚀',
              subtitle: 'We\'ll guide you step-by-step through the magic',
              icon: Icons.play_arrow,
              color: Colors.green,
              demoDescription:
                  'Ready to see SoundForge in action? We\'ll create a personalized track based on your preferences from the previous steps. This usually takes 10-30 seconds.',
              isRequired: false,
            ),
            InteractiveAction(
              id: 'track_customization',
              type: InteractiveActionType.selection,
              title: 'Pick your first track style',
              subtitle: 'Based on your genres, here are some starter options',
              icon: Icons.tune,
              color: Colors.green,
              multiSelect: false,
              isRequired: false,
              options: [
                ActionOption(
                  id: 'chill_vibes',
                  label: 'Chill Vibes - Perfect for relaxing',
                  icon: Icons.self_improvement,
                  color: Colors.teal,
                ),
                ActionOption(
                  id: 'energetic_beat',
                  label: 'Energetic Beat - Get pumped up!',
                  icon: Icons.bolt,
                  color: Colors.orange,
                ),
                ActionOption(
                  id: 'ambient_journey',
                  label: 'Ambient Journey - Atmospheric soundscape',
                  icon: Icons.cloud,
                  color: Colors.blueGrey,
                ),
                ActionOption(
                  id: 'surprise_me',
                  label: 'Surprise Me! - Let AI choose',
                  icon: Icons.shuffle,
                  color: Colors.purple,
                ),
              ],
            ),
          ],
          requiresActions: false,
          canSkip: true,
          skipLabel: 'Skip Demo',
          continueLabel: 'Create My Track',
        ),

        // Étape 6: Configuration finale et lancement
        OnboardingStep(
          title: '🎉 You\'re ready to rock!',
          description:
              'Just a few final touches to personalize your creative workspace',
          icon: Icons.celebration,
          color: Colors.deepPurple,
          trustIndicator: TrustIndicator(
            icon: Icons.verified,
            text: 'Ready to Create Magic',
            color: Colors.deepPurple,
          ),
          actions: [
            InteractiveAction(
              id: 'username_setup',
              type: InteractiveActionType.textInput,
              title: 'Choose your artist name',
              subtitle: 'This will be visible when you share your creations',
              icon: Icons.person,
              color: Colors.deepPurple,
              placeholder: 'Enter your artist name',
              inputType: TextInputType.text,
              maxLength: 20,
              isRequired: false,
            ),
            InteractiveAction(
              id: 'quality_preference',
              type: InteractiveActionType.selection,
              title: 'Audio Quality Preference',
              subtitle: 'Balance between quality and generation speed',
              icon: Icons.high_quality,
              color: Colors.deepPurple,
              multiSelect: false,
              isRequired: true,
              options: [
                ActionOption(
                  id: 'fast',
                  label: 'Fast Generation - Good quality, quick results',
                  icon: Icons.speed,
                  color: Colors.orange,
                ),
                ActionOption(
                  id: 'balanced',
                  label: 'Balanced - Great quality, moderate speed',
                  icon: Icons.balance,
                  color: Colors.blue,
                ),
                ActionOption(
                  id: 'premium',
                  label: 'Premium Quality - Best audio, takes longer',
                  icon: Icons.diamond,
                  color: Colors.purple,
                ),
              ],
              validationError: 'Please select your quality preference',
            ),
            InteractiveAction(
              id: 'cloud_sync',
              type: InteractiveActionType.toggle,
              title: 'Cloud Sync',
              subtitle: 'Automatically backup your creations to the cloud',
              icon: Icons.cloud_sync,
              color: Colors.deepPurple,
              defaultValue: true,
              isRequired: false,
            ),
          ],
          requiresActions: true,
          canSkip: false,
          continueLabel: 'Start Creating! 🚀',
        ),
      ];
}
