import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/language_model.dart';
import '../../core/providers/app_providers.dart';
import 'content_loader.dart';

/// Provider for the currently selected language.
final selectedLanguageProvider =
    StateNotifierProvider<LanguageNotifier, LanguageModel>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final contentLoader = ref.watch(contentLoaderProvider);
  return LanguageNotifier(prefs, contentLoader);
});

/// Provider for the list of available languages.
final availableLanguagesProvider = Provider<List<LanguageModel>>((ref) {
  return LanguageModel.supportedLanguages;
});

/// Manages language selection and persistence.
class LanguageNotifier extends StateNotifier<LanguageModel> {
  LanguageNotifier(this._prefs, this._contentLoader)
      : super(LanguageModel.supportedLanguages.first) {
    _loadSavedLanguage();
  }

  final SharedPreferences _prefs;
  final ContentLoader _contentLoader;

  static const _key = 'selected_language_id';

  String get currentLanguageId => state.id;

  /// Load the saved language preference.
  void _loadSavedLanguage() {
    final savedId = _prefs.getString(_key);
    if (savedId != null) {
      state = LanguageModel.getById(savedId);
    }
  }

  /// Switch to a different language.
  Future<void> switchLanguage(String languageId) async {
    if (languageId == state.id) return;

    // Clear cached content from previous language.
    _contentLoader.clearCache();

    // Update state.
    state = LanguageModel.getById(languageId);

    // Persist selection.
    await _prefs.setString(_key, languageId);

    // Preload new language content.
    await _contentLoader.preloadLanguage(languageId);
  }
}
