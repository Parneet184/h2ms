import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../notices/application/notice_providers.dart';
import '../../../notices/domain/notice_model.dart';
import '../../../auth/application/auth_provider.dart';

class CreateWardenNoticeScreen extends ConsumerStatefulWidget {
  const CreateWardenNoticeScreen({super.key});

  @override
  ConsumerState<CreateWardenNoticeScreen> createState() => _CreateWardenNoticeScreenState();
}

class _CreateWardenNoticeScreenState extends ConsumerState<CreateWardenNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedAudience = 'All Students';
  bool _isUrgent = false;
  String? _attachedFileName;
  bool _isPublishing = false;

  final List<String> _audienceOptions = [
    'All Students', '1st Year Only', '2nd Year Only', '3rd Year Only', '4th Year Only', 'Hostel Staff'
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
      _attachedFileName = 'Official_Notice_Document.pdf';
    });
  }

  Future<void> _publish() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isPublishing = true);

      try {
        final currentUser = ref.read(currentUserProvider);
        final wardenName = currentUser?.name ?? 'Chief Warden';

        final prefix = _isUrgent ? 'URGENT: ' : '';
        final finalTitle = '$prefix${_titleController.text.trim()}';

        final newNotice = NoticeModel(
          id: '', // Supabase generates this
          title: finalTitle,
          shortDescription: _contentController.text.trim().take(100),
          fullDescription: '${_contentController.text.trim()}\n\n[Audience: $_selectedAudience]',
          postedBy: wardenName,
          postedAt: DateTime.now(),
          hasAttachment: _attachedFileName != null,
          attachmentName: _attachedFileName,
        );

        // Save to Supabase repository
        await ref.read(noticeRepositoryProvider).createNotice(newNotice);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notice Broadcasted Successfully!'), backgroundColor: AppColors.success),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error publishing notice: $e'), backgroundColor: AppColors.error),
          );
        }
      } finally {
        if (mounted) setState(() => _isPublishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Broadcast'),
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
              const Text('Notice Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g., Mandatory Room Inspection',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 24),
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
              const Text('Attachments (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              if (_attachedFileName == null)
                OutlinedButton.icon(
                  onPressed: _pickDocument,
                  icon: const Icon(Icons.attach_file, color: AppColors.primary),
                  label: const Text('Attach Document or PDF', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.success.withValues(alpha: 0.5))),
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
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isPublishing ? null : _publish,
                  icon: _isPublishing
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.campaign, color: Colors.white),
                  label: Text(_isPublishing ? 'PUBLISHING...' : 'PUBLISH TO STUDENTS', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
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

// Extension helper for short description substring trimming
extension on String {
  String take(int n) => length <= n ? this : '${substring(0, n)}...';
}