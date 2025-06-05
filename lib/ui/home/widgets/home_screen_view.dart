import 'package:flutter/material.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/ui/home/view_model/home_screen_view_model.dart';
import 'package:provider/provider.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/ui/home/widgets/add_medicine/adding_medicine.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/model/medicine.dart';
import 'package:sesli_ilac_bildirim_uygulamasi/ui/home/widgets/update_medicine_screen.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> with TickerProviderStateMixin {
  List<Medicine> medicines = [];
  bool isLoading = true;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadMedicines();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
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
      
      _animationController?.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        _showErrorSnackBar('İlaçlar yüklenirken hata oluştu: $e');
      }
    }
  }

  Future<void> _deleteMedicine(Medicine medicine) async {
    // Optimistic UI update
    final originalMedicines = List<Medicine>.from(medicines);
    setState(() {
      medicines.removeWhere((m) => m.id == medicine.id);
    });

    try {
      final viewModel = context.read<HomeScreenViewModel>();
      await viewModel.deleteMedicine(medicine);

      if (mounted) {
        _showSuccessSnackBar('${medicine.name} başarıyla silindi');
      }
    } catch (e) {
      // Revert optimistic update on error
      setState(() {
        medicines = originalMedicines;
      });
      
      if (mounted) {
        _showErrorSnackBar('İlaç silinirken hata oluştu: $e');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showDeleteConfirmation(Medicine medicine) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red[400], size: 28),
              const SizedBox(width: 8),
              const Text('İlacı Sil'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${medicine.name ?? "Bu ilaç"} kalıcı olarak silinecek.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bu işlem geri alınamaz.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMedicine(medicine);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMedicineCard(Medicine medicine, int index) {
    final viewModel = context.read<HomeScreenViewModel>();
    final isRunningLow = viewModel.isRunningLow(medicine);
    final endDateText = viewModel.calculateEndDate(medicine);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Card(
        elevation: isRunningLow ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isRunningLow 
            ? BorderSide(color: Colors.red.withOpacity(0.3), width: 1)
            : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateMedicineScreen(medicine: medicine),
              ),
            );

            if (result == true) {
              _loadMedicines();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Medicine Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isRunningLow 
                        ? [Colors.red[300]!, Colors.red[600]!]
                        : [Theme.of(context).primaryColor.withOpacity(0.7), Theme.of(context).primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text(
                      (medicine.name?.isNotEmpty == true)
                          ? medicine.name!.substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Medicine Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medicine Name
                      Text(
                        medicine.name ?? 'İsimsiz İlaç',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Description
                      if (medicine.description?.isNotEmpty == true)
                        Text(
                          medicine.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // Usage and Notification Info
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (medicine.usageType?.isNotEmpty == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                medicine.usageType!.map((e) => e.name).join(", "),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          
                          if (medicine.notificationTimes?.isNotEmpty == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${medicine.notificationTimes!.length} bildirim',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      // End Date Info
                      if (medicine.numberOfPills != null &&
                          medicine.notificationTimes?.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                isRunningLow ? Icons.warning : Icons.check_circle,
                                size: 16,
                                color: isRunningLow ? Colors.red : Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  endDateText,
                                  style: TextStyle(
                                    color: isRunningLow ? Colors.red : Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Delete Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'İlacı Sil',
                    onPressed: () => _showDeleteConfirmation(medicine),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: _fadeAnimation != null 
        ? FadeTransition(
            opacity: _fadeAnimation!,
            child: _buildEmptyStateContent(),
          )
        : _buildEmptyStateContent(),
    );
  }

  Widget _buildEmptyStateContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.medication_outlined,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Henüz ilaç eklenmemiş',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'İlk ilacınızı ekleyerek başlayın',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddMedicineScreen(),
              ),
            );

            if (result == true || result == null) {
              _loadMedicines();
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('İlaç Ekle'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'İlaç Takibim',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, size: 20),
            ),
            tooltip: 'İlaç Ekle',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMedicineScreen(),
                ),
              );

              if (result == true || result == null) {
                _loadMedicines();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMedicines,
        color: Theme.of(context).primaryColor,
        child: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'İlaçlar yükleniyor...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : medicines.isEmpty
                ? _buildEmptyState()
                : _fadeAnimation != null
                    ? FadeTransition(
                        opacity: _fadeAnimation!,
                        child: ListView.builder(
                          itemCount: medicines.length,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 4.0,
                          ),
                          itemBuilder: (context, index) {
                            return _buildMedicineCard(medicines[index], index);
                          },
                        ),
                      )
                    : ListView.builder(
                        itemCount: medicines.length,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4.0,
                        ),
                        itemBuilder: (context, index) {
                          return _buildMedicineCard(medicines[index], index);
                        },
                      ),
      ),
    );
  }
}