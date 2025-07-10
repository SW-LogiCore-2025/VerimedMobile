import 'package:flutter/material.dart';

class ScannedBarcodeLabel extends StatelessWidget {

  const ScannedBarcodeLabel({
    required this.isLoading, required this.isScannerActive, super.key,
  });
  final bool isLoading;
  final bool isScannerActive;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    return _buildScannerState();
  }

  Widget _buildLoadingState() {
    return const Column(
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
        SizedBox(height: 16),
        Text(
          'Verificando medicamento...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScannerState() {
    return Column(
      children: [
        const Text(
          'Escanea el código QR del medicamento',
          overflow: TextOverflow.fade,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        _buildScannerStatusIndicator(),
      ],
    );
  }

  Widget _buildScannerStatusIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isScannerActive ? Icons.camera_alt : Icons.camera_alt_outlined,
          color: isScannerActive ? Colors.green : Colors.orange,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          isScannerActive ? 'Scanner activo' : 'Iniciando scanner...',
          style: TextStyle(
            color: isScannerActive ? Colors.green : Colors.orange,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class ScannerSuccessLabel extends StatelessWidget {
  const ScannerSuccessLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 30,
        ),
        SizedBox(height: 8),
        Text(
          'Código detectado correctamente',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Text(
          'Procesando...',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
