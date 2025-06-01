import 'program_kursus.dart';

class Lembaga {
  final int id;
  final String nama;
  final String? deskripsi;
  final String? gambar;
  final String? alamat;
  final String? linkMaps;
  final String? whatsapp;
  final bool isRecommended;
  final List<ProgramKursus>? programKursus;
  final double? reviewsAvgRating;
  bool isFavorited;

  Lembaga({
    required this.id,
    required this.nama,
    this.deskripsi,
    this.gambar,
    this.alamat,
    this.linkMaps,
    this.whatsapp,
    required this.isRecommended,
    this.programKursus,
    this.reviewsAvgRating,
    this.isFavorited = false,
  });

  factory Lembaga.fromJson(Map<String, dynamic> json) {
    print('Parsing JSON for Lembaga: $json');

    print('Field id: ${json['id']} (Type: ${json['id'].runtimeType})');
    print('Field nama: ${json['nama']} (Type: ${json['nama'].runtimeType})');
    print('Field deskripsi: ${json['deskripsi']} (Type: ${json['deskripsi']?.runtimeType})');
    print('Field gambar: ${json['gambar']} (Type: ${json['gambar']?.runtimeType})');
    print('Field alamat: ${json['alamat']} (Type: ${json['alamat']?.runtimeType})');
    print('Field link_maps: ${json['link_maps']} (Type: ${json['link_maps']?.runtimeType})');
    print('Field whatsapp: ${json['whatsapp']} (Type: ${json['whatsapp']?.runtimeType})');
    print('Field is_recommended: ${json['is_recommended']} (Type: ${json['is_recommended']?.runtimeType})');
    print('Field program_kursuses: ${json['program_kursuses']} (Type: ${json['program_kursuses']?.runtimeType})');

    try {
      final programKursusRaw = json['program_kursuses'] as List?;
      print('Program Kursus raw data: $programKursusRaw');

      List<ProgramKursus>? parsedProgramKursus;
      if (programKursusRaw != null) {
        if (programKursusRaw.isNotEmpty) {
          parsedProgramKursus = programKursusRaw.map((program) {
            print('Parsing program: $program');
            try {
              return ProgramKursus.fromJson(program as Map<String, dynamic>);
            } catch (e) {
              print('Error parsing program: $e');
              return ProgramKursus(
                id: 0,
                lembagaId: 0,
                namaProgram: 'Program Tidak Diketahui',
                bahasa: 'Tidak Diketahui',
                harga: 0.0,
                durasi: 'Tidak Diketahui',
              );
            }
          }).toList();
          print('Parsed ProgramKursus: $parsedProgramKursus');
        } else {
          print('No program_kursuses data available (empty list)');
        }
      } else {
        print('No program_kursuses data available (null)');
      }

      return Lembaga(
        id: _parseInt(json['id']),
        nama: json['nama'] as String? ?? 'Nama Tidak Diketahui',
        deskripsi: json['deskripsi'] as String?,
        gambar: json['gambar'] as String?,
        alamat: json['alamat'] as String?,
        linkMaps: json['link_maps'] as String?,
        whatsapp: json['whatsapp'] as String?,
        isRecommended: _parseBool(json['is_recommended']),
        programKursus: parsedProgramKursus,
        reviewsAvgRating: _parseDouble(json['reviews_avg_rating']),
        isFavorited: false,
      );
    } catch (e, stackTrace) {
      print('Error parsing Lembaga: $e');
      print('StackTrace: $stackTrace');
      rethrow;
    }
  }

  // Getter untuk kompatibilitas dengan kode lama
  String? get bahasa => programKursus != null && programKursus!.isNotEmpty ? programKursus![0].bahasa : null;
  double? get price => programKursus != null && programKursus!.isNotEmpty ? programKursus![0].harga : null;
  String? get duration => programKursus != null && programKursus!.isNotEmpty ? programKursus![0].durasi : null;

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    throw Exception('Cannot parse $value to int');
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}