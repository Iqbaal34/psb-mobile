// lib/register.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterFlowPage extends StatefulWidget {
  const RegisterFlowPage({super.key});

  @override
  State<RegisterFlowPage> createState() => _RegisterFlowPageState();
}

class _RegisterFlowPageState extends State<RegisterFlowPage> {
  final page = PageController();
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  // API
  static const String baseUrl = "http://10.18.118.179/psb-api"; // TODO: ganti
  Uri get insertUrl => Uri.parse("$baseUrl/insertregister.php");
  Uri get updateOrtuUrl => Uri.parse("$baseUrl/update_orangtua.php");
  Uri get cekUrl => Uri.parse("$baseUrl/cek_pendaftaran.php");
  // Step 1 controllers
  final nisC = TextEditingController();
  final namaC = TextEditingController();
  final telpC = TextEditingController();
  final alamatC = TextEditingController();
  final emailC = TextEditingController();
  final asalSekolahC = TextEditingController();
  String? gender; // 'Laki-Laki' | 'Perempuan'
  int? day, month, year;

  // Step 2 controllers
  final ibuC = TextEditingController();
  final telpIbuC = TextEditingController();

  bool loading1 = false;
  bool loading2 = false;
  int? siswaId; // dari insert step 1

  @override
  void dispose() {
    page.dispose();
    nisC.dispose();
    namaC.dispose();
    telpC.dispose();
    alamatC.dispose();
    emailC.dispose();
    asalSekolahC.dispose();
    ibuC.dispose();
    telpIbuC.dispose();
    super.dispose();
  }

  void snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _submitStep1() async {
    if (!_step1Key.currentState!.validate()) return;
    if (day == null || month == null || year == null) {
      snack('Tanggal lahir belum lengkap');
      return;
    }
    setState(() => loading1 = true);
    final tgl =
        "${year!.toString().padLeft(4, '0')}-"
        "${month!.toString().padLeft(2, '0')}-"
        "${day!.toString().padLeft(2, '0')}";

    try {
      final resp = await http.post(
        insertUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nisn": nisC.text.trim(), // <= ubah dari nis ke nisn
          "nama_siswa": namaC.text.trim(),
          "nomor_telepon": telpC.text.trim(),
          "alamat": alamatC.text.trim(),
          "tgl_lahir": tgl,
          "email": emailC.text.trim(),
          "asal_sekolah": asalSekolahC.text.trim(),
          "jenis_kelamin": gender,
        }),
      );

      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && data['success'] == true) {
        siswaId = data['id'];
        // animasi geser ke kanan (next page)
        await page.animateToPage(
          1,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOut,
        );
      } else {
        snack(data['message'] ?? 'Gagal menyimpan data');
      }
    } catch (_) {
      snack('Gagal terhubung ke server');
    } finally {
      if (mounted) setState(() => loading1 = false);
    }
  }

  Future<void> _submitStep2() async {
    if (siswaId == null) {
      snack('ID belum ada dari Step 1');
      return;
    }
    if (!_step2Key.currentState!.validate()) return;

    setState(() => loading2 = true);
    try {
      final resp = await http.post(
        updateOrtuUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "id": siswaId,
          "nama_ibu": ibuC.text.trim(),
          "nomor_telp_ibu": telpIbuC.text.trim(),
        }),
      );
      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && data['success'] == true) {
        snack('Pendaftaran berhasil dikirim');
        if (!mounted) return;
        Navigator.pop(context); // atau ke dashboard
      } else {
        snack(data['message'] ?? 'Gagal menyimpan Data Orang Tua');
      }
    } catch (_) {
      snack('Gagal terhubung ke server');
    } finally {
      if (mounted) setState(() => loading2 = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF1D3C5C);

    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: page,
          physics:
              const NeverScrollableScrollPhysics(), // pindah hanya via tombol
          children: [
            // STEP 1
            Column(
              children: [
                _Header(
                  title: 'Form Pendaftaran Peserta Didik',
                  subtitle: 'Langkah 1 dari 2 : Data Diri',
                  indicatorColor: blue,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _step1Key,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('NISN'),
                          TextFormField(
                            controller: nisC,
                            keyboardType: TextInputType.number,
                            validator:
                                (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Wajib diisi'
                                        : null,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan NISN',
                            ),
                          ),
                          const SizedBox(height: 14),
                          _label('Nama Lengkap'),
                          TextFormField(
                            controller: namaC,
                            validator:
                                (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Wajib diisi'
                                        : null,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan Nama Lengkap',
                            ),
                          ),
                          const SizedBox(height: 14),
                          _label('Nomor Telepon'),
                          TextFormField(
                            controller: telpC,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: 'Contoh : 085892327275',
                            ),
                          ),
                          const SizedBox(height: 14),
                          _label('Alamat'),
                          TextFormField(
                            controller: alamatC,
                            minLines: 2,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan Alamat',
                            ),
                          ),
                          const SizedBox(height: 14),
                          _label('Tanggal Lahir'),
                          Row(
                            children: [
                              Expanded(
                                child: _dropInt(
                                  'Tanggal',
                                  1,
                                  31,
                                  day,
                                  (v) => setState(() => day = v),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _dropInt(
                                  'Bulan',
                                  1,
                                  12,
                                  month,
                                  (v) => setState(() => month = v),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _dropYear(
                                  'Tahun',
                                  year,
                                  (v) => setState(() => year = v),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _label('email'),
                          TextFormField(
                            controller: emailC,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Wajib diisi';
                              final ok = RegExp(
                                r'^[^@]+@[^@]+\.[^@]+$',
                              ).hasMatch(v);
                              return ok ? null : 'Email tidak valid';
                            },
                            decoration: const InputDecoration(
                              hintText: 'Contoh : nama@email.com',
                            ),
                          ),
                          const SizedBox(height: 14),
                          _label('Asal Sekolah'),
                          TextFormField(
                            controller: asalSekolahC,
                            decoration: const InputDecoration(
                              hintText: 'Masukan Asal Sekolah',
                            ),
                          ),
                          const SizedBox(height: 14),
                          _label('Jenis Kelamin'),
                          DropdownButtonFormField<String>(
                            value: gender,
                            hint: const Text(
                              'Contoh : Laki - Laki / Perempuan',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Laki-Laki',
                                child: Text('Laki - Laki'),
                              ),
                              DropdownMenuItem(
                                value: 'Perempuan',
                                child: Text('Perempuan'),
                              ),
                            ],
                            onChanged: (v) => setState(() => gender = v),
                            validator:
                                (v) => v == null ? 'Pilih salah satu' : null,
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              onPressed: loading1 ? null : _submitStep1,
                              child:
                                  loading1
                                      ? const CircularProgressIndicator()
                                      : const Text(
                                        'Continue',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // STEP 2
            Column(
              children: [
                _Header(
                  title: 'Form Pendaftaran Peserta Didik',
                  subtitle: 'Langkah 2 dari 2 : Data Orang Tua',
                  indicatorColor: Colors.black54,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _step2Key,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Nama Ibu'),
                          TextFormField(
                            controller: ibuC,
                            validator:
                                (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Wajib diisi'
                                        : null,
                            decoration: const InputDecoration(
                              hintText: 'Masukan Nama Ibu',
                            ),
                          ),
                          const SizedBox(height: 14),
                          _label('Nomor Telepon Ibu'),
                          TextFormField(
                            controller: telpIbuC,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: 'Contoh : 085892327275',
                            ),
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              onPressed: loading2 ? null : _submitStep2,
                              child:
                                  loading2
                                      ? const CircularProgressIndicator()
                                      : const Text(
                                        'Submit',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // helpers UI
  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      t,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );

  Widget _dropInt(
    String hint,
    int start,
    int end,
    int? val,
    ValueChanged<int?> onChanged,
  ) {
    return DropdownButtonFormField<int>(
      value: val,
      hint: Text(hint),
      items:
          List.generate(
            end - start + 1,
            (i) => start + i,
          ).map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Pilih' : null,
    );
  }

  Widget _dropYear(String hint, int? val, ValueChanged<int?> onChanged) {
    final now = DateTime.now().year;
    final years = List.generate(50, (i) => now - i);
    return DropdownButtonFormField<int>(
      value: val,
      hint: Text(hint),
      items:
          years
              .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
              .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Pilih' : null,
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color indicatorColor;
  const _Header({
    required this.title,
    required this.subtitle,
    required this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // back icon
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        // logo + title
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEAF1F9),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.school_rounded, size: 40),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Container(
                height: 4,
                width: 110,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
