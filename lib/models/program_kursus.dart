class ProgramKursus {
  final int id;
  final int lembagaId;
  final String namaProgram;
  final String bahasa;
  final double harga;
  final String durasi;

  ProgramKursus({
    required this.id,
    required this.lembagaId,
    required this.namaProgram,
    required this.bahasa,
    required this.harga,
    required this.durasi,
  });

  factory ProgramKursus.fromJson(Map<String, dynamic> json) {
    return ProgramKursus(
      id: json['id'] as int,
      lembagaId: json['lembaga_id'] as int,
      namaProgram: json['nama_program'] as String? ?? 'Tidak Diketahui',
      bahasa: json['bahasa'] as String? ?? 'Tidak Diketahui',
      harga: (json['harga'] is int ? (json['harga'] as int).toDouble() : json['harga'] as double?) ?? 0.0,
      durasi: json['durasi'] as String? ?? 'Tidak Diketahui',
    );
  }
}