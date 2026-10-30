import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/stock_item_model.dart';
import '../../bloc/pharmacy/pharmacy_cubit.dart';
import '../../bloc/settings/settings_cubit.dart';

class PartnerStockScreen extends StatelessWidget {
  const PartnerStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 16,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: Text(
                    AppStrings.get('manage_stock', locale),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _showAddStockDialog(context, locale),
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<PharmacyCubit, PharmacyState>(
              builder: (context, state) {
                if (state.status == PharmacyStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.stockItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 56,
                          color: AppColors.textLight.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.get('no_stock', locale),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _showAddStockDialog(context, locale),
                          icon: const Icon(Icons.add),
                          label: Text(AppStrings.get('add_medicine', locale)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.stockItems.length,
                  itemBuilder: (context, index) {
                    final item = state.stockItems[index];
                    return _StockItemCard(
                      item: item,
                      locale: locale,
                      onEdit: () => _showEditStockDialog(context, locale, item),
                      onDelete: () {
                        context.read<PharmacyCubit>().deleteStockItem(item.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStockDialog(BuildContext context, String locale) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();
    String status = 'in_stock';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.get('add_medicine', locale),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('medicine_name', locale),
                  prefixIcon: const Icon(Icons.medication_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '${AppStrings.get('price', locale)} (RWF)',
                  prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppStrings.get('quantity', locale),
                  prefixIcon: const Icon(Icons.inventory_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: InputDecoration(
                  labelText: AppStrings.get('status', locale),
                  prefixIcon: const Icon(Icons.info_outline, size: 20),
                ),
                items: const [
                  DropdownMenuItem(value: 'in_stock', child: Text('In Stock')),
                  DropdownMenuItem(
                    value: 'low_stock',
                    child: Text('Low Stock'),
                  ),
                  DropdownMenuItem(
                    value: 'out_of_stock',
                    child: Text('Out of Stock'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setSheetState(() => status = val);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;

                    final pharmacyState = context.read<PharmacyCubit>().state;
                    final pharmacy = pharmacyState.pharmacy;
                    if (pharmacy == null) return;

                    final stockItem = StockItemModel(
                      id: '',
                      pharmacyId: pharmacy.id,
                      pharmacyName: pharmacy.name,
                      pharmacyArea: pharmacy.area,
                      pharmacyPhone: pharmacy.phone,
                      pharmacyHours: pharmacy.hours,
                      pharmacyLat: pharmacy.latitude,
                      pharmacyLng: pharmacy.longitude,
                      medicineName: nameController.text.trim(),
                      status: status,
                      quantity: int.tryParse(quantityController.text) ?? 0,
                      price: int.tryParse(priceController.text) ?? 0,
                      updatedAt: DateTime.now(),
                    );

                    context.read<PharmacyCubit>().addStockItem(stockItem);
                    Navigator.pop(ctx);
                  },
                  child: Text(AppStrings.get('add_medicine', locale)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditStockDialog(
    BuildContext context,
    String locale,
    StockItemModel item,
  ) {
    final priceController = TextEditingController(
      text: item.price.toStringAsFixed(0),
    );
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    String status = item.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${AppStrings.get('edit', locale)} ${item.medicineName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '${AppStrings.get('price', locale)} (RWF)',
                  prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppStrings.get('quantity', locale),
                  prefixIcon: const Icon(Icons.inventory_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: InputDecoration(
                  labelText: AppStrings.get('status', locale),
                  prefixIcon: const Icon(Icons.info_outline, size: 20),
                ),
                items: const [
                  DropdownMenuItem(value: 'in_stock', child: Text('In Stock')),
                  DropdownMenuItem(
                    value: 'low_stock',
                    child: Text('Low Stock'),
                  ),
                  DropdownMenuItem(
                    value: 'out_of_stock',
                    child: Text('Out of Stock'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setSheetState(() => status = val);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final updated = item.copyWith(
                      price: int.tryParse(priceController.text) ?? item.price,
                      quantity:
                          int.tryParse(quantityController.text) ??
                          item.quantity,
                      status: status,
                      updatedAt: DateTime.now(),
                    );
                    context.read<PharmacyCubit>().updateStockItem(updated);
                    Navigator.pop(ctx);
                  },
                  child: Text(AppStrings.get('save_changes', locale)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockItemCard extends StatelessWidget {
  final StockItemModel item;
  final String locale;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StockItemCard({
    required this.item,
    required this.locale,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (item.status) {
      'in_stock' => AppColors.successGreen,
      'low_stock' => AppColors.warningYellow,
      _ => AppColors.errorRed,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.medicineName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.quantity} ${AppStrings.get('packs', locale)} · ${item.formattedPrice}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.primaryGreen,
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.errorRed,
          ),
        ],
      ),
    );
  }
}
