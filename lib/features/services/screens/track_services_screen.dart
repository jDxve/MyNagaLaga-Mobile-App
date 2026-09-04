// lib/features/tracking/screens/track_cases_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mynagalaga_mobile_app/common/resources/colors.dart';
import 'package:mynagalaga_mobile_app/common/widgets/custom_app_bar.dart';
import 'package:mynagalaga_mobile_app/features/services/components/track_case/tracking_widget.dart';


class TrackCasesScreen extends ConsumerWidget {
  static const routeName = "/track-cases";

  const TrackCasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(title: "Track Requests"),
      body: TrackingWidget(),
    );
  }
}