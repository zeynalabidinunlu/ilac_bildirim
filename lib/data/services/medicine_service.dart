import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/enum/UsageType.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/model/medicine.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/notification/service/notification_service.dart';

class MedicineService {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [MedicineSchema],
      directory: dir.path,
    );
  }

  Future<void> addMedicine(Medicine medicine) async {
    await isar.writeTxn(() async {
      await isar.medicines.put(medicine);
    });
    await NotificationService.scheduleMedicineNotifications(medicine);
  }

  Future<List<Medicine>> getMedicines() async {
    return isar.medicines.where().findAll();
  }

  Future<void> deleteMedicine(Medicine medicine) async {
    await NotificationService.cancelMedicineNotifications(medicine);

    await isar.writeTxn(() async {
      await isar.medicines.delete(medicine.id);
    });
  }

  Future<void> updateMedicine(Medicine medicine) async {
    await NotificationService.cancelMedicineNotifications(medicine);

    await isar.writeTxn(() async {
      await isar.medicines.put(medicine);
    });
    await NotificationService.scheduleMedicineNotifications(medicine);
  }

  Future<void> clearMedicines() async {
    await NotificationService.cancelAllNotifications();

    await isar.writeTxn(() async {
      await isar.medicines.clear();
    });
  }

  Future<void> close() async {
    await isar.close();
  }

  Future<bool> isDatabaseEmpty() async {
    final count = await isar.medicines.count();
    return count == 0;
  }

  Future<Medicine?> getMedicineById(Id id) async {
    return isar.medicines.get(id);
  }

  Future<List<Medicine>> getMedicinesByName(String name) async {
    return isar.medicines.filter().nameEqualTo(name).findAll();
  }

  Future<List<Medicine>> getMedicinesByUsageType(UsageType usageType) async {
    return isar.medicines.filter().usageTypeElementEqualTo(usageType).findAll();
  }
}
