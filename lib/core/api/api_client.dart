import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../storage/secure_storage.dart';

class ApiResponse {
  final bool success;
  final int statusCode;
  final dynamic data;
  final String? message;

  ApiResponse({
    required this.success,
    required this.statusCode,
    this.data,
    this.message,
  });
}

class ApiClient {
  static Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await SecureStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<ApiResponse> get(String url, {bool withAuth = true}) async {
    try {
      final headers = await _getHeaders(withAuth: withAuth);
      final response = await http.get(Uri.parse(url), headers: headers);
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(success: false, statusCode: 500, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse> post(String url, Map<String, dynamic> body, {bool withAuth = true}) async {
    try {
      final headers = await _getHeaders(withAuth: withAuth);
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(success: false, statusCode: 500, message: 'Koneksi gagal: $e');
    }
  }

  static Future<ApiResponse> postMultipart(
    String url,
    Map<String, String> fields, {
    XFile? file,
    String fileField = 'photo',
    bool withAuth = true,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      final headers = await _getHeaders(withAuth: withAuth);
      headers.remove('Content-Type'); // Allow multipart boundary to be set automatically
      request.headers.addAll(headers);

      request.fields.addAll(fields);

      if (file != null) {
        try {
          if (file.path.isNotEmpty) {
            final multipartFile = await http.MultipartFile.fromPath(
              fileField,
              file.path,
              filename: file.name,
            );
            request.files.add(multipartFile);
          } else {
            final bytes = await file.readAsBytes();
            final multipartFile = http.MultipartFile.fromBytes(
              fileField,
              bytes,
              filename: file.name,
            );
            request.files.add(multipartFile);
          }
        } catch (_) {
          final bytes = await file.readAsBytes();
          final multipartFile = http.MultipartFile.fromBytes(
            fileField,
            bytes,
            filename: file.name,
          );
          request.files.add(multipartFile);
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(success: false, statusCode: 500, message: 'Koneksi gagal: $e');
    }
  }

  static Future<http.Response> getRaw(String url, {bool withAuth = true}) async {
    final headers = <String, String>{};
    if (withAuth) {
      final token = await SecureStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return await http.get(Uri.parse(url), headers: headers);
  }

  static Future<ApiResponse> delete(String url, Map<String, dynamic>? body, {bool withAuth = true}) async {
    try {
      final headers = await _getHeaders(withAuth: withAuth);
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(success: false, statusCode: 500, message: 'Koneksi gagal: $e');
    }
  }

  static ApiResponse _parseResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      
      String? message;
      if (body is Map) {
        if (body['message'] != null) {
          message = body['message'].toString();
        } else if (body['errors'] is Map) {
          final errors = body['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              message = firstError.first.toString();
            } else {
              message = firstError.toString();
            }
          }
        }
      }

      return ApiResponse(
        success: isSuccess,
        statusCode: response.statusCode,
        data: body is Map ? body['data'] : null,
        message: message ?? (isSuccess ? 'Sukses' : 'Terjadi kesalahan (HTTP ${response.statusCode}).'),
      );
    } catch (e) {
      if (response.statusCode == 413) {
        return ApiResponse(
          success: false,
          statusCode: 413,
          message: 'Ukuran berkas terlalu besar untuk dikirim ke server (HTTP 413).',
        );
      }
      return ApiResponse(
        success: false,
        statusCode: response.statusCode,
        message: 'Respon server tidak valid (HTTP ${response.statusCode}).',
      );
    }
  }
}
