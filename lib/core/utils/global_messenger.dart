import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';
import '../utils/color_extension.dart';

class GlobalMessenger {
  static final GlobalKey<ScaffoldMessengerState> globalMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showMessage(
    BuildContext context, {
    required String message,
    bool isSuccess = true,
  }) {
    final banner = MaterialBanner(
      content: Text(
        message,
        style: TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: isSuccess
          ? AppColors.getSuccess(context)
          : AppColors.error,
      elevation: 3,
      dividerColor: Colors.transparent,

      actions: [
        IconButton(
          icon: Icon(Icons.close, color: AppColors.textDark),
          onPressed: () {
            globalMessengerKey.currentState?.hideCurrentMaterialBanner();
          },
        ),
      ],
    );

    globalMessengerKey.currentState
      ?..hideCurrentMaterialBanner()
      ..showMaterialBanner(banner);

    Future.delayed(const Duration(seconds: 3), () {
      globalMessengerKey.currentState?.hideCurrentMaterialBanner();
    });
  }

  static void showSleekNotification(
    BuildContext context, {
    required String message,
    FaIconData? icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.only(top: 60, left: 20, right: 20),
      dismissDirection: DismissDirection.up,
      duration: const Duration(seconds: 2),
      content: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: colorScheme.onSurface.withOpacity(0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onPrimary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                FaIcon(
                  icon,
                  color: Colors.greenAccent.adapt(context),
                  size: 14,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.greenAccent.adapt(context),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    globalMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showSleekXpNotification(BuildContext context, int xpReward) {
    showSleekNotification(
      context,
      message: '+$xpReward XP',
      icon: FontAwesomeIcons.arrowUpRightDots,
    );
  }

  static void showLevelUpNotification(
    BuildContext context,
    int newLevel, {
    String? description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.only(top: 60, left: 20, right: 20),
      dismissDirection: DismissDirection.up,
      duration: const Duration(seconds: 4),
      content: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.blueAccent..adapt(context).withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent..adapt(context).withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.crown,
              color: Colors.amber.adapt(context),
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              'LEVEL UP!',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'You reached Level $newLevel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.blueAccent.adapt(context),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),

            if (description != null && description.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: colorScheme.onSurface.withOpacity(0.12)),
              ),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    globalMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
