// lib/services/notification/permission_service.dart

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestNotificationPermissions() async {
    // Bildirim izni kontrolü
    PermissionStatus notificationStatus = await Permission.notification.status;
    
    if (!notificationStatus.isGranted) {
      notificationStatus = await Permission.notification.request();
    }

    // Alarm izni (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    return notificationStatus.isGranted;
  }

  static Future<bool> requestMicrophonePermission() async {
    PermissionStatus micStatus = await Permission.microphone.status;
    
    if (!micStatus.isGranted) {
      micStatus = await Permission.microphone.request();
    }

    return micStatus.isGranted;
  }

  static Future<bool> checkAllPermissions() async {
    final notificationGranted = await requestNotificationPermissions();
    final microphoneGranted = await requestMicrophonePermission();
    
    return notificationGranted && microphoneGranted;
  }

  static Future<void> showPermissionDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('İzinler Gerekli'),
          content: const Text(
            'Uygulamanın düzgün çalışması için bildirim ve mikrofon izinleri gereklidir.',
          ),
          actions: [
            TextButton(
              child: const Text('Ayarlara Git'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}