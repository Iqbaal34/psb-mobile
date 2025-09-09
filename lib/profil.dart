import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Warna konsisten dengan dashboard
const Color primaryNavy = Color(0xFF223A5E);
const Color accentBlue = Color(0xFF4A90E2);
const Color softBlue = Color(0xFFE3F2FD);
const Color softGrey = Color(0xFFF5F7FA);
const Color accentYellow = Color(0xFFFFE082);

class ProfilPage extends StatefulWidget {
  final String nisn;
  const ProfilPage({super.key, required this.nisn});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Map<String, dynamic>? profil;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    final url = Uri.parse('http://192.168.0.213/psb-api/get_profil.php');
    try {
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nisn': widget.nisn}),
      );
      final data = jsonDecode(resp.body);
      if (data['success'] == true && data['data'] != null) {
        setState(() {
          profil = data['data'];
          loading = false;
        });
      } else {
        setState(() {
          profil = null;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        profil = null;
        loading = false;
      });
    }
  }

  Widget buildDataRow(String label, String? value, {IconData? icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(icon, color: accentBlue, size: 22),
            ),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: primaryNavy,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value != null && value.isNotEmpty ? value : '-',
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softGrey,
      appBar: AppBar(
        backgroundColor: primaryNavy,
        iconTheme: const IconThemeData(color: Colors.white), // back icon jadi putih
        title: const Text(
          'Data Diri Siswa',
          style: TextStyle(color: Colors.white), // judul jadi putih
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : profil == null
              ? const Center(child: Text('Data profil tidak ditemukan.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                const Icon(Icons.account_circle,
                                    size: 70, color: accentBlue),
                                const SizedBox(height: 12),
                                Text(
                                  profil!['nama_siswa'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: primaryNavy,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'NISN: ${profil!['nisn'] ?? '-'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          buildDataRow('Email', profil!['email'], icon: Icons.email_rounded),
                          buildDataRow('No. Telepon', profil!['nomor_telepon'], icon: Icons.phone),
                          buildDataRow('Alamat', profil!['alamat'], icon: Icons.home_rounded),
                          buildDataRow('Tanggal Lahir', profil!['tgl_lahir'], icon: Icons.cake_rounded),
                          buildDataRow('Asal Sekolah', profil!['asal_sekolah'], icon: Icons.school_rounded),
                          buildDataRow('Jenis Kelamin', profil!['jenis_kelamin'], icon: Icons.wc_rounded),
                          buildDataRow('Agama', profil!['agama'], icon: Icons.mosque_rounded),
                          buildDataRow('Nama Ibu', profil!['nama_ibu'], icon: Icons.person_rounded),
                          buildDataRow('No. Telp Ibu', profil!['nomor_telp_ibu'], icon: Icons.phone_android_rounded),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}