import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'register.dart';

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
  // GANTI sesuai alamat server milikmu
  static const String baseUrl = "http://10.18.118.179/psb-api";
  Uri get cekUrl => Uri.parse("$baseUrl/cek_pendaftaran.php");

  bool? sudahDaftar;

  @override
  void initState() {
    super.initState();
    _cekStatusAwal();
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
        body: jsonEncode({"nisn": widget.nisn}), // pakai nisn
      );
      if (resp.statusCode != 200) return false;
      final data = jsonDecode(resp.body);
      return data['registered'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _onTapDaftar() async {
    final registered = await _hasRegistered();

    if (registered) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.close_rounded, color: Colors.red),
              SizedBox(width: 2),
              Text('Anda sudah mendaftar',
              style: TextStyle(fontSize: 17)),
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

    // Belum daftar -> buka halaman register (flow 2 langkah)
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterFlowPage()),
    );

    // Setelah kembali, cek ulang status
    _cekStatusAwal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF164863),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/siswa.png'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.nama,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.notifications_none, color: Colors.white),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),
          const Text(
            "Kategori",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Kategori 1 (klik untuk daftar)
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _onTapDaftar,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF74A8E3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Daftar Disini",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Jadilah bagian dari Moonzherian!",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Image.asset('assets/images/siswi1.png', height: 80),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Kategori 2 (Lihat Ranking) -> buka URL eksternal
          InkWell(
            borderRadius: BorderRadius.circular(16),
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
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFCDD966),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Lihat Ranking",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Klik disini untuk melihat ranking siswa.",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  Image.asset('assets/images/siswa1.png', height: 80),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Artikel",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
          const SizedBox(height: 12),

          // Artikel 1
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.asset('assets/images/artikel1.png'),
                ),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "11 Orang Siswa lolos seleksi Olimpiade Sains Tingkat Kota tahun 2025",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Sebelas siswa telah berhasil lolos seleksi Olimpiade Sains Nasional (OSN) Tingkat Kota Tangerang Selatan...",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Artikel 2
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.asset('assets/images/artikel2.png'),
                ),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kepala Sekolah SMAN 2 Tangsel Raih Gelar Doktor",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Selamat dan sukses atas diraihnya gelar doktor oleh Bapak kepala sekolah SMAN 2 Kota Tangerang Selatan...",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
