import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/device_config.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_header.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Step 0 = Credentials, Step 1 = Device Setup & Confirmation
  int _currentStep = 0;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _showPassword = false;
  bool _isLoading = false;

  // 1 to 8 Devices setup
  int _deviceCount = 2;
  late final List<TextEditingController> _deviceControllers;
  late final List<String> _selectedTypes;

  @override
  void initState() {
    super.initState();
    _deviceControllers = List.generate(
      8,
      (i) => TextEditingController(text: 'Device ${i + 1}'),
    );
    _selectedTypes = List.generate(8, (_) => 'light');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    for (final c in _deviceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _proceedToDeviceSetup() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showAlert('Missing Info', 'Please enter your email and password.');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showAlert('Invalid Email', 'Please enter a valid email address.');
      return;
    }

    if (password.length < 6) {
      _showAlert(
          'Weak Password', 'Password must be at least 6 characters long.');
      return;
    }

    if (password != confirm) {
      _showAlert('Mismatch', 'Passwords do not match.');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _currentStep = 1;
    });
  }

  void _backToCredentials() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentStep = 0;
    });
  }

  void _setDeviceCount(int count) {
    HapticFeedback.selectionClick();
    setState(() {
      _deviceCount = count.clamp(1, 8);
    });
  }

  Future<void> _handleSignup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid != null) {
        final initialData = <String, dynamic>{
          'esp32_status': 0,
          'device_count': _deviceCount,
        };

        for (int i = 1; i <= _deviceCount; i++) {
          final customName = _deviceControllers[i - 1].text.trim();
          initialData['light$i'] = 0;
          initialData['light${i}_name'] =
              customName.isEmpty ? 'Device $i' : customName;
          initialData['light${i}_type'] = _selectedTypes[i - 1];
        }

        await FirebaseDatabase.instance
            .ref('users/$uid/devices')
            .set(initialData);
      }
    } on FirebaseAuthException catch (e) {
      _showAlert('Signup Failed', e.message ?? 'An error occurred.');
    } catch (e) {
      _showAlert('Signup Failed', e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK',
                style: TextStyle(
                    color: AuthColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMain =
        isDark ? AuthColors.textMainDark : AuthColors.textMainLight;
    final textMuted =
        isDark ? AuthColors.textMutedDark : AuthColors.textMutedLight;
    final inputBg = isDark ? AuthColors.inputBgDark : AuthColors.inputBgLight;
    final inputBorder =
        isDark ? AuthColors.inputBorderDark : AuthColors.inputBorderLight;

    return AuthBackground(
      title: _currentStep == 0 ? 'Create account' : 'Configure Devices',
      subtitle: _currentStep == 0
          ? 'Join SmartHome to manage your appliances.'
          : 'Initialize your ESP32 controller device nodes (1 to 8).',
      badgeText: _currentStep == 0 ? 'Step 1 of 2' : 'Step 2 of 2',
      headerWidget: AuthHeader(
        title: _currentStep == 0 ? 'Create account' : 'Configure Devices',
        subtitle: _currentStep == 0
            ? 'Join SmartHome to manage your appliances.'
            : 'Initialize your ESP32 controller device nodes (1 to 8).',
        svgAsset: _currentStep == 0
            ? 'assets/svg/security_shield.svg'
            : 'assets/svg/smart_home.svg',
      ),
      onBack: () {
        if (_currentStep == 1) {
          _backToCredentials();
        } else if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: _currentStep == 0
          ? _buildStepOne(textMain, textMuted)
          : _buildStepTwo(isDark, textMain, textMuted, inputBg, inputBorder),
    );
  }

  Widget _buildStepOne(Color textMain, Color textMuted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          label: 'Email',
          hintText: 'name@example.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline_rounded,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Password',
          hintText: 'Minimum 6 characters',
          controller: _passwordController,
          isPassword: true,
          showPassword: _showPassword,
          prefixIcon: Icons.lock_outline_rounded,
          onTogglePassword: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Confirm Password',
          hintText: 'Re-enter your password',
          controller: _confirmController,
          isPassword: true,
          showPassword: _showPassword,
          prefixIcon: Icons.lock_outline_rounded,
          onTogglePassword: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
        ),
        const SizedBox(height: 22),
        AuthPrimaryButton(
          text: 'Continue to Devices',
          onPressed: _proceedToDeviceSetup,
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: TextStyle(
                fontSize: 13,
                color: textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Log In',
                style: TextStyle(
                  fontSize: 13,
                  color: AuthColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepTwo(
    bool isDark,
    Color textMain,
    Color textMuted,
    Color inputBg,
    Color inputBorder,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: inputBorder),
          ),
          child: Column(
            children: [
              Text(
                'CHOOSE NUMBER OF DEVICES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _deviceCount > 1
                        ? () => _setDeviceCount(_deviceCount - 1)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: AuthColors.primary,
                    iconSize: 28,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: AuthColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: AuthColors.primary, width: 1.2),
                    ),
                    child: Text(
                      '$_deviceCount',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: textMain,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _deviceCount < 8
                        ? () => _setDeviceCount(_deviceCount + 1)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                    color: AuthColors.primary,
                    iconSize: 28,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [1, 2, 4, 6, 8].map((count) {
                  final isSelected = _deviceCount == count;
                  return ChoiceChip(
                    label: Text(
                      '$count ${count == 1 ? "Device" : "Devices"}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : textMain,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AuthColors.primary,
                    backgroundColor: isDark ? Colors.white10 : Colors.white,
                    onSelected: (_) => _setDeviceCount(count),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Customize Labels & Types (1 to $_deviceCount)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textMain,
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(_deviceCount, (index) {
          final deviceIndex = index + 1;
          final currentType = _selectedTypes[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: inputBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AuthColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'DEVICE $deviceIndex',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AuthColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _deviceControllers[index],
                        style: TextStyle(
                          color: textMain,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Device $deviceIndex',
                          hintStyle: TextStyle(color: textMuted),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: deviceTypesList.map((cfg) {
                    final isTypeSelected = currentType == cfg.type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedTypes[index] = cfg.type;
                          });
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isTypeSelected
                                ? AuthColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isTypeSelected
                                  ? AuthColors.primary
                                  : inputBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isTypeSelected ? cfg.activeIcon : cfg.icon,
                                size: 13,
                                color: isTypeSelected
                                    ? Colors.white
                                    : textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                cfg.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isTypeSelected
                                      ? Colors.white
                                      : textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        AuthPrimaryButton(
          text: 'Confirm & Register ($_deviceCount Devices)',
          isLoading: _isLoading,
          onPressed: _handleSignup,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _isLoading ? null : _backToCredentials,
          style: TextButton.styleFrom(
            foregroundColor: textMuted,
          ),
          child: const Text('Back to Credentials'),
        ),
      ],
    );
  }
}
