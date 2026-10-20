import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../auth/application/auth_provider.dart';
import '../../application/complaint_providers.dart';
import '../../domain/complaint_model.dart';

class NewComplaintScreen extends ConsumerStatefulWidget {
  final bool isMessIssue;

  const NewComplaintScreen({super.key, required this.isMessIssue});

  @override
  ConsumerState<NewComplaintScreen> createState() => _NewComplaintScreenState();
}

class _NewComplaintScreenState extends ConsumerState<NewComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isPrivate = false;
  ComplaintCategory? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<ComplaintCategory> get _availableCategories {
    if (widget.isMessIssue) {
      return [
        ComplaintCategory.foodQuality,
        ComplaintCategory.staffBehavior,
        ComplaintCategory.messCleanliness,
        ComplaintCategory.other
      ];
    } else {
      return [
        ComplaintCategory.plumbing,
        ComplaintCategory.electricity,
        ComplaintCategory.carpentry,
        ComplaintCategory.furniture,
        ComplaintCategory.ground,
        ComplaintCategory.cleanliness,
        ComplaintCategory.indiscipline,
        ComplaintCategory.other
      ];
    }
  }

  String _formatCategoryName(ComplaintCategory category) {
    String name = category.name;
    return name.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').toUpperCase();
  }

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category'), backgroundColor: AppColors.error),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        final user = ref.read(currentUserProvider);

        final newComplaint = ComplaintModel(
          id: '', // Supabase generates ID automatically
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          authorName: user?.name ?? 'Unknown Student',
          authorUid: user?.uid ?? '',
          roomNumber: user?.roomNumber ?? 'Unassigned',
          category: _selectedCategory!,
          status: ComplaintStatus.open,
          postedAt: DateTime.now(),
          upvotes: 0,
          hasUpvoted: false,
          isPrivate: _isPrivate,
        );

        await ref.read(complaintRepositoryProvider).createComplaint(newComplaint);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.isMessIssue ? 'Mess' : 'Hostel'} issue submitted!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error submitting complaint: $e'), backgroundColor: AppColors.error),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report ${widget.isMessIssue ? 'Mess' : 'Hostel'} Issue'),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SwitchListTile(
                  title: const Text('Make Private', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Only you and the staff will see this issue.'),
                  activeColor: AppColors.primary,
                  value: _isPrivate,
                  onChanged: (bool value) => setState(() => _isPrivate = value),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<ComplaintCategory>(
                value: _selectedCategory,
                hint: const Text('Select issue type...'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _availableCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(_formatCategoryName(category)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 24),
              const Text('Issue Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Keep it short and descriptive...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 24),
              const Text('Detailed Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Provide details so staff can resolve it quickly...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.length < 10 ? 'Provide more details' : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text(
                    'Submit Complaint',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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