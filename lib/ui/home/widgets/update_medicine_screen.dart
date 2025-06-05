import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/enum/UsageType.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/model/medicine.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/ui/home/view_model/home_screen_view_model.dart';

class UpdateMedicineScreen extends StatefulWidget {
  final Medicine medicine;

  const UpdateMedicineScreen({Key? key, required this.medicine}) : super(key: key);

  @override
  State<UpdateMedicineScreen> createState() => _UpdateMedicineScreenState();
}

class _UpdateMedicineScreenState extends State<UpdateMedicineScreen> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _notificationTextController;
  late final TextEditingController _numberOfPillsController;

  late List<UsageType> _selectedUsageTypes;
  late List<DateTime> _notificationTimes;
  
  bool _isLoading = false;
  bool _hasChanges = false;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeControllers();
    _setupChangeListeners();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
    _animationController?.forward();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.medicine.name);
    _descriptionController = TextEditingController(text: widget.medicine.description);
    _notificationTextController = TextEditingController(text: widget.medicine.notificationText);
    _numberOfPillsController = TextEditingController(
      text: widget.medicine.numberOfPills?.toString() ?? '',
    );
    
    _selectedUsageTypes = widget.medicine.usageType?.toList() ?? [];
    _notificationTimes = widget.medicine.notificationTimes?.toList() ?? [];
  }

  void _setupChangeListeners() {
    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _notificationTextController.addListener(_onFieldChanged);
    _numberOfPillsController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _notificationTextController.dispose();
    _numberOfPillsController.dispose();
    super.dispose();
  }

  Future<void> _addNotificationTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      
      // Duplicate time check
      bool isDuplicate = _notificationTimes.any((existingTime) =>
          existingTime.hour == selectedDateTime.hour &&
          existingTime.minute == selectedDateTime.minute);
      
      if (isDuplicate) {
        _showErrorSnackBar('Bu saat zaten eklenmiş!');
        return;
      }

      setState(() {
        _notificationTimes.add(selectedDateTime);
        _notificationTimes.sort((a, b) => a.compareTo(b)); // Sort times
        _hasChanges = true;
      });

      // Show feedback
      HapticFeedback.lightImpact();
      _showSuccessSnackBar('Bildirim zamanı eklendi');
    }
  }

  void _removeNotificationTime(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final time = _notificationTimes[index];
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Zamanı Sil'),
            ],
          ),
          content: Text(
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} bildirim zamanını silmek istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _notificationTimes.removeAt(index);
                  _hasChanges = true;
                });
                HapticFeedback.lightImpact();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateMedicine() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Lütfen tüm gerekli alanları doldurun');
      return;
    }

    if (_notificationTimes.isEmpty) {
      _showErrorSnackBar('En az bir bildirim zamanı eklemelisiniz');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final updatedMedicine = Medicine()
      ..id = widget.medicine.id
      ..name = _nameController.text.trim()
      ..description = _descriptionController.text.trim()
      ..usageType = _selectedUsageTypes.isNotEmpty ? _selectedUsageTypes : null
      ..notificationText = _notificationTextController.text.trim()
      ..notificationTimes = _notificationTimes.isNotEmpty ? _notificationTimes : null
      ..numberOfPills = int.tryParse(_numberOfPillsController.text.trim()) ?? 0;

    try {
      await context.read<HomeScreenViewModel>().updateMedicine(updatedMedicine);

      if (mounted) {
        HapticFeedback.mediumImpact();
        _showSuccessSnackBar('İlaç başarıyla güncellendi!');
        
        // Delay to show success message
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        HapticFeedback.heavyImpact();
        _showErrorSnackBar('Güncelleme hatası: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Değişiklikler Kaydedilmedi'),
            ],
          ),
          content: const Text(
            'Yaptığınız değişiklikler kaybedilecek. Çıkmak istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Kalmaya Devam Et'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Çık'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Widget _buildAnimatedCard({
    required Widget child,
    required int index,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutBack,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: child,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'İlaç Düzenle',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            if (_hasChanges)
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: _isLoading ? null : _updateMedicine,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.save,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  tooltip: 'Kaydet',
                ),
              ),
          ],
        ),
        body: _fadeAnimation != null
            ? FadeTransition(
                opacity: _fadeAnimation!,
                child: _buildBody(),
              )
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Basic Info Section
            _buildAnimatedCard(
              index: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Temel Bilgiler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _nameController,
                      labelText: 'İlaç Adı *',
                      prefixIcon: Icons.medication,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'İlaç adı boş olamaz';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _numberOfPillsController,
                      labelText: 'Toplam Hap Sayısı *',
                      prefixIcon: Icons.local_pharmacy,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Toplam hap sayısı boş olamaz';
                        }
                        final number = int.tryParse(value);
                        if (number == null || number <= 0) {
                          return 'Lütfen geçerli bir sayı girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _descriptionController,
                      labelText: 'Açıklama',
                      prefixIcon: Icons.description,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Usage Types Section
            _buildAnimatedCard(
              index: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kullanım Türleri',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
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
                              _hasChanges = true;
                            });
                            HapticFeedback.selectionClick();
                          },
                          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                          checkmarkColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notification Section
            _buildAnimatedCard(
              index: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bildirim Ayarları',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextFormField(
                      controller: _notificationTextController,
                      labelText: 'Bildirim Metni',
                      prefixIcon: Icons.message,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notification Times Section
            _buildAnimatedCard(
              index: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Bildirim Zamanları *',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: _addNotificationTime,
                            icon: Icon(
                              Icons.add_alarm,
                              color: Theme.of(context).primaryColor,
                            ),
                            tooltip: 'Zaman Ekle',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_notificationTimes.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Henüz bildirim zamanı eklenmedi. En az bir zaman eklemelisiniz.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _notificationTimes.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final time = _notificationTimes[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.schedule,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                'Günlük bildirim ${index + 1}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _removeNotificationTime(index),
                                  tooltip: 'Zamanı Sil',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateMedicine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _hasChanges ? 4 : 2,
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Güncelleniyor...',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _hasChanges ? 'Değişiklikleri Kaydet' : 'Güncelle',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}