class Report {
  final String id;
  final String category;
  final String severity;
  final String? description;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String status;
  final String deviceId;
  final int votes;
  final int views;
  final int confirmations;
  final int solvedConfirm;
  final double trustScore;
  final DateTime createdAt;
  final DateTime? respondedAt;

  Report({
    required this.id,
    required this.category,
    required this.severity,
    this.description,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    required this.status,
    required this.deviceId,
    required this.votes,
    required this.views,
    required this.confirmations,
    required this.solvedConfirm,
    required this.trustScore,
    required this.createdAt,
    this.respondedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      category: json['category'] ?? 'unknown',
      severity: json['severity'] ?? 'medium',
      description: json['description'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imageUrl: json['image_url'],
      status: json['status'] ?? 'new',
      deviceId: json['device_id'] ?? '',
      votes: json['votes'] ?? 0,
      views: json['views'] ?? 0,
      confirmations: json['confirmations'] ?? 0,
      solvedConfirm: json['solved_confirm'] ?? 0,
      trustScore: (json['trust_score'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      respondedAt: json['responded_at'] != null 
        ? DateTime.parse(json['responded_at']) 
        : null,
    );
  }

  String get categoryLabel {
    return {
      'road': 'حفرة طريق',
      'light': 'انعدام الإنارة',
      'water': 'تسرب المياه',
      'garbage': 'تراكم نفايات',
      'animal': 'مساعدة حيوانات',
      'unknown': 'مشكلة غير محددة',
    }[category] ?? category;
  }

  String get categoryIcon {
    return {
      'road': '🛣️',
      'light': '💡',
      'water': '🚰',
      'garbage': '🗑️',
      'animal': '🐾',
      'unknown': '📍',
    }[category] ?? '📍';
  }

  String get statusLabel {
    return {
      'new': 'جديد',
      'progress': 'قيد المعالجة',
      'done': 'تم الحل',
    }[status] ?? status;
  }
}
