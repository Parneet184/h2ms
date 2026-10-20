class RoommateModel {
  final String name;
  final String uid;
  final String department;
  final String contact;

  RoommateModel({
    required this.name,
    required this.uid,
    required this.department,
    required this.contact,
  });
}

class RoomFurniture {
  final int beds;
  final int tables;
  final int chairs;
  final int almirahs;

  RoomFurniture({
    required this.beds,
    required this.tables,
    required this.chairs,
    required this.almirahs,
  });
}

class RoomInfoModel {
  final String roomNumber;
  final bool isAC;
  final int capacity;
  final List<RoommateModel> roommates;
  final RoomFurniture furniture;

  RoomInfoModel({
    required this.roomNumber,
    required this.isAC,
    required this.capacity,
    required this.roommates,
    required this.furniture,
  });
}