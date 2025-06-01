import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/lembaga.dart';
import 'detail_lembaga_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Lembaga> lembagas = [];
  List<Lembaga> filteredLembagas = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  String? selectedBahasa;
  String? selectedHarga;

  @override
  void initState() {
    super.initState();
    fetchRecommendedLembagas();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchRecommendedLembagas() async {
    setState(() => isLoading = true);
    try {
      final apiService = ApiService();
      final result = await apiService.fetchRecommendedLembagas();
      print('Recommended Lembagas: $result');
      setState(() {
        lembagas = result;
        filteredLembagas = result;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error fetching recommended lembagas: $e');
      print('StackTrace: $stackTrace');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat rekomendasi: $e')),
      );
    }
  }

  Future<void> fetchAllLembagas() async {
    setState(() => isLoading = true);
    try {
      final apiService = ApiService();
      final result = await apiService.fetchAllLembagas();
      print('All Lembagas: $result');
      setState(() {
        lembagas = result;
        filteredLembagas = result;
        _applyFilters();
        isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error fetching all lembagas: $e');
      print('StackTrace: $stackTrace');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat semua lembaga: $e')),
      );
    }
  }

  void _onSearchChanged() {
    setState(() {
      filteredLembagas = lembagas.where((lembaga) {
        final query = _searchController.text.toLowerCase();
        return lembaga.nama.toLowerCase().contains(query) ||
            (lembaga.alamat?.toLowerCase().contains(query) ?? false);
      }).toList();
      _applyFilters();
    });
  }

  void _applyFilters() {
    filteredLembagas = lembagas.where((lembaga) {
      bool matchesBahasa = true;
      bool matchesHarga = true;

      // Debug: Cetak data lembaga untuk memeriksa properti
      print('Lembaga: ${lembaga.nama}, Bahasa: ${lembaga.bahasa}, Price: ${lembaga.price}');

      // Filter Bahasa
      if (selectedBahasa != null && lembaga.bahasa != null) {
        String bahasaFromFilter = selectedBahasa!.toLowerCase();
        String bahasaFromApi = lembaga.bahasa!.toLowerCase();
        print('Comparing bahasa: Filter: $bahasaFromFilter, API: $bahasaFromApi');
        matchesBahasa = bahasaFromApi.contains(bahasaFromFilter);
      } else if (selectedBahasa != null && lembaga.bahasa == null) {
        matchesBahasa = false; // Jika bahasa dari API null tetapi filter ada, tidak cocok
      }

      // Filter Harga
      if (selectedHarga != null && lembaga.price != null) {
        print('Comparing price: Filter: $selectedHarga, API: ${lembaga.price}');
        if (selectedHarga == '< 500K') {
          matchesHarga = lembaga.price! < 500000;
        } else if (selectedHarga == '500K - 1jt') {
          matchesHarga = lembaga.price! >= 500000 && lembaga.price! <= 1000000;
        } else if (selectedHarga == '> 1jt') {
          matchesHarga = lembaga.price! > 1000000;
        }
      } else if (selectedHarga != null && lembaga.price == null) {
        matchesHarga = false; // Jika price dari API null tetapi filter ada, tidak cocok
      }

      print('Matches - Bahasa: $matchesBahasa, Harga: $matchesHarga');
      return matchesBahasa && matchesHarga;
    }).toList();

    print('Filtered Lembagas: $filteredLembagas');
    print('Jumlah lembaga setelah filter: ${filteredLembagas.length}');
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height * 0.6, // Ditambah untuk menampung semua opsi
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const Text(
                      'Filter Kursus',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Bahasa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'Bahasa Inggris',
                        'Bahasa Jepang',
                        'Bahasa Mandarin',
                        'Bahasa Arab',
                        'Bahasa Perancis',
                        'Bahasa Spanyol',
                        'Bahasa Jerman',
                      ].map((bahasa) {
                        return ChoiceChip(
                          label: Text(bahasa),
                          selected: selectedBahasa == bahasa,
                          selectedColor: Colors.purple.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: selectedBahasa == bahasa ? Colors.purple : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          onSelected: (selected) {
                            setModalState(() {
                              selectedBahasa = selected ? bahasa : null;
                            });
                            setState(() {
                              _applyFilters();
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Harga',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['< 500K', '500K - 1jt', '> 1jt'].map((harga) {
                        return ChoiceChip(
                          label: Text(harga),
                          selected: selectedHarga == harga,
                          selectedColor: Colors.purple.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: selectedHarga == harga ? Colors.purple : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          onSelected: (selected) {
                            setModalState(() {
                              selectedHarga = selected ? harga : null;
                            });
                            setState(() {
                              _applyFilters();
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black26,
                      ),
                      child: const Text(
                        'Terapkan Filter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Makin mudah cari tempat kursus',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            'Ideal di Pareverse!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Image.asset(
                          'assets/onboarding_icon.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari kursus ideal...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.filter_list,
                            color: Colors.grey,
                          ),
                          onPressed: _showFilterMenu,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Rekomendasi Kursus Terbaik',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: fetchAllLembagas,
                          child: const Text(
                            'See All',
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Colors.purple,
                        ),
                      )
                    else if (filteredLembagas.isEmpty)
                      const Center(
                        child: Text(
                          'Tidak ada data rekomendasi kursus saat ini.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredLembagas.length,
                          itemBuilder: (context, index) {
                            final lembaga = filteredLembagas[index];
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                onTap: () async {
                                  try {
                                    print('Mengambil detail untuk ID: ${lembaga.id}');
                                    final apiService = ApiService();
                                    final detailedLembaga = await apiService.fetchLembagaDetail(lembaga.id.toString());
                                    print('Data detail lembaga: $detailedLembaga');
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
                                },
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      lembaga.bahasa ?? 'Bahasa Tidak Diketahui',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      lembaga.alamat ?? 'Alamat Tidak Diketahui',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                trailing: lembaga.isRecommended
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.purple.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'Recommended',
                                          style: TextStyle(
                                            color: Colors.purple,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
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
        currentIndex: 0,
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
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/favorite');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }
}