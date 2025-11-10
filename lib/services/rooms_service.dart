// lib/services/rooms_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room.dart';

class RoomsService {
  final _db = Supabase.instance.client;

  Future<List<Room>> fetchRooms(int floorId) async {
    final res = await _db
        .from('rooms')
        .select('id,floor_id,name,x_norm,y_norm,info,nearest_node_id')
        .eq('floor_id', floorId)
        .order('name');
    return (res as List)
        .map((e) => Room.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> updateRoomPosition({
    required int roomId,
    required double xNorm,
    required double yNorm,
  }) async {
    await _db.from('rooms').update({
      'x_norm': xNorm,
      'y_norm': yNorm,
    }).eq('id', roomId);
  }
}
