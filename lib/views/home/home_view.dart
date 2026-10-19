import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/home_viewmodel.dart';
import '../../core/theme/app_colors.dart';
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
      body: IndexedStack(index: vm.currentTab, children: pages),
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
    const activeAccent = AppColors.primary;
    const inactiveGrey = AppColors.textSecondary;

    void activate() {
      HapticFeedback.selectionClick();
      onTap();
    }

    return Expanded(
      child: Semantics(
        container: true,
        button: true,
        selected: isSelected,
        label: '$label tab',
        onTap: activate,
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: InkWell(
              onTap: activate,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 24,
                      color: isSelected ? activeAccent : inactiveGrey,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: isSelected ? activeAccent : inactiveGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
