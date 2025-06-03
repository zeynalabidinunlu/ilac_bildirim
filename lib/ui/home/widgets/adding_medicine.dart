import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/enum/UsageType.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/model/medicine.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/ui/home/view_model/home_screen_view_model.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({Key? key}) : super(key: key);

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notificationTextController = TextEditingController();
  
  List<UsageType> _selectedUsageTypes = [];
  List<DateTime> _notificationTimes = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _notificationTextController.dispose();
    super.dispose();
  }

  void _addNotificationTime() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((TimeOfDay? time) {
      if (time != null) {
        final now = DateTime.now();
        final selectedDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        setState(() {
          _notificationTimes.add(selectedDateTime);
        });
      }
    });
  }

  void _removeNotificationTime(int index) {
    setState(() {
      _notificationTimes.removeAt(index);
    });
  }

  void _saveMedicine() async {
    if (_formKey.currentState!.validate()) {
      final medicine = Medicine()
        ..name = _nameController.text.trim()
        ..description = _descriptionController.text.trim()
        ..usageType = _selectedUsageTypes.isNotEmpty ? _selectedUsageTypes : null
        ..notificationText = _notificationTextController.text.trim()
        ..notificationTimes = _notificationTimes.isNotEmpty ? _notificationTimes : null;

      try {
        await context.read<HomeScreenViewModel>().addMedicine(medicine);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('İlaç başarıyla eklendi!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İlaç Ekle'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // İlaç Adı
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'İlaç Adı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'İlaç adı boş olamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Açıklama
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Kullanım Türleri
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kullanım Türleri',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        children: UsageType.values.map((usageType) {
                          final isSelected = _selectedUsageTypes.contains(usageType);
                          return FilterChip(
                            label: Text(usageType.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedUsageTypes.add(usageType);
                                } else {
                                  _selectedUsageTypes.remove(usageType);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bildirim Metni
              TextFormField(
                controller: _notificationTextController,
                decoration: const InputDecoration(
                  labelText: 'Bildirim Metni',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notifications),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Bildirim Zamanları
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bildirim Zamanları',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: _addNotificationTime,
                            icon: const Icon(Icons.add_alarm),
                            tooltip: 'Zaman Ekle',
                          ),
                        ],
                      ),
                      if (_notificationTimes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Henüz bildirim zamanı eklenmedi',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _notificationTimes.length,
                          itemBuilder: (context, index) {
                            final time = _notificationTimes[index];
                            return ListTile(
                              leading: const Icon(Icons.access_time),
                              title: Text(
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeNotificationTime(index),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Kaydet Butonu
              ElevatedButton(
                onPressed: _saveMedicine,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'İlacı Kaydet',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}