import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {

  const ErrorDialog({
    required this.title, required this.message, required this.onRetry, super.key,
  });
  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 30),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 10),
          const Text(
            'Por favor, verifica tu conexión a internet e intenta nuevamente.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onRetry,
          child: const Text('Reintentar'),
        ),
      ],
    );
  }
}

class ProductNotFoundDialog extends StatelessWidget {

  const ProductNotFoundDialog({
    required this.scannedValue, required this.errorDetail, required this.onScanAnother, super.key,
  });
  final String scannedValue;
  final String errorDetail;
  final VoidCallback onScanAnother;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.red, size: 30),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Medicamento No Encontrado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('QR/Serial Consultado: $scannedValue'),
          const SizedBox(height: 12),
          _buildWarningContainer(),
          const SizedBox(height: 12),
          _buildRecommendations(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onScanAnother,
          child: const Text(
            'Escanear Otro',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        ElevatedButton(
          onPressed: onScanAnother,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Entendido'),
        ),
      ],
    );
  }

  Widget _buildWarningContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚠️ MEDICAMENTO NO ENCONTRADO',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorDetail,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Esto podría indicar que:',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '• El medicamento no está registrado en nuestro sistema\n'
            '• El código QR está dañado o mal formateado\n'
            '• El serial number no es válido',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recomendaciones:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '• Verifique que el código QR esté en buen estado\n'
          '• Consulte con el farmacéutico o proveedor\n'
          '• No consuma el medicamento si tiene dudas sobre su autenticidad',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class InvalidQrDialog extends StatelessWidget {
  final String scannedValue;
  final String errorDetail;
  final VoidCallback onScanAnother;

  const InvalidQrDialog({
    super.key,
    required this.scannedValue,
    required this.errorDetail,
    required this.onScanAnother,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Row(
        children: [
          Icon(Icons.qr_code_scanner, color: Colors.red, size: 30),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'QR No Válido',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Código escaneado: $scannedValue'),
          const SizedBox(height: 12),
          _buildWarningContainer(),
          const SizedBox(height: 12),
          _buildRecommendations(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onScanAnother,
          child: const Text(
            'Escanear Otro',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        ElevatedButton(
          onPressed: onScanAnother,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Entendido'),
        ),
      ],
    );
  }

  Widget _buildWarningContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚠️ CÓDIGO QR NO VÁLIDO',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorDetail,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Esto podría indicar que:',
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '• El código QR no corresponde a un medicamento VeriMed\n'
            '• El formato del código no es compatible\n'
            '• El código contiene información no relacionada con medicamentos',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recomendaciones:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '• Asegúrese de escanear solo códigos QR de medicamentos VeriMed\n'
          '• Verifique que el código QR esté completo y legible\n'
          '• Si el medicamento es válido, consulte al proveedor',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
