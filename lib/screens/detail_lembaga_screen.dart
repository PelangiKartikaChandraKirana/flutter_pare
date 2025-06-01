import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/lembaga.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // Untuk Clipboard
import 'package:shared_preferences/shared_preferences.dart'; // Untuk menyimpan bookmark

class DetailLembagaScreen extends StatefulWidget {
  final Lembaga lembaga;

  const DetailLembagaScreen({super.key, required this.lembaga});

  @override
  _DetailLembagaScreenState createState() => _DetailLembagaScreenState();
}

class _DetailLembagaScreenState extends State<DetailLembagaScreen> {
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorited = prefs.getBool('favorite_${widget.lembaga.id}') ?? false;
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorited = !isFavorited;
      prefs.setBool('favorite_${widget.lembaga.id}', isFavorited);
    });
  }

  Future<void> _launchWhatsApp(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      print('Nomor WhatsApp tidak tersedia');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor WhatsApp tidak tersedia untuk lembaga ini.')),
      );
      return;
    }

    String formattedNumber = phoneNumber.startsWith('+') ? phoneNumber.substring(1) : phoneNumber;
    print('Nomor WhatsApp yang digunakan: $formattedNumber');

    final whatsappUrl = Uri.parse('https://wa.me/$formattedNumber');
    print('URL WhatsApp: $whatsappUrl');

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(
          whatsappUrl,
          mode: LaunchMode.externalApplication,
        );
        print('Berhasil membuka WhatsApp');
      } else {
        print('WhatsApp tidak terpasang, membuka di browser sebagai fallback');
        await launchUrl(
          whatsappUrl,
          mode: LaunchMode.platformDefault,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'WhatsApp tidak terpasang. Anda akan diarahkan ke browser. Nomor: $formattedNumber',
            ),
            action: SnackBarAction(
              label: 'Salin Nomor',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: formattedNumber));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nomor telah disalin ke clipboard')),
                );
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('Error saat membuka WhatsApp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka WhatsApp: $e'),
          action: SnackBarAction(
            label: 'Salin Nomor',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: formattedNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nomor telah disalin ke clipboard')),
              );
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _launchMaps(String? linkMaps) async {
    if (linkMaps == null || linkMaps.isEmpty) {
      print('Link Maps tidak tersedia');
      return;
    }

    final mapsUrl = Uri.parse(linkMaps);
    print('URL Maps: $mapsUrl');

    try {
      if (await canLaunchUrl(mapsUrl)) {
        await launchUrl(
          mapsUrl,
          mode: LaunchMode.externalApplication,
        );
        print('Berhasil membuka Google Maps');
      } else {
        print('Tidak dapat membuka Google Maps: Aplikasi mungkin tidak terpasang');
        throw 'Tidak dapat membuka Google Maps.';
      }
    } catch (e) {
      print('Error saat membuka Google Maps: $e');
      throw 'Gagal membuka Google Maps: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: widget.lembaga.gambar != null
                            ? DecorationImage(
                                image: NetworkImage('http://13.251.54.99/storage/${widget.lembaga.gambar}'),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  print('Gagal memuat gambar: $exception');
                                  print('StackTrace: $stackTrace');
                                },
                              )
                            : const DecorationImage(
                                image: AssetImage('assets/placeholder_image.jpg'),
                                fit: BoxFit.cover,
                              ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.school, color: Colors.purple, size: 24), // Ikon sekolah/toga
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.lembaga.nama,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.grey, size: 18),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.lembaga.alamat ?? 'Alamat Tidak Diketahui',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.lembaga.alamat != null)
                            TextButton(
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: widget.lembaga.alamat!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Alamat telah disalin ke clipboard')),
                                );
                              },
                              child: const Text(
                                'Salin Alamat',
                                style: TextStyle(
                                  color: Colors.purple,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Html(
                        data: widget.lembaga.deskripsi ?? 'Deskripsi tidak tersedia',
                        style: {
                          'p': Style(
                            fontSize: FontSize(14),
                            color: Colors.black54,
                            lineHeight: const LineHeight(1.5),
                          ),
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Detail Program',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bahasa',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.lembaga.bahasa ?? 'Tidak Diketahui',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Harga',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.lembaga.price != null
                                    ? 'Rp ${widget.lembaga.price!.toInt()}'
                                    : 'Tidak Diketahui',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Durasi',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.lembaga.duration ?? 'Tidak Diketahui',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Program Tersedia',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.lembaga.programKursus == null || widget.lembaga.programKursus!.isEmpty)
                        const Text(
                          'Tidak ada program tersedia',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      else
                        Column(
                          children: widget.lembaga.programKursus!.map((program) {
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                title: Text(
                                  program.namaProgram,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  'Harga: Rp ${program.harga.toInt()} | Durasi: ${program.durasi}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: isFavorited ? Colors.red : Colors.grey,
                      size: 30,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _launchWhatsApp(context, widget.lembaga.whatsapp);
                      },
                      icon: const Icon(Icons.chat, color: Colors.white),
                      label: const Text(
                        'Hubungi via WhatsApp',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await _launchMaps(widget.lembaga.linkMaps);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Icon(
                      Icons.directions,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}