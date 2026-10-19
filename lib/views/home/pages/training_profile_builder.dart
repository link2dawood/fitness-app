import 'package:flutter/material.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/onboarding_repository.dart';

class TrainingProfileBuilder extends StatefulWidget {
  const TrainingProfileBuilder({
    super.key,
    this.profile,
    required this.builder,
  });
  final UserProfile? profile;
  final Widget Function(BuildContext, UserProfile?) builder;
  @override
  State<TrainingProfileBuilder> createState() => _TrainingProfileBuilderState();
}

class _TrainingProfileBuilderState extends State<TrainingProfileBuilder> {
  late Future<UserProfile?> future = widget.profile != null
      ? Future.value(widget.profile)
      : OnboardingRepository().loadProfile();
  @override
  void didUpdateWidget(TrainingProfileBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      future = widget.profile != null
          ? Future.value(widget.profile)
          : OnboardingRepository().loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<UserProfile?>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError) {
        return Scaffold(
          appBar: AppBar(title: const Text('Training profile')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not load your fitness profile.'),
                TextButton(
                  onPressed: () => setState(
                    () => future = OnboardingRepository().loadProfile(),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }
      return widget.builder(context, snapshot.data);
    },
  );
}
