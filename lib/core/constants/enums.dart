enum UserRole {
  student,
  warden,
  guard,
  messIncharge,
  superAdmin,
}

// NEW ENUMS FOR GATEPASS FEATURE
enum PassType {
  gatepass, // Short duration (e.g., going to the market for 2 hours)
  leave,    // Long duration (e.g., going home for the weekend)
}

enum PassStatus {
  pending,    // Waiting for Warden
  approved,   // Warden approved, ready for Guard to scan OUT
  active,     // Guard scanned OUT, student is outside
  completed,  // Guard scanned IN, student returned
  rejected,   // Warden denied
  expired,    // Student never left, pass time ran out
}

enum ComplaintCategory {
  // Hostel Categories
  plumbing,
  electricity,
  carpentry,
  furniture,
  ground,
  cleanliness,
  indiscipline,

  // Mess Categories
  foodQuality,
  staffBehavior,
  messCleanliness,

  // General
  other,
}

enum ComplaintStatus {
  open,
  inProgress,
  resolved,
}
enum HostelType {
  boys,
  girls,
  none, // For day scholars or staff
}