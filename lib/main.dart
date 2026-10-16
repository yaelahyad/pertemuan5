import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pencatatan Stok Barang',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const StokBarangPage(),
    );
  }
}

class StokBarangPage extends StatefulWidget {
  const StokBarangPage({super.key});

  @override
  State<StokBarangPage> createState() => _StokBarangPageState();
}

class _StokBarangPageState extends State<StokBarangPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _tglMasukController = TextEditingController();
  final _tglKeluarController = TextEditingController();
  final _kodeController = TextEditingController();
  final _stokController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _tglMasukController.dispose();
    _tglKeluarController.dispose();
    _kodeController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Future<void> _simpanBarang() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      int kodeBarang = int.parse(_kodeController.text.trim());
      int jumlahStok = int.parse(_stokController.text.trim());

      await FirebaseFirestore.instance.collection('stok_barang').add({
        'nama_barang': _namaController.text.trim(),
        'tanggal_masuk': _tglMasukController.text.trim(),
        'tanggal_keluar': _tglKeluarController.text.trim(),
        'kode_barang': kodeBarang,
        'jumlah_stok': jumlahStok,
        'waktu': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil menyimpan data barang!'),
          backgroundColor: Colors.green,
        ),
      );

      _namaController.clear();
      _tglMasukController.clear();
      _tglKeluarController.clear();
      _kodeController.clear();
      _stokController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Stok Barang'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. Nama Barang (Inisial Nama Depan: 'T')
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Barang (Awali Inisial "T")',
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: T-Laptop Dell',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama Barang wajib diisi';
                  }
                  if (!value.trim().toUpperCase().startsWith('T')) {
                    return 'Nama Barang harus diawali inisial nama depan "T"';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // 2. Tanggal Masuk
              TextFormField(
                controller: _tglMasukController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Masuk Barang (DD/MM/YYYY)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tanggal Masuk wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // 3. Tanggal Keluar
              TextFormField(
                controller: _tglKeluarController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Keluar Barang (DD/MM/YYYY)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tanggal Keluar wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // 4. Kode Barang (Min 6 angka & Akhiran NIM 139)
              TextFormField(
                controller: _kodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kode Barang (Min 6 digit, akhiran 139)',
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: 100139',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kode Barang wajib diisi';
                  }
                  final input = value.trim();
                  if (int.tryParse(input) == null) {
                    return 'Kode Barang harus berupa angka bulat';
                  }
                  if (input.length < 6) {
                    return 'Kode Barang minimal harus 6 angka';
                  }
                  if (!input.endsWith('139')) {
                    return 'Kode Barang harus diakhiri 3 angka NIM (139)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // 5. Jumlah Stok
              TextFormField(
                controller: _stokController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Stok',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Jumlah Stok wajib diisi';
                  }
                  final stok = int.tryParse(value.trim());
                  if (stok == null) {
                    return 'Jumlah Stok harus berupa angka';
                  }
                  if (stok < 0) {
                    return 'Jumlah Stok tidak boleh negatif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _simpanBarang,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Simpan Barang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}