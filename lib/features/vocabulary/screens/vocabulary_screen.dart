import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/animated_widgets.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../data/services/content_loader.dart';
import '../../../data/services/language_manager.dart';

class VocabularyScreen extends ConsumerWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = ref.watch(userProgressProvider);
    final language = ref.watch(selectedLanguageProvider);
    final contentLoader = ref.watch(contentLoaderProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${language.name} Vocabulary'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: contentLoader.loadVocabulary(language.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No vocabulary available yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vocabulary for ${language.name} is coming soon!',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          // Extract categories from loaded data
          final categoryNames = <String>[];
          final categoryWordCounts = <String, int>{};
          for (final cat in categories) {
            if (cat is Map<String, dynamic>) {
              final name = cat['name'] as String? ?? '';
              final words = cat['words'] as List? ?? [];
              categoryNames.add(name);
              categoryWordCounts[name] = words.length;
            }
          }

          final totalWords =
              categoryWordCounts.values.fold(0, (a, b) => a + b);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary card
              FadeSlideIn(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusLg),
                    boxShadow: DesignTokens.shadowSm,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            DesignTokens.primary.withOpacity(0.12),
                        child: const Icon(Icons.book,
                            color: DesignTokens.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${progress.wordsLearned} words learned',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$totalWords total words available',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'CATEGORIES',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: DesignTokens.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),

              ...categoryNames.asMap().entries.map((entry) {
                final idx = entry.key;
                final category = entry.value;
                final total = categoryWordCounts[category] ?? 0;
                final learned =
                    progress.categoryProgress[category] ?? 0;
                final progressValue = total > 0
                    ? (learned / total).clamp(0.0, 1.0)
                    : 0.0;
                final icon =
                    AppConstants.categoryIcons[category] ?? '📖';

                return FadeSlideIn(
                  delay: Duration(milliseconds: 60 * (idx + 1)),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: progressValue >= 1.0
                              ? DesignTokens.success.withOpacity(0.12)
                              : DesignTokens.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: progressValue >= 1.0
                              ? const Icon(Icons.check,
                                  color: DesignTokens.success, size: 18)
                              : Text(icon,
                                  style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                      title: Text(
                        category,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progressValue,
                                    minHeight: 6,
                                    backgroundColor: DesignTokens.primary
                                        .withOpacity(0.15),
                                    color: progressValue >= 1.0
                                        ? DesignTokens.success
                                        : DesignTokens.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$learned/$total',
                                style:
                                    theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: DesignTokens.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push('/flashcard?category=$category');
                      },
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
