import 'package:evolv_mobile/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppNotifications {

  static void showSnackBar(BuildContext context, String message,
      {Color? color, IconData? icon}) {
    final backgroundColor = color ?? AppTheme.notificationBgColor[800];
    final iconData = icon ?? Icons.info_outline;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(iconData, color: AppTheme.backgroundColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: AppTheme.backgroundColor, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show a modern dialog for critical actions (like session expired)
  static Future<void> showAlertDialog(
      BuildContext context, String title, String message,
      {String buttonText = "OK", VoidCallback? onConfirm}) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primarySubColor[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppTheme.notificationBgColor)),
        content: Text(message,
            style: TextStyle(color: AppTheme.primaryBlack, fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
            child: Text(
              buttonText,
              style: TextStyle(
                color: AppTheme.secondaryColor[100], // brisk pink accent
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  /// Modern confirmation dialog with Cancel + Confirm button
  static Future<void> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
    String cancelText = "Cancel",
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primarySubColor[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.notificationBgColor,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(color: AppTheme.primaryBlack, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              cancelText,
              style: TextStyle(
                color: AppTheme.secondaryColor[200],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              confirmText,
              style: TextStyle(
                color: AppTheme.secondaryColor[100],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sleek toast for subtle messages
  static Future<void> showToast(String message,
      {Color? bgColor, Color? textColor, ToastGravity gravity = ToastGravity.BOTTOM}) async{
    
    await Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      backgroundColor: bgColor ?? AppTheme.notificationBgColor[800],
      textColor: textColor ?? AppTheme.backgroundColor,
      fontSize: 16.0,
    );

    Future.delayed(const Duration(seconds: 2), () {
      Fluttertoast.cancel();
    });
  }
}
