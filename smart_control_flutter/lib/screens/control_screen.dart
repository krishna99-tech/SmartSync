import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/device_config.dart';
import '../theme/app_theme.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen>
    with SingleTickerProviderStateMixin {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late final DatabaseReference _devicesRef;
  StreamSubscription<DatabaseEvent>? _devicesSubscription;

  int _deviceCount = 2;
  List<bool> _lights = List.filled(2, false);
  List<String> _lightNames = List.filled(2, '');
  List<String> _deviceTypes = List.filled(2, 'light');
  late List<TextEditingController> _nameControllers;

  bool _renameEnabled = false;
  bool? _espConnected;
  String _statusMessage = 'Syncing...';
  Color _statusColor = const Color(0xFF8F9BB3);
  bool _isLoading = true;
  bool _isRefreshing = false;

  late AnimationController _spinController;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _nameControllers = List.generate(
      _deviceCount,
      (i) => TextEditingController(text: 'Device ${i + 1}'),
    );

    final uid = currentUser?.uid;
    if (uid != null) {
      _devicesRef = FirebaseDatabase.instance.ref('users/$uid/devices');
      _listenToDevices();
    } else {
      _isLoading = false;
    }
  }

  void _listenToDevices() {
    _devicesSubscription = _devicesRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        _updateLocalStates(Map<String, dynamic>.from(data));
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }, onError: (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _updateLocalStates(Map<String, dynamic> data) {
    int detectedCount = 0;
    if (data['device_count'] is int) {
      detectedCount = data['device_count'] as int;
    } else if (data['device_count'] != null) {
      detectedCount = int.tryParse(data['device_count'].toString()) ?? 0;
    }

    if (detectedCount <= 0) {
      // Auto-detect based on light1 through light8 keys in DB
      for (int i = 1; i <= 8; i++) {
        if (data.containsKey('light$i') ||
            data.containsKey('light${i}_name') ||
            data.containsKey('light${i}_type')) {
          detectedCount = i;
        }
      }
    }

    if (detectedCount < 1) detectedCount = 2;
    if (detectedCount > 8) detectedCount = 8;

    // Adjust controllers count to match detectedCount
    while (_nameControllers.length < detectedCount) {
      _nameControllers.add(
        TextEditingController(text: 'Device ${_nameControllers.length + 1}'),
      );
    }
    while (_nameControllers.length > detectedCount) {
      _nameControllers.removeLast().dispose();
    }

    final newStates = <bool>[];
    final newNames = <String>[];
    final newTypes = <String>[];

    for (int i = 1; i <= detectedCount; i++) {
      newStates.add(data['light$i'] == 1);
      final name = data['light${i}_name']?.toString() ?? 'Device $i';
      newNames.add(name);
      if (!_renameEnabled && _nameControllers[i - 1].text != name) {
        _nameControllers[i - 1].text = name;
      }
      newTypes.add(data['light${i}_type']?.toString() ?? 'light');
    }

    final isOnline = data['esp32_status'] == 1;
    setState(() {
      _deviceCount = detectedCount;
      _lights = newStates;
      _lightNames = newNames;
      _deviceTypes = newTypes;
      _espConnected = isOnline;
      _statusMessage = isOnline ? 'SYSTEM ONLINE' : 'SYSTEM OFFLINE';
      _statusColor = isOnline ? AppColors.online : AppColors.offline;
    });
  }

  Future<void> _checkSystemStatus() async {
    setState(() {
      _isRefreshing = true;
    });
    HapticFeedback.heavyImpact();
    _spinController.forward(from: 0);

    try {
      await _devicesRef.update({'esp32_status': 0});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not reach database.')),
        );
      }
    } finally {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _isRefreshing = false;
          });
        }
      });
    }
  }

  Future<void> _toggleDevice(int index) async {
    if (_espConnected != true) {
      HapticFeedback.heavyImpact();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('System Offline'),
          content: const Text(
            'The ESP32 controller is currently unreachable. Please make sure your hardware is powered on and connected to Wi-Fi.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    final nextState = !_lights[index] ? 1 : 0;
    try {
      await _devicesRef.child('light${index + 1}').set(nextState);
    } catch (_) {
      // Handled
    }
  }

  Future<void> _saveConfig() async {
    HapticFeedback.lightImpact();
    final updates = <String, dynamic>{
      'device_count': _deviceCount,
    };
    for (int i = 0; i < _deviceCount; i++) {
      final name = _nameControllers[i].text.trim().isEmpty
          ? 'Device ${i + 1}'
          : _nameControllers[i].text.trim();
      updates['light${i + 1}_name'] = name;
      updates['light${i + 1}_type'] = _deviceTypes[i];
    }

    try {
      await _devicesRef.update(updates);
      setState(() {
        _renameEnabled = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration saved successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Save failed.')),
        );
      }
    }
  }

  IconData _getIcon(int index, bool isActive) {
    final type = _deviceTypes[index];
    final config = deviceTypesList.firstWhere(
      (d) => d.type == type,
      orElse: () => deviceTypesList[0],
    );
    return isActive ? config.activeIcon : config.icon;
  }

  @override
  void dispose() {
    _devicesSubscription?.cancel();
    _spinController.dispose();
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final width = size.width;

    // Responsive columns
    final isTablet = width > 768;
    final isDesktop = width > 1100;
    final numColumns = isDesktop ? 4 : (isTablet ? 3 : 2);
    final cardGap = width * 0.035;

    final glassColor = AppColors.glass(isDark);
    final borderColor = AppColors.border(isDark);
    final textMain = AppColors.textMain(isDark);
    final textSub = AppColors.textSub(isDark);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark
            ? AppColors.controlDarkBg.first
            : AppColors.controlLightBg.first,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        ),
      );
    }

    final email = currentUser?.email ?? 'User';
    final rawName = email.contains('@') ? email.split('@').first : email;
    final userName = rawName
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');

    final activeCount = _lights.where((val) => val).length;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? AppColors.controlDarkBg
                      : AppColors.controlLightBg,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: cardGap.clamp(16.0, 32.0),
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Card (Welcome & Status)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: glassColor,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: borderColor, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Brand & Sync Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.bolt,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'SMARTCONTROL HUB',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: _isRefreshing
                                      ? null
                                      : _checkSystemStatus,
                                  tooltip: 'Ping Controller',
                                  icon: RotationTransition(
                                    turns: _spinController,
                                    child: Icon(
                                      Icons.sync,
                                      size: 24,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Welcome Message
                            Text(
                              '$_greeting,',
                              style: TextStyle(
                                color: textSub,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textMain,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Status & Active Appliances Metrics Row
                            Row(
                              children: [
                                // Online/Offline Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _statusColor,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _statusColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: _statusColor
                                                  .withValues(alpha: 0.7),
                                              blurRadius: 8,
                                              spreadRadius: 1.5,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _statusMessage,
                                        style: TextStyle(
                                          color: _statusColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Active Appliances Metric
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : Colors.black.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.power,
                                        size: 15,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$activeCount of $_deviceCount Active',
                                        style: TextStyle(
                                          color: textMain,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Action Bar (Devices Header + Setup Mode Toggle)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Devices',
                                style: TextStyle(
                                  color: textMain,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$_deviceCount Devices',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_renameEnabled) {
                                _saveConfig();
                              } else {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _renameEnabled = true;
                                });
                              }
                            },
                            icon: Icon(
                              _renameEnabled
                                  ? Icons.check_circle
                                  : Icons.tune_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: Text(
                              _renameEnabled ? 'Save Changes' : 'Setup Devices',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _renameEnabled
                                  ? AppColors.online
                                  : AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Setup Mode: Devices Count Controls
                      if (_renameEnabled) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.settings_input_component,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Devices: $_deviceCount of 8 Max',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          color: textMain,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Click card icons to change type, or edit label',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: textSub,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline),
                                    color: AppColors.offline,
                                    tooltip: 'Remove device',
                                    onPressed: _deviceCount > 1
                                        ? () {
                                            HapticFeedback.lightImpact();
                                            setState(() {
                                              _deviceCount--;
                                              if (_lights.length > _deviceCount) {
                                                _lights.removeLast();
                                              }
                                              if (_lightNames.length >
                                                  _deviceCount) {
                                                _lightNames.removeLast();
                                              }
                                              if (_deviceTypes.length >
                                                  _deviceCount) {
                                                _deviceTypes.removeLast();
                                              }
                                              if (_nameControllers.length >
                                                  _deviceCount) {
                                                _nameControllers
                                                    .removeLast()
                                                    .dispose();
                                              }
                                            });
                                          }
                                        : null,
                                  ),
                                  IconButton(
                                    icon:
                                        const Icon(Icons.add_circle_outline),
                                    color: AppColors.online,
                                    tooltip: 'Add device',
                                    onPressed: _deviceCount < 8
                                        ? () {
                                            HapticFeedback.lightImpact();
                                            setState(() {
                                              _deviceCount++;
                                              _lights.add(false);
                                              _lightNames
                                                  .add('Device $_deviceCount');
                                              _deviceTypes.add('light');
                                              _nameControllers.add(
                                                TextEditingController(
                                                    text:
                                                        'Device $_deviceCount'),
                                              );
                                            });
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Devices Grid (1 to 8 dynamic cards)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final itemWidth = (constraints.maxWidth -
                                  (cardGap * (numColumns - 1))) /
                              numColumns;

                          return Wrap(
                            spacing: cardGap,
                            runSpacing: cardGap,
                            children: List.generate(_deviceCount, (index) {
                              return SizedBox(
                                width: itemWidth,
                                child: _buildDeviceCard(
                                  index: index,
                                  isDark: isDark,
                                  textMain: textMain,
                                  textSub: textSub,
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard({
    required int index,
    required bool isDark,
    required Color textMain,
    required Color textSub,
  }) {
    if (index >= _lights.length ||
        index >= _lightNames.length ||
        index >= _deviceTypes.length ||
        index >= _nameControllers.length) {
      return const SizedBox.shrink();
    }

    final isOn = _lights[index];
    final isEspOnline = _espConnected == true;

    return InkWell(
      onTap: () => _toggleDevice(index),
      borderRadius: BorderRadius.circular(26),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            colors: isOn
                ? AppColors.activeCardGradient
                : AppColors.cardInactive(isDark),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isOn
                ? Colors.white.withValues(alpha: 0.3)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.06)),
            width: 1.2,
          ),
          boxShadow: isOn
              ? [
                  BoxShadow(
                    color: const Color(0xFF1D4ED8)
                        .withValues(alpha: isDark ? 0.35 : 0.20),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Opacity(
          opacity: isEspOnline ? 1.0 : 0.55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Top Row: Device Icon & Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _renameEnabled
                        ? () {
                            HapticFeedback.lightImpact();
                            final curIdx = deviceTypesList.indexWhere(
                              (d) => d.type == _deviceTypes[index],
                            );
                            final nextType = deviceTypesList[
                                    (curIdx + 1) % deviceTypesList.length]
                                .type;
                            setState(() {
                              _deviceTypes[index] = nextType;
                            });
                          }
                        : null,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isOn
                            ? Colors.white.withValues(alpha: 0.2)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04)),
                        borderRadius: BorderRadius.circular(16),
                        border: _renameEnabled
                            ? Border.all(
                                color: AppColors.accent,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          _getIcon(index, isOn),
                          size: 26,
                          color: isOn
                              ? Colors.white
                              : AppColors.iconInactive(isDark),
                        ),
                      ),
                    ),
                  ),
                  Switch(
                    value: isOn,
                    onChanged: (val) {
                      if (!_renameEnabled) {
                        _toggleDevice(index);
                      }
                    },
                    thumbColor:
                        const WidgetStatePropertyAll<Color>(Colors.white),
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF93C5FD),
                    inactiveTrackColor: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Card Bottom: Name & Status
              if (_renameEnabled)
                TextField(
                  controller: _nameControllers[index],
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Device Name',
                    isDense: true,
                    contentPadding: EdgeInsets.only(bottom: 6),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.accent, width: 2),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.accent, width: 1.2),
                    ),
                  ),
                )
              else ...[
                Text(
                  _lightNames[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isOn || isDark ? Colors.white : textMain,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isOn ? Colors.white : textSub,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOn ? 'ACTIVE' : 'STANDBY',
                      style: TextStyle(
                        color: isOn || isDark
                            ? Colors.white.withValues(alpha: 0.8)
                            : textSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
