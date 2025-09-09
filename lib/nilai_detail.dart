import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Color primaryNavy = Color(0xFF223A5E);
const Color accentBlue = Color(0xFF4A90E2);
const Color softGrey = Color(0xFFF5F7FA);

class NilaiDetailPage extends StatefulWidget {
  final String nisn;
  const NilaiDetailPage({super.key, required this.nisn});

  @override
  State<NilaiDetailPage> createState() => _NilaiDetailPageState();
}

class _NilaiDetailPageState extends State<NilaiDetailPage> {
  Map<String, dynamic>? nilai;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadNilai();
  }

  Future<void> _loadNilai() async {
    final url = Uri.parse('http://192.168.0.213/psb-api/get_nilai.php');
    try {
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nisn': widget.nisn}),
      );
      final data = jsonDecode(resp.body);
      if (data['success'] == true && data['data'] != null) {
        setState(() {
          nilai = data['data'];
          loading = false;
        });
      } else {
        setState(() {
          nilai = null;
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        nilai = null;
        loading = false;
      });
    }
  }

  Widget buildNilaiRow(String label, dynamic value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: primaryNavy))),
          const SizedBox(width: 10),
          Text(value != null ? value.toString() : '-', style: const TextStyle(fontSize: 15)),
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Detail Nilai', style: TextStyle(color: Colors.white)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : nilai == null
              ? const Center(child: Text('Data nilai tidak ditemukan.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildNilaiRow('NISN', nilai!['nisn']),
                          buildNilaiRow('Nama', nilai!['nama_siswa']),
                          buildNilaiRow('Nilai IPA', nilai!['nilai_ipa']),
                          buildNilaiRow('Nilai MTK', nilai!['nilai_mtk']),
                          buildNilaiRow('Nilai B. Indo', nilai!['nilai_bindo']),
                          buildNilaiRow('Nilai B. Inggris', nilai!['nilai_bing']),
                          buildNilaiRow('Nilai Agama', nilai!['nilai_agama']),
                          buildNilaiRow('Nilai PKN', nilai!['nilai_pkn']),
                          buildNilaiRow('Nilai IPS', nilai!['nilai_ips']),
                          // Tambahkan field lain jika ada
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}