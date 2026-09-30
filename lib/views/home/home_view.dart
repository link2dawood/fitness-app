import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/home_viewmodel.dart';
import 'pages/discover_page.dart';
import 'pages/report_page.dart';
import 'pages/settings_page.dart';
import 'pages/training_page.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    final pages = const [
      TrainingPage(),
      DiscoverPage(),
      ReportPage(),
      SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: vm.currentTab,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFF1F3F7), width: 1.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.timer_rounded,
                  label: 'Training',
                  isSelected: vm.currentTab == 0,
                  onTap: () => vm.setTab(0),
                ),
                _buildNavItem(
                  icon: Icons.explore_rounded,
                  label: 'Discover',
                  isSelected: vm.currentTab == 1,
                  onTap: () => vm.setTab(1),
                ),
                _buildNavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Report',
                  isSelected: vm.currentTab == 2,
                  onTap: () => vm.setTab(2),
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Settings',
                  isSelected: vm.currentTab == 3,
                  onTap: () => vm.setTab(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const activeBlue = Color(0xFF0062FF);
    const inactiveGrey = Color(0xFF9CA3AF);

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? activeBlue : inactiveGrey,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeBlue : inactiveGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
