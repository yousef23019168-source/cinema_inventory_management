import 'package:flutter/material.dart';

const List<String> kEquipmentCategories = [
  'Camera',
  'Lens',
  'Lighting',
  'Grip',
  'Audio',
  'Monitor',
  'Accessories',
  'Other',
];

IconData categoryIcon(String category) {
  switch (category) {
    case 'Camera':
      return Icons.videocam_outlined;
    case 'Lens':
      return Icons.camera_outlined;
    case 'Lighting':
      return Icons.lightbulb_outline;
    case 'Grip':
      return Icons.construction_outlined;
    case 'Audio':
      return Icons.mic_none_outlined;
    case 'Monitor':
      return Icons.monitor_outlined;
    case 'Accessories':
      return Icons.extension_outlined;
    default:
      return Icons.category_outlined;
  }
}
