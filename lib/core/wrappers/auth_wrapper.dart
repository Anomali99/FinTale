import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../constants/app_colors.dart';
import '../constants/ui_dict.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;
  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    if (authController.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                UiDict.authSetup,
                style: TextStyle(color: AppColors.primary.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<UserController>(
      builder: (context, userController, child) {
        if (userController.currentUser != null) {
          return this.child;
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}
