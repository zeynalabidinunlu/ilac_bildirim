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

  Future<void> closeDatabase() async {
    await _medicineService.close();
  }
  
}
