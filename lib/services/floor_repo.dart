// lib/services/floor_repo.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/floor.dart';

class FloorRepo {
  final _db = Supabase.instance.client;

  Future<List<Floor>> fetchFloors() async {
  final res = await _db.from('floors').select().order('id', ascending: true);
  return (res as List)
      .map<Floor>((e) => Floor.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

Future<Floor> getFloor(int id) async {
  final res = await _db.from('floors').select().eq('id', id).single();
  return Floor.fromJson(Map<String, dynamic>.from(res));
}

}
