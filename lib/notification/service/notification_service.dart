// lib/services/notification/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/notification/service/tts_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:sesli_ilac_bildirim_uygulamasi/model/medicine.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Timezone verisini başlat
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul')); // Türkiye timezone

    // Android ayarları
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS ayarları
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Genel ayarlar
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Plugin'i başlat
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotification,
    );

    // Ön planda bildirim dinleyicisi
    _notifications
        .getNotificationAppLaunchDetails()
        .then((details) async {
      if (details != null && details.didNotificationLaunchApp) {
        final payload = details.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          await TTSService.speak(payload);
        }
      }
    });

    // TTS servisini başlat
    await TTSService.initialize();

    _isInitialized = true;
  }

  // Bildirime tıklandığında çalışacak fonksiyon
  static void _onNotificationTapped(NotificationResponse response) async {
    final payload = response.payload;
    
    if (payload != null && payload.isNotEmpty) {
      print('Notification payload: $payload');
      await TTSService.speak(payload);
      print('Bildirim Payload: $payload');
    }
  }

  // Arka planda bildirim işleme
  static void _onBackgroundNotification(NotificationResponse details) async {
    final payload = details.payload;
    if (payload != null && payload.isNotEmpty) {
      await TTSService.speak(payload);
    }
  }

  // Tek seferlik bildirim gönder
  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medicine_channel',
      'İlaç Bildirimleri',
      channelDescription: 'İlaç alma zamanı bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload ?? body,
    );

    // Bildirimi sesli oku - anlık bildirimde hemen oku
    await TTSService.speak(payload ?? body);
  }

  // Zamanlanmış bildirim ayarla
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicine_scheduled_channel',
      'Zamanlanmış İlaç Bildirimleri',
      channelDescription: 'Belirli saatlerde gönderilen ilaç bildirimleri',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true,
      onlyAlertOnce: false,
      category: AndroidNotificationCategory.alarm,
      autoCancel: false,
      ongoing: false, // true olursa bildirim sürekli durur, false yapıyoruz
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      payload: payload ?? body,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // İlaç için bildirim ayarla
  static Future<void> scheduleMedicineNotifications(Medicine medicine) async {
    if (medicine.notificationTimes == null || 
        medicine.notificationTimes!.isEmpty) {
      return;
    }

    final title = 'İlaç Zamanı!';
    final body = medicine.notificationText?.isNotEmpty == true
        ? medicine.notificationText!
        : '${medicine.name} alma zamanı geldi.';
    
    // Sesli okunacak metni güncelliyoruz
    final speechText = medicine.notificationText?.isNotEmpty == true
        ? '${medicine.name}  ${medicine.notificationText}'
        : '${medicine.name} alma zamanı geldi.';

    for (int i = 0; i < medicine.notificationTimes!.length; i++) {
      final notificationTime = medicine.notificationTimes![i];
      final notificationId = (medicine.id * 1000) + i;

      DateTime scheduledDateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        notificationTime.hour,
        notificationTime.minute,
      );

      if (scheduledDateTime.isBefore(DateTime.now())) {
        scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
      }

      // Özel ilaç bildirimi fonksiyonu kullan
      await _scheduleMedicineNotificationWithTTS(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDateTime,
        speechText: speechText,
      );
    }
  }

  // İlaç bildirimi için özel fonksiyon (TTS ile)
  static Future<void> _scheduleMedicineNotificationWithTTS({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String speechText,
  }) async {
    if (!_isInitialized) await initialize();

    // Özel Android ayarları - ses çıkarma için
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicine_tts_channel',
      'Sesli İlaç Bildirimleri',
      channelDescription: 'Sesli okunan ilaç bildirimleri',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true,
      onlyAlertOnce: false,
      category: AndroidNotificationCategory.alarm,
      autoCancel: true,
      // Bildirim geldiğinde otomatik TTS için ekstra ayarlar
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'speak_action',
          'Sesli Oku',
          showsUserInterface: false,
        ),
      ],
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      payload: speechText,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Bildirim zamanı geldiğinde TTS çalıştırmak için timer ayarla
    _scheduleAutoTTS(scheduledDate, speechText);
  }

  // Otomatik TTS için timer ayarla
  static void _scheduleAutoTTS(DateTime scheduledDate, String speechText) {
    final duration = scheduledDate.difference(DateTime.now());
    
    if (duration.inSeconds > 0) {
      Future.delayed(duration, () async {
        print('Otomatik TTS çalışıyor: $speechText');
        await TTSService.speak(speechText);
      });
    }
  }

  // Günlük tekrar eden bildirim ayarla
  static Future<void> scheduleRepeatingDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_daily_channel',
          'Günlük İlaç Bildirimleri',
          channelDescription: 'Her gün tekrar eden ilaç bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload ?? body,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Sonraki zaman dilimini hesapla
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // Belirli bildirimi iptal et
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // İlaç bildirimlerini iptal et
  static Future<void> cancelMedicineNotifications(Medicine medicine) async {
    if (medicine.notificationTimes == null || 
        medicine.notificationTimes!.isEmpty) {
      return;
    }

    for (int i = 0; i < medicine.notificationTimes!.length; i++) {
      final notificationId = (medicine.id * 1000) + i;
      await cancelNotification(notificationId);
    }
  }

  // Tüm bildirimleri iptal et
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Bekleyen bildirimleri listele
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Test bildirimi gönder
  static Future<void> sendTestNotification() async {
    await showInstantNotification(
      id: 999999,
      title: 'Test Bildirimi',
      body: 'Bu bir test bildirimidir. Sesli bildirim çalışıyor mu?',
    );
  }
}