// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/enums.dart';
// import '../../../auth/application/auth_provider.dart';
// import '../../domain/pass_model.dart';
// import '../../application/pass_providers.dart';
// import '../../data/pass_repository.dart';
//
// class LeaveRequestScreen extends ConsumerStatefulWidget {
//   const LeaveRequestScreen({super.key});
//
//   @override
//   ConsumerState<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
// }
//
// class _LeaveRequestScreenState extends ConsumerState<LeaveRequestScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   // Controllers
//   final _addressController = TextEditingController();
//
//   // State variables
//   String? _selectedReason;
//   DateTime? _outDate;
//   DateTime? _inDate;
//   TimeOfDay? _outTime;
//
//   final List<String> _leaveReasons = [
//     'Vacation',
//     'Holiday',
//     'Request from parents',
//     'Medical leave',
//     'Weekend',
//     'Summer vacation',
//     'Winter vacation'
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     // Pre-fill the address with the student's saved Home Address!
//     final user = ref.read(currentUserProvider);
//     if (user != null && user.homeAddress.isNotEmpty) {
//       _addressController.text = user.homeAddress;
//     }
//   }
//
//   @override
//   void dispose() {
//     _addressController.dispose();
//     super.dispose();
//   }
//
//   // Helper to pick Dates
//   Future<void> _pickDate({required bool isOutDate}) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: isOutDate ? DateTime.now() : (_outDate ?? DateTime.now()),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)), // Up to a year in advance
//     );
//
//     if (pickedDate != null && mounted) {
//       setState(() {
//         if (isOutDate) {
//           _outDate = pickedDate;
//           // If inDate is now before outDate, reset it
//           if (_inDate != null && _inDate!.isBefore(_outDate!)) {
//             _inDate = null;
//           }
//         } else {
//           _inDate = pickedDate;
//         }
//       });
//     }
//   }
//
//   // Helper to pick Time
//   Future<void> _pickTime() async {
//     final TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//
//     if (pickedTime != null && mounted) {
//       setState(() {
//         _outTime = pickedTime;
//       });
//     }
//   }
//
//   void _submitRequest() {
//     if (_formKey.currentState!.validate()) {
//       if (_selectedReason == null) {
//         _showError('Please select a reason for your leave.');
//         return;
//       }
//       if (_outDate == null || _inDate == null || _outTime == null) {
//         _showError('Please select Out Date, Out Time, and Expected Return Date.');
//         return;
//       }
//
//       // Combine Date and Time for the final DateTime objects
//       final requestedOutTime = DateTime(
//         _outDate!.year, _outDate!.month, _outDate!.day,
//         _outTime!.hour, _outTime!.minute,
//       );
//
//       // Since we don't ask for an "In Time", we default to 6:00 PM (18:00) on the return date
//       final expectedInTime = DateTime(
//         _inDate!.year, _inDate!.month, _inDate!.day,
//         18, 0,
//       );
//
//       if (expectedInTime.isBefore(requestedOutTime)) {
//         _showError('Return date cannot be before Out date.');
//         return;
//       }
//
//       final user = ref.read(currentUserProvider);
//
//       // Create the Pass Model
//       final newPass = PassModel(
//         id: 'leave_${DateTime.now().millisecondsSinceEpoch}',
//         studentUid: user!.uid,
//         studentName: user.name,
//         roomNumber: user.roomNumber,
//         type: PassType.leave, // Hardcoded to Leave
//         status: PassStatus.pending,
//         reason: '$_selectedReason - Address: ${_addressController.text.trim()}',
//         requestedOutTime: requestedOutTime,
//         expectedInTime: expectedInTime,
//       );
//
//       // Save to database
//       ref.read(passRepositoryProvider).createNewPass(newPass);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Leave Application Submitted!'), backgroundColor: AppColors.success),
//       );
//       Navigator.pop(context);
//     }
//   }
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: AppColors.error),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Apply for Leave'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Notice Banner
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 margin: const EdgeInsets.only(bottom: 24),
//                 decoration: BoxDecoration(
//                   color: AppColors.warning.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: AppColors.warning.withOpacity(0.3)),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.warning_amber_rounded, color: AppColors.warning),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         'Leaves require Warden approval. Please submit your request at least 24 hours in advance.',
//                         style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // --- 1. Reason Selection ---
//               const Text('Reason for Leave', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//               const SizedBox(height: 10),
//               DropdownButtonFormField<String>(
//                 value: _selectedReason,
//                 hint: const Text('Select a reason...'),
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.surface,
//                 ),
//                 items: _leaveReasons.map((reason) {
//                   return DropdownMenuItem(
//                     value: reason,
//                     child: Text(reason),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedReason = value;
//                   });
//                 },
//                 validator: (value) => value == null ? 'Please select a reason' : null,
//               ),
//               const SizedBox(height: 24),
//
//               // --- 2. Address During Leave ---
//               const Text('Address During Leave', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _addressController,
//                 maxLines: 2,
//                 decoration: InputDecoration(
//                   hintText: 'Where will you be staying?',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.surface,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) return 'Please provide an address';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),
//
//               // --- 3. Dates & Times ---
//               const Text('Leave Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//               const SizedBox(height: 10),
//               Card(
//                 margin: EdgeInsets.zero,
//                 shape: RoundedRectangleBorder(
//                   side: BorderSide(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   children: [
//                     // OUT DATE
//                     ListTile(
//                       leading: const Icon(Icons.event_busy, color: AppColors.warning),
//                       title: const Text('Departure Date'),
//                       subtitle: Text(_outDate != null ? _formatDate(_outDate!) : 'Tap to select'),
//                       onTap: () => _pickDate(isOutDate: true),
//                     ),
//                     const Divider(height: 1),
//                     // OUT TIME
//                     ListTile(
//                       leading: const Icon(Icons.access_time, color: AppColors.warning),
//                       title: const Text('Departure Time'),
//                       subtitle: Text(_outTime != null ? _outTime!.format(context) : 'Tap to select'),
//                       onTap: _pickTime,
//                     ),
//                     const Divider(height: 1),
//                     // IN DATE
//                     ListTile(
//                       leading: const Icon(Icons.event_available, color: AppColors.success),
//                       title: const Text('Return Date'),
//                       subtitle: Text(_inDate != null ? _formatDate(_inDate!) : 'Tap to select'),
//                       onTap: () => _pickDate(isOutDate: false),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 40),
//
//               // --- 4. Submit Button ---
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _submitRequest,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: const Text('Submit Application', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _formatDate(DateTime dt) {
//     return '${dt.day}/${dt.month}/${dt.year}';
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/pass_repository.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/enums.dart';
import '../../../auth/application/auth_provider.dart';
import '../../domain/pass_model.dart';
import '../../application/pass_providers.dart';

class LeaveRequestScreen extends ConsumerStatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  ConsumerState<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends ConsumerState<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();

  String? _selectedReason;
  DateTime? _outDate;
  DateTime? _inDate;
  TimeOfDay? _outTime;
  bool _isSubmitting = false;

  final List<String> _leaveReasons = [
    'Vacation',
    'Holiday',
    'Request from parents',
    'Medical leave',
    'Weekend',
    'Summer vacation',
    'Winter vacation'
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null && user.homeAddress.isNotEmpty) {
      _addressController.text = user.homeAddress;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isOutDate}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isOutDate ? DateTime.now() : (_outDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        if (isOutDate) {
          _outDate = pickedDate;
          if (_inDate != null && _inDate!.isBefore(_outDate!)) {
            _inDate = null;
          }
        } else {
          _inDate = pickedDate;
        }
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && mounted) {
      setState(() {
        _outTime = pickedTime;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedReason == null) {
        _showError('Please select a reason for your leave.');
        return;
      }
      if (_outDate == null || _inDate == null || _outTime == null) {
        _showError('Please select Out Date, Out Time, and Expected Return Date.');
        return;
      }

      final requestedOutTime = DateTime(
        _outDate!.year, _outDate!.month, _outDate!.day,
        _outTime!.hour, _outTime!.minute,
      );

      final expectedInTime = DateTime(
        _inDate!.year, _inDate!.month, _inDate!.day,
        18, 0,
      );

      if (expectedInTime.isBefore(requestedOutTime)) {
        _showError('Return date cannot be before Out date.');
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        final user = ref.read(currentUserProvider);

        final newPass = PassModel(
          id: '', // Supabase generates this
          studentUid: user!.uid,
          studentName: user.name,
          roomNumber: user.roomNumber,
          type: PassType.leave,
          status: PassStatus.pending,
          reason: '$_selectedReason - Address: ${_addressController.text.trim()}',
          requestedOutTime: requestedOutTime,
          expectedInTime: expectedInTime,
        );

        // Await the push to the database
        await ref.read(passRepositoryProvider).createNewPass(newPass);

        // Refresh the student's history list
        ref.invalidate(studentHistoryProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Leave Application Submitted!'), backgroundColor: AppColors.success),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        _showError('Error submitting leave: $e');
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Leave'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Leaves require Warden approval. Please submit your request at least 24 hours in advance.',
                        style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const Text('Reason for Leave', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                hint: const Text('Select a reason...'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                items: _leaveReasons.map((reason) {
                  return DropdownMenuItem(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedReason = value),
                validator: (value) => value == null ? 'Please select a reason' : null,
              ),
              const SizedBox(height: 24),
              const Text('Address During Leave', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Where will you be staying?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Please provide an address' : null,
              ),
              const SizedBox(height: 24),
              const Text('Leave Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.event_busy, color: AppColors.warning),
                      title: const Text('Departure Date'),
                      subtitle: Text(_outDate != null ? _formatDate(_outDate!) : 'Tap to select'),
                      onTap: () => _pickDate(isOutDate: true),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.access_time, color: AppColors.warning),
                      title: const Text('Departure Time'),
                      subtitle: Text(_outTime != null ? _outTime!.format(context) : 'Tap to select'),
                      onTap: _pickTime,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.event_available, color: AppColors.success),
                      title: const Text('Return Date'),
                      subtitle: Text(_inDate != null ? _formatDate(_inDate!) : 'Tap to select'),
                      onTap: () => _pickDate(isOutDate: false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit Application', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}