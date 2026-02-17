// lib/features/tracking/screens/track_cases_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/resources/colors.dart';
import '../../../common/widgets/custom_app_bar.dart';
import '../components/track_case/tracking_widget.dart';


class TrackCasesScreen extends ConsumerWidget {
  static const routeName = "/track-cases";

  const TrackCasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(title: "Track Requests"),
      body: const TrackingWidget(),
    );
  }
}