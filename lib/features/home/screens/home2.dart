import 'dart:io';

import 'package:faithlock/core/constants/export.dart';
import 'package:faithlock/shared/widgets/export.dart';
import 'package:flutter/material.dart';

/// Use case réel démontrant FastFonts vs FastTextStyle
/// Scénario: App de profil utilisateur avec différents besoins typographiques
class Home2Screen extends StatefulWidget {
  const Home2Screen({super.key});

  @override
  State<Home2Screen> createState() => _Home2ScreenState();
}

class _Home2ScreenState extends State<Home2Screen> {
  File? profileImage;
  String userName = "Sarah Johnson";
  String userRole = "Senior Product Designer";
  int followers = 2847;
  bool isPremium = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: FastListView(
          padding: const EdgeInsets.all(20),
          children: [
            // === SECTION 1: EN-TÊTE PROFIL ===
            _buildProfileHeader(),

            const SizedBox(height: 32),

            // === SECTION 2: DÉMONSTRATION FAST TYPOGRAPHY ===
            _buildTypographyShowcase(),

            const SizedBox(height: 32),

            // === SECTION 3: DÉMONSTRATION FAST FONTS ===
            _buildFontsShowcase(),

            const SizedBox(height: 32),

            // === SECTION 4: CAS D'USAGE MIXTE ===
            _buildMixedUsageExample(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Photo de profil avec FastImagePicker
          FastImagePicker(
            image: profileImage,
            onImageSelected: (file) {
              setState(() {
                profileImage = file;
              });
            },
            width: 120,
            height: 120,
            placeholder: 'Photo profil',
          ),

          const SizedBox(height: 16),

          // 🎯 FAST TYPOGRAPHY: Styles prédéfinis pour UI
          Text(
            userName,
            style: FastTextStyle.largeTitle(context), // Alan Sans avec tailles iOS/Material
          ),

          Text(
            userRole,
            style: FastTextStyle.listSubtitle(context), // Couleurs automatiques
          ),

          const SizedBox(height: 12),

          // Badge premium avec style contextuel
          if (isPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '⭐ Premium',
                style: FastTextStyle.caption1(context).copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypographyShowcase() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎨 FastTextStyle - Styles UI prédéfinis',
            style: FastTextStyle.headline(context, color: Colors.blue),
          ),
          
          const SizedBox(height: 16),
          
          // Test du dark mode 
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🌙 Test Dark/Light Mode:', style: FastTextStyle.caption1(context)),
                const SizedBox(height: 8),
                Text('Texte adaptatif', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                Text('Texte secondaire', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Container(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Avantages:',
            style: FastTextStyle.title3(context),
          ),

          const SizedBox(height: 8),

          _buildFeatureItem('✅ Tailles platform-aware (iOS 34pt vs Material 57sp)'),
          _buildFeatureItem('✅ Couleurs système automatiques'),
          _buildFeatureItem('✅ Accessibilité intégrée (Dynamic Type)'),
          _buildFeatureItem('✅ Sémantique (navigationTitle, error, success)'),

          const SizedBox(height: 16),

          // Exemples pratiques
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exemples:', style: FastTextStyle.caption1(context)),
                const SizedBox(height: 8),
                Text('Titre principal', style: FastTextStyle.title1(context)),
                Text('Texte de base', style: FastTextStyle.body(context)),
                Text('Message d\'erreur', style: FastTextStyle.error(context)),
                Text('Message de succès', style: FastTextStyle.success(context)),
                Text('Bouton', style: FastTextStyle.button(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontsShowcase() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚙️ FastFonts - Configuration technique',
            style: FastTextStyle.headline(context, color: Colors.green),
          ),

          const SizedBox(height: 16),

          Text(
            'Avantages:',
            style: FastTextStyle.title3(context),
          ),

          const SizedBox(height: 8),

          _buildFeatureItem('✅ Contrôle précis des polices'),
          _buildFeatureItem('✅ Fallbacks platform-spécifiques'),
          _buildFeatureItem('✅ Poids de police personnalisés'),
          _buildFeatureItem('✅ Styles techniques flexibles'),

          const SizedBox(height: 16),

          // Démonstration des poids Alan Sans
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Poids Alan Sans:', style: FastTextStyle.caption1(context)),
                const SizedBox(height: 8),

                // 🎯 FAST FONTS: Contrôle précis des poids
                Text(
                  'Alan Sans Light',
                  style: FastFonts.primaryStyle(
                    weight: FastFonts.light,
                    size: 18,
                  ),
                ),
                Text(
                  'Alan Sans Regular',
                  style: FastFonts.primaryStyle(
                    weight: FastFonts.regular,
                    size: 18,
                  ),
                ),
                Text(
                  'Alan Sans Medium',
                  style: FastFonts.primaryStyle(
                    weight: FastFonts.medium,
                    size: 18,
                  ),
                ),
                Text(
                  'Alan Sans Bold',
                  style: FastFonts.primaryStyle(
                    weight: FastFonts.bold,
                    size: 18,
                  ),
                ),
                Text(
                  'Alan Sans Black',
                  style: FastFonts.primaryStyle(
                    weight: FastFonts.black,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMixedUsageExample() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🚀 Cas d\'usage mixte - Card de statistiques',
            style: FastTextStyle.headline(context, color: Colors.purple),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Statistique 1
                Expanded(
                  child: Column(
                    children: [
                      // 🎯 FAST FONTS: Chiffre important avec poids custom
                      Text(
                        '$followers',
                        style: FastFonts.primaryStyle(
                          weight: FastFonts.black, // Poids maximum pour impact
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      // 🎯 FAST TYPOGRAPHY: Label sémantique
                      Text(
                        'Followers',
                        style: FastTextStyle.caption1(context),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).dividerColor,
                ),

                // Statistique 2
                Expanded(
                  child: Column(
                    children: [
                      // 🎯 FAST FONTS: Design personnalisé
                      Text(
                        '156',
                        style: FastFonts.primaryStyle(
                          weight: FastFonts.bold,
                          size: 32,
                          color: Colors.green,
                        ),
                      ),

                      // 🎯 FAST TYPOGRAPHY: Style système
                      Text(
                        'Posts',
                        style: FastTextStyle.caption1(context),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).dividerColor,
                ),

                // Statistique 3
                Expanded(
                  child: Column(
                    children: [
                      // 🎯 FAST FONTS: Créativité typographique
                      Text(
                        '4.9',
                        style: FastFonts.primaryStyle(
                          weight: FastFonts.extraBold,
                          size: 32,
                          color: Colors.orange,
                          letterSpacing: -1.0, // Espacement custom
                        ),
                      ),

                      // 🎯 FAST TYPOGRAPHY: Cohérence UI
                      Text(
                        'Rating',
                        style: FastTextStyle.caption1(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            '💡 Résumé:',
            style: FastTextStyle.title3(context),
          ),

          const SizedBox(height: 8),

          _buildFeatureItem('FastTextStyle = Interface utilisateur cohérente'),
          _buildFeatureItem('FastFonts = Créativité et contrôle technique'),
          _buildFeatureItem('Utilisez les deux selon le besoin!'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: FastTextStyle.body(context),
      ),
    );
  }
}
