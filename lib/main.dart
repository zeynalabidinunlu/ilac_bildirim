import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/data/services/medicine_service.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/notification/service/notification_service.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/notification/service/permission_service.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/ui/home/view_model/home_screen_view_model.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/ui/home/widgets/home_screen_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MedicineService.init();
  await NotificationService.initialize();
  await PermissionService.checkAllPermissions();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => MedicineService()),
        ChangeNotifierProvider(
          create: (context) =>
              HomeScreenViewModel(context.read<MedicineService>()),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: HomeScreenView(),
        ),
      ),
    );
  }
}
