import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CreateMessAnnouncementScreen extends StatefulWidget {
  const CreateMessAnnouncementScreen({super.key});

  @override
  State<CreateMessAnnouncementScreen> createState() => _CreateMessAnnouncementScreenState();
}

class _CreateMessAnnouncementScreenState extends State<CreateMessAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedAudience = 'All Students';
  bool _isUrgent = false;
  String? _attachedFileName;

  // Custom audience list for the Mess Incharge
  final List<String> _audienceOptions = [
    'All Students',
    'Boys Hostel',
    'Girls Hostel'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _pickDocument() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening file picker...'), duration: Duration(milliseconds: 500)),
    );
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _attachedFileName = 'Updated_Menu_List.pdf';
    });
  }

  void _publish() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mess Announcement Broadcasted!'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context); // Go back to the feed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Mess Broadcast'),
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. SETTINGS (AUDIENCE & URGENCY) ---
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Target Audience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedAudience,
                              isExpanded: true,
                              items: _audienceOptions.map((String value) {
                                return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)));
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) setState(() => _selectedAudience = newValue);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Urgent?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Switch(
                          value: _isUrgent,
                          onChanged: (val) => setState(() => _isUrgent = val),
                          activeColor: AppColors.error,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- 2. TITLE ---
              const Text('Notice Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g., Dinner Menu Update',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 24),

              // --- 3. CONTENT ---
              const Text('Message Body', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Type your detailed announcement here...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Message is required' : null,
              ),
              const SizedBox(height: 24),

              // --- 4. ATTACHMENT ---
              const Text('Attachments (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              if (_attachedFileName == null)
                OutlinedButton.icon(
                  onPressed: _pickDocument,
                  icon: const Icon(Icons.attach_file, color: AppColors.primary),
                  label: const Text('Attach Document or PDF', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.success.withOpacity(0.5))),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: AppColors.success),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(_attachedFileName!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.error),
                        onPressed: () => setState(() => _attachedFileName = null),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      )
                    ],
                  ),
                ),

              const SizedBox(height: 40),

              // --- 5. PUBLISH BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _publish,
                  icon: const Icon(Icons.campaign, color: Colors.white),
                  label: const Text('PUBLISH TO STUDENTS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}