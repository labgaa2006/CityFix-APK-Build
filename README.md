# CityFix Flutter App

تطبيق Flutter لمنصة CityFix للإبلاغ عن مشاكل مدينة الأغواط.

## معلومات المشروع

- **API Base:** https://fixcity.city/api
- **المنصة العامة:** https://fixcity.city
- **GitHub Backend:** https://github.com/labgaa2006/CityFix

## متطلبات التطوير

```
Flutter SDK >= 3.0.0
Dart >= 3.0.0
Android Studio
JDK 17
```

## تثبيت المشروع

```bash
flutter pub get
flutter run
```

## بناء APK

```bash
flutter build apk --release
# الملف: build/app/outputs/flutter-apk/app-release.apk
```

## بناء AAB لـ Google Play

```bash
flutter build appbundle --release
# الملف: build/app/outputs/bundle/release/app-release.aab
```

## الشاشات

| الشاشة | الوصف |
|--------|-------|
| بلاغ جديد | إرسال بلاغ مفصّل أو سريع مع صورة + GPS |
| بلاغاتي | عرض البلاغات المرسلة من هذا الجهاز |
| الإشعارات | إشعارات Firebase FCM |
| النقاط | نظام الـ Gamification |

## إعداد Firebase

1. أنشئ ملف `google-services.json` من Firebase Console
2. ضعه في: `android/app/google-services.json`
3. معلومات Firebase:
   - Project ID: `cityfix-81b7c`
   - Sender ID: `823881406061`
   - App ID: `1:823881406061:web:375b9249f8f9f344385164`

## الأذونات المطلوبة

- **GPS:** ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION
- **الكاميرا:** CAMERA, READ_EXTERNAL_STORAGE
- **الإشعارات:** POST_NOTIFICATIONS
- **الإنترنت:** INTERNET

## Keystore للتوقيع

```
المسار: /root/cityfix-twa/android.keystore
كلمة المرور: CityFix2025
Package ID: cityfix.app
```

## API Headers المطلوبة

كل طلب يحتاج:
```
X-Device-ID: AND-XXXXXXXXX  (محفوظ في SharedPreferences)
```

## ملاحظات مهمة

- يتم توليد `device_id` تلقائياً عند أول تشغيل
- الحد اليومي: 30 بلاغ/جهاز
- النقاط محفوظة في SharedPreferences (+15 لكل بلاغ)
- الإشعارات تصل عند تغيير حالة بلاغاتك
