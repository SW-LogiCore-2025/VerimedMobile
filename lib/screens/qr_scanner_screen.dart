import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:verimedapp/models/product.dart';
import 'package:verimedapp/services/product_repository.dart';
import 'package:verimedapp/services/qr_analysis_service.dart';
import 'package:verimedapp/utilities/app_constants.dart';
import 'package:verimedapp/widgets/dialogs/error_dialogs.dart';
import 'package:verimedapp/widgets/dialogs/product_result_dialog.dart';
import 'package:verimedapp/widgets/scanned_barcode_label.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // Dependencies (Dependency Injection)
  late final ProductRepository _productRepository;
  late final QrAnalysisService _qrAnalysisService;
  late final MobileScannerController _controller;

  // State variables
  Barcode? _barcode;
  bool _isLoading = false;
  bool _isScannerActive = false;

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
    _initializeScanner();
  }

  void _initializeDependencies() {
    _productRepository = ApiProductRepository();
    _qrAnalysisService = QrAnalysisService();
    _controller = MobileScannerController(
      formats: [BarcodeFormat.all],
      autoStart: false,
    );
  }

  void _initializeScanner() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScanner();
    });
  }

  Future<void> _startScanner() async {
    try {
      setState(() => _isScannerActive = true);
      await _controller.start();
      debugPrint('✅ Scanner iniciado correctamente');
    } catch (e) {
      debugPrint('❌ Error al iniciar scanner: $e');
      setState(() => _isScannerActive = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.black,
      body: _buildScannerBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        AppConstants.appTitle,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppConstants.primaryBlue,
      elevation: 0,
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildScannerBody() {
    return Stack(
      children: [
        _buildMobileScanner(),
        _buildScannerOverlay(),
        _buildBottomPanel(),
      ],
    );
  }

  Widget _buildMobileScanner() {
    return MobileScanner(
      controller: _controller,
      onDetect: _handleBarcodeDetection,
      scanWindow: Rect.fromCenter(
        center: MediaQuery.of(context).size.center(Offset.zero),
        width: AppConstants.scanWindowSize,
        height: AppConstants.scanWindowSize,
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Container(
      decoration: const ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: AppConstants.primaryBlue,
          borderRadius: 10,
          borderLength: AppConstants.scannerOverlayBorderLength,
          borderWidth: AppConstants.scannerOverlayBorderWidth,
          cutOutSize: AppConstants.scanWindowSize,
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        alignment: Alignment.bottomCenter,
        height: 150,
        decoration: _buildBottomPanelDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _buildBarcodePreview(),
        ),
      ),
    );
  }

  BoxDecoration _buildBottomPanelDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.black.withOpacity(0.8),
          Colors.black.withOpacity(0.4),
          Colors.transparent,
        ],
      ),
    );
  }

  Widget _buildBarcodePreview() {
    if (_barcode != null) {
      return const ScannerSuccessLabel();
    }

    return ScannedBarcodeLabel(
      isLoading: _isLoading,
      isScannerActive: _isScannerActive,
    );
  }

  void _handleBarcodeDetection(BarcodeCapture barcodes) {
    if (!mounted || barcodes.barcodes.isEmpty || _isLoading) {
      return;
    }

    final Barcode barcode = barcodes.barcodes.first;
    _processBarcode(barcode);
  }

  void _processBarcode(Barcode barcode) {
    setState(() {
      _barcode = barcode;
      _isLoading = true;
      _isScannerActive = false;
    });

    _controller.stop();
    _verifyMedicine(barcode.displayValue ?? '');
  }

  Future<void> _verifyMedicine(String scannedValue) async {
    try {
      // Single Responsibility: Separate QR analysis from product verification
      final analysisResult = _qrAnalysisService.analyzeQrValue(scannedValue);

      if (!analysisResult.isValid) {
        _showInvalidQrDialog(scannedValue, analysisResult.errorMessage!);
        return;
      }

      // Single Responsibility: Product repository handles API calls
      final product = await _productRepository.getProductBySerial(
        analysisResult.serialNumber!,
      );

      _showProductResult(product);
    } on ProductNotFoundException catch (e) {
      _showProductNotFoundDialog(scannedValue, e.message);
    } on ApiException catch (e) {
      _showErrorDialog('Error del Servidor', e.message);
    } on NetworkException catch (e) {
      _showErrorDialog('Error de Conexión', e.message);
    } catch (e) {
      _showInvalidQrDialog(scannedValue, 'Error inesperado al procesar el código QR: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showProductResult(Product product) {
    showDialog<void>(
      context: context,
      builder: (context) => ProductResultDialog(
        product: product,
        onScanAnother: _resetScanner,
        onAccept: _resetScanner,
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        onRetry: _resetScanner,
      ),
    );
  }

  void _showProductNotFoundDialog(String scannedValue, String errorDetail) {
    showDialog<void>(
      context: context,
      builder: (context) => ProductNotFoundDialog(
        scannedValue: scannedValue,
        errorDetail: errorDetail,
        onScanAnother: _resetScanner,
      ),
    );
  }

  void _showInvalidQrDialog(String scannedValue, String errorMessage) {
    showDialog<void>(
      context: context,
      builder: (context) => InvalidQrDialog(
        scannedValue: scannedValue,
        errorDetail: errorMessage,
        onScanAnother: _resetScanner,
      ),
    );
  }

  void _resetScanner() {
    Navigator.of(context).pop();
    setState(() {
      _barcode = null;
      _isLoading = false;
    });
    _startScanner();
  }
}

// Clase personalizada para crear el overlay del escáner QR
class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final double width = rect.width;
    final double height = rect.height;
    final double cutOutWidth = cutOutSize < width ? cutOutSize : width - borderWidth;
    final double cutOutHeight = cutOutSize < height ? cutOutSize : height - borderWidth;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final cutOutRect = Rect.fromLTWH(
      rect.left + (width - cutOutWidth) / 2 + borderWidth,
      rect.top + (height - cutOutHeight) / 2 + borderWidth,
      cutOutWidth - borderWidth * 2,
      cutOutHeight - borderWidth * 2,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndCorners(
          cutOutRect,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
        backgroundPaint..blendMode = BlendMode.clear,
      )
      ..restore();

    // Draw the corners
    final path = Path()
      // Top left corner
      ..moveTo(cutOutRect.left - borderLength, cutOutRect.top)
      ..quadraticBezierTo(
        cutOutRect.left - borderLength,
        cutOutRect.top - borderLength,
        cutOutRect.left,
        cutOutRect.top - borderLength,
      )
      ..lineTo(cutOutRect.left + borderLength, cutOutRect.top - borderLength)
      // Top right corner
      ..moveTo(cutOutRect.right - borderLength, cutOutRect.top - borderLength)
      ..lineTo(cutOutRect.right, cutOutRect.top - borderLength)
      ..quadraticBezierTo(
        cutOutRect.right + borderLength,
        cutOutRect.top - borderLength,
        cutOutRect.right + borderLength,
        cutOutRect.top,
      )
      ..lineTo(cutOutRect.right + borderLength, cutOutRect.top + borderLength)
      // Bottom right corner
      ..moveTo(cutOutRect.right + borderLength, cutOutRect.bottom - borderLength)
      ..lineTo(cutOutRect.right + borderLength, cutOutRect.bottom)
      ..quadraticBezierTo(
        cutOutRect.right + borderLength,
        cutOutRect.bottom + borderLength,
        cutOutRect.right,
        cutOutRect.bottom + borderLength,
      )
      ..lineTo(cutOutRect.right - borderLength, cutOutRect.bottom + borderLength)
      // Bottom left corner
      ..moveTo(cutOutRect.left + borderLength, cutOutRect.bottom + borderLength)
      ..lineTo(cutOutRect.left, cutOutRect.bottom + borderLength)
      ..quadraticBezierTo(
        cutOutRect.left - borderLength,
        cutOutRect.bottom + borderLength,
        cutOutRect.left - borderLength,
        cutOutRect.bottom,
      )
      ..lineTo(cutOutRect.left - borderLength, cutOutRect.bottom - borderLength);

    canvas.drawPath(path, boxPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
