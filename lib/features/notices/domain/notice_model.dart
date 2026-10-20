// class NoticeModel {
//   final String id;
//   final String title;
//   final String shortDescription;
//   final String fullDescription;
//   final String postedBy; // e.g., 'Warden', 'DSW', etc.
//   final DateTime postedAt;
//   final bool hasAttachment;
//   final String? attachmentName;
//
//   NoticeModel({
//     required this.id,
//     required this.title,
//     required this.shortDescription,
//     required this.fullDescription,
//     required this.postedBy,
//     required this.postedAt,
//     this.hasAttachment = false,
//     this.attachmentName,
//   });
// }

class NoticeModel {
  final String id;
  final String title;
  final String shortDescription;
  final String fullDescription;
  final String postedBy;
  final DateTime postedAt;
  final bool hasAttachment;
  final String? attachmentName;

  NoticeModel({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    required this.postedBy,
    required this.postedAt,
    this.hasAttachment = false,
    this.attachmentName,
  });

  // Factory to parse from Supabase JSON rows
  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      shortDescription: json['short_description'] ?? '',
      fullDescription: json['full_description'] ?? '',
      postedBy: json['posted_by'] ?? 'Administration',
      postedAt: json['posted_at'] != null
          ? DateTime.parse(json['posted_at']).toLocal()
          : DateTime.now(),
      hasAttachment: json['has_attachment'] ?? false,
      attachmentName: json['attachment_name'],
    );
  }

  // Convert to JSON if needed for writing/inserting
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'short_description': shortDescription,
      'full_description': fullDescription,
      'posted_by': postedBy,
      'posted_at': postedAt.toIso8601String(),
      'has_attachment': hasAttachment,
      'attachment_name': attachmentName,
    };
  }
}