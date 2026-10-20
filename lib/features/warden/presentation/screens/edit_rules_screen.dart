import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// --- RULE MODEL ---
class HostelRuleModel {
  String id;
  String title;
  String description;

  HostelRuleModel({
    required this.id,
    required this.title,
    required this.description,
  });
}

class EditRulesScreen extends StatefulWidget {
  const EditRulesScreen({super.key});

  @override
  State<EditRulesScreen> createState() => _EditRulesScreenState();
}

class _EditRulesScreenState extends State<EditRulesScreen> {
  late List<HostelRuleModel> _rules;

  @override
  void initState() {
    super.initState();
    _rules = _getMockRules();
  }

  // --- ACTIONS ---

  void _showRuleDialog({HostelRuleModel? existingRule}) {
    final isEditing = existingRule != null;
    final titleController = TextEditingController(text: isEditing ? existingRule.title : '');
    final descController = TextEditingController(text: isEditing ? existingRule.description : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Rule' : 'Add New Rule', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rule Title', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Curfew Timings',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Rule Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Provide detailed guidelines...',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty || descController.text.trim().isEmpty) return;

                setState(() {
                  if (isEditing) {
                    existingRule.title = titleController.text.trim();
                    existingRule.description = descController.text.trim();
                  } else {
                    _rules.add(HostelRuleModel(
                      id: DateTime.now().toString(),
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                    ));
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEditing ? 'Rule Updated Successfully!' : 'New Rule Added!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: Text(isEditing ? 'Save Changes' : 'Add Rule'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(HostelRuleModel rule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rule?', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete the rule "${rule.title}"? This will remove it from the student handbook immediately.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              setState(() => _rules.remove(rule));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rule deleted.'), backgroundColor: AppColors.error));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // --- UI BUILDER ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rules & Regulations'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey.shade50,
      body: _rules.isEmpty
          ? const Center(child: Text('No rules defined yet.', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _rules.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final rule = _rules[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), shape: BoxShape.circle),
                        child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rule.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            const SizedBox(height: 8),
                            Text(rule.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _showRuleDialog(existingRule: rule),
                        icon: const Icon(Icons.edit, size: 16, color: Colors.deepPurple),
                        label: const Text('Edit', style: TextStyle(color: Colors.deepPurple)),
                      ),
                      TextButton.icon(
                        onPressed: () => _confirmDelete(rule),
                        icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                        label: const Text('Delete', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRuleDialog(),
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Rule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- MOCK DATA ---
  List<HostelRuleModel> _getMockRules() {
    return [
      HostelRuleModel(
        id: '1',
        title: 'Curfew Timings',
        description: 'All students must return to the hostel premises by 9:00 PM on weekdays and 10:00 PM on weekends. Late entries will be heavily penalized and parents will be notified.',
      ),
      HostelRuleModel(
        id: '2',
        title: 'Electrical Appliances',
        description: 'Heavy electrical appliances such as heaters, induction cooktops, and personal air coolers are strictly prohibited in the rooms to prevent fire hazards.',
      ),
      HostelRuleModel(
        id: '3',
        title: 'Visitor Policy',
        description: 'Outsiders, including friends from other hostels, are not allowed inside the rooms. Visitors must meet students in the designated visitor lounge near the main reception.',
      ),
      HostelRuleModel(
        id: '4',
        title: 'Noise and Discipline',
        description: 'Students must maintain strict silence in the corridors after 10:30 PM. Playing loud music or causing disturbances will result in disciplinary action.',
      ),
    ];
  }
}