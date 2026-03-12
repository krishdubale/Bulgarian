import 'package:flutter/material.dart';
import '../../../core/constants/bulgarian_data.dart';

class PronunciationScreen extends StatelessWidget {
  const PronunciationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Pronunciation Trainer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: theme.colorScheme.primary.withOpacity(0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🗣️ Tips for Bulgarian Pronunciation',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Bulgarian uses a 30-letter Cyrillic alphabet\n'
                    '• Most letters have one consistent sound (unlike English)\n'
                    '• The letter Ъ (uh) is unique to Bulgarian – like the "u" in "hurt"\n'
                    '• Stress is unpredictable – learn it with each word\n'
                    '• The rolled "R" (Р) sounds like the Spanish R',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'LETTER PRONUNCIATION GUIDE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...BulgarianData.alphabet.map(
            (letter) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                  child: Text(
                    letter.cyrillic.split('').first,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      letter.cyrillic,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: theme.colorScheme.secondary.withOpacity(0.15),
                      ),
                      child: Text(
                        letter.romanization,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(letter.pronunciationGuide),
                    Text(
                      '${letter.exampleWordBulgarian} = ${letter.exampleWordEnglish}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
