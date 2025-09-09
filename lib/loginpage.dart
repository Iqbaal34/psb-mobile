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

    final url = Uri.parse('http://192.168.0.213/psb-api/login.php');
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
              nisn: data['data']['nisn'].toString(),
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF10345B),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSQBwuddBfDYzFHfvCjSk2dHhn1KL_weVdxIA&s',
                      height: 80,
                      width: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error, color: Colors.red, size: 50),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "PSB SMAN Harvard Tangerang Selatan",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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
                  buildTextField("NISN", nisnController, "Masukkan NISN"),
                  const SizedBox(height: 20),

                  buildTextField("Nama Lengkap", namaController, "Masukkan Nama Lengkap"),
                  const SizedBox(height: 20),

                  buildTextField("Nama Ibu Kandung", ibuController, "Masukkan Nama Ibu Kandung"),
                  const SizedBox(height: 30),

                  // Tombol Login
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10345B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Error message
                  if (errorMessage.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi builder untuk textfield biar rapi
  Widget buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
