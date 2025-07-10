import 'package:flutter/material.dart';
import 'package:verimedapp/screens/qr_scanner_screen.dart';
import 'package:verimedapp/utilities/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashTimer();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppConstants.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceOut,
    );
    _animationController.forward();
  }

  void _startSplashTimer() {
    Future.delayed(AppConstants.splashDuration, () {
      if (mounted) {
        _navigateToScanner();
      }
    });
  }

  void _navigateToScanner() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => const QrScannerScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _buildGradientDecoration(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimatedLogo(),
              const SizedBox(height: 30),
              _buildAnimatedTitle(),
              const SizedBox(height: 10),
              _buildAnimatedSubtitle(),
              const SizedBox(height: 50),
              _buildAnimatedLoader(),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppConstants.lightBlue,
          AppConstants.primaryBlue,
          AppConstants.darkBlue,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(60),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.verified_user,
          size: 60,
          color: AppConstants.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return FadeTransition(
      opacity: _animation,
      child: const Text(
        AppConstants.appTitle,
        style: AppTextStyles.splashTitle,
      ),
    );
  }

  Widget _buildAnimatedSubtitle() {
    return FadeTransition(
      opacity: _animation,
      child: const Text(
        AppConstants.appSubtitle,
        style: AppTextStyles.splashSubtitle,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAnimatedLoader() {
    return FadeTransition(
      opacity: _animation,
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}
