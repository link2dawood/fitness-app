import 'package:flutter/material.dart';

import '../../core/settings/general_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/app_language.dart';

Future<void> showLanguageOptions(BuildContext context) => showDialog<void>(
  context: context,
  builder: (_) => const LanguageOptionsDialog(),
);

class LanguageOptionsDialog extends StatefulWidget {
  const LanguageOptionsDialog({super.key});
  @override
  State<LanguageOptionsDialog> createState() => _LanguageOptionsDialogState();
}

class _LanguageOptionsDialogState extends State<LanguageOptionsDialog> {
  final settings = GeneralSettings.instance;
  late final ScrollController _scrollController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: settings.language.index * 64.0,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _select(AppLanguage language) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await settings.setLanguage(language);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save language. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: SizedBox(
      width: 420,
      height: MediaQuery.sizeOf(context).height * 0.88,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: AppLanguage.values.length,
                  itemExtent: 64,
                  itemBuilder: (context, index) {
                    final language = AppLanguage.values[index];
                    final selected = settings.language == language;
                    return Semantics(
                      checked: selected,
                      inMutuallyExclusiveGroup: true,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        leading: Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected
                              ? AppColors.primary
                              : const Color(0xFF757575),
                          size: 28,
                        ),
                        title: Text(
                          language.label,
                          textDirection: language.rtl
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          textAlign: language.rtl
                              ? TextAlign.right
                              : TextAlign.left,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        onTap: _saving ? null : () => _select(language),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (_saving)
              const LinearProgressIndicator(color: AppColors.primary),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Saves your preference. App translations are not available yet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
