import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// --- INVENTORY MODEL ---
class InventoryItemModel {
  final String id;
  final String name;
  final IconData icon;
  int total;
  int inUse;
  int damaged;

  InventoryItemModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.total,
    required this.inUse,
    required this.damaged,
  });

  // Dynamically calculate what's left in the store room
  int get availableInStore => total - inUse - damaged;
}

class InventoryManagerScreen extends StatefulWidget {
  const InventoryManagerScreen({super.key});

  @override
  State<InventoryManagerScreen> createState() => _InventoryManagerScreenState();
}

class _InventoryManagerScreenState extends State<InventoryManagerScreen> {
  late List<InventoryItemModel> _inventoryItems;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _inventoryItems = _getMockInventory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- ACTIONS ---

  void _showAdjustStockDialog(InventoryItemModel item, bool isAddingStock) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isAddingStock ? 'Add New Stock' : 'Report Damaged Item', style: TextStyle(color: isAddingStock ? AppColors.success : AppColors.error, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Item: ${item.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Text(isAddingStock
                  ? 'How many new ${item.name.toLowerCase()} are arriving from the supplier?'
                  : 'How many ${item.name.toLowerCase()} are being moved to the damaged pile?',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter quantity...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(amountController.text.trim()) ?? 0;
                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid quantity.')));
                  return;
                }

                setState(() {
                  if (isAddingStock) {
                    item.total += amount;
                  } else {
                    // Moving from Available/In-Use to Damaged
                    if (item.availableInStore >= amount) {
                      item.damaged += amount;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough available stock to mark as damaged.')));
                      return;
                    }
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(isAddingStock ? 'Stock Added Successfully!' : 'Damage Reported Successfully!'),
                  backgroundColor: isAddingStock ? AppColors.success : AppColors.error,
                ));
              },
              style: ElevatedButton.styleFrom(backgroundColor: isAddingStock ? AppColors.success : AppColors.error),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // --- UI BUILDER ---

  @override
  Widget build(BuildContext context) {
    // Calculate global stats
    int totalAssets = 0;
    int totalDamaged = 0;
    for (var item in _inventoryItems) {
      totalAssets += item.total;
      totalDamaged += item.damaged;
    }

    // Filter items based on search
    final filteredItems = _inventoryItems.where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Manager'),
        elevation: 0,
        backgroundColor: Colors.brown, // Distinct color for inventory
      ),
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // --- 1. GLOBAL SUMMARY ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.brown,
              boxShadow: [BoxShadow(color: Colors.brown.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Expanded(child: _buildGlobalStat('Total Assets', '$totalAssets', Icons.inventory_2, Colors.white)),
                Container(width: 1, height: 40, color: Colors.white30),
                Expanded(child: _buildGlobalStat('Items Damaged', '$totalDamaged', Icons.build_circle, Colors.orangeAccent)),
              ],
            ),
          ),

          // --- 2. SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search inventory (e.g., Beds, Fans)...',
                prefixIcon: const Icon(Icons.search, color: Colors.brown),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
          ),

          // --- 3. INVENTORY LIST ---
          Expanded(
            child: filteredItems.isEmpty
                ? Center(child: Text('No items found for "$_searchQuery"', style: const TextStyle(color: AppColors.textSecondary)))
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              itemCount: filteredItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _buildInventoryCard(filteredItems[index]),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildGlobalStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold, height: 1.1)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildInventoryCard(InventoryItemModel item) {
    final bool hasLowStock = item.availableInStore < 10; // Alert threshold

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.brown.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(item.icon, color: Colors.brown, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text('Total Registered: ${item.total}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (hasLowStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Text('LOW STOCK', style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
              ],
            ),
          ),

          // Stats Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusColumn('In Use', '${item.inUse}', AppColors.primary),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                _buildStatusColumn('In Store', '${item.availableInStore}', hasLowStock ? AppColors.error : AppColors.success),
                Container(width: 1, height: 30, color: Colors.grey.shade300),
                _buildStatusColumn('Damaged', '${item.damaged}', AppColors.warning),
              ],
            ),
          ),
          const Divider(height: 1),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showAdjustStockDialog(item, false),
                  icon: const Icon(Icons.report_problem, color: AppColors.warning, size: 18),
                  label: const Text('Report Damage', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
                ),
              ),
              Container(width: 1, height: 20, color: Colors.grey.shade300),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showAdjustStockDialog(item, true),
                  icon: const Icon(Icons.add_box, color: AppColors.success, size: 18),
                  label: const Text('Add Stock', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  // --- MOCK DATA ---
  List<InventoryItemModel> _getMockInventory() {
    return [
      InventoryItemModel(id: 'i1', name: 'Beds (Iron Frame)', icon: Icons.bed, total: 600, inUse: 542, damaged: 8),
      InventoryItemModel(id: 'i2', name: 'Mattresses', icon: Icons.rectangle_outlined, total: 600, inUse: 542, damaged: 15),
      InventoryItemModel(id: 'i3', name: 'Study Tables', icon: Icons.desk, total: 620, inUse: 542, damaged: 12),
      InventoryItemModel(id: 'i4', name: 'Study Chairs', icon: Icons.chair_alt, total: 650, inUse: 542, damaged: 24),
      InventoryItemModel(id: 'i5', name: 'Ceiling Fans', icon: Icons.mode_fan_off, total: 280, inUse: 250, damaged: 5), // Shows LOW STOCK (25 available)
      InventoryItemModel(id: 'i6', name: 'Almirahs (Wardrobes)', icon: Icons.door_sliding, total: 600, inUse: 542, damaged: 2),
    ];
  }
}