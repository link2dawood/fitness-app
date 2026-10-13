import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WorkoutSettingsView extends StatefulWidget {
  const WorkoutSettingsView({super.key});

  @override
  State<WorkoutSettingsView> createState() => _WorkoutSettingsViewState();
}

class _WorkoutSettingsViewState extends State<WorkoutSettingsView> {
  bool _musicOn = true;
  final int _prepSeconds = 15;
  final String _restTimerMode = 'Default';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF111827),
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Workout Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFF3F4F6),
            height: 1,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _buildItem(
            icon: Icons.person_outline_rounded,
            title: 'Gender',
            onTap: () {},
          ),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          _buildItem(
            icon: Icons.music_note_rounded,
            title: 'Music',
            valueText: _musicOn ? 'on >' : 'off >',
            onTap: () {
              setState(() {
                _musicOn = !_musicOn;
              });
            },
          ),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          _buildItem(
            icon: Icons.coffee_rounded,
            title: 'Rest timer',
            valueText: '$_restTimerMode >',
            onTap: () {},
          ),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          _buildItem(
            icon: Icons.history_toggle_off_rounded,
            title: 'Prep timer',
            valueText: '$_prepSeconds secs >',
            onTap: () {},
          ),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          _buildItem(
            icon: Icons.record_voice_over_rounded,
            title: 'Sound options',
            onTap: () {},
          ),
          const Divider(color: Color(0xFFF3F4F6), height: 1),
          _buildItem(
            icon: Icons.replay_rounded,
            title: 'Restart progress',
            onTap: () {
              HapticFeedback.selectionClick();
              _showRestartProgressDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    String? valueText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: const Color(0xFF8E97A5),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            if (valueText != null)
              Text(
                valueText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0066FF),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showRestartProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Restart Progress?'),
        content: const Text('Are you sure you want to restart all workout progress?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Workout progress restarted.')),
              );
            },
            child: const Text('Restart', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
