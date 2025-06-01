import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/lembaga.dart';
import 'detail_lembaga_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Lembaga> favoriteLembagas = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final favoriteKeys = allKeys.where((key) => key.startsWith('favorite_') && prefs.getBool(key) == true).toList();

      final apiService = ApiService();
      final List<Lembaga> result = [];
      for (var key in favoriteKeys) {
        final id = key.replaceFirst('favorite_', '');
        final lembaga = await apiService.fetchLembagaDetail(id);
        result.add(lembaga);
      }

      setState(() {
        favoriteLembagas = result;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error fetching favorite lembagas: $e');
      print('StackTrace: $stackTrace');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat lembaga favorit: $e')),
      );
    }
  }

  Future<void> _removeFavorite(Lembaga lembaga) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('favorite_${lembaga.id}', false);
    setState(() {
      favoriteLembagas.remove(lembaga);
    });
  }

  Future<void> _navigateToDetail(Lembaga lembaga) async {
    try {
      final apiService = ApiService();
      final detailedLembaga = await apiService.fetchLembagaDetail(lembaga.id.toString());
      if (detailedLembaga != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailLembagaScreen(lembaga: detailedLembaga),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data detail tidak tersedia')),
        );
      }
    } catch (e, stackTrace) {
      print('Error navigating to detail: $e');
      print('StackTrace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Favorit',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.purple,
                        ),
                      )
                    : favoriteLembagas.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada lembaga yang difavoritkan.',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: favoriteLembagas.length,
                            itemBuilder: (context, index) {
                              final lembaga = favoriteLembagas[index];
                              return Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  onTap: () => _navigateToDetail(lembaga),
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.purple.withOpacity(0.1),
                                    child: const Icon(
                                      Icons.school,
                                      color: Colors.purple,
                                      size: 28,
                                    ),
                                  ),
                                  title: Text(
                                    lembaga.nama,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        lembaga.bahasa ?? 'Bahasa Tidak Diketahui',
                                        style: GoogleFonts.poppins(
                                          color: Colors.orange,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        lembaga.alamat ?? 'Alamat Tidak Diketahui',
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => _removeFavorite(lembaga),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        elevation: 10,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }
}