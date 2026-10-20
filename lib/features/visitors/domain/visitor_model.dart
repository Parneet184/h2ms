class VisitorModel {
  final String id;
  final String title; // e.g., "Family Visit", "Friend Visit"
  final DateTime visitDate;
  final String duration; // e.g., "2 hours", "45 mins"
  final int numberOfVisitors;
  final List<String> visitorNames;
  final String relation; // e.g., "Family", "Friend", "Guardian"
  final String purpose;

  VisitorModel({
    required this.id,
    required this.title,
    required this.visitDate,
    required this.duration,
    required this.numberOfVisitors,
    required this.visitorNames,
    required this.relation,
    required this.purpose,
  });
}