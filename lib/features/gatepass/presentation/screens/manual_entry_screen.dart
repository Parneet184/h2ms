import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';

// A mock model specifically for the Manual Action list
class ManualEntryItem {
  final String id;
  final String name;
  final String uid;
  final String room;
  final PassType type;
  PassStatus status; // Approved (ready to leave) or Active (ready to return)

  ManualEntryItem({
    required this.id,
    required this.name,
    required this.uid,
    required this.room,
    required this.type,
    required this.status,
  });
}

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<ManualEntryItem> _allPasses = [];
  List<ManualEntryItem> _filteredPasses = [];

  @override
  void initState() {
    super.initState();
    _allPasses = _generateMockActionablePasses();
    _filteredPasses = _allPasses;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- SEARCH FILTER LOGIC ---
  void _filterPasses(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredPasses = _allPasses;
      });
    } else {
      setState(() {
        _filteredPasses = _allPasses.where((pass) {
          final lowerQuery = query.toLowerCase();
          return pass.name.toLowerCase().contains(lowerQuery) ||
              pass.uid.toLowerCase().contains(lowerQuery) ||
              pass.room.toLowerCase().contains(lowerQuery);
        }).toList();
      });
    }
  }

  // --- ACTION LOGIC ---
  void _performAction(ManualEntryItem pass) {
    final bool isCheckingOut = pass.status == PassStatus.approved;

    // In a real app, this updates the database. Here, we'll just remove them from the "actionable" list.
    setState(() {
      _allPasses.removeWhere((p) => p.id == pass.id);
      _filterPasses(_searchController.text); // Refresh the filtered list
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCheckingOut ? '${pass.name} Checked OUT manually.' : '${pass.name} Checked IN manually.'),
        backgroundColor: isCheckingOut ? AppColors.warning : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Entry / Exit'),
      ),
      body: Column(
        children: [
          // --- SEARCH BAR ---
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.background,
            child: TextField(
              controller: _searchController,
              onChanged: _filterPasses,
              decoration: InputDecoration(
                hintText: 'Search UID, Name, or Room...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterPasses('');
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // --- LIST OF ACTIONABLE PASSES ---
          Expanded(
            child: _filteredPasses.isEmpty
                ? const Center(
              child: Text('No pending passes or active students match your search.', style: TextStyle(color: AppColors.textSecondary)),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredPasses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final pass = _filteredPasses[index];
                final isCheckingOut = pass.status == PassStatus.approved;

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                              child: const Icon(Icons.person, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pass.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('UID: ${pass.uid} • Room ${pass.room}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                ],
                              ),
                            ),
                            // Pass Type Badge (Gatepass vs Leave)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: pass.type == PassType.leave ? AppColors.primaryLight.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                pass.type.name.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: pass.type == PassType.leave ? AppColors.primaryLight : AppColors.success
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // ACTION BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _performAction(pass),
                            icon: Icon(isCheckingOut ? Icons.output : Icons.login, color: Colors.white),
                            label: Text(
                                isCheckingOut ? 'MARK AS CHECK-OUT' : 'MARK AS CHECK-IN',
                                style: const TextStyle(fontWeight: FontWeight.bold)
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCheckingOut ? AppColors.warning : AppColors.success,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- MOCK DATA GENERATOR ---
  List<ManualEntryItem> _generateMockActionablePasses() {
    return [
      // Students who are Approved and waiting to leave
      ManualEntryItem(id: '1', name: 'Gursajanpreet Singh', uid: '23F06012', room: '101', type: PassType.gatepass, status: PassStatus.approved),
      ManualEntryItem(id: '2', name: 'Aarav Sharma', uid: '23F06015', room: '101', type: PassType.leave, status: PassStatus.approved),
      ManualEntryItem(id: '3', name: 'Ravi Kumar', uid: '23F06042', room: '210', type: PassType.gatepass, status: PassStatus.approved),

      // Students who are Active (currently outside) and need to return
      ManualEntryItem(id: '4', name: 'Vikram Singh', uid: '21F9021', room: '305', type: PassType.gatepass, status: PassStatus.active),
      ManualEntryItem(id: '5', name: 'Rahul Sharma', uid: '22F1042', room: '204', type: PassType.leave, status: PassStatus.active),
    ];
  }
}