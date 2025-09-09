import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'register.dart';
import 'loginpage.dart';
import 'profil.dart';
import 'nilai_detail.dart';

// Warna utama
const Color primaryNavy = Color(0xFF223A5E);
const Color accentBlue = Color(0xFF4A90E2);
const Color softBlue = Color(0xFFE3F2FD);
const Color softGrey = Color(0xFFF5F7FA);
const Color accentYellow = Color(0xFFFFE082);

class DashboardSiswa extends StatefulWidget {
  final String nisn;
  final String nama;

  const DashboardSiswa({
    super.key,
    required this.nisn,
    required this.nama,
  });

  @override
  State<DashboardSiswa> createState() => _DashboardSiswaState();
}

class _DashboardSiswaState extends State<DashboardSiswa> {
  static const String baseUrl = "http://192.168.0.213/psb-api";
  Uri get cekUrl => Uri.parse("$baseUrl/cek_pendaftaran.php");
  Uri get rataRataUrl => Uri.parse("$baseUrl/get_ratarata.php");

  bool? sudahDaftar;
  double? rataRata;

  @override
  void initState() {
    super.initState();
    _cekStatusAwal();
    _loadRataRata();
  }

  Future<void> _cekStatusAwal() async {
    final status = await _hasRegistered();
    if (!mounted) return;
    setState(() => sudahDaftar = status);
  }

  Future<bool> _hasRegistered() async {
    try {
      final resp = await http.post(
        cekUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"nisn": widget.nisn}),
      );
      if (resp.statusCode != 200) return false;
      final data = jsonDecode(resp.body);
      return data['registered'] == true;
    } catch (e) {
      debugPrint("Error cek status: $e");
      return false;
    }
  }

  Future<double?> _getRataRata() async {
    try {
      final resp = await http.post(
        rataRataUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"nisn": widget.nisn}),
      );
      debugPrint("Response code: ${resp.statusCode}");
      debugPrint("Response body: ${resp.body}");
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body);
      if (data['success'] == true && data['data'] != null) {
        return (data['data']['rata_rata'] as num?)?.toDouble();
      } else {
        debugPrint("API error: ${data['message']}");
        return null;
      }
    } catch (e) {
      debugPrint("Error ambil rata-rata: $e");
      return null;
    }
  }

  Future<void> _loadRataRata() async {
    final rata = await _getRataRata();
    if (!mounted) return;
    setState(() => rataRata = rata);
  }

  Future<void> _onTapDaftar() async {
    final registered = await _hasRegistered();
    if (registered) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: softGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.close_rounded, color: Colors.red),
              SizedBox(width: 6),
              Text(
                'Anda sudah mendaftar',
                style: TextStyle(fontSize: 17),
              ),
            ],
          ),
          content: const Text('Data pendaftaran Anda sudah tersimpan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterFlowPage()),
    );
    _cekStatusAwal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softGrey,
      appBar: AppBar(
        backgroundColor: primaryNavy,
        automaticallyImplyLeading: false,
        elevation: 2,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/siswa.png'),
              backgroundColor: accentBlue,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.nama,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: accentYellow),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: accentYellow),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Loginpage()),
                );
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),
          const Text(
            "Peserta Didik Baru",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryNavy,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          buildCategoryCard(
            title: "Daftar Disini",
            subtitle: "Jadilah bagian dari Moonzherian!",
            gradient: const LinearGradient(
              colors: [accentBlue, primaryNavy],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            textColor: Colors.white,
            image: 'assets/images/siswi1.png',
            onTap: _onTapDaftar,
          ),
          const SizedBox(height: 16),
          buildCategoryCard(
            title: "Lihat Ranking",
            subtitle: "Klik disini untuk melihat ranking siswa.",
            gradient: const LinearGradient(
              colors: [accentYellow, softBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            textColor: primaryNavy,
            image: 'assets/images/siswa1.png',
            onTap: () async {
              final url = Uri.parse(
                "https://gabung.sman2xiirpl.kel4.my.id/ranking",
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tidak bisa membuka tautan.')),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: sudahDaftar == true
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfilPage(nisn: widget.nisn),
                            ),
                          );
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: sudahDaftar == true
                          ? accentYellow.withOpacity(0.5)
                          : Colors.red[100],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.assignment_turned_in,
                            size: 36,
                            color: sudahDaftar == true
                                ? primaryNavy
                                : Colors.red[700]),
                        const SizedBox(height: 8),
                        const Text(
                          "Status",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: primaryNavy),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sudahDaftar == true ? "Terdaftar" : "Belum Terdaftar",
                          style: TextStyle(
                            color: sudahDaftar == true
                                ? primaryNavy
                                : Colors.red[700],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // ...existing code...
              Expanded(
                child: GestureDetector(
                  onTap: rataRata != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NilaiDetailPage(nisn: widget.nisn),
                            ),
                          );
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: accentBlue.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.leaderboard, size: 36, color: accentBlue),
                        const SizedBox(height: 8),
                        const Text(
                          "Nilai Rata-rata",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: primaryNavy),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rataRata != null
                              ? rataRata!.toStringAsFixed(1)
                              : "Belum ada",
                          style: const TextStyle(
                              fontSize: 13, color: primaryNavy),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Artikel",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          buildArticleHorizontalCard(
            image: 'assets/images/artikel1.png',
            title:
                "11 Orang Siswa lolos seleksi Olimpiade Sains Tingkat Kota tahun 2025",
            description:
                "Sebelas siswa telah berhasil lolos seleksi Olimpiade Sains Nasional (OSN) Tingkat Kota Tangerang Selatan...",
          ),
          const SizedBox(height: 12),
          buildArticleHorizontalCard(
            image: 'assets/images/artikel2.png',
            title: "Kepala Sekolah SMAN Harvard Tangsel Raih Gelar Doktor",
            description:
                "Selamat dan sukses atas diraihnya gelar doktor oleh Bapak kepala sekolah SMAN Harvard Kota Tangerang Selatan...",
          ),
        ],
      ),
    );
  }

  Widget buildCategoryCard({
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required Color textColor,
    required String image,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 0.5,
                      )),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: TextStyle(fontSize: 14, color: textColor)),
                ],
              ),
            ),
            Image.asset(image, height: 80),
          ],
        ),
      ),
    );
  }

  // Artikel horizontal card
  Widget buildArticleHorizontalCard({
    required String image,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                image,
                width: 100,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: primaryNavy,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(description,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black54),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}