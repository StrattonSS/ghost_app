// lib/permissions/permissions_handler.dart

import 'package:permission_handler/permission_handler.dart';

class PermissionsHandler {
  /// Request camera and microphone permissions from the user.
  static Future<bool> requestCameraAndMicPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    return cameraStatus.isGranted && micStatus.isGranted;
  }

  /// Check if both camera and microphone permissions are already granted.
  static Future<bool> hasCameraAndMicPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;
    return cameraStatus.isGranted && micStatus.isGranted;
  }

  /// Combined method used by splash screen
  static Future<bool> requestAll() async {
    final permissions = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    return permissions.values.every((status) => status.isGranted);
  }
}
