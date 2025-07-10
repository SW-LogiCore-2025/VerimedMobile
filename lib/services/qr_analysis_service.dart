class QrAnalysisService {

  QrAnalysisResult analyzeQrValue(String scannedValue) {
    if (scannedValue.isEmpty) {
      return QrAnalysisResult.invalid('Código QR vacío');
    }

    if (_isUrl(scannedValue)) {
      return _analyzeUrl(scannedValue);
    } else {
      return _analyzeDirectSerial(scannedValue);
    }
  }

  bool _isUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  QrAnalysisResult _analyzeUrl(String url) {
    try {
      final Uri uri = Uri.parse(url);
      final List<String> pathSegments = uri.pathSegments;

      if (_isValidVeriMedUrl(pathSegments)) {
        final String serialNumber = _extractSerialFromPath(pathSegments);
        return QrAnalysisResult.success(serialNumber);
      } else {
        return QrAnalysisResult.invalid(
          'QR no válido.',
        );
      }
    } catch (e) {
      return QrAnalysisResult.invalid('Error al procesar URL: $e');
    }
  }

  QrAnalysisResult _analyzeDirectSerial(String value) {
    // Validar que el serial number tenga un formato válido
    if (value.length < 3) {
      return QrAnalysisResult.invalid('Serial number muy corto');
    }

    return QrAnalysisResult.success(value);
  }

  bool _isValidVeriMedUrl(List<String> pathSegments) {
    return pathSegments.length >= 5 &&
           pathSegments.contains('api') &&
           pathSegments.contains('verimed') &&
           pathSegments.contains('product') &&
           pathSegments.contains('by-serial');
  }

  String _extractSerialFromPath(List<String> pathSegments) {
    final int bySerialIndex = pathSegments.indexOf('by-serial');
    if (bySerialIndex < pathSegments.length - 1) {
      return pathSegments[bySerialIndex + 1];
    }
    throw Exception('Serial number no encontrado en la URL');
  }
}

class QrAnalysisResult {

  factory QrAnalysisResult.invalid(String errorMessage) {
    return QrAnalysisResult._(
      isValid: false,
      errorMessage: errorMessage,
    );
  }

  const QrAnalysisResult._({
    required this.isValid,
    this.serialNumber,
    this.errorMessage,
  });

  factory QrAnalysisResult.success(String serialNumber) {
    return QrAnalysisResult._(
      isValid: true,
      serialNumber: serialNumber,
    );
  }
  final bool isValid;
  final String? serialNumber;
  final String? errorMessage;
}
