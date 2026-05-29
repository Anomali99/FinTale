import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/global_messenger.dart';
import '../../../core/utils/hash_helper.dart';
import '../../../services/local_auth_service.dart';

class VerifyPinScreen extends StatefulWidget {
  final String savedPinHash;
  final bool isCancelable;
  final String? title;
  final String? userEmail;
  final bool isBiometricEnabled;

  const VerifyPinScreen({
    super.key,
    required this.savedPinHash,
    this.title,
    this.userEmail,
    this.isBiometricEnabled = false,
    this.isCancelable = true,
  });

  @override
  State<VerifyPinScreen> createState() => _VerifyPinScreenState();
}

class _VerifyPinScreenState extends State<VerifyPinScreen> {
  String _pinInput = '';

  @override
  void initState() {
    super.initState();

    if (widget.isBiometricEnabled) {
      _triggerBiometric();
    }
  }

  Future<void> _triggerBiometric() async {
    bool success = await LocalAuthService.authenticateBiometricOnly();
    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_pinInput.length < 6) {
        _pinInput += number;
        if (_pinInput.length == 6) {
          _verifyPin();
        }
      }
    });
  }

  void _onBackPressed() {
    setState(() {
      if (_pinInput.isNotEmpty) {
        _pinInput = _pinInput.substring(0, _pinInput.length - 1);
      }
    });
  }

  void _verifyPin() {
    bool isMatch = HashHelper.verifyPin(_pinInput, widget.savedPinHash);

    if (isMatch) {
      Navigator.pop(context, true);
    } else {
      GlobalMessenger.swowMessage(message: UiDict.pinWrong, isSuccess: true);

      setState(() {
        _pinInput = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.isCancelable,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: widget.isCancelable
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => Navigator.pop(context, false),
                )
              : null,
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),

              Text(
                widget.title ?? UiDict.pinInput,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 24,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.userEmail ?? 'Anonymous',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  bool isFilled = index < _pinInput.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? AppColors.primary
                          : AppColors.textSecondary.withOpacity(0.3),
                    ),
                  );
                }),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    _buildNumpadRow(['1', '2', '3']),
                    const SizedBox(height: 24),
                    _buildNumpadRow(['4', '5', '6']),
                    const SizedBox(height: 24),
                    _buildNumpadRow(['7', '8', '9']),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.isBiometricEnabled
                            ? _buildFingerprintButton()
                            : const SizedBox(width: 68, height: 68),

                        _buildNumberButton('0'),
                        _buildBackButton(),
                      ],
                    ),
                  ],
                ),
              ),

              if (!widget.isCancelable)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 24,
                    left: 24,
                    right: 24,
                  ),
                  child: Row(
                    mainAxisAlignment: widget.userEmail != null
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                    children: [
                      if (widget.userEmail != null)
                        TextButton(
                          onPressed: () {
                            /* TODO: Lupa PIN Logic */
                          },
                          child: const Text(
                            UiDict.forgotPin,
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          UiDict.changeAcount,
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: numbers.map((num) => _buildNumberButton(num)).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => _onNumberPressed(number),
      borderRadius: BorderRadius.circular(34),
      child: Container(
        width: 68,
        height: 68,
        color: Colors.transparent,
        child: Center(
          child: Text(
            number,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFingerprintButton() {
    return InkWell(
      onTap: _triggerBiometric,
      borderRadius: BorderRadius.circular(34),
      child: const SizedBox(
        width: 68,
        height: 68,
        child: Center(
          child: Icon(
            Icons.fingerprint,
            size: 36,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: _onBackPressed,
      borderRadius: BorderRadius.circular(34),
      child: SizedBox(
        width: 68,
        height: 68,
        child: Center(
          child: FaIcon(
            FontAwesomeIcons.deleteLeft,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
