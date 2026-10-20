import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/room_info_model.dart';

// A provider that supplies the current user's room details
final roomInfoProvider = Provider<RoomInfoModel>((ref) {
  return RoomInfoModel(
    roomNumber: '101',
    isAC: true,
    capacity: 3, // The user + 2 roommates
    furniture: RoomFurniture(
      beds: 3,
      tables: 3,
      chairs: 3,
      almirahs: 3,
    ),
    roommates: [
      RoommateModel(
        name: 'Aarav Sharma',
        uid: '23F06015',
        department: 'Computer Science',
        contact: '+91 9876543220',
      ),
      RoommateModel(
        name: 'Ravi Kumar',
        uid: '23F06042',
        department: 'Information Tech',
        contact: '+91 9876543221',
      ),
    ],
  );
});