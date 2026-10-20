import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../auth/application/auth_provider.dart';
import '../../domain/pass_model.dart';
import '../../application/pass_providers.dart';
import '../../data/pass_repository.dart';

class RequestPassScreen extends ConsumerStatefulWidget {
  const RequestPassScreen({super.key});

  @override
  ConsumerState<RequestPassScreen> createState() => _RequestPassScreenState();
}

class _RequestPassScreenState extends ConsumerState<RequestPassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  PassType _selectedType = PassType.gatepass;
  DateTime? _requestedOutTime;
  DateTime? _expectedInTime;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isOutTime}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isOutTime) {
            _requestedOutTime = selectedDateTime;
            _expectedInTime ??= selectedDateTime.add(const Duration(hours: 2));
          } else {
            _expectedInTime = selectedDateTime;
          }
        });
      }
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      if (_requestedOutTime == null || _expectedInTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar( // <-- Removed const
              content: const Text('Please select both Out and In times.'),
              backgroundColor: AppColors.error
          ),
        );
        return;
      }

      if (_expectedInTime!.isBefore(_requestedOutTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar( // <-- Removed const
              content: const Text('Return time cannot be before Out time.'),
              backgroundColor: AppColors.error
          ),
        );
        return;
      }

      final user = ref.read(currentUserProvider);

      final newPass = PassModel(
        id: 'pass_${DateTime.now().millisecondsSinceEpoch}',
        studentUid: user!.uid,
        studentName: user.name,
        roomNumber: '101',
        type: _selectedType,
        status: PassStatus.pending,
        reason: _reasonController.text.trim(),
        requestedOutTime: _requestedOutTime!,
        expectedInTime: _expectedInTime!,
      );

      ref.read(passRepositoryProvider).createNewPass(newPass);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar( // <-- Removed const
            content: const Text('Pass Request Submitted!'),
            backgroundColor: AppColors.success
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Pass'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pass Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              SegmentedButton<PassType>(
                segments: const [
                  ButtonSegment(value: PassType.gatepass, label: Text('Gatepass (Short)')),
                  ButtonSegment(value: PassType.leave, label: Text('Leave (Long)')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<PassType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primaryLight.withOpacity(0.2);
                    }
                    return Colors.transparent;
                  }),
                ),
              ),
              const SizedBox(height: 24),

              const Text('Reason for leaving', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'E.g., Going to the local market for stationery...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a reason';
                  }
                  if (value.length < 5) {
                    return 'Reason is too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              const Text('Timings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.output, color: AppColors.warning), // Removed const
                      title: const Text('Requested Out Time'),
                      subtitle: Text(_requestedOutTime != null
                          ? _formatDateTime(_requestedOutTime!)
                          : 'Tap to select'),
                      onTap: () => _pickDateTime(isOutTime: true),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.login, color: AppColors.success), // Removed const
                      title: const Text('Expected Return Time'),
                      subtitle: Text(_expectedInTime != null
                          ? _formatDateTime(_expectedInTime!)
                          : 'Tap to select'),
                      onTap: () => _pickDateTime(isOutTime: false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final time = TimeOfDay.fromDateTime(dt);
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} at $hour:$minute $period';
  }
}