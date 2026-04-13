import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../data/models/language_model.dart';
import '../../../data/services/language_manager.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final languages = ref.watch(availableLanguagesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: DesignTokens.spacingXl),
              Text(
                '🌍',
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: DesignTokens.spacingMd),
              Text(
                'Choose Language',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.spacingSm),
              Text(
                'What would you like to learn?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: DesignTokens.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.spacingXl),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: DesignTokens.spacingMd,
                    mainAxisSpacing: DesignTokens.spacingMd,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final isSelected = lang.id == selectedLanguage.id;
                    return _LanguageCard(
                      language: lang,
                      isSelected: isSelected,
                      onTap: () async {
                        await ref.read(selectedLanguageProvider.notifier)
                            .switchLanguage(lang.id);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final LanguageModel language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: DesignTokens.animNormal,
      curve: DesignTokens.animCurveEnter,
      child: Material(
        color: isSelected
            ? DesignTokens.primary.withOpacity(0.08)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              border: Border.all(
                color: isSelected
                    ? DesignTokens.primary
                    : Colors.grey.shade300,
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected ? DesignTokens.glowPrimary : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  language.flag,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(height: DesignTokens.spacingSm),
                Text(
                  language.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? DesignTokens.primary : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  language.script,
                  style: theme.textTheme.bodySmall,
                ),
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  const Icon(Icons.check_circle,
                      color: DesignTokens.primary, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
