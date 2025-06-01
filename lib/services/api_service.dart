import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';
  import '../models/lembaga.dart';

  class ApiService {
    static const String baseUrl = 'http://13.251.54.99/api';

    Future<List<Lembaga>> fetchRecommendedLembagas() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token == null) {
          throw Exception('Token tidak ditemukan. Silakan login kembali.');
        }
        final response = await http.get(
          Uri.parse('$baseUrl/lembagas/recommended'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        print('Status Code (Recommended Lembagas): ${response.statusCode}');
        print('Response Body (Recommended Lembagas): ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> lembagaList = data['data'] ?? [];
          return lembagaList.map((json) => Lembaga.fromJson(json)).toList();
        } else if (response.statusCode == 401) {
          throw Exception('Autentikasi gagal: Token tidak valid. Silakan login ulang.');
        } else {
          throw Exception('Gagal memuat lembaga rekomendasi: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Error di fetchRecommendedLembagas: $e');
        throw Exception('Gagal memuat data: $e');
      }
    }

    Future<List<Lembaga>> fetchAllLembagas() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token == null) {
          throw Exception('Token tidak ditemukan. Silakan login kembali.');
        }
        final response = await http.get(
          Uri.parse('$baseUrl/lembagas'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        print('Status Code (All Lembagas): ${response.statusCode}');
        print('Response Body (All Lembagas): ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> lembagaList = data['data'] ?? [];
          return lembagaList.map((json) => Lembaga.fromJson(json)).toList();
        } else if (response.statusCode == 401) {
          throw Exception('Autentikasi gagal: Token tidak valid. Silakan login ulang.');
        } else {
          throw Exception('Gagal memuat semua lembaga: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Error di fetchAllLembagas: $e');
        throw Exception('Gagal memuat data: $e');
      }
    }

    Future<Lembaga> fetchLembagaDetail(String id) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token == null) {
          throw Exception('Token tidak ditemukan. Silakan login kembali.');
        }

        final response = await http.get(
          Uri.parse('$baseUrl/lembagas/$id'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        print('Status Code (Detail Lembaga): ${response.statusCode}');
        print('Response Body (Detail Lembaga): ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['data'] == null) {
            throw Exception('Data lembaga tidak ditemukan di respons API');
          }
          if (data['data'] is! Map<String, dynamic>) {
            throw Exception('Format data tidak valid: data["data"] bukan objek JSON');
          }
          return Lembaga.fromJson(data['data']);
        } else if (response.statusCode == 404) {
          throw Exception('Lembaga dengan ID $id tidak ditemukan');
        } else if (response.statusCode == 401) {
          throw Exception('Autentikasi gagal: Token tidak valid. Silakan login ulang.');
        } else {
          throw Exception('Gagal memuat detail lembaga: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Error di fetchLembagaDetail: $e');
        throw Exception('Gagal memuat detail lembaga: $e');
      }
    }
  }