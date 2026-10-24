import 'package:flutter/material.dart';

/// Keeps recovery available without automatically deleting unreadable data.
class StorageRecoveryView extends StatefulWidget {
  const StorageRecoveryView({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    required this.onReset,
    required this.resetLabel,
    required this.resetDescription,
  });
  final String title, message, resetLabel, resetDescription;
  final Future<void> Function() onRetry, onReset;
  @override
  State<StorageRecoveryView> createState() => _StorageRecoveryViewState();
}

class _StorageRecoveryViewState extends State<StorageRecoveryView> {
  bool _busy = false;
  String? _error;
  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action().timeout(const Duration(seconds: 15));
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not complete recovery. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    if (_busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text('${widget.resetLabel}?'),
        content: Text(widget.resetDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(widget.resetLabel),
          ),
        ],
      ),
    );
    if (mounted && confirmed == true) await _run(widget.onReset);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storage_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(widget.message, textAlign: TextAlign.center),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy ? null : () => _run(widget.onRetry),
                  child: Text(_busy ? 'Please wait…' : 'Retry'),
                ),
                TextButton(
                  onPressed: _busy ? null : _reset,
                  child: Text(widget.resetLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
