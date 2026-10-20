import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'hostel_records_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  final StudentDirectoryModel student;

  const StudentProfileScreen({super.key, required this.student});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  // Local state to hold the editable numbers
  late String _studentContact;
  late String _fatherContact;
  late String _motherContact;

  @override
  void initState() {
    super.initState();
    _studentContact = widget.student.contact;
    // We are splitting the parent contact for the UI mock. In a real DB, these would be separate fields.
    _fatherContact = widget.student.parentContact;
    _motherContact = '9876500000'; // Mocking a separate mother contact
  }

  void _simulateCall(String name, String number) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dialing $name... ($number)'), backgroundColor: Colors.teal),
    );
  }

  void _editContacts() {
    final studentCtrl = TextEditingController(text: _studentContact);
    final fatherCtrl = TextEditingController(text: _fatherContact);
    final motherCtrl = TextEditingController(text: _motherContact);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Contact Info', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEditField('Student Mobile', studentCtrl),
                const SizedBox(height: 12),
                _buildEditField('Father\'s Mobile', fatherCtrl),
                const SizedBox(height: 12),
                _buildEditField('Mother\'s Mobile', motherCtrl),
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
                setState(() {
                  _studentContact = studentCtrl.text.trim();
                  _fatherContact = fatherCtrl.text.trim();
                  _motherContact = motherCtrl.text.trim();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contacts updated successfully!'), backgroundColor: AppColors.success));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        elevation: 0,
        backgroundColor: Colors.indigo,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- PROFILE HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 24, top: 16),
              decoration: const BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(student.name[0], style: const TextStyle(fontSize: 40, color: Colors.indigo, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  Text(student.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('UID: ${student.uid}', style: const TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text('Room ${student.roomNumber}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  )
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ACADEMIC DETAILS ---
                  const Text('Academic Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _buildDataRow(Icons.school, 'Department', student.department),
                    const Divider(height: 24),
                    _buildDataRow(Icons.timeline, 'Academic Year', 'Year ${student.year}'),
                    const Divider(height: 24),
                    _buildDataRow(Icons.bloodtype, 'Blood Group', 'O+ (Positive)'),
                  ]),
                  const SizedBox(height: 24),

                  // --- CONTACT INFORMATION (WITH EDIT BUTTON) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Contact & Emergency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      TextButton.icon(
                        onPressed: _editContacts,
                        icon: const Icon(Icons.edit, size: 16, color: Colors.indigo),
                        label: const Text('Edit', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoCard([
                    _buildActionRow(Icons.phone_android, 'Student Mobile', _studentContact),
                    const Divider(height: 24),
                    _buildActionRow(Icons.male, 'Father\'s Mobile', _fatherContact),
                    const Divider(height: 24),
                    _buildActionRow(Icons.female, 'Mother\'s Mobile', _motherContact),
                    const Divider(height: 24),
                    _buildDataRow(Icons.home, 'Home Address', '123 Model Town, Block B, Punjab, India'),
                  ]),
                  const SizedBox(height: 24),

                  // --- WARDEN ACTIONS ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room reassignment initiated.'))),
                      icon: const Icon(Icons.swap_horiz, color: Colors.indigo),
                      label: const Text('Reassign Room', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 16)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.indigo),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDataRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.indigo),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.indigo),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _simulateCall(label, value),
          icon: const Icon(Icons.call, color: Colors.teal),
          style: IconButton.styleFrom(backgroundColor: Colors.teal.withOpacity(0.1)),
        )
      ],
    );
  }
}