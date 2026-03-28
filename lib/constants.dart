class AppConstants {
  static const String baseUrl = 'https://fixcity.city/api';
  static const String publicUrl = 'https://fixcity.city';
  
  // Firebase
  static const String firebaseVapidKey = 
    'BKDsGY_wBB9fx9H9WFylfKIpnc8drsfBV_vPzhyIP7DzGZpA9dBaambXymeIGt3I22Bo17MN7tirndAR1K5I5F4';
  
  // Categories
  static const Map<String, Map<String, String>> categories = {
    'road':    {'label': 'حفرة طريق',       'icon': '🛣️'},
    'light':   {'label': 'انعدام الإنارة',   'icon': '💡'},
    'water':   {'label': 'تسرب المياه',      'icon': '🚰'},
    'garbage': {'label': 'تراكم نفايات',     'icon': '🗑️'},
    'animal':  {'label': 'مساعدة حيوانات',   'icon': '🐾'},
    'unknown': {'label': 'مشكلة غير محددة',  'icon': '📍'},
  };

  // Severities
  static const Map<String, String> severities = {
    'urgent': '🔴 عاجل',
    'medium': '🟡 متوسط',
    'simple': '🟢 بسيط',
  };

  // Status labels
  static const Map<String, String> statusLabels = {
    'new':      '🔴 جديد',
    'progress': '🟠 قيد المعالجة',
    'done':     '✅ محلول',
  };
}
