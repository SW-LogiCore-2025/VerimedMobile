import 'package:flutter/material.dart';

class DateFormatter {
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatDateString(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';

    try {
      final DateTime date = DateTime.parse(dateString);
      return formatDate(date);
    } catch (e) {
      return dateString;
    }
  }
}

class AppConstants {
  static const String appTitle = 'VeriMed';
  static const String appSubtitle = 'Verifica la autenticidad de tus medicamentos';

  // Configuración de red - Cambiar según el entorno
  static const String serverHost = '192.168.18.4'; // Tu IP local
  static const String serverPort = '8080';
  static const String apiPath = '/api/verimed/product';

  // URL completa del backend
  static String get backendUrl => 'http://$serverHost:$serverPort$apiPath';

  // Colors
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color lightBlue = Color(0xFF2196F3);
  static const Color darkBlue = Color(0xFF0D47A1);

  // Scanner
  static const double scanWindowSize = 300;
  static const double scannerOverlayBorderWidth = 10;
  static const double scannerOverlayBorderLength = 30;

  // Timeouts
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(seconds: 2);
}

class AppTextStyles {
  static const TextStyle splashTitle = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 2,
  );

  static const TextStyle splashSubtitle = TextStyle(
    fontSize: 16,
    color: Colors.white70,
    fontWeight: FontWeight.w300,
  );

  static const TextStyle productName = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  );

  static const TextStyle productDescription = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );
}
