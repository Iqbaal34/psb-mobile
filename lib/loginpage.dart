import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Dashboard.dart'; // pastikan file Dashboard.dart ada

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final TextEditingController nisnController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController ibuController = TextEditingController();

  String errorMessage = '';

  Future<void> loginUser() async {
    final nisn = nisnController.text.trim();
    final nama = namaController.text.trim();
    final ibu = ibuController.text.trim();

    if (nisn.isEmpty || nama.isEmpty || ibu.isEmpty) {
      setState(() => errorMessage = 'Semua kolom harus diisi!');
      return;
    }

    final url = Uri.parse('http://10.18.118.179/psb-api/login.php'); // ganti sesuai alamat server kamu
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nisn": nisn,
          "nama": nama,
          "ibu": ibu,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardSiswa(
              nisn: data['data']['nisn'].toString(), // <-- Perbaikan di sini
              nama: data['data']['nama'],
            ),
          ),
        );
      } else {
        setState(() => errorMessage = data['message']);
      }
    } catch (e) {
      setState(() => errorMessage = 'Gagal terhubung ke server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFF10345B),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 27),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(
                    'https://sman2tangsel.sch.id/web/images/logo-mzr-1570786241.png',
                    height: 120,
                    width: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error, color: Colors.red);
                    },
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "Penerimaan Peserta Didik\nSMAN 2 Tangerang Selatan",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form Login
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("NISN", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nisnController,
                    decoration: InputDecoration(
                      hintText: "Masukkan NISN",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("Nama Lengkap", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: namaController,
                    decoration: InputDecoration(
                      hintText: "Masukkan Nama Lengkap",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("Nama Ibu Kandung", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: ibuController,
                    decoration: InputDecoration(
                      hintText: "Masukkan Nama Ibu Kandung",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10345B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle( color: Colors.white ,fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
