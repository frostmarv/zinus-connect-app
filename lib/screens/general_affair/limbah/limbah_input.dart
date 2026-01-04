// lib/screens/general_affair/limbah/limbah_input.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zinus_connect/widgets/camera/app_camera_page.dart';
import 'package:zinus_connect/widgets/camera/camera_config.dart';

class LimbahInputScreen extends StatefulWidget {
  const LimbahInputScreen({super.key});

  @override
  State<LimbahInputScreen> createState() => _LimbahInputScreenState();
}

class _LimbahInputScreenState extends State<LimbahInputScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nopolController = TextEditingController();
  final _netController = TextEditingController();
  final _unitController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // === DATA ===
  final DateTime _timestamp = DateTime.now();
  String? _selectedJenisMobil;
  String? _selectedVendor;
  String? _selectedJenisLimbah;

  // === IMAGE UPLOAD ===
  final List<File> _fotoMobilImages = [];
  final List<File> _fotoBeratKosongImages = [];
  static const int _maxImages = 5;

  // === LOADING & SUBMIT ===
  bool _isSubmitting = false;

  // === OPTIONS ===
  final List<String> _jenisMobilOptions = [
    'Truck Box',
    'Pickup',
    'Container',
    'Dump Truck',
    'Lainnya',
  ];

  final List<Map<String, String>> _vendorOptions = [
    {'value': 'PT. ABC', 'label': 'PT. ABC'},
    {'value': 'PT. DKI', 'label': 'PT. DKI'},
  ];

  final List<Map<String, String>> _jenisLimbahOptions = [
    {'value': 'Scrap', 'label': 'Scrap'},
    {'value': 'Slice Foam', 'label': 'Slice Foam'},
    {'value': 'Balok', 'label': 'Balok'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nopolController.dispose();
    _netController.dispose();
    _unitController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // === CAMERA HANDLING ===
  Future<void> _openCamera({
    required List<File> targetList,
    required String code,
  }) async {
    if (targetList.length >= _maxImages) {
      _showError('Maksimal $_maxImages foto');
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppCameraPage(
          watermarkConfig: CameraWatermarkConfig(
            title: "ZINUS CONNECT",
            code: code,
            showTimestamp: true,
          ),
          onCapture: (file) {
            if (mounted) {
              setState(() {
                targetList.add(file);
              });
            }
          },
        ),
      ),
    );

    // Optional: handle if user cancels camera without capture
  }

  // === SUBMIT ===
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) return;

    if (_selectedVendor == null || _selectedJenisLimbah == null) {
      _showError('Lengkapi semua field wajib');
      return;
    }

    final nopol = _nopolController.text.trim();
    final net = _netController.text.trim();
    final unit = _unitController.text.trim();

    if (nopol.isEmpty || net.isEmpty || unit.isEmpty) {
      _showError('Field NOPOL, Net, dan Unit wajib diisi');
      return;
    }

    final netValue = double.tryParse(net);
    if (netValue == null || netValue <= 0) {
      _showError('Net harus berupa angka > 0');
      return;
    }

    if (mounted) setState(() => _isSubmitting = true);

    try {
      // ✅ Simulasi submit — ganti dengan API call sesuai kebutuhan
      await Future.delayed(const Duration(milliseconds: 800));

      // Kirim data ke backend (contoh terkomentar)
      // final response = await LimbahRepository.submit({ ... });

      if (mounted) {
        _showSuccess('Data limbah berhasil disimpan!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showError('Gagal menyimpan data: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // === UI HELPERS ===
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF1D4ED8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // === WIDGET: CAMERA PICKER ===
  Widget _buildCameraPicker({
    required String label,
    required List<File> imageList,
    required String code,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...imageList.asMap().entries.map((entry) {
              final index = entry.key;
              final image = entry.value;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () {
                        if (mounted) {
                          setState(() {
                            imageList.removeAt(index);
                          });
                        }
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            if (imageList.length < _maxImages)
              GestureDetector(
                onTap: () => _openCamera(targetList: imageList, code: code),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF2563EB),
                    size: 32,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // === WIDGET: TEXT FIELD ===
  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    bool isReadOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          enabled: enabled,
          readOnly: isReadOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFDC2626),
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 20,
            ),
          ),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
          keyboardType: keyboardType,
          validator: validator,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // === WIDGET: DROPDOWN ===
  Widget _buildLabeledDropdown({
    required String label,
    String? value,
    required List<Map<String, String>> options,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: enabled ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withAlpha(20),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              isDense: true,
            ),
            initialValue: value,
            items: options.map((opt) {
              return DropdownMenuItem(
                value: opt['value'],
                child: Text(
                  opt['label']!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
              );
            }).toList(),
            onChanged: enabled ? onChanged : null,
            isExpanded: true,
            dropdownColor: Colors.white,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: enabled ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
              size: 28,
            ),
            hint: Text(
              enabled ? 'Pilih...' : '-',
              style: TextStyle(
                color: enabled ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1),
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Input Data Limbah',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
            color: Color(0xFF1D4ED8),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2563EB).withAlpha(25),
                  const Color(0xFF2563EB).withAlpha(77),
                  const Color(0xFF2563EB).withAlpha(25),
                ],
              ),
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timestamp
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 10),
                      child: Text(
                        'Timestamp',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                          fontSize: 15,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: const [0.0, 1.0],
                          colors: [
                            const Color(0xFF2563EB).withAlpha(20),
                            const Color(0xFF1D4ED8).withAlpha(20),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF2563EB).withAlpha(51),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withAlpha(38),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withAlpha(38),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.access_time_rounded,
                              color: Color(0xFF2563EB),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm:ss').format(_timestamp),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildLabeledTextField(
                  label: 'NOPOL',
                  controller: _nopolController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Wajib diisi';
                    }
                    return null;
                  },
                ),

                _buildCameraPicker(
                  label: 'Foto Berat Kosong',
                  imageList: _fotoBeratKosongImages,
                  code: 'GA-LIMBAH-BERAT',
                ),

                _buildLabeledTextField(
                  label: 'Net',
                  controller: _netController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Wajib diisi';
                    }
                    final num = double.tryParse(value.trim());
                    if (num == null || num <= 0) return 'Net harus > 0';
                    return null;
                  },
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),

                _buildLabeledTextField(
                  label: 'Unit',
                  controller: _unitController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Wajib diisi';
                    }
                    return null;
                  },
                ),

                _buildLabeledDropdown(
                  label: 'Jenis Mobil',
                  value: _selectedJenisMobil,
                  options: _jenisMobilOptions
                      .map((item) => {'value': item, 'label': item})
                      .toList(),
                  onChanged: (val) => setState(() => _selectedJenisMobil = val),
                ),

                _buildCameraPicker(
                  label: 'Foto Mobil',
                  imageList: _fotoMobilImages,
                  code: 'GA-LIMBAH-MOBIL',
                ),

                _buildLabeledDropdown(
                  label: 'Vendor',
                  value: _selectedVendor,
                  options: _vendorOptions,
                  onChanged: (val) => setState(() => _selectedVendor = val),
                ),

                _buildLabeledDropdown(
                  label: 'Jenis Limbah',
                  value: _selectedJenisLimbah,
                  options: _jenisLimbahOptions,
                  onChanged: (val) => setState(() => _selectedJenisLimbah = val),
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitForm,
                    icon: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save_rounded, size: 20),
                    label: Text(
                      _isSubmitting ? 'Menyimpan...' : 'Simpan Data Limbah',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSubmitting
                          ? const Color(0xFF1D4ED8).withAlpha(178)
                          : const Color(0xFF1D4ED8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: const Color(0xFF2563EB).withAlpha(102),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}