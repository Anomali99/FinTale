import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/hash_helper.dart';

enum PinStep { enterOld, enterNew, confirmNew }

class CreatePinScreen extends StatefulWidget {
  final String? currentPinHash;
  final String? userEmail;

  const CreatePinScreen({super.key, this.currentPinHash, this.userEmail});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  String _oldPinInput = '';
  String _firstPin = '';
  String _confirmPin = '';

  late PinStep _currentStep;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.currentPinHash != null
        ? PinStep.enterOld
        : PinStep.enterNew;
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_currentStep == PinStep.enterOld) {
        if (_oldPinInput.length < 6) {
          _oldPinInput += number;
          if (_oldPinInput.length == 6) _verifyOldPin();
        }
      } else if (_currentStep == PinStep.enterNew) {
        if (_firstPin.length < 6) {
          _firstPin += number;
          if (_firstPin.length == 6) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) setState(() => _currentStep = PinStep.confirmNew);
            });
          }
        }
      } else if (_currentStep == PinStep.confirmNew) {
        if (_confirmPin.length < 6) {
          _confirmPin += number;
          if (_confirmPin.length == 6) _verifyAndSaveNewPin();
        }
      }
    });
  }

  void _onBackPressed() {
    setState(() {
      if (_currentStep == PinStep.enterOld) {
        if (_oldPinInput.isNotEmpty)
          _oldPinInput = _oldPinInput.substring(0, _oldPinInput.length - 1);
      } else if (_currentStep == PinStep.enterNew) {
        if (_firstPin.isNotEmpty)
          _firstPin = _firstPin.substring(0, _firstPin.length - 1);
      } else if (_currentStep == PinStep.confirmNew) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          _currentStep = PinStep.enterNew;
          _firstPin = _firstPin.substring(0, _firstPin.length - 1);
        }
      }
    });
  }

  void _verifyOldPin() {
    if (widget.currentPinHash != null &&
        HashHelper.verifyPin(_oldPinInput, widget.currentPinHash!)) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _currentStep = PinStep.enterNew);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN Lama salah.'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _oldPinInput = '');
    }
  }

  void _verifyAndSaveNewPin() async {
    if (_firstPin == _confirmPin) {
      final settingsController = context.read<SettingsController>();

      String hashedNewPin = HashHelper.hashPin(_confirmPin);
      settingsController.changePinHash(value: hashedNewPin);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN Keamanan berhasil diperbarui!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN konfirmasi tidak cocok.'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() {
        _confirmPin = '';
        _firstPin = '';
        _currentStep = PinStep.enterNew;
      });
    }
  }

  String get _currentTitle {
    switch (_currentStep) {
      case PinStep.enterOld:
        return 'Masukkan PIN Lama';
      case PinStep.enterNew:
        return 'Buat PIN Baru';
      case PinStep.confirmNew:
        return 'Konfirmasi PIN Baru';
    }
  }

  String get _currentSubtitle {
    switch (_currentStep) {
      case PinStep.enterOld:
        return 'Verifikasi identitas Anda untuk melanjutkan';
      case PinStep.enterNew:
        return 'PIN ini akan digunakan untuk mengunci aplikasi';
      case PinStep.confirmNew:
        return 'Masukkan kembali 6 digit PIN untuk verifikasi';
    }
  }

  String get _currentInputText {
    switch (_currentStep) {
      case PinStep.enterOld:
        return _oldPinInput;
      case PinStep.enterNew:
        return _firstPin;
      case PinStep.confirmNew:
        return _confirmPin;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              _currentTitle,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 48),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                bool isFilled = index < _currentInputText.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? AppColors.primary : Colors.white10,
                    border: Border.all(
                      color: isFilled
                          ? AppColors.primary
                          : AppColors.textSecondary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                );
              }),
            ),

            const Spacer(),

            if (_currentStep == PinStep.enterOld &&
                widget.userEmail != null &&
                widget.userEmail!.isNotEmpty)
              TextButton(
                onPressed: () {
                  /* TODO: Implement Send OTP*/
                },
                child: const Text(
                  'Lupa PIN?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            if (!(_currentStep == PinStep.enterOld &&
                widget.userEmail != null &&
                widget.userEmail!.isNotEmpty))
              const SizedBox(height: 48),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Column(
                children: [
                  _buildNumpadRow(['1', '2', '3']),
                  const SizedBox(height: 20),
                  _buildNumpadRow(['4', '5', '6']),
                  const SizedBox(height: 20),
                  _buildNumpadRow(['7', '8', '9']),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 68, height: 68),
                      _buildNumberButton('0'),
                      _buildBackButton(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceVariant.withOpacity(0.5),
        ),
        child: Center(
          child: Text(
            number,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
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
            color: AppColors.textPrimary.withOpacity(0.8),
            size: 22,
          ),
        ),
      ),
    );
  }
}
