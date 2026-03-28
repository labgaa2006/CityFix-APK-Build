import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── شاشة الإشعارات ──────────────────────────────────────────
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🔔', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('ستصلك إشعارات عند تحديث بلاغاتك',
                style: TextStyle(fontSize: 15, color: Colors.grey)),
            SizedBox(height: 8),
            Text('أو عند وجود مشاكل تم الإبلاغ عنها قريباً منك',
                style: TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─── شاشة النقاط ────────────────────────────────────────────
class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  int _points = 0;
  int _reports = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _points = prefs.getInt('points') ?? 0;
      _reports = prefs.getInt('reports_count') ?? 0;
    });
  }

  Map<String, dynamic> get _level {
    if (_points >= 200) return {'name': '🌟 أسطورة', 'color': Colors.purple, 'next': null};
    if (_points >= 100) return {'name': '🏆 بطل', 'color': Colors.amber, 'next': 200};
    if (_points >= 60) return {'name': '🏙️ حارس المدينة', 'color': Colors.blue, 'next': 100};
    if (_points >= 30) return {'name': '🔍 محقق', 'color': Colors.teal, 'next': 60};
    if (_points >= 10) return {'name': '⭐ نشيط', 'color': Colors.orange, 'next': 30};
    return {'name': '🌱 مبتدئ', 'color': Colors.green, 'next': 10};
  }

  @override
  Widget build(BuildContext context) {
    final lv = _level;
    final nextPts = lv['next'] as int?;
    final progress = nextPts != null ? _points / nextPts : 1.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('نقاطي', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // بطاقة النقاط
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: (lv['color'] as Color).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(lv['name'] as String,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('$_points نقطة',
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: lv['color'] as Color)),
                    const SizedBox(height: 16),
                    if (nextPts != null) ...[
                      LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade200,
                        color: lv['color'] as Color,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Text('${nextPts - _points} نقطة للمستوى التالي',
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // إحصائيات
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: '📋',
                    label: 'بلاغات مرسلة',
                    value: _reports.toString(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: '⭐',
                    label: 'نقاط مكتسبة',
                    value: _points.toString(),
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // كيف تكسب نقاط
            const Align(
              alignment: Alignment.centerRight,
              child: Text('كيف تكسب نقاط؟',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const SizedBox(height: 10),
            _PointRow(icon: '📸', text: 'إرسال بلاغ مفصّل', points: '+15'),
            _PointRow(icon: '⚡', text: 'إرسال بلاغ سريع', points: '+15'),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _PointRow extends StatelessWidget {
  final String icon;
  final String text;
  final String points;

  const _PointRow({required this.icon, required this.text, required this.points});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(points,
                style: TextStyle(
                    color: Colors.green.shade700, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
