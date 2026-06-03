import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GlobalMessenger {
  static final GlobalKey<ScaffoldMessengerState> globalMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showMessage({required String message, bool isSuccess = true}) {
    final banner = MaterialBanner(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: isSuccess
          ? const Color(0xFF4CAF50)
          : const Color(0xFFEF5350),
      elevation: 3,
      dividerColor: Colors.transparent,

      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
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

  static void showSleekNotification({
    required String message,
    FaIconData? icon,
  }) {
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
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white12, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                FaIcon(icon, color: Colors.greenAccent, size: 14),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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

  static void showSleekXpNotification(int xpReward) {
    showSleekNotification(
      message: '+$xpReward XP',
      icon: FontAwesomeIcons.arrowUpRightDots,
    );
  }

  static void showLevelUpNotification(int newLevel, {String? description}) {
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
          color: const Color(0xFF232336),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.blueAccent.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(FontAwesomeIcons.crown, color: Colors.amber, size: 28),
            const SizedBox(height: 12),
            /* TODO */
            Text(
              'LEVEL UP!',
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 4),
            /* TODO */
            Text(
              'You reached Level $newLevel',
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.blueAccent,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),

            if (description != null && description.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: Colors.white12),
              ),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white70,
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
