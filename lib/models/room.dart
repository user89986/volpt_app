// lib/models/room.dart
class Room {
  final int id;
  final int floorId;
  final String name;
  final double xNorm; // 0..1
  final double yNorm; // 0..1
  final String? info;

  // NEW: может быть null, если мы ещё не привязали кабинет к узлу
  final int? nearestNodeId;

  Room({
    required this.id,
    required this.floorId,
    required this.name,
    required this.xNorm,
    required this.yNorm,
    this.info,
    this.nearestNodeId, // NEW
  });

  factory Room.fromJson(Map<String, dynamic> j) => Room(
        id: j['id'] as int,
        floorId: j['floor_id'] as int,
        name: j['name'] as String,
        xNorm: (j['x_norm'] as num).toDouble(),
        yNorm: (j['y_norm'] as num).toDouble(),
        info: j['info'] as String?,
        // NEW: безопасно читаем nullable int
        nearestNodeId: j['nearest_node_id'] as int?,
      );
}
