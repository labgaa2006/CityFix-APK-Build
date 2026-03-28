import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../constants.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  File? _image;
  String _selectedCategory = '';
  String _selectedSeverity = 'medium';
  Position? _position;
  bool _loadingGPS = false;
  bool _sending = false;
  final _descController = TextEditingController();
  bool _isQuickMode = false;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _getLocation() async {
    setState(() => _loadingGPS = true);
    final pos = await LocationService.getCurrentLocation();
    setState(() {
      _position = pos;
      _loadingGPS = false;
    });
    if (pos == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذّر تحديد الموقع — تأكد من تفعيل GPS'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (_image == null) {
      _showError('يرجى إضافة صورة');
      return;
    }
    if (!_isQuickMode && _selectedCategory.isEmpty) {
      _showError('يرجى اختيار نوع المشكلة');
      return;
    }
    if (_position == null) {
      _showError('يرجى تحديد الموقع');
      return;
    }

    setState(() => _sending = true);

    try {
      final report = await ApiService.submitReport(
        image: _image!,
        category: _isQuickMode ? 'unknown' : _selectedCategory,
        severity: _isQuickMode ? 'medium' : _selectedSeverity,
        latitude: _position!.latitude,
        longitude: _position!.longitude,
        description: _descController.text.isNotEmpty
            ? _descController.text
            : null,
      );

      if (mounted) {
        _showSuccess();
        _reset();
      }
    } catch (e) {
      if (mounted) _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _reset() {
    setState(() {
      _image = null;
      _selectedCategory = '';
      _selectedSeverity = 'medium';
      _position = null;
    });
    _descController.clear();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('✅ تم إرسال البلاغ'),
        content: const Text('شكراً لمساهمتك في تحسين مدينتنا!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CityFix', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _isQuickMode = !_isQuickMode),
            icon: Icon(_isQuickMode ? Icons.tune : Icons.flash_on),
            label: Text(_isQuickMode ? 'مفصّل' : 'سريع'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // عنوان النوع
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: _isQuickMode
                    ? Colors.orange.shade50
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(_isQuickMode ? Icons.flash_on : Icons.assignment,
                      color: _isQuickMode ? Colors.orange : Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    _isQuickMode ? 'تبليغ سريع' : 'تبليغ مفصّل',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isQuickMode ? Colors.orange.shade800 : Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // الصورة
            GestureDetector(
              onTap: () => _showImagePicker(),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _image != null ? Colors.green : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('اضغط لالتقاط صورة',
                              style: TextStyle(color: Colors.grey)),
                          Text('* الصورة إجبارية',
                              style: TextStyle(color: Colors.red, fontSize: 12)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // الفئات (للبلاغ المفصّل فقط)
            if (!_isQuickMode) ...[
              const Text('نوع المشكلة *',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.categories.entries
                    .where((e) => e.key != 'unknown')
                    .map((e) => _CategoryChip(
                          icon: e.value['icon']!,
                          label: e.value['label']!,
                          selected: _selectedCategory == e.key,
                          onTap: () =>
                              setState(() => _selectedCategory = e.key),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),

              // الخطورة
              const Text('مستوى الخطورة',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: AppConstants.severities.entries.map((e) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(e.value, style: const TextStyle(fontSize: 12)),
                        selected: _selectedSeverity == e.key,
                        onSelected: (_) =>
                            setState(() => _selectedSeverity = e.key),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // الوصف
              TextField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'وصف المشكلة (اختياري)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
                maxLength: 200,
              ),
              const SizedBox(height: 16),
            ],

            // GPS
            OutlinedButton.icon(
              onPressed: _loadingGPS ? null : _getLocation,
              icon: _loadingGPS
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _position != null ? Icons.location_on : Icons.my_location,
                      color: _position != null ? Colors.green : null,
                    ),
              label: Text(
                _position != null
                    ? '${_position!.latitude.toStringAsFixed(4)}°N ${_position!.longitude.toStringAsFixed(4)}°E'
                    : 'تحديد الموقع',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _position != null ? Colors.green : null,
                side: BorderSide(
                  color: _position != null ? Colors.green : Colors.grey,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            // زر الإرسال
            ElevatedButton.icon(
              onPressed: _sending ? null : _submit,
              icon: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
              label: Text(_sending ? 'جارٍ الإرسال...' : '🚨 إرسال البلاغ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1650E8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('اختيار من المعرض'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
