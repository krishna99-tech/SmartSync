import 'package:flutter/material.dart';

class DeviceConfig {
  final String type;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const DeviceConfig({
    required this.type,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

const List<DeviceConfig> deviceTypesList = [
  DeviceConfig(
    type: 'light',
    label: 'Light',
    icon: Icons.lightbulb_outline,
    activeIcon: Icons.lightbulb,
  ),
  DeviceConfig(
    type: 'fan',
    label: 'Fan',
    icon: Icons.air_outlined,
    activeIcon: Icons.air,
  ),
  DeviceConfig(
    type: 'ac',
    label: 'AC',
    icon: Icons.ac_unit_outlined,
    activeIcon: Icons.ac_unit,
  ),
  DeviceConfig(
    type: 'plug',
    label: 'Plug',
    icon: Icons.power_outlined,
    activeIcon: Icons.power,
  ),
];
