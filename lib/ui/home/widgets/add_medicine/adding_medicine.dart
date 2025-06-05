import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/enum/UsageType.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/model/medicine.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/ui/home/view_model/home_screen_view_model.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notificationTextController = TextEditingController();
  final _numberOfPillsController = TextEditingController();

  List<UsageType> _selectedUsageTypes = [];
  List<TimeOfDay> _notificationTimes = [];
  bool _isSubmitting = false;
  int _currentStep = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form validation states
  bool _isNameValid = false;
  bool _isPillCountValid = false;
  bool _hasNotificationTimes = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Add listeners for real-time validation
    _nameController.addListener(_validateName);
    _numberOfPillsController.addListener(_validatePillCount);
  }

  void _validateName() {
    final isValid = _nameController.text.trim().length >= 2;
    if (_isNameValid != isValid) {
      setState(() => _isNameValid = isValid);
    }
  }

  void _validatePillCount() {
    final text = _numberOfPillsController.text.trim();
    final number = int.tryParse(text);
    final isValid = number != null && number > 0;
    if (_isPillCountValid != isValid) {
      setState(() => _isPillCountValid = isValid);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _notificationTextController.dispose();
    _numberOfPillsController.dispose();
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool get _canProceedToNextStep {
    switch (_currentStep) {
      case 0:
        return _isNameValid && _isPillCountValid;
      case 1:
        return true; // Usage types are optional
      case 2:
        return _hasNotificationTimes;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < 2 && _canProceedToNextStep) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _addNotificationTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Hatırlatma zamanını seçin',
      cancelText: 'İptal',
      confirmText: 'Seç',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Colors.white,
                ),
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              hourMinuteTextStyle: Theme.of(context).textTheme.headlineMedium,
              dayPeriodTextStyle: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      if (_notificationTimes.contains(time)) {
        _showSnackBar(
          'Bu zaman zaten eklenmiş',
          isError: true,
          icon: Icons.warning_amber_rounded,
        );
        return;
      }

      setState(() {
        _notificationTimes.add(time);
        _notificationTimes.sort((a, b) {
          final aInMinutes = a.hour * 60 + a.minute;
          final bInMinutes = b.hour * 60 + b.minute;
          return aInMinutes.compareTo(bInMinutes);
        });
        _hasNotificationTimes = _notificationTimes.isNotEmpty;
      });

      HapticFeedback.selectionClick();
      _showSnackBar(
        'Hatırlatma zamanı eklendi',
        icon: Icons.access_time,
      );
    }
  }

  void _removeNotificationTime(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _notificationTimes.removeAt(index);
      _hasNotificationTimes = _notificationTimes.isNotEmpty;
    });

    _showSnackBar(
      'Hatırlatma zamanı kaldırıldı',
      icon: Icons.delete_outline,
    );
  }

  void _showSnackBar(String message, {bool isError = false, IconData? icon}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        duration: Duration(seconds: isError ? 3 : 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasNotificationTimes) {
      _showSnackBar(
        'En az bir hatırlatma zamanı eklemelisiniz',
        isError: true,
        icon: Icons.error_outline,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      final now = DateTime.now();
      final notificationTimes = _notificationTimes
          .map((time) => DateTime(
                now.year,
                now.month,
                now.day,
                time.hour,
                time.minute,
              ))
          .toList();

      final medicine = Medicine()
        ..name = _nameController.text.trim()
        ..description = _descriptionController.text.trim()
        ..usageType =
            _selectedUsageTypes.isNotEmpty ? _selectedUsageTypes : null
        ..notificationText = _notificationTextController.text.trim().isEmpty
            ? '${_nameController.text.trim()} alma zamanınız!'
            : _notificationTextController.text.trim()
        ..notificationTimes = notificationTimes
        ..numberOfPills = int.parse(_numberOfPillsController.text.trim());

      await context.read<HomeScreenViewModel>().addMedicine(medicine);

      if (!mounted) return;

      HapticFeedback.heavyImpact();
      Navigator.of(context).pop(true);

      _showSnackBar(
        'İlaç başarıyla eklendi! 🎉',
        icon: Icons.check_circle,
      );
    } catch (e) {
      if (!mounted) return;

      HapticFeedback.heavyImpact();
      _showSnackBar(
        'İlaç eklenirken bir hata oluştu: ${e.toString()}',
        isError: true,
        icon: Icons.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Yeni İlaç Ekle'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: _showHelpDialog,
            tooltip: 'Yardım',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(),

            // Form Content
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildBasicInfoStep(),
                    _buildUsageTypeStep(),
                    _buildNotificationStep(),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            children: List.generate(3, (index) {
              final isActive = index <= _currentStep;
              final isCompleted = index < _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: isActive
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.3),
                        ),
                      ),
                    ),
                    if (index < 2) const SizedBox(width: 8),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepLabel('Temel Bilgiler', 0),
              _buildStepLabel('Kullanım Türü', 1),
              _buildStepLabel('Hatırlatmalar', 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel(String label, int step) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive || isCompleted
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  'İlaç Bilgileri',
                  'İlacınızın temel bilgilerini girin',
                  Icons.medication_rounded,
                ),
                const SizedBox(height: 24),
                _buildAnimatedTextField(
                  controller: _nameController,
                  label: 'İlaç Adı',
                  hint: 'Örn: Parol, Aspirin',
                  icon: Icons.local_pharmacy_rounded,
                  isRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'İlaç adı en az 2 karakter olmalıdır';
                    }
                    return null;
                  },
                  suffixIcon: _isNameValid ? Icons.check_circle : null,
                ),
                const SizedBox(height: 20),
                _buildAnimatedTextField(
                  controller: _numberOfPillsController,
                  label: 'Toplam Hap Sayısı',
                  hint: 'Kaç adet?',
                  icon: Icons.format_list_numbered_rounded,
                  isRequired: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Hap sayısını girin';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Geçerli bir sayı girin (1 veya daha fazla)';
                    }
                    if (number > 1000) {
                      return 'Çok yüksek bir değer';
                    }
                    return null;
                  },
                  suffixIcon: _isPillCountValid ? Icons.check_circle : null,
                ),
                const SizedBox(height: 20),
                _buildAnimatedTextField(
                  controller: _descriptionController,
                  label: 'Açıklama (İsteğe bağlı)',
                  hint: 'Özel notlarınız...',
                  icon: Icons.note_rounded,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  'Kullanım Türleri',
                  'İlacınızı nasıl kullanacağınızı seçin (İsteğe bağlı)',
                  Icons.healing_rounded,
                ),
                const SizedBox(height: 24),
                _buildUsageTypeSelection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimatedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  'Hatırlatma Ayarları',
                  'İlacınızı almayı unutmamanız için hatırlatmalar oluşturun',
                  Icons.notifications_active_rounded,
                ),
                const SizedBox(height: 24),
                _buildAnimatedTextField(
                  controller: _notificationTextController,
                  label: 'Bildirim Metini',
                  hint: 'Örn: "İlacınızı alma zamanı!"',
                  icon: Icons.message_rounded,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                _buildNotificationTimesSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isRequired = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
    IconData? suffixIcon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon != null
              ? Icon(
                  suffixIcon,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }

  Widget _buildUsageTypeSelection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: UsageType.values.map((usageType) {
        final isSelected = _selectedUsageTypes.contains(usageType);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: FilterChip(
            label: Text(usageType.name),
            selected: isSelected,
            onSelected: (selected) {
              HapticFeedback.selectionClick();
              setState(() {
                if (selected) {
                  _selectedUsageTypes.add(usageType);
                } else {
                  _selectedUsageTypes.remove(usageType);
                }
              });
            },
            showCheckmark: true,
            checkmarkColor: Theme.of(context).colorScheme.onPrimary,
            selectedColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surface,
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            labelStyle: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotificationTimesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Hatırlatma Zamanları *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
         const   SizedBox(width: 12), // Metin ve buton arasına boşluk ekledik
            Flexible(
              child: FilledButton.icon(
                onPressed: _addNotificationTime,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Zaman Ekle'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_notificationTimes.isEmpty)
          _buildEmptyNotificationState()
        else
          _buildNotificationTimesList(),
      ],
    );
  }

  Widget _buildEmptyNotificationState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz hatırlatma zamanı eklenmedi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlacınızı düzenli alabilmek için hatırlatma zamanları ekleyin',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTimesList() {
    return Column(
      children: _notificationTimes.asMap().entries.map((entry) {
        final index = entry.key;
        final time = entry.value;

        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 50)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: ValueKey('${time.hour}:${time.minute}'),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _removeNotificationTime(index),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.delete_rounded,
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
                title: Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Text(
                  _getTimeDescription(time),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => _removeNotificationTime(index),
                  tooltip: 'Kaldır',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getTimeDescription(TimeOfDay time) {
    final hour = time.hour;
    if (hour >= 6 && hour < 12) return 'Sabah';
    if (hour >= 12 && hour < 17) return 'Öğleden sonra';
    if (hour >= 17 && hour < 21) return 'Akşam';
    return 'Gece';
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Geri'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              flex: _currentStep > 0 ? 2 : 1,
              child: _currentStep < 2
                  ? FilledButton.icon(
                      onPressed: _canProceedToNextStep ? _nextStep : null,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('İleri'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: _isSubmitting ? null : _saveMedicine,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(
                          _isSubmitting ? 'Kaydediliyor...' : 'İlacı Kaydet'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.help_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Text('Yardım'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              Icons.medication_rounded,
              'Temel Bilgiler',
              'İlaç adı ve hap sayısı zorunludur. Açıklama isteğe bağlıdır.',
            ),
            _buildHelpItem(
              Icons.healing_rounded,
              'Kullanım Türleri',
              'İlacınızı nasıl kullandığınızı belirtebilirsiniz (isteğe bağlı).',
            ),
            _buildHelpItem(
              Icons.notifications_active_rounded,
              'Hatırlatmalar',
              'En az bir hatırlatma zamanı eklemelisiniz. Özel mesaj yazmak isteğe bağlıdır.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
