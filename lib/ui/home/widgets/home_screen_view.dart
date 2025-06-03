import 'package:flutter/material.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/notification/service/notification_service.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/ui/home/view_model/home_screen_view_model.dart';
import 'package:provider/provider.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/ui/home/widgets/adding_medicine.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/model/medicine.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {
  List<Medicine> medicines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    setState(() {
      isLoading = true;
    });

    try {
      final viewModel = context.read<HomeScreenViewModel>();
      final loadedMedicines = await viewModel.getMedicines();
      
      setState(() {
        medicines = loadedMedicines;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İlaçlar yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteMedicine(Medicine medicine) async {
    try {
      final viewModel = context.read<HomeScreenViewModel>();
      await viewModel.deleteMedicine(medicine);
      
      // Liste yeniden yükle
      await _loadMedicines();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İlaç başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İlaç silinirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesli İlaç Bildirim Uygulaması'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: 'Test Bildirimi',
            onPressed: () {
              NotificationService.sendTestNotification();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'İlaç Ekle',
            onPressed: () async {
              final result = await Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => const AddMedicineScreen(),
                ),
              );
              
              // İlaç ekleme sayfasından dönüldüğünde listeyi yenile
              if (result == true || result == null) {
                _loadMedicines();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMedicines,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : medicines.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Henüz ilaç eklenmemiş',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Sağ üstteki + butonuna tıklayarak ilaç ekleyebilirsiniz',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: medicines.length,
                    padding: const EdgeInsets.all(8.0),
                    itemBuilder: (context, index) {
                      final medicine = medicines[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              (medicine.name?.isNotEmpty == true) 
                                  ? medicine.name!.substring(0, 1).toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            medicine.name ?? 'İsimsiz İlaç',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (medicine.description?.isNotEmpty == true)
                                Text(
                                  medicine.description!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (medicine.usageType?.isNotEmpty == true)
                                Text(
                                  'Kullanım: ${medicine.usageType!.map((e) => e.name).join(", ")}',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              if (medicine.notificationTimes?.isNotEmpty == true)
                                Text(
                                  'Bildirimler: ${medicine.notificationTimes!.length} zaman',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'İlacı Sil',
                            onPressed: () {
                              // Silme onayı dialog'u
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('İlacı Sil'),
                                    content: Text(
                                      '${medicine.name ?? "Bu ilaç"} silinsin mi?',
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('İptal'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text(
                                          'Sil',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _deleteMedicine(medicine);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}