/// Dil, erişilebilirlik ve geri bildirim. Metinler [AppStrings] sözlüğünden.
library;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../config/app_config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final t = scope.t;
    final settings = scope.settings;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.settingsHeaderStart,
                AppDimens.settingsHeaderTop,
                AppDimens.pagePadding,
                AppDimens.settingsHeaderEndGap,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.text,
                  ),
                  const SizedBox(width: AppDimens.spaceXXSmall),
                  Text(
                    t(AppStringKey.settings),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.pagePadding,
                  AppDimens.settingsListTop,
                  AppDimens.pagePadding,
                  AppDimens.settingsListBottom,
                ),
                children: [
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(
                          icon: Icons.language,
                          label: t(AppStringKey.language),
                        ),
                        const SizedBox(height: AppDimens.spaceRegular),
                        Row(
                          children: [
                            for (final entry
                                in AppLanguages.supported.entries) ...[
                              Expanded(
                                child: _LanguageChip(
                                  label: t(
                                    AppStringKey.languageNameKeys[entry.key]!,
                                  ),
                                  selected: scope.languageCode == entry.key,
                                  onTap: () => settings.setLanguage(entry.key),
                                ),
                              ),
                              if (entry.key != AppLanguages.supported.keys.last)
                                const SizedBox(width: AppDimens.spaceSmall),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.spaceRegular),
                  _Card(
                    child: Column(
                      children: [
                        _ToggleRow(
                          label: t(AppStringKey.colorBlindMode),
                          hint: t(AppStringKey.colorBlindModeHint),
                          value: scope.colorBlindMode,
                          onChanged: settings.setColorBlindMode,
                        ),
                        const Divider(
                          color: AppColors.divider,
                          height: AppDimens.dividerHeight,
                        ),
                        _ToggleRow(
                          label: t(AppStringKey.sound),
                          value: scope.soundEnabled,
                          onChanged: settings.setSoundEnabled,
                        ),
                        const Divider(
                          color: AppColors.divider,
                          height: AppDimens.dividerHeight,
                        ),
                        _ToggleRow(
                          label: t(AppStringKey.haptic),
                          value: scope.hapticEnabled,
                          onChanged: settings.setHapticEnabled,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.spaceRegular),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(
                          icon: Icons.info_outline_rounded,
                          label: t(AppStringKey.about),
                        ),
                        const SizedBox(height: AppDimens.spaceXSmall),
                        _MetaRow(
                          label: t(AppStringKey.game),
                          value: AppIdentity.appName,
                        ),
                        _MetaRow(
                          label: t(AppStringKey.version),
                          value: AppIdentity.version,
                        ),
                        _MetaRow(
                          label: t(AppStringKey.developedBy),
                          value: AppIdentity.developer,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        child: child,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppDimens.iconSection, color: AppColors.textMuted),
        const SizedBox(width: AppDimens.spaceXSmall),
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accent : AppColors.chipIdle,
      borderRadius: BorderRadius.circular(AppDimens.languageChipRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.languageChipRadius),
        child: SizedBox(
          height: AppDimens.languageChipHeight,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.background : AppColors.text,
                fontWeight: AppType.chipWeight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final String? hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimens.toggleRowVertical,
      ),
      child: Row(
        crossAxisAlignment:
            hint == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyLarge),
                if (hint != null) ...[
                  const SizedBox(height: AppDimens.spaceXXSmall),
                  Text(hint!, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.metaRowVertical),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
