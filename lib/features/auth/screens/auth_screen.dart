import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/skill_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/global_messenger.dart';
import '../../../widgets/custom_button.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  void _loginHandle(BuildContext context) async {
    final authController = context.read<AuthController>();
    final skillController = context.read<SkillController>();
    await authController.loginAnonymously();
    await skillController.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final authController = context.watch<AuthController>();

    if (authController.errorMessage != null) {
      debugPrint(authController.errorMessage);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GlobalMessenger.showMessage(
          message: authController.errorMessage!,
          isSuccess: false,
        );
        authController.clearError();
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FinTale',
                style: GoogleFonts.montserrat(
                  textStyle: Theme.of(context).textTheme.headlineLarge,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                UiDict.authJourney,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(flex: 2),
              Center(
                child: Image.asset(
                  'assets/images/auth_icon.png',
                  height: screenHeight * 0.35,
                  fit: BoxFit.contain,
                ),
              ),

              const Spacer(flex: 3),
              Text(
                UiDict.authWelcome,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                UiDict.authDesc,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              if (authController.isLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              else
                CustomButton(
                  title: UiDict.authSkip,
                  color: AppColors.primary,
                  icon: FontAwesomeIcons.khanda,
                  onTap: () => _loginHandle(context),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
