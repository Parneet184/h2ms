import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/visitor_model.dart';

// Provider that supplies the list of visitors sorted by date (newest first)
final visitorsProvider = Provider<List<VisitorModel>>((ref) {
  final now = DateTime.now();

  final visitors = [
    VisitorModel(
      id: 'v1',
      title: 'Family Visit',
      visitDate: now.subtract(const Duration(days: 5, hours: 2)),
      duration: '3 hours',
      numberOfVisitors: 3,
      visitorNames: ['Mr. Singh (Father)', 'Mrs. Kaur (Mother)', 'Aman Singh (Brother)'],
      relation: 'Family',
      purpose: 'Dropping off winter clothes and snacks.',
    ),
    VisitorModel(
      id: 'v2',
      title: 'Local Guardian Visit',
      visitDate: now.subtract(const Duration(days: 15, hours: 5)),
      duration: '45 mins',
      numberOfVisitors: 1,
      visitorNames: ['Rajesh Kumar'],
      relation: 'Local Guardian',
      purpose: 'Routine check-in and document signing.',
    ),
    VisitorModel(
      id: 'v3',
      title: 'Friend Visit',
      visitDate: now.subtract(const Duration(days: 42, hours: 1)),
      duration: '2 hours',
      numberOfVisitors: 2,
      visitorNames: ['Rahul Sharma', 'Vikram Singh'],
      relation: 'Friends',
      purpose: 'Group study for mid-term exams.',
    ),
  ];

  // Ensure they are sorted from newest to oldest
  visitors.sort((a, b) => b.visitDate.compareTo(a.visitDate));
  return visitors;
});