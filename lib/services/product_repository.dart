import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../utilities/app_constants.dart';

abstract class ProductRepository {
  Future<Product> getProductBySerial(String serialNumber);
}

class ApiProductRepository implements ProductRepository {
  // Usar la configuración centralizada
  static String get _baseUrl => AppConstants.backendUrl;

  @override
  Future<Product> getProductBySerial(String serialNumber) async {
    final url = '$_baseUrl/by-serial/$serialNumber';

    try {
      final http.Response response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        if (responseData is! Map<String, dynamic>) {
          throw ApiException('Respuesta del servidor en formato inválido');
        }

        final Map<String, dynamic> jsonData = responseData;
        return Product.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw ProductNotFoundException('Producto no encontrado: $serialNumber');
      } else {
        throw ApiException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ProductNotFoundException || e is ApiException) {
        rethrow;
      }
      throw NetworkException('Error de conexión: $e');
    }
  }
}

class ProductNotFoundException implements Exception {
  ProductNotFoundException(this.message);
  final String message;
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
}

class NetworkException implements Exception {
  NetworkException(this.message);
  final String message;
}
