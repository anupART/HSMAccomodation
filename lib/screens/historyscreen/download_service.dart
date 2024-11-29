import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  static Future<void> initializeDownloader() async {
    try {
      await FlutterDownloader.initialize(debug: true);
    } catch (e) {
      debugPrint('Failed to initialize downloader: $e');
    }
  }

  Future<void> downloadExcel(BuildContext context, String name) async {
    try {
      // Check only notification permission
      bool hasPermission = await _checkNotificationPermission(context);
      if (!hasPermission) {
        return;
      }

      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        _showError(context, "Cannot access storage");
        return;
      }

      final response = await http.post(
        Uri.parse('https://beds-accomodation.vercel.app/api/EXCELdownloadBookingHistory'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name}),
      );

      if (!context.mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final downloadUrl = data['url'];
        if (downloadUrl == null || downloadUrl.isEmpty) {
          _showError(context, "Invalid download URL received");
          return;
        }
        debugPrint('Download URL: $downloadUrl');
        debugPrint('Save Directory: ${directory.path}');
        final taskId = await FlutterDownloader.enqueue(
          url: downloadUrl,
          savedDir: directory.path,
          fileName: 'BookingHistory_$name.xlsx',
          showNotification: true,
          openFileFromNotification: true,
          saveInPublicStorage: true,
        );

        if (taskId == null) {
          _showError(context, "Failed to start download");
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Download started: 'BookingHistory_$name.xlsx'"),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _showError(context, "Server error: ${response.statusCode}");
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, "Error: ${e.toString()}");
      }
    }
  }

  Future<bool> _checkNotificationPermission(BuildContext context) async {
    final status = await Permission.notification.status;

    if (status.isDenied) {
      // Request notification permission
      final result = await Permission.notification.request();

      if (result.isDenied || result.isPermanentlyDenied) {
        if (context.mounted) {
          _showPermissionDialog(context);
        }
        return false;
      }
    }

    return true;
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Notification Permission Required"),
        content: const Text(
          "Notification permission is required to show download progress. Please enable notifications in settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}