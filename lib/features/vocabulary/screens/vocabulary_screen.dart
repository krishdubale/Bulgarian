import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/vocabulary_provider.dart';

class VocabularyScreen extends ConsumerWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Choose a category to practice',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ...AppConstants.vocabularyCategories.map((category) {
            final words = ref.watch(categoryWordsProvider(category));
            final icon =
                AppConstants.categoryIcons[category] ?? '📖';
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.primary.withOpacity(0.1),
                  child: Text(icon, style: const TextStyle(fontSize: 20)),
                ),
                title: Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('${words.length} words'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () =>
                    context.push('/flashcard?category=$category'),
              ),
            );
          }),
        ],
      ),
    );
  }
}
