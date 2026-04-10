import 'package:permission_handler/permission_handler.dart';

class PermissionsHandler {
  const PermissionsHandler._();

  static const List<Permission> _cameraAndMicPermissions = [
    Permission.camera,
    Permission.microphone,
  ];

  /// Request camera and microphone permissions.
  /// Returns true only when both permissions are granted.
  static Future<bool> requestCameraAndMicPermissions() async {
    final statuses = await _cameraAndMicPermissions.request();
    return _allGranted(statuses);
  }

  /// Check if camera and microphone permissions are already granted.
  static Future<bool> hasCameraAndMicPermissions() async {
    final statuses = await Future.wait(
      _cameraAndMicPermissions.map((permission) => permission.status),
    );

    return statuses.every((status) => status.isGranted);
  }

  /// Request all permissions currently needed by the app at startup level.
  /// Right now this matches camera + microphone.
  static Future<bool> requestAll() async {
    final statuses = await _cameraAndMicPermissions.request();
    return _allGranted(statuses);
  }

  /// Returns true if any required permission is permanently denied.
  static Future<bool> hasPermanentlyDeniedCameraOrMic() async {
    final statuses = await Future.wait(
      _cameraAndMicPermissions.map((permission) => permission.status),
    );

    return statuses.any((status) => status.isPermanentlyDenied);
  }

  /// Opens the operating system app settings screen.
  static Future<bool> openSettings() async {
    return openAppSettings();
  }

  static bool _allGranted(Map<Permission, PermissionStatus> statuses) {
    return statuses.values.every((status) => status.isGranted);
  }
}