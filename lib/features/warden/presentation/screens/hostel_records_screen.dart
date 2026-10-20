import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'student_profile_screen.dart';
import 'room_details_screen.dart';

// --- DIRECTORY MODEL ---
class StudentDirectoryModel {
  final String name;
  final String uid;
  final String department;
  final String roomNumber;
  final String contact;
  final String parentContact;
  final int year;

  StudentDirectoryModel({
    required this.name, required this.uid, required this.department,
    required this.roomNumber, required this.contact, required this.parentContact, required this.year,
  });
}

class HostelRecordsScreen extends StatefulWidget {
  const HostelRecordsScreen({super.key});

  @override
  State<HostelRecordsScreen> createState() => _HostelRecordsScreenState();
}

class _HostelRecordsScreenState extends State<HostelRecordsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<StudentDirectoryModel> _allStudents;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _allStudents = _getMockDirectory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<StudentDirectoryModel>> _groupStudentsByRoom(List<StudentDirectoryModel> students) {
    final Map<String, List<StudentDirectoryModel>> grouped = {};
    for (var student in students) {
      if (!grouped.containsKey(student.roomNumber)) {
        grouped[student.roomNumber] = [];
      }
      grouped[student.roomNumber]!.add(student);
    }
    final sortedKeys = grouped.keys.toList()..sort();
    return {for (var key in sortedKeys) key: grouped[key]!};
  }

  // ROUTE TO STUDENT PROFILE
  void _openStudentProfile(StudentDirectoryModel student) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => StudentProfileScreen(student: student)));
  }

  // ROUTE TO ROOM DETAILS
  void _openRoomDetails(String roomNumber, List<StudentDirectoryModel> occupants) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => RoomDetailsScreen(roomNumber: roomNumber, occupants: occupants)));
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchQuery.isNotEmpty;

    List<StudentDirectoryModel> searchResults = [];
    if (isSearching) {
      searchResults = _allStudents.where((s) {
        return s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.uid.contains(_searchQuery) ||
            s.roomNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Records'),
        elevation: 0,
        backgroundColor: Colors.indigo,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by Name, UID, or Room...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: isSearching
                    ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    }
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          if (!isSearching)
            Container(
              color: Colors.indigo,
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                isScrollable: true,
                tabs: const [Tab(text: '1st Year'), Tab(text: '2nd Year'), Tab(text: '3rd Year'), Tab(text: '4th Year')],
              ),
            ),

          Expanded(
            child: isSearching
                ? _buildSearchResults(searchResults)
                : TabBarView(
              controller: _tabController,
              children: [
                _buildYearTab(1),
                _buildYearTab(2),
                _buildYearTab(3),
                _buildYearTab(4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearTab(int year) {
    final studentsInYear = _allStudents.where((s) => s.year == year).toList();
    if (studentsInYear.isEmpty) return Center(child: Text('No students found for Year $year', style: const TextStyle(color: AppColors.textSecondary)));

    final groupedRooms = _groupStudentsByRoom(studentsInYear);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedRooms.length,
      itemBuilder: (context, index) {
        String roomNumber = groupedRooms.keys.elementAt(index);
        List<StudentDirectoryModel> roommates = groupedRooms[roomNumber]!;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
          child: ExpansionTile(
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.meeting_room, color: Colors.indigo),
            ),
            title: Text('Room $roomNumber', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            subtitle: Text('${roommates.length} Occupants', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            children: [
              // --- NEW: ROOM DETAILS BUTTON ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => _openRoomDetails(roomNumber, roommates),
                  icon: const Icon(Icons.remove_red_eye, size: 16, color: Colors.indigo),
                  label: const Text('View Full Room Details', style: TextStyle(color: Colors.indigo)),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.indigo.withOpacity(0.3))),
                ),
              ),
              const Divider(height: 16),
              ...roommates.map((student) => _buildStudentListTile(student)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(List<StudentDirectoryModel> results) {
    if (results.isEmpty) return const Center(child: Text('No matching students or rooms found.', style: TextStyle(color: AppColors.textSecondary)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
          child: _buildStudentListTile(results[index]),
        );
      },
    );
  }

  Widget _buildStudentListTile(StudentDirectoryModel student) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Text(student.name[0], style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
      ),
      title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text('UID: ${student.uid} • ${student.department}', style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => _openStudentProfile(student),
    );
  }

  // --- MOCK DATA ---
  List<StudentDirectoryModel> _getMockDirectory() {
    return [
      StudentDirectoryModel(name: 'Aarav Sharma', uid: '267106010', department: 'B.Tech CSE', roomNumber: 'A-101', contact: '9876543210', parentContact: '9876543211', year: 1),
      StudentDirectoryModel(name: 'Rohan Gupta', uid: '267106041', department: 'B.Tech ME', roomNumber: 'A-101', contact: '9876543220', parentContact: '9876543221', year: 1),
      StudentDirectoryModel(name: 'Aditya Verma', uid: '267106088', department: 'B.Tech ECE', roomNumber: 'A-102', contact: '9876543230', parentContact: '9876543231', year: 1),
      StudentDirectoryModel(name: 'Gursajanpreet Singh', uid: '257106013', department: 'B.Tech CSE', roomNumber: 'B-201', contact: '9123456780', parentContact: '9811122233', year: 2),
      StudentDirectoryModel(name: 'Vikram Singh', uid: '257106045', department: 'B.Tech CSE', roomNumber: 'B-201', contact: '9988776655', parentContact: '9988776656', year: 2),
      StudentDirectoryModel(name: 'Rahul Kumar', uid: '247106088', department: 'B.Tech ME', roomNumber: 'C-305', contact: '9123456780', parentContact: '9123456781', year: 3),
      StudentDirectoryModel(name: 'Amit Patel', uid: '237106092', department: 'B.Tech IT', roomNumber: 'D-410', contact: '9877766655', parentContact: '9877766656', year: 4),
    ];
  }
}