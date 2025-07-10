import 'package:flutter/material.dart';
import 'package:verimedapp/models/product.dart';
import 'package:verimedapp/utilities/app_constants.dart';
import 'package:verimedapp/widgets/medicine_image_widget.dart';

class ProductResultDialog extends StatelessWidget {

  const ProductResultDialog({
    required this.product, required this.onScanAnother, required this.onAccept, super.key,
  });
  final Product product;
  final VoidCallback onScanAnother;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: _buildAuthenticityMessage(),
      content: SingleChildScrollView(
        child: _buildContent(),
      ),
      actions: _buildActions(),
    );
  }


  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductHeader(),
        // Fechas importantes
        if (product.manufactureDate != null || product.expirationDate != null) ...[
          const SizedBox(height: 12),
          _buildDateInfo(),
        ],
        // Composición (nuevo container)
        if (product.composition != null) ...[
          const SizedBox(height: 12),
          _buildCompositionInfo(),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildProductHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedicineImageWidget(imageUrl: product.image),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.name != null) ...[
                Text(product.name!, style: AppTextStyles.productName),
                const SizedBox(height: 4),
              ],
              if (product.description != null) ...[
                Text(product.description!, style: AppTextStyles.productDescription),
                const SizedBox(height: 8),
              ],
              // Información importante al lado derecho debajo de la descripción
              _buildCompactProductInfo(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactProductInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.serialNumber != null) ...[
            _buildInfoRow('🔢', 'Serial', product.serialNumber!),
          ],
          if (product.batchCode != null) ...[
            _buildInfoRow('📦', 'Lote', product.batchCode!),
          ],
          if (product.productTypeManufacturer != null) ...[
            _buildInfoRow('🏭', 'Fabricante', product.productTypeManufacturer!),
          ],
          if (product.productTypeName != null) ...[
            _buildInfoRow('💊', 'Tipo', product.productTypeName!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$emoji ',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📅 Fechas Importantes',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (product.manufactureDate != null) ...[
            Text('🏭 Fecha de Fabricación: ${DateFormatter.formatDate(product.manufactureDate)}'),
            const SizedBox(height: 4),
          ],
          if (product.expirationDate != null) ...[
            Text('⏰ Fecha de Expiración: ${DateFormatter.formatDate(product.expirationDate)}'),
            const SizedBox(height: 4),
            ExpirationWarningWidget(product: product),
          ],
        ],
      ),
    );
  }

  Widget _buildCompositionInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🧪 Composición',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.purple,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.composition!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticityMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Este medicamento ha sido verificado como auténtico.',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    return [
      TextButton(
        onPressed: onScanAnother,
        child: const Text('Escanear Otro'),
      ),
      ElevatedButton(
        onPressed: onAccept,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryBlue,
          foregroundColor: Colors.white,
        ),
        child: const Text('Aceptar'),
      ),
    ];
  }
}

class ExpirationWarningWidget extends StatelessWidget {

  const ExpirationWarningWidget({
    required this.product, super.key,
  });
  final Product product;

  @override
  Widget build(BuildContext context) {
    if (product.expirationDate == null) {
      return const SizedBox.shrink();
    }

    if (product.isExpired) {
      return _buildExpiredWarning();
    } else if (product.isExpiringSoon) {
      return _buildExpiringSoonWarning();
    } else {
      return _buildValidWarning();
    }
  }

  Widget _buildExpiredWarning() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: const Text(
        '⚠️ MEDICAMENTO VENCIDO - NO CONSUMIR',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildExpiringSoonWarning() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Text(
        '⚠️ Expira en ${product.daysUntilExpiration} días',
        style: const TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildValidWarning() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Text(
        '✅ Válido por ${product.daysUntilExpiration} días más',
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
