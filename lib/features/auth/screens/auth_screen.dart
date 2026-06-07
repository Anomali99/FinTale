import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/skill_controller.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/theme/app_colors.dart';
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
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 34.0,
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

              const Spacer(flex: 1),
              Center(
                child: SizedBox(
                  width: screenHeight * 0.4,
                  height: screenHeight * 0.4,
                  child: SvgPicture.asset(
                    'assets/images/in_app_icon.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const Spacer(flex: 1),
              Text(
                UiDict.authWelcome,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(flex: 1),
              Text(
                UiDict.authDesc,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 2),

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
