import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/menu_model.dart';
import '../../application/mess_providers.dart';

// Helper class to bind a text controller and focus node together for every single food item
class MenuItemField {
  final TextEditingController controller;
  final FocusNode focusNode;

  MenuItemField(String text)
      : controller = TextEditingController(text: text),
        focusNode = FocusNode();

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

class EditDayMenuScreen extends ConsumerStatefulWidget {
  final DayMenuModel dayMenu;

  const EditDayMenuScreen({super.key, required this.dayMenu});

  @override
  ConsumerState<EditDayMenuScreen> createState() => _EditDayMenuScreenState();
}

class _EditDayMenuScreenState extends ConsumerState<EditDayMenuScreen> {
  // Lists holding our dynamic text fields
  final List<MenuItemField> _breakfastItems = [];
  final List<MenuItemField> _lunchItems = [];
  final List<MenuItemField> _snacksItems = [];
  final List<MenuItemField> _dinnerItems = [];

  @override
  void initState() {
    super.initState();
    _initCategory(widget.dayMenu.breakfast, _breakfastItems);
    _initCategory(widget.dayMenu.lunch, _lunchItems);
    _initCategory(widget.dayMenu.snacks, _snacksItems);
    _initCategory(widget.dayMenu.dinner, _dinnerItems);
  }

  // Parses the comma-separated string and creates a text field for each item
  void _initCategory(String menuString, List<MenuItemField> list) {
    if (menuString.trim().isEmpty) return;
    final items = menuString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
    for (var item in items) {
      list.add(MenuItemField(item));
    }
  }

  @override
  void dispose() {
    // Clean up memory
    for (var item in [..._breakfastItems, ..._lunchItems, ..._snacksItems, ..._dinnerItems]) {
      item.dispose();
    }
    super.dispose();
  }

  // Extracts the text from the controllers and joins them with commas
  String _extractMenuString(List<MenuItemField> list) {
    return list
        .map((item) => item.controller.text.trim())
        .where((text) => text.isNotEmpty) // Ignore empty fields
        .join(', ');
  }

  void _saveMenu() {
    ref.read(weeklyMenuProvider.notifier).updateDayMenu(
      widget.dayMenu.dayOfWeek,
      _extractMenuString(_breakfastItems),
      _extractMenuString(_lunchItems),
      _extractMenuString(_snacksItems),
      _extractMenuString(_dinnerItems),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.dayMenu.dayName} Menu Updated Successfully!'), backgroundColor: AppColors.success),
    );
    Navigator.pop(context);
  }

  // --- INLINE ADD / DELETE LOGIC ---

  void _handleAddItem(List<MenuItemField> currentList) {
    setState(() {
      final newItem = MenuItemField('');
      currentList.add(newItem);

      // Auto-focus the new field after it builds
      Future.delayed(const Duration(milliseconds: 100), () {
        newItem.focusNode.requestFocus();
      });
    });
  }

  void _handleDeleteItem(List<MenuItemField> currentList, int index) {
    setState(() {
      currentList[index].dispose();
      currentList.removeAt(index);
    });
  }

  // --- UI BUILDER ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.dayMenu.dayName}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Info Banner
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryLight.withOpacity(0.1),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Tap any text field to edit inline. Use the pencil to auto-focus.', style: TextStyle(fontSize: 13, color: AppColors.textPrimary))),
              ],
            ),
          ),

          // Expandable Lists
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildExpandableMealSection('Breakfast', Icons.free_breakfast, _breakfastItems),
                const SizedBox(height: 12),
                _buildExpandableMealSection('Lunch', Icons.lunch_dining, _lunchItems),
                const SizedBox(height: 12),
                _buildExpandableMealSection('Snacks', Icons.emoji_food_beverage, _snacksItems),
                const SizedBox(height: 12),
                _buildExpandableMealSection('Dinner', Icons.dinner_dining, _dinnerItems),
                const SizedBox(height: 40),

                // SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _saveMenu,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('SAVE UPDATED MENU', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableMealSection(String title, IconData icon, List<MenuItemField> itemsList) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: title == 'Breakfast',
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
          subtitle: Text('${itemsList.length} items', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Map through the items and build the inline edit rows
            ...itemsList.asMap().entries.map((entry) {
              int idx = entry.key;
              MenuItemField field = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    // INLINE TEXT FIELD
                    Expanded(
                      child: TextFormField(
                        controller: field.controller,
                        focusNode: field.focusNode,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'Enter food item...',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          // Hidden border until focused
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.transparent),
                          ),
                          // Highlighted border when editing
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // PENCIL ICON (Forces focus & moves cursor to end)
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
                      onPressed: () {
                        field.focusNode.requestFocus();
                        field.controller.selection = TextSelection.fromPosition(TextPosition(offset: field.controller.text.length));
                      },
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),

                    // DELETE DUSTBIN
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                      onPressed: () => _handleDeleteItem(itemsList, idx),
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            }),

            // ADD NEW ITEM BUTTON
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _handleAddItem(itemsList),
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  label: const Text('Add Item', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}