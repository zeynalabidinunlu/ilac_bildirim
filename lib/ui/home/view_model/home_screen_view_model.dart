import 'package:flutter/material.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/data/services/medicine_service.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/enum/UsageType.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/model/medicine.dart';

class HomeScreenViewModel extends ChangeNotifier {
  final MedicineService _medicineService;

  HomeScreenViewModel(this._medicineService);

  Future<void> addMedicine(Medicine medicine) async {
    await _medicineService.addMedicine(medicine);
    notifyListeners();
  }

  Future<List<Medicine>> getMedicines() async {
    return await _medicineService.getMedicines();
  }

  Future<void> deleteMedicine(Medicine medicine) async {
    await _medicineService.deleteMedicine(medicine);
    notifyListeners();
  }

  Future<void> updateMedicine(Medicine medicine) async {
    await _medicineService.updateMedicine(medicine);
    notifyListeners();
  }

  Future<void> clearMedicines() async {
    await _medicineService.clearMedicines();
    notifyListeners();
  }

  Future<Medicine?> getMedicineById(int id) async {
    return await _medicineService.getMedicineById(id);
  }

  Future<List<Medicine>> getMedicinesByName(String name) async {
    return await _medicineService.getMedicinesByName(name);
  }

  Future<List<Medicine>> getMedicinesByUsageType(UsageType usageType) async {
    return await _medicineService.getMedicinesByUsageType(usageType);
  }

  Future<bool> isDatabaseEmpty() async {
    return await _medicineService.isDatabaseEmpty();
  }

  Future<DateTime?> calculateOfMedicineEndDate(Medicine medicine) async {
    if (medicine.endDate != null) {
      return medicine.endDate;
    } else if (medicine.startDate != null && medicine.numberOfPills != null) {
      return medicine.startDate!.add(Duration(days: medicine.numberOfPills!));
    }
    return null;
  }

  Future<void> closeDatabase() async {
    await _medicineService.close();
  }

  String calculateEndDate(Medicine medicine) {
    // Geçersiz veri kontrolü
    if (medicine.numberOfPills == null ||
        medicine.numberOfPills! <= 0 ||
        medicine.notificationTimes == null ||
        medicine.notificationTimes!.isEmpty) {
      return 'Bilinmiyor';
    }

    // Günlük kaç kez ilaç içiliyor
    final int dailyUsage = medicine.usageType!.length;

    // Kaç gün yeteceği hesaplanır
    final int remainingDays = medicine.numberOfPills! ~/ dailyUsage;

    // Bitiş tarihi hesaplanır
    final DateTime endDate = DateTime.now().add(Duration(days: remainingDays));

    // Kalan gün sayısına göre kullanıcıya bilgi verilir
    if (remainingDays < 7) {
      return '$remainingDays gün kaldı';
    } else if (remainingDays < 30) {
      final int weeks = remainingDays ~/ 7;
      return '$weeks hafta kaldı';
    } else {
      return '${endDate.day}.${endDate.month}.${endDate.year} tarihinde bitecek';
    }
  }

  bool isRunningLow(Medicine medicine) {
    if (medicine.numberOfPills! <= 0 ||
        medicine.notificationTimes == null ||
        medicine.notificationTimes!.isEmpty) {
      return true;
    }

    final dailyUsage = medicine.notificationTimes!.length;
    final remainingDays = medicine.numberOfPills! ~/ dailyUsage;

    // 7 günden az kaldıysa uyarı göster
    return remainingDays < 7;
  }
}
