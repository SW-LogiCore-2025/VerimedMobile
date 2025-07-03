import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(
    const MaterialApp(title: 'VeriMed', home: SplashScreen()),
  );
}

/// Splash Screen que se muestra al inicio de la aplicación
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceOut,
    );

    _animationController.forward();

    // Navegar al escáner después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => const MobileScannerSimple(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2196F3), // Azul
              Color(0xFF1976D2), // Azul más oscuro
              Color(0xFF0D47A1), // Azul muy oscuro
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _animation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    size: 60,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              FadeTransition(
                opacity: _animation,
                child: const Text(
                  'VeriMed',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeTransition(
                opacity: _animation,
                child: const Text(
                  'Verifica la autenticidad de tus medicamentos',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 50),
              FadeTransition(
                opacity: _animation,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Implementation of Mobile Scanner example with simple configuration
class MobileScannerSimple extends StatefulWidget {
  /// Constructor for simple Mobile Scanner example
  const MobileScannerSimple({super.key});

  @override
  State<MobileScannerSimple> createState() => _MobileScannerSimpleState();
}

class _MobileScannerSimpleState extends State<MobileScannerSimple> {
  Barcode? _barcode;
  bool _isLoading = false;
  String? _codigoManual; // Para almacenar códigos ingresados manualmente
  bool _isScannerActive = false; // Estado del scanner
  
  // URL de tu backend
  static const String backendUrl = 'http://localhost:8080/api/verimed/product';
  
  MobileScannerController controller = MobileScannerController(
    // Configuración para detectar todos los tipos de códigos
    formats: [
      BarcodeFormat.all,
    ],
    autoStart: false, // No iniciar automáticamente
  );

  @override
  void initState() {
    super.initState();
    print('🟡 Inicializando scanner...'); // Debug
    // Iniciar el controlador después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScanner();
    });
  }

  void _startScanner() async {
    try {
      setState(() {
        _isScannerActive = true;
      });
      await controller.start();
      print('✅ Scanner iniciado correctamente'); // Debug
    } catch (e) {
      print('❌ Error al iniciar scanner: $e'); // Debug
      setState(() {
        _isScannerActive = false;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _barcodePreview(Barcode? value) {
    if (_isLoading) {
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
    
    if (value == null) {
      return Column(
        children: [
          Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 30,
          ),
          SizedBox(height: 8),
          Text(
            'Escanea el código QR del medicamento\no toca el icono de teclado para ingresarlo manualmente',
            overflow: TextOverflow.fade,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          // Indicador de estado del scanner
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isScannerActive ? Icons.camera_alt : Icons.camera_alt_outlined,
                color: _isScannerActive ? Colors.green : Colors.orange,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                _isScannerActive ? 'Scanner activo' : 'Iniciando scanner...',
                style: TextStyle(
                  color: _isScannerActive ? Colors.green : Colors.orange,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 30,
        ),
        const SizedBox(height: 8),
        const Text(
          'Código detectado:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.displayValue ?? 'No display value.',
          overflow: TextOverflow.fade,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    print('📷 Evento de captura - Códigos detectados: ${barcodes.barcodes.length}'); // Debug
    
    if (mounted && barcodes.barcodes.isNotEmpty && !_isLoading) {
      final Barcode barcode = barcodes.barcodes.first;
      print('✅ Código detectado: ${barcode.displayValue}'); // Debug
      print('📊 Tipo de código: ${barcode.format}'); // Debug
      print('📍 Posición: ${barcode.corners}'); // Debug
      
      setState(() {
        _barcode = barcode;
        _codigoManual = null; // Limpiar código manual al escanear
        _isLoading = true;
        _isScannerActive = false; // Scanner pausado durante procesamiento
      });
      
      // Pausar el escáner temporalmente
      controller.stop();
      print('⏸️ Scanner pausado para procesamiento'); // Debug
      
      // Consultar al backend
      _verificarMedicamento(barcode.displayValue ?? '');
    } else if (!mounted) {
      print('⚠️ Widget no montado, ignorando código'); // Debug
    } else if (barcodes.barcodes.isEmpty) {
      print('📷 Captura sin códigos'); // Debug
    } else if (_isLoading) {
      print('⏳ Ya procesando un código, ignorando nuevo'); // Debug
    }
  }
  
  Future<void> _verificarMedicamento(String scannedValue) async {
    try {
      String code = scannedValue;
      String finalUrl = '';
      
      // Verificar si el valor escaneado es una URL completa
      if (scannedValue.startsWith('http://') || scannedValue.startsWith('https://')) {
        print('URL completa detectada: $scannedValue'); // Debug
        
        try {
          final Uri scannedUri = Uri.parse(scannedValue);
          final List<String> pathSegments = scannedUri.pathSegments;
          
          // Buscar el código en los segmentos de la URL
          // Patrón esperado: /api/verimed/product/{code}
          if (pathSegments.length >= 4 && 
              pathSegments.contains('api') && 
              pathSegments.contains('verimed') && 
              pathSegments.contains('product')) {
            
            final int productIndex = pathSegments.indexOf('product');
            if (productIndex < pathSegments.length - 1) {
              code = pathSegments[productIndex + 1];
              print('Código extraído de URL: $code'); // Debug
              
              // Usar nuestro backend con el código extraído
              finalUrl = '$backendUrl?code=$code';
            } else {
              throw Exception('URL no contiene código después de /product/');
            }
          } else {
            throw Exception('URL no sigue el patrón esperado: /api/verimed/product/{code}');
          }
        } catch (e) {
          print('Error al procesar URL: $e');
          _mostrarError('La URL escaneada no tiene el formato correcto.\nFormato esperado: http://servidor.com/api/verimed/product/{código}');
          return;
        }
      } else {
        // Es solo un código, construir URL normal
        print('Código simple detectado: $scannedValue'); // Debug
        code = scannedValue;
        finalUrl = '$backendUrl?code=$code';
      }
      
      print('URL final para consulta: $finalUrl'); // Debug
      print('Código a verificar: $code'); // Debug
      
      final http.Response response = await http.get(
        Uri.parse(finalUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        
        if (data.isNotEmpty) {
          // Si hay productos, tomar el primero o mostrar todos
          _mostrarResultado(data);
        } else {
          _mostrarMedicamentoNoAutentico('No se encontró ningún producto con el código: $code');
        }
      } else {
        _mostrarError('Error al verificar el medicamento. Código: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión: $e');
      _mostrarError('Error de conexión. Verifica tu internet.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _mostrarResultado(List<dynamic> products) {
    // Si encontramos productos, el medicamento es auténtico
    final bool esAutentico = products.isNotEmpty;
    final String mensaje = esAutentico 
        ? 'Medicamento verificado correctamente en la base de datos'
        : 'No se encontró información para este código';
    
    // Si hay productos, tomar el primero para mostrar (o mostrar todos si se requiere)
    String? productName;
    String? manufacturer;
    String? serialNumber;
    String? productId;
    String? createdAt;
    String? certificateUrl;
    String? nameBatch;
    String? code;
    String? hash;
    
    if (products.isNotEmpty) {
      final product = products.first as Map<String, dynamic>;
      productId = product['id']?.toString();
      manufacturer = product['manufacturer'] as String?;
      serialNumber = product['serialNumber'] as String?;
      
      // El campo 'name' es un objeto, no un string
      final nameObject = product['name'];
      
      if (nameObject != null && nameObject is Map<String, dynamic>) {
        code = nameObject['code'] as String?;
        hash = nameObject['hash'] as String?;
        createdAt = nameObject['createdAt'] as String?;
        certificateUrl = nameObject['certificateUrl'] as String?;
        nameBatch = nameObject['nameBatch'] as String?;
      }
      
      // El nombre del producto será el nameBatch o el serialNumber
      productName = nameBatch ?? serialNumber;
    }
    
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(
                esAutentico ? Icons.verified : Icons.warning,
                color: esAutentico ? Colors.green : Colors.red,
                size: 30,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  esAutentico ? '✅ Medicamento Auténtico Verificado' : 'Medicamento No Encontrado',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Código Escaneado: ${_barcode?.displayValue ?? _codigoManual ?? 'N/A'}'),
                const SizedBox(height: 8),
                
                if (productId != null) ...[
                  Text('ID del Producto: $productId', 
                       style: const TextStyle(fontWeight: FontWeight.bold),),
                  const SizedBox(height: 8),
                ],
                
                if (productName != null) ...[
                  Text('Medicamento: $productName', 
                       style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),),
                  const SizedBox(height: 8),
                ],
                
                if (serialNumber != null) ...[
                  Text('Principio Activo: $serialNumber'),
                  const SizedBox(height: 4),
                ],
                
                if (manufacturer != null) ...[
                  Text('Fabricante: $manufacturer'),
                  const SizedBox(height: 4),
                ],
                
                if (code != null) ...[
                  Text('Código: $code', 
                       style: const TextStyle(fontWeight: FontWeight.bold),),
                  const SizedBox(height: 4),
                ],
                
                if (createdAt != null) ...[
                  const SizedBox(height: 8),
                  Text('Fecha de Registro: ${_formatDate(createdAt)}'),
                ],
                
                // Mostrar información adicional si hay múltiples productos
                if (products.length > 1) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      '📦 Se encontraron ${products.length} productos con este código',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 12),
                Text(
                  esAutentico ? '✅ $mensaje' : '⚠️ $mensaje',
                  style: TextStyle(
                    color: esAutentico ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                // Mostrar certificado si está disponible
                if (certificateUrl != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📄 Certificado disponible',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          certificateUrl,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Mostrar hash para verificación adicional (solo para debug/técnicos)
                if (hash != null) ...[
                  const SizedBox(height: 8),
                  ExpansionTile(
                    title: const Text(
                      'Información técnica',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Hash: $hash',
                          style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetearEscaner();
              },
              child: const Text('Escanear Otro'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetearEscaner();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
  
  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
  
  void _mostrarError(String mensaje) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text('Error'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(mensaje),
              const SizedBox(height: 10),
              const Text(
                'Por favor, verifica tu conexión a internet e intenta nuevamente.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetearEscaner();
              },
              child: const Text('Reintentar'),
            ),
          ],
        );
      },
    );
  }
  
  void _resetearEscaner() {
    print('🔄 Reseteando scanner...'); // Debug
    setState(() {
      _barcode = null;
      _codigoManual = null;
      _isLoading = false;
    });
    // Reiniciar el escáner
    _startScanner();
  }

  void _mostrarDialogoIngresarCodigo() {
    final TextEditingController codigoController = TextEditingController();
    
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.keyboard, color: Color(0xFF1976D2), size: 30),
              SizedBox(width: 10),
              Text('Ingresar Código Manualmente'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Puedes ingresar el código medicamento:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Código simple: A8BBD6037CFD',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codigoController,
                decoration: InputDecoration(
                  labelText: 'Código',
                  hintText: 'A8BBD6037CFD',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.qr_code),
                ),
                textCapitalization: TextCapitalization.none, // Permitir URLs en minúsculas
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.of(context).pop();
                    _verificarCodigoManual(value.trim());
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final String codigo = codigoController.text.trim();
                if (codigo.isNotEmpty) {
                  Navigator.of(context).pop();
                  _verificarCodigoManual(codigo);
                } else {
                  // Mostrar mensaje de error si el campo está vacío
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor ingresa un código válido'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
              child: const Text('Verificar'),
            ),
          ],
        );
      },
    );
  }
  
  void _verificarCodigoManual(String codigo) {
    print('⌨️ Verificación manual del código: $codigo'); // Debug
    // Pausar el escáner
    controller.stop();
    
    // Almacenar el código manual y limpiar el barcode escaneado
    setState(() {
      _codigoManual = codigo;
      _barcode = null;
      _isLoading = true;
      _isScannerActive = false; // Scanner pausado durante procesamiento
    });
    
    // Verificar el código en el backend
    _verificarMedicamento(codigo);
  }

  void _mostrarMedicamentoNoAutentico(String detalleError) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
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
                  'Medicamento No Auténtico',
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
              Text('Código Consultado: ${_barcode?.displayValue ?? _codigoManual ?? 'N/A'}'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ ADVERTENCIA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Este medicamento no se encuentra en nuestra base de datos de productos auténticos.',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Esto podría indicar que:',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• El medicamento no es auténtico\n• El código está mal ingresado\n',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Recomendaciones:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '• Verifique el código nuevamente\n• No consuma el medicamento si tiene dudas',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _mostrarDialogoIngresarCodigo();
              },
              child: const Text(
                'Ingresar Código Nuevamente',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetearEscaner();
              },
              child: const Text(
                'Escanear Otro',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetearEscaner();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'VeriMed - Escáner',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.bug_report),
            iconSize: 24,
            tooltip: 'Prueba con código demo',
            onPressed: () => _verificarCodigoManual('A8BBD6037CFD'),
          ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.keyboard),
            iconSize: 32,
            onPressed: _mostrarDialogoIngresarCodigo,
          ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.flash_on),
            iconSize: 32,
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.cameraswitch),
            iconSize: 32,
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
            scanWindow: Rect.fromCenter(
              center: MediaQuery.of(context).size.center(Offset.zero),
              width: 300,
              height: 300,
            ),
          ),
          // Overlay con esquinas para enfocar el área de escaneo
          Container(
            decoration: const ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: Color(0xFF1976D2),
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          // Panel inferior con información
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _barcodePreview(_barcode),
              ),
            ),
          ),
        ],
      ),
    );
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
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + borderRadius, rect.top)
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
    final double borderWidthSize = width / 2;
    final double height = rect.height;
    final double borderOffset = borderWidth / 2;
    final double effectiveBorderLength = borderLength > cutOutSize / 2 + borderOffset
        ? borderWidthSize / 2
        : borderLength;
    final double effectiveCutOutSize = cutOutSize < width ? cutOutSize : width - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - effectiveCutOutSize / 2 + borderOffset,
      rect.top + height / 2 - effectiveCutOutSize / 2 + borderOffset,
      effectiveCutOutSize - borderOffset * 2,
      effectiveCutOutSize - borderOffset * 2,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
        boxPaint,
      )
      ..restore();

    // Dibujar las esquinas
    final path = Path();
    // Top left
    path.moveTo(cutOutRect.left - borderOffset, cutOutRect.top + effectiveBorderLength);
    path.lineTo(cutOutRect.left - borderOffset, cutOutRect.top + borderRadius);
    path.quadraticBezierTo(cutOutRect.left - borderOffset, cutOutRect.top - borderOffset,
        cutOutRect.left + borderRadius, cutOutRect.top - borderOffset,);
    path.lineTo(cutOutRect.left + effectiveBorderLength, cutOutRect.top - borderOffset);

    // Top right
    path.moveTo(cutOutRect.right - effectiveBorderLength, cutOutRect.top - borderOffset);
    path.lineTo(cutOutRect.right - borderRadius, cutOutRect.top - borderOffset);
    path.quadraticBezierTo(cutOutRect.right + borderOffset, cutOutRect.top - borderOffset,
        cutOutRect.right + borderOffset, cutOutRect.top + borderRadius,);
    path.lineTo(cutOutRect.right + borderOffset, cutOutRect.top + effectiveBorderLength);

    // Bottom left
    path.moveTo(cutOutRect.left - borderOffset, cutOutRect.bottom - effectiveBorderLength);
    path.lineTo(cutOutRect.left - borderOffset, cutOutRect.bottom - borderRadius);
    path.quadraticBezierTo(cutOutRect.left - borderOffset, cutOutRect.bottom + borderOffset,
        cutOutRect.left + borderRadius, cutOutRect.bottom + borderOffset,);
    path.lineTo(cutOutRect.left + effectiveBorderLength, cutOutRect.bottom + borderOffset);

    // Bottom right
    path.moveTo(cutOutRect.right - effectiveBorderLength, cutOutRect.bottom + borderOffset);
    path.lineTo(cutOutRect.right - borderRadius, cutOutRect.bottom + borderOffset);
    path.quadraticBezierTo(cutOutRect.right + borderOffset, cutOutRect.bottom + borderOffset,
        cutOutRect.right + borderOffset, cutOutRect.bottom - borderRadius,);
    path.lineTo(cutOutRect.right + borderOffset, cutOutRect.bottom - effectiveBorderLength);

    canvas.drawPath(path, borderPaint);
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
