import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/backup.dart';
import '../../data/backup_store.dart';
import '../../data/providers.dart';
import '../../shared/format.dart';
import '../../shared/widgets/confirm.dart';

/// "Sun 25 Oct 2026, 00:41", or "None yet".
String formatBackupTime(DateTime? t) =>
    t == null ? 'None yet' : '${formatDate(t)}, ${formatTimeOfDay(t)}';

/// Settings → Backup: when the last copy was made, back up (and share) now,
/// restore from a file.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  void _say(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _run(Future<void> Function() task) async {
    setState(() => _busy = true);
    try {
      await task();
    } catch (e) {
      if (mounted) _say('Failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _backUp(Backups backups) => _run(() async {
    final file = await backups.backUpNow();
    if (!mounted) return;
    _say('Saved in ${backups.store.location}.');
    if (Platform.isAndroid) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/octet-stream')],
        ),
      );
    }
  });

  Future<void> _restore(Backups backups) async {
    if (ref.read(activeWorkoutProvider).value != null) {
      _say('Finish or discard the running workout first.');
      return;
    }
    final picked = await FilePicker.pickFiles(dialogTitle: 'Choose a backup');
    if (picked.isEmpty || !mounted) return;
    await _run(() async {
      final staged = await backups.stage(await picked.first.readAsBytes());
      final BackupInfo info;
      try {
        info = backups.inspect(staged);
      } on BackupException catch (e) {
        if (mounted) _say('$e');
        return;
      }
      if (!mounted || !await _confirmRestore(info)) return;
      await backups.restore(staged);
      if (mounted) _say('Backup restored.');
    });
  }

  Future<bool> _confirmRestore(BackupInfo info) {
    final last = info.lastWorkout;
    return confirm(
      context,
      title: 'Restore this backup?',
      message:
          '${info.workouts} ${info.workouts == 1 ? 'workout' : 'workouts'}'
          '${last == null ? '' : ', the last on ${formatDate(last)}'}.\n\n'
          'It replaces all your data. The current data is backed up first, '
          'so you can go back.',
      action: 'Restore',
      destructive: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final backups = ref.watch(backupsProvider);
    final last = ref.watch(lastBackupProvider).value;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup'),
        bottom: _busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: backups == null
          ? const Center(child: Text('No backups on this device.'))
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'A copy of all your data is saved in '
                    '${backups.store.location} after every finished workout, '
                    'and once a day when something changed. The newest 30 '
                    'automatic copies are kept; copies made here stay until '
                    'you delete them.',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Last backup'),
                  subtitle: Text(
                    formatBackupTime(last) +
                        (backups.lastError == null
                            ? ''
                            : '\nLast automatic backup failed: '
                                  '${backups.lastError}'),
                    style: backups.lastError == null
                        ? null
                        : TextStyle(color: colors.error),
                  ),
                ),
                ListTile(
                  enabled: !_busy,
                  leading: Icon(
                    Platform.isAndroid ? Icons.share_outlined : Icons.save_alt,
                  ),
                  title: Text(
                    Platform.isAndroid ? 'Back up and share…' : 'Back up now',
                  ),
                  subtitle: Platform.isAndroid
                      ? const Text('Then send it to Drive, mail …')
                      : null,
                  onTap: () => _backUp(backups),
                ),
                ListTile(
                  enabled: !_busy,
                  leading: const Icon(Icons.settings_backup_restore),
                  title: const Text('Restore from a backup…'),
                  subtitle: const Text(
                    'Replaces all data; the current data is backed up first',
                  ),
                  onTap: () => _restore(backups),
                ),
              ],
            ),
    );
  }
}
