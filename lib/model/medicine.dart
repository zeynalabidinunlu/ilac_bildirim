import 'package:isar/isar.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/enum/UsageType.dart';

part 'medicine.g.dart';

@collection
class Medicine {
  Id id = Isar.autoIncrement;

  String? name;

  String? description;

  @Enumerated(EnumType.name)
  List<UsageType>? usageType;

  String? notificationText;

  List<DateTime>? notificationTimes;

  int? numberOfPills;

  bool? isActive;

  DateTime? endDate;

  DateTime? startDate;
}
