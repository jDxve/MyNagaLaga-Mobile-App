import 'package:flutter/material.dart';
import '../components/onboarding_content.dart';
import '../components/onboarding_top_bar.dart';
import '../components/onboarding_bottom.dart';
import '../../../common/resources/images_icons.dart';
import '../../../common/resources/strings.dart';
import '../../home/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final PageController _backgroundController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': AppImages.onboarding1,
      'title': AppString.onboarding1Title,
      'description': AppString.onboarding1Description,
    },
    {
      'image': AppImages.onboarding2,
      'title': AppString.onboarding2Title,
      'description': AppString.onboarding2Description,
    },
    {
      'image': AppImages.onboarding3,
      'title': AppString.onboarding3Title,
      'description': AppString.onboarding3Description,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _backgroundController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _backgroundController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Image.asset(
                page['image']!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          SafeArea(
            child: Column(
              children: [
                buildOnboardingTopBar(
                  currentPage: _currentPage,
                  onBackPressed: () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      _backgroundController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  onSkipPressed: _completeOnboarding,
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return buildOnboardingContent(
                        title: page['title']!,
                        description: page['description']!,
                      );
                    },
                  ),
                ),
                buildOnboardingBottomSection(
                  currentPage: _currentPage,
                  totalPages: _pages.length,
                  onNextPressed: _onNextPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
