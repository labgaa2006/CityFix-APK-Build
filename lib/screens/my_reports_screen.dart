import 'package:flutter/material.dart';
import '../models/report.dart';
import '../services/api_service.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  List<Report> _reports = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final reports = await ApiService.getMyReports();
      setState(() { _reports = reports; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Color _statusColor(String status) {
    return {'new': Colors.red, 'progress': Colors.orange, 'done': Colors.green}[status] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بلاغاتي', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
                  ],
                ))
              : _reports.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('📋', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 12),
                          Text('لم ترسل أي بلاغ بعد',
                              style: TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _reports.length,
                        itemBuilder: (ctx, i) => _ReportCard(report: _reports[i]),
                      ),
                    ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  const _ReportCard({required this.report});

  Color get _statusColor {
    return {'new': Colors.red, 'progress': Colors.orange, 'done': Colors.green}[report.status] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // صورة أو أيقونة
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: report.imageUrl != null
                  ? Image.network(report.imageUrl!,
                      width: 70, height: 70, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _iconPlaceholder())
                  : _iconPlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(report.categoryIcon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(report.categoryLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(report.statusLabel,
                            style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  if (report.description != null) ...[
                    const SizedBox(height: 4),
                    Text(report.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 2),
                      Text('${report.latitude.toStringAsFixed(3)}°N',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                      const SizedBox(width: 8),
                      Icon(Icons.thumb_up_outlined, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 2),
                      Text('${report.votes}',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconPlaceholder() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey.shade100,
      child: Center(child: Text(report.categoryIcon, style: const TextStyle(fontSize: 28))),
    );
  }
}
