enum SosType { medical, security, missingStudent, fire }
enum SosStatus { active, acknowledged, resolved }

class SosAlertModel {
  final String id;
  final SosType type;
  final String title;
  final String description;
  final String location;
  final String reportedBy;
  final DateTime reportedAt;
  final String? contactNumber;
  SosStatus status;

  SosAlertModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.location,
    required this.reportedBy,
    required this.reportedAt,
    this.contactNumber,
    required this.status,
  });

  factory SosAlertModel.fromJson(Map<String, dynamic> json) {
    return SosAlertModel(
      id: json['id']?.toString() ?? '',
      type: SosType.values.firstWhere(
            (e) => e.name.toLowerCase() == (json['type'] ?? '').toString().toLowerCase(),
        orElse: () => SosType.security,
      ),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      reportedBy: json['reported_by'] ?? 'Unknown',
      reportedAt: json['reported_at'] != null ? DateTime.parse(json['reported_at']).toLocal() : DateTime.now(),
      contactNumber: json['contact_number'],
      status: SosStatus.values.firstWhere(
            (e) => e.name.toLowerCase() == (json['status'] ?? '').toString().toLowerCase(),
        orElse: () => SosStatus.active,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'title': title,
      'description': description,
      'location': location,
      'reported_by': reportedBy,
      'reported_at': reportedAt.toIso8601String(),
      'contact_number': contactNumber,
      'status': status.name,
    };
  }
}