import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../profile/presentation/profile_colors.dart';
import '../../../profile/presentation/widgets/profile_module_widgets.dart';
import '../../domain/entities/app_settings.dart';
import '../state/settings_store.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({
    super.key,
    required this.settingsStore,
    required this.onProfileReset,
    required this.onProfileRestored,
    required this.onOpenAssessments,
  });
  final SettingsStore settingsStore;
  final VoidCallback onProfileReset;
  final Future<void> Function() onProfileRestored;
  final VoidCallback onOpenAssessments;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: settingsStore,
    builder: (context, _) => ProfileModuleScaffold(
      title: 'Account Settings',
      followAppTheme: true,
      child: ProfileModuleBody(
        children: [
          const _LocalStatusBanner(),
          _section(
            context,
            'Appearance & locale',
            Icons.palette_outlined,
            ProfileCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SettingLabel('App theme'),
                  const SizedBox(height: 10),
                  _ThemeSelector(
                    selected: settingsStore.settings.themeMode,
                    enabled: !settingsStore.saving,
                    onChanged: (mode) =>
                        _save(context, () => settingsStore.setTheme(mode)),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  const _SettingLabel('Display language'),
                  const SizedBox(height: 3),
                  Text(
                    'English (US)',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'More languages will be available in a future update.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _section(
            context,
            'Units & formatting',
            Icons.straighten,
            ProfileCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SettingLabel('Measurement standard'),
                  const SizedBox(height: 4),
                  Text(
                    'Used across body measurements and progress.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _UnitOption(
                          title: 'Metric',
                          details: 'kg  ·  cm  ·  km',
                          selected:
                              settingsStore.settings.units ==
                              MeasurementUnits.metric,
                          enabled: !settingsStore.saving,
                          onTap: () => _save(
                            context,
                            () =>
                                settingsStore.setUnits(MeasurementUnits.metric),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _UnitOption(
                          title: 'Imperial',
                          details: 'lb  ·  in  ·  mi',
                          selected:
                              settingsStore.settings.units ==
                              MeasurementUnits.imperial,
                          enabled: !settingsStore.saving,
                          onTap: () => _save(
                            context,
                            () => settingsStore.setUnits(
                              MeasurementUnits.imperial,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _section(
            context,
            'Local data',
            Icons.storage_outlined,
            ProfileCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: ProfileColors.green.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.verified_user_outlined,
                          color: ProfileColors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stored on this device',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _statusText(settingsStore.localData),
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      _DataCount(
                        value: settingsStore.localData?.assessments,
                        label: 'Assessments',
                      ),
                      _DataCount(
                        value: settingsStore.localData?.measurements,
                        label: 'Measurements',
                      ),
                      _DataCount(
                        value: settingsStore.localData?.goals,
                        label: 'Goals',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _InfoNote(
                    text: 'Your profile and training records stay in the local ObjectBox database. No account or cloud sync is configured.',
                  ),
                ],
              ),
            ),
          ),
          _section(
            context,
            'Privacy & permissions',
            Icons.notifications_active_outlined,
            ProfileCard(
              child: Column(
                children: [
                  _SettingsAction(
                    icon: Icons.notifications_none,
                    title: 'Workout reminders',
                    subtitle: 'Review how notifications are handled.',
                    onTap: () => _showInfo(
                      context,
                      'Notifications',
                      'Motion Orbit does not schedule notifications in this build. It will not send workout or assessment reminders.',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _SettingsAction(
                    icon: Icons.videocam_outlined,
                    title: 'Camera access',
                    subtitle: 'Not requested. Camera capture is not enabled.',
                    onTap: () => _showInfo(
                      context,
                      'Camera access',
                      'This build does not capture camera video, and it has not requested camera permission. If camera-based form checks are added, access should be requested only when you start that feature.',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _SettingsAction(
                    icon: Icons.policy_outlined,
                    title: 'Privacy policy & training disclaimer',
                    subtitle:
                        'See what stays on this device and how it is used.',
                    onTap: () => _showInfo(
                      context,
                      'Privacy & training data',
                      'Profile details, assessments, measurements, and goals are stored in this app’s local ObjectBox database. This build has no account, cloud sync, telemetry server, or camera capture. Training measurements are self-reported and are not medical advice.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          _section(
            context,
            'AI models · offline intelligence',
            Icons.psychology_outlined,
            ProfileCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.model_training_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Movement Analyzer',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'No model installed in this build',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 19,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This build includes no on-device inference runtime or model weights. Your manual fitness assessments are available locally.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onOpenAssessments,
                      icon: const Icon(Icons.insights_outlined, size: 18),
                      label: const Text('Open assessments'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _section(
            context,
            'Data management',
            Icons.storage_outlined,
            ProfileCard(
              child: Column(
                children: [
                  _SettingsAction(
                    icon: Icons.download_outlined,
                    title: 'Export JSON backup',
                    subtitle: 'Create a full local profile backup file.',
                    onTap: () => _shareBackup(context, csv: false),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _SettingsAction(
                    icon: Icons.table_view_outlined,
                    title: 'Export CSV',
                    subtitle: 'Share records in a spreadsheet-friendly format.',
                    onTap: () => _shareBackup(context, csv: true),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _SettingsAction(
                    icon: Icons.upload_file_outlined,
                    title: 'Restore backup from clipboard',
                    subtitle: 'Paste a Motion Orbit JSON backup to restore it.',
                    onTap: () => _restoreBackup(context),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _SettingsAction(
                    icon: Icons.delete_outline,
                    title: 'Reset local profile data',
                    subtitle: 'Remove the saved profile and all local records.',
                    danger: true,
                    onTap: () => _confirmReset(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This keeps your theme and unit preferences.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ProfileCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(
                      'assets/profile/motion_orbit_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Motion Orbit',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Version 0.1.0 (Offline Build)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outlineVariant
                        .withValues(alpha: .5),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    children: [
                      _AboutLink(
                        icon: Icons.code,
                        label: 'Open Source Licenses',
                        onTap: () => _openExternalLink(
                          context,
                          Uri.parse(
                            'https://github.com/brilliyant/motion-orbit/blob/main/LICENSE',
                          ),
                        ),
                      ),
                      Text(
                        '·',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      _AboutLink(
                        icon: Icons.terminal,
                        label: 'GitHub Repository',
                        onTap: () => _openExternalLink(
                          context,
                          Uri.parse(
                            'https://github.com/brilliyant/motion-orbit',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _section(
    BuildContext context,
    String title,
    IconData icon,
    Widget child,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 3, bottom: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    ),
  );

  Future<void> _showInfo(BuildContext context, String title, String message) =>
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );

  Future<void> _openExternalLink(BuildContext context, Uri uri) async {
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        _showMessage(context, 'Could not open the link. Please try again.');
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Could not open the link. Please try again.');
      }
    }
  }

  Future<void> _shareBackup(BuildContext context, {required bool csv}) async {
    try {
      final content = csv
          ? settingsStore.createCsvBackup()
          : settingsStore.createJsonBackup();
      final bytes = Uint8List.fromList(utf8.encode(content));
      await Share.shareXFiles([
        XFile.fromData(
          bytes,
          name: csv ? 'motion_orbit_backup.csv' : 'motion_orbit_backup.json',
          mimeType: csv ? 'text/csv' : 'application/json',
        ),
      ], subject: 'Motion Orbit local backup');
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Could not create the backup. Please try again.');
      }
    }
  }

  Future<void> _restoreBackup(BuildContext context) async {
    final controller = TextEditingController();
    var pasted = false;
    final shouldRestore = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Restore local backup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste a Motion Orbit JSON backup. Restoring replaces the saved profile and records.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Backup JSON',
                  border: OutlineInputBorder(),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    controller.text = data?.text ?? '';
                    setDialogState(() => pasted = controller.text.isNotEmpty);
                  },
                  icon: const Icon(Icons.content_paste, size: 17),
                  label: Text(pasted ? 'Pasted' : 'Paste clipboard'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: controller.text.trim().isEmpty
                  ? null
                  : () => Navigator.of(dialogContext).pop(true),
              child: const Text('Restore'),
            ),
          ],
        ),
      ),
    );
    if (shouldRestore != true) {
      controller.dispose();
      return;
    }
    try {
      await settingsStore.restoreBackup(controller.text);
      await onProfileRestored();
      if (context.mounted) _showMessage(context, 'Backup restored.');
    } catch (error) {
      if (context.mounted) {
        final message = error is FormatException
            ? error.message
            : 'Could not restore the backup. Please check the JSON and try again.';
        _showMessage(context, message);
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _confirmReset(BuildContext context) async {
    final reset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_forever_outlined),
        title: const Text('Reset local profile data?'),
        content: const Text(
          'This permanently removes the saved profile, assessments, measurements, goals, and local recovery snapshots. Theme and unit preferences are kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset data'),
          ),
        ],
      ),
    );
    if (reset != true) return;
    try {
      await settingsStore.resetProfileData();
      onProfileReset();
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Could not reset local profile data.');
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _statusText(LocalDataSummary? data) {
    if (data == null) return 'Reading local database…';
    if (!data.profileSaved) return 'Local database is ready';
    return '${data.totalRecords} saved records · Live from ObjectBox';
  }

  Future<void> _save(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save this setting. Please try again.'),
        ),
      );
    }
  }
}

class _LocalStatusBanner extends StatelessWidget {
  const _LocalStatusBanner();
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: ProfileColors.green.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(Icons.circle, color: ProfileColors.green, size: 8),
        SizedBox(width: 9),
        Expanded(
          child: Text(
            'LOCAL DATABASE ON DEVICE',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: .7,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          'ZERO SYNC',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: .5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

class _SettingLabel extends StatelessWidget {
  const _SettingLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurface,
    ),
  );
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });
  final AppThemeMode selected;
  final bool enabled;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Row(
      children: [
        _choice(
          context,
          AppThemeMode.system,
          'System',
          Icons.settings_brightness_outlined,
        ),
        _choice(
          context,
          AppThemeMode.light,
          'Light',
          Icons.light_mode_outlined,
        ),
        _choice(context, AppThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
      ],
    ),
  );

  Widget _choice(
    BuildContext context,
    AppThemeMode value,
    String label,
    IconData icon,
  ) {
    final active = selected == value;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: active
              ? Theme.of(context).colorScheme.surface
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: enabled ? () => onChanged(value) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 17,
                    color: active
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UnitOption extends StatelessWidget {
  const _UnitOption({
    required this.title,
    required this.details,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });
  final String title;
  final String details;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: selected
        ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .42)
        : Theme.of(context).colorScheme.surfaceContainerLow,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: .38)
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              details,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DataCount extends StatelessWidget {
  const _DataCount({required this.value, required this.label});
  final int? value;
  final String label;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value?.toString() ?? '–',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        Icons.info_outline,
        size: 15,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            height: 1.4,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ],
  );
}

class _SettingsAction extends StatelessWidget {
  const _SettingsAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: danger
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: danger
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 19,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    ),
  );
}

class _AboutLink extends StatelessWidget {
  const _AboutLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: scheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: scheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
