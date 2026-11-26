import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/theme/app_theme.dart';

/// Implements Stitch `select_language_screen`.
class SelectLanguageScreen extends StatelessWidget {
  final bool fromSettings;

  const SelectLanguageScreen({super.key, this.fromSettings = false});

  static const List<Map<String, String>> _languages = [
    {
      'code': 'en',
      'name': 'English',
      'native': 'English (India)',
      'greeting': 'Fresh farm produce at honest prices',
    },
    {
      'code': 'mr',
      'name': 'Marathi',
      'native': 'मराठी',
      'greeting': 'शेतकऱ्यांकडून थेट तुमच्या दारात ताजी उत्पादने',
    },
    {
      'code': 'hi',
      'name': 'Hindi',
      'native': 'हिन्दी',
      'greeting': 'किसानों से सीधे आपके घर तक ताज़ा उपज',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: fromSettings
          ? AppBar(title: const Text('Language Settings'))
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.margin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.translate, size: 16, color: AppColors.onSecondaryContainer),
                    SizedBox(width: 6),
                    Text(
                      'MULTILINGUAL HARVEST',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Choose Your Preferred Language',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Browse produce names, harvest notes, and order updates in the language you are most comfortable with.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.separated(
                  itemCount: _languages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = settings.languageCode == lang['code'];
                    return InkWell(
                      onTap: () => settings.setLanguage(lang['code']!),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.surfaceContainerLow
                              : AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryContainer
                                : AppColors.cardBorder,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: AppShadows.level1,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryContainer
                                    : AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                              ),
                              child: Center(
                                child: Text(
                                  lang['code']!.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${lang['native']} • ${lang['name']}',
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    lang['greeting']!,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? AppColors.primaryContainer
                                  : AppColors.outline,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (fromSettings) {
                      context.pop();
                    } else {
                      context.go('/login');
                    }
                  },
                  child: Text(fromSettings ? 'Save Language' : 'Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
