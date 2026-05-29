import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/settings_controller.dart';
import '../../controllers/user_controller.dart';
import '../../services/local_auth_service.dart';
import '../constants/ui_dict.dart';

class LockWrapper extends StatefulWidget {
  final Widget child;

  const LockWrapper({super.key, required this.child});

  @override
  State<LockWrapper> createState() => _LockWrapperState();
}

class _LockWrapperState extends State<LockWrapper> with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _isPrompting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _checkLockStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (LocalAuthService.isAuthenticatingOS) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      final settings = context.read<SettingsController>();
      if (settings.isAppLock && !_isLocked) {
        setState(() => _isLocked = true);
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isLocked && !_isPrompting) _promptUnlock();
    }
  }

  void _checkLockStatus() {
    Future.microtask(() {
      if (!mounted) return;
      final settings = context.read<SettingsController>();
      if (settings.isAppLock) {
        setState(() => _isLocked = true);
        _promptUnlock();
      }
    });
  }

  Future<void> _promptUnlock() async {
    if (_isPrompting) return;
    _isPrompting = true;

    final settings = context.read<SettingsController>();
    final userEmail = context.read<UserController>().currentUser?.email;
    bool unlocked = false;

    if (!unlocked) {
      String? savedHash = settings.currentPinHash;

      if (savedHash != null && savedHash.isNotEmpty && mounted) {
        final result =
            await Navigator.pushNamed(
                  context,
                  '/verify-pin',
                  arguments: {
                    "savedPinHash": savedHash,
                    "isCancelable": false,
                    "userEmail": userEmail,
                    "isBiometricEnabled": settings.isBiometricActive,
                    "title": UiDict.pinInput,
                  },
                )
                as bool?;
        unlocked = result ?? false;
      } else {
        unlocked = true;
      }
    }

    if (unlocked && mounted) {
      setState(() => _isLocked = false);
    }

    _isPrompting = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(UiDict.appLock, style: TextStyle(fontSize: 20)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _promptUnlock,
                child: const Text(UiDict.openApp),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
