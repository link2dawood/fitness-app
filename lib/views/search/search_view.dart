import 'package:flutter/material.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String? _selectedBodyFocus;
  String? _selectedWorkoutType;
  String? _selectedLevel;
  String? _selectedDuration;

  // Dedicated body part definitions with zoomed alignments focusing on each muscle group
  final List<Map<String, dynamic>> _bodyFocusItems = [
    {
      'label': 'Back',
      'primaryAsset': 'assets/images/body_back.png',
      'fallbackAsset': 'assets/images/splash_bg.png',
      'alignment': const Alignment(0.0, -0.8),
      'scale': 2.0,
    },
    {
      'label': 'Arm',
      'primaryAsset': 'assets/images/body_arm.png',
      'fallbackAsset': 'assets/images/splash_bg.png',
      'alignment': const Alignment(-0.7, -0.3),
      'scale': 2.4,
    },
    {
      'label': 'Butt & Leg',
      'primaryAsset': 'assets/images/body_leg.png',
      'fallbackAsset': 'assets/images/workout_squat.jpg',
      'alignment': const Alignment(0.0, 0.4),
      'scale': 1.6,
    },
    {
      'label': 'Chest',
      'primaryAsset': 'assets/images/body_chest.png',
      'fallbackAsset': 'assets/images/splash_bg.png',
      'alignment': const Alignment(0.0, -0.45),
      'scale': 2.2,
    },
    {
      'label': 'Shoulder',
      'primaryAsset': 'assets/images/body_shoulder.png',
      'fallbackAsset': 'assets/images/splash_bg.png',
      'alignment': const Alignment(0.65, -0.65),
      'scale': 2.2,
    },
    {
      'label': 'Full Body',
      'primaryAsset': 'assets/images/body_fullbody.png',
      'fallbackAsset': 'assets/images/male-Avatar.png',
      'alignment': Alignment.center,
      'scale': 1.0,
    },
    {
      'label': 'Abs',
      'primaryAsset': 'assets/images/body_abs.png',
      'fallbackAsset': 'assets/images/workout_abs.jpg',
      'alignment': const Alignment(0.0, 0.1),
      'scale': 1.8,
    },
  ];

  final List<Map<String, dynamic>> _workoutTypes = [
    {'label': 'HIIT', 'icon': Icons.bolt_rounded},
    {'label': 'Fat Burning', 'icon': Icons.local_fire_department_rounded},
    {'label': 'Build Muscle', 'icon': Icons.fitness_center_rounded},
    {'label': 'Warm-Up', 'icon': Icons.accessibility_new_rounded},
    {'label': 'With Equipment', 'icon': Icons.fitness_center_rounded},
    {'label': 'Low Impact', 'icon': Icons.sentiment_satisfied_alt_rounded},
    {'label': 'Stretch', 'icon': Icons.self_improvement_rounded},
  ];

  final List<Map<String, dynamic>> _levels = [
    {
      'label': 'Beginner',
      'bgColor': Color(0xFFEBF3FE),
      'textColor': Color(0xFF1E60F7),
    },
    {
      'label': 'Intermediate',
      'bgColor': Color(0xFFFFF3E8),
      'textColor': Color(0xFFE87813),
    },
    {
      'label': 'Advanced',
      'bgColor': Color(0xFFFDE8EC),
      'textColor': Color(0xFFE53958),
    },
  ];

  final List<String> _durations = [
    '≤10\nmins',
    '11-20\nmins',
    '21-30\nmins',
    '>30\nmins',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Search Bar & Cancel Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F7),
                        borderRadius: BorderRadius.circular(23),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: (val) {
                          setState(() {});
                        },
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F2937),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search workouts, plans...',
                          hintStyle: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF9CA3AF),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Color(0xFF9CA3AF),
                            size: 22,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0066FF),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  // 1. Body Focus Section
                  _buildSectionHeader('Body Focus'),
                  const SizedBox(height: 14),
                  _buildBodyFocusList(),

                  const SizedBox(height: 26),

                  // 2. Workout Type Section
                  _buildSectionHeader('Workout Type'),
                  const SizedBox(height: 14),
                  _buildWorkoutTypeGrid(),

                  const SizedBox(height: 26),

                  // 3. Level Section
                  _buildSectionHeader('Level'),
                  const SizedBox(height: 14),
                  _buildLevelRow(),

                  const SizedBox(height: 26),

                  // 4. Duration Section
                  _buildSectionHeader('Duration'),
                  const SizedBox(height: 14),
                  _buildDurationRow(),

                  const SizedBox(height: 32),

                  // 5. Can't find what you want? Request Button
                  _buildRequestSection(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF111827),
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildBodyFocusList() {
    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _bodyFocusItems.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = _bodyFocusItems[index];
          final label = item['label'] as String;
          final isSelected = _selectedBodyFocus == label;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedBodyFocus = isSelected ? null : label;
              });
            },
            child: Column(
              children: [
                _buildBodyFocusAvatar(item, isSelected),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF0066FF)
                        : const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBodyFocusAvatar(Map<String, dynamic> item, bool isSelected) {
    final primaryAsset = item['primaryAsset'] as String?;
    final fallbackAsset = item['fallbackAsset'] as String;
    final alignment = item['alignment'] as Alignment? ?? Alignment.center;
    final scale = item['scale'] as double? ?? 1.0;

    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? const Color(0xFF0066FF) : Colors.transparent,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: primaryAsset != null
            ? Image.asset(
                primaryAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildCroppedFallback(fallbackAsset, alignment, scale),
              )
            : _buildCroppedFallback(fallbackAsset, alignment, scale),
      ),
    );
  }

  Widget _buildCroppedFallback(
    String asset,
    Alignment alignment,
    double scale,
  ) {
    return Transform.scale(
      scale: scale,
      alignment: alignment,
      child: Image.asset(asset, fit: BoxFit.cover, alignment: alignment),
    );
  }

  Widget _buildWorkoutTypeGrid() {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // Column 1
          Column(
            children: [
              _buildWorkoutTypeCard(_workoutTypes[0]),
              const SizedBox(height: 12),
              _buildWorkoutTypeCard(_workoutTypes[2]),
            ],
          ),
          const SizedBox(width: 12),
          // Column 2
          Column(
            children: [
              _buildWorkoutTypeCard(_workoutTypes[1]),
              const SizedBox(height: 12),
              _buildWorkoutTypeCard(_workoutTypes[3]),
            ],
          ),
          const SizedBox(width: 12),
          // Column 3
          Column(
            children: [
              _buildWorkoutTypeCard(_workoutTypes[4]),
              const SizedBox(height: 12),
              _buildWorkoutTypeCard(_workoutTypes[6]),
            ],
          ),
          const SizedBox(width: 12),
          // Column 4
          Column(children: [_buildWorkoutTypeCard(_workoutTypes[5])]),
        ],
      ),
    );
  }

  Widget _buildWorkoutTypeCard(Map<String, dynamic> item) {
    final label = item['label'] as String;
    final icon = item['icon'] as IconData;
    final isSelected = _selectedWorkoutType == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedWorkoutType = isSelected ? null : label;
        });
      },
      child: Container(
        width: 148,
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0066FF).withValues(alpha: 0.1)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0066FF) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? const Color(0xFF0066FF)
                      : const Color(0xFF1F2937),
                  height: 1.2,
                ),
              ),
            ),
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? const Color(0xFF0066FF)
                  : const Color(0xFF0F172A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          for (int i = 0; i < _levels.length; i++) ...[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLevel = _selectedLevel == _levels[i]['label']
                        ? null
                        : _levels[i]['label'] as String;
                  });
                },
                child: Container(
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _levels[i]['bgColor'] as Color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedLevel == _levels[i]['label']
                          ? (_levels[i]['textColor'] as Color)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _levels[i]['label'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _levels[i]['textColor'] as Color,
                    ),
                  ),
                ),
              ),
            ),
            if (i < _levels.length - 1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildDurationRow() {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _durations.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final label = _durations[index];
          final isSelected = _selectedDuration == label;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDuration = isSelected ? null : label;
              });
            },
            child: Container(
              width: 110,
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0066FF).withValues(alpha: 0.1)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0066FF)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -6,
                    bottom: -6,
                    child: Icon(
                      Icons.access_time_filled_rounded,
                      size: 40,
                      color: Colors.black.withValues(alpha: 0.04),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? const Color(0xFF0066FF)
                            : const Color(0xFF0F172A),
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(child: Divider(color: Color(0xFFE2E8F0))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Can't find what you want?",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tell us what workout or plan you need!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0066FF)),
                  SizedBox(width: 8),
                  Text(
                    'Tell us what you need',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0066FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
