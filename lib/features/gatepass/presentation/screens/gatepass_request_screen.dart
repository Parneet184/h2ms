// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../data/pass_repository.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/constants/enums.dart';
// import '../../../auth/application/auth_provider.dart';
// import '../../domain/pass_model.dart';
// import '../../application/pass_providers.dart';
//
//
// class GatepassRequestScreen extends ConsumerStatefulWidget {
//   const GatepassRequestScreen({super.key});
//
//   @override
//   ConsumerState<GatepassRequestScreen> createState() => _GatepassRequestScreenState();
// }
//
// class _GatepassRequestScreenState extends ConsumerState<GatepassRequestScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _reasonController = TextEditingController();
//
//   DateTime? _requestedOutTime;
//   DateTime? _expectedInTime;
//
//   @override
//   void dispose() {
//     _reasonController.dispose();
//     super.dispose();
//   }
//
//   // Helper to pick Date and Time
//   Future<void> _pickDateTime({required bool isOutTime}) async {
//     // For a Gatepass, they usually leave today, but we give a 1-day window just in case.
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 1)),
//     );
//
//     if (pickedDate != null && mounted) {
//       final TimeOfDay? pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );
//
//       if (pickedTime != null) {
//         final selectedDateTime = DateTime(
//           pickedDate.year,
//           pickedDate.month,
//           pickedDate.day,
//           pickedTime.hour,
//           pickedTime.minute,
//         );
//
//         setState(() {
//           if (isOutTime) {
//             _requestedOutTime = selectedDateTime;
//             // Auto-set Expected In Time to 2 hours later for convenience
//             _expectedInTime ??= selectedDateTime.add(const Duration(hours: 2));
//           } else {
//             _expectedInTime = selectedDateTime;
//           }
//         });
//       }
//     }
//   }
//
//   void _submitRequest() {
//     if (_formKey.currentState!.validate()) {
//       if (_requestedOutTime == null || _expectedInTime == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please select both Out and In times.'), backgroundColor: AppColors.error),
//         );
//         return;
//       }
//
//       if (_expectedInTime!.isBefore(_requestedOutTime!)) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Return time cannot be before Out time.'), backgroundColor: AppColors.error),
//         );
//         return;
//       }
//
//       final user = ref.read(currentUserProvider);
//
//       final newPass = PassModel(
//         id: 'pass_${DateTime.now().millisecondsSinceEpoch}',
//         studentUid: user!.uid,
//         studentName: user.name,
//         roomNumber: user.roomNumber,
//         type: PassType.gatepass, // HARDCODED to gatepass for this screen
//         status: PassStatus.pending,
//         reason: _reasonController.text.trim(),
//         requestedOutTime: _requestedOutTime!,
//         expectedInTime: _expectedInTime!,
//       );
//
//       ref.read(passRepositoryProvider).createNewPass(newPass);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Gatepass Request Submitted!'), backgroundColor: AppColors.success),
//       );
//       Navigator.pop(context);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Request Gatepass'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Notice banner specific to Gatepasses
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 margin: const EdgeInsets.only(bottom:24),
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryLight.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.info_outline, color: AppColors.primary),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         'Gatepasses are for short trips outside the campus (e.g., market, stationary).',
//                         style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // --- 1. Reason Text Field ---
//               const Text('Reason for leaving', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _reasonController,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   hintText: 'E.g., Going to the local market for stationery...',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                   filled: true,
//                   fillColor: AppColors.surface,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) return 'Please enter a reason';
//                   if (value.length < 5) return 'Reason is too short';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),
//
//               // --- 2. Date & Time Pickers ---
//               const Text('Timings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//               const SizedBox(height: 10),
//               Card(
//                 margin: EdgeInsets.zero,
//                 child: Column(
//                   children: [
//                     ListTile(
//                       leading: const Icon(Icons.output, color: AppColors.warning),
//                       title: const Text('Requested Out Time'),
//                       subtitle: Text(_requestedOutTime != null
//                           ? _formatDateTime(_requestedOutTime!)
//                           : 'Tap to select'),
//                       onTap: () => _pickDateTime(isOutTime: true),
//                     ),
//                     const Divider(height: 1),
//                     ListTile(
//                       leading: const Icon(Icons.login, color: AppColors.success),
//                       title: const Text('Expected Return Time'),
//                       subtitle: Text(_expectedInTime != null
//                           ? _formatDateTime(_expectedInTime!)
//                           : 'Tap to select'),
//                       onTap: () => _pickDateTime(isOutTime: false),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 40),
//
//               // --- 3. Submit Button ---
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _submitRequest,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _formatDateTime(DateTime dt) {
//     final time = TimeOfDay.fromDateTime(dt);
//     final period = time.period == DayPeriod.am ? 'AM' : 'PM';
//     final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
//     final minute = time.minute.toString().padLeft(2, '0');
//     return '${dt.day}/${dt.month}/${dt.year} at $hour:$minute $period';
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

class GatepassRequestScreen extends ConsumerStatefulWidget {
  const GatepassRequestScreen({super.key});

  @override
  ConsumerState<GatepassRequestScreen> createState() => _GatepassRequestScreenState();
}

class _GatepassRequestScreenState extends ConsumerState<GatepassRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  DateTime? _requestedOutTime;
  DateTime? _expectedInTime;
  bool _isSubmitting = false; // Added to prevent double-tapping the submit button

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
      lastDate: DateTime.now().add(const Duration(days: 1)),
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

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      if (_requestedOutTime == null || _expectedInTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both Out and In times.'), backgroundColor: AppColors.error),
        );
        return;
      }

      if (_expectedInTime!.isBefore(_requestedOutTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Return time cannot be before Out time.'), backgroundColor: AppColors.error),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        final user = ref.read(currentUserProvider);

        final newPass = PassModel(
          id: '', // Supabase will auto-generate the ID as a UUID
          studentUid: user!.uid,
          studentName: user.name,
          roomNumber: user.roomNumber,
          type: PassType.gatepass,
          status: PassStatus.pending,
          reason: _reasonController.text.trim(),
          // FIX APPLIED HERE: Convert local pickers to UTC before sending
          requestedOutTime: _requestedOutTime!.toUtc(),
          expectedInTime: _expectedInTime!.toUtc(),
        );

        // Await the push to the database
        await ref.read(passRepositoryProvider).createNewPass(newPass);

        // Refresh the student's history so the new pass shows up instantly
        ref.invalidate(studentHistoryProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gatepass Request Submitted!'), backgroundColor: AppColors.success),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
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
        title: const Text('Request Gatepass'),
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
                margin: const EdgeInsets.only(bottom:24),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Gatepasses are for short trips outside the campus (e.g., market, stationary).',
                        style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
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
                  if (value == null || value.trim().isEmpty) return 'Please enter a reason';
                  if (value.length < 5) return 'Reason is too short';
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
                      leading: const Icon(Icons.output, color: AppColors.warning),
                      title: const Text('Requested Out Time'),
                      subtitle: Text(_requestedOutTime != null
                          ? _formatDateTime(_requestedOutTime!)
                          : 'Tap to select'),
                      onTap: () => _pickDateTime(isOutTime: true),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.login, color: AppColors.success),
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
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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