import '../../../../core/constants/enums.dart';

class ComplaintModel {
  final String id;
  final String title;
  final String description;
  final String authorName;
  final String authorUid;
  final String roomNumber;
  final ComplaintCategory category;
  final ComplaintStatus status;
  final DateTime postedAt;
  final int upvotes;
  final bool hasUpvoted;
  final bool isPrivate;
  final String? assignedTo;

  ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.authorName,
    required this.authorUid,
    required this.roomNumber,
    required this.category,
    required this.status,
    required this.postedAt,
    required this.upvotes,
    required this.hasUpvoted,
    required this.isPrivate,
    this.assignedTo,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      authorName: json['author_name'] ?? 'Unknown',
      authorUid: json['author_uid'] ?? '',
      roomNumber: json['room_number'] ?? 'N/A',
      category: ComplaintCategory.values.firstWhere(
            (e) => e.name.toLowerCase() == (json['category'] ?? '').toString().toLowerCase(),
        orElse: () => ComplaintCategory.other,
      ),
      status: ComplaintStatus.values.firstWhere(
            (e) => e.name.toLowerCase() == (json['status'] ?? '').toString().toLowerCase(),
        orElse: () => ComplaintStatus.open,
      ),
      postedAt: json['posted_at'] != null ? DateTime.parse(json['posted_at']).toLocal() : DateTime.now(),
      upvotes: json['upvotes'] ?? 0,
      hasUpvoted: json['has_upvoted'] ?? false,
      isPrivate: json['is_private'] ?? false,
      assignedTo: json['assigned_to'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'author_uid': authorUid,
      'author_name': authorName,
      'room_number': roomNumber,
      'category': category.name,
      'status': status.name,
      'posted_at': postedAt.toIso8601String(),
      'upvotes': upvotes,
      'is_private': isPrivate,
      'assigned_to': assignedTo,
    };
  }
}