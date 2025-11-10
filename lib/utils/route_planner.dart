import 'dart:ui';
import '../models/floor.dart';
import '../models/room.dart';
import '../models/graph.dart';
import 'pathfinding.dart';

/// Перевод CRS Simple (LatLng) -> нормализованные [0..1]
/// lat = y * scale * H, lng = x * scale * W  =>  x = lng/(W*scale), y = lat/(H*scale)
Map<String, double> centerCrsToNorm({
  required Floor floor,
  required double latitude,
  required double longitude,
  double scale = 0.0009,
}) {
  final w = floor.imageWidth.toDouble();
  final h = floor.imageHeight.toDouble();
  final xNorm = longitude / (w * scale);
  final yNorm = latitude  / (h * scale);
  return {'x': xNorm, 'y': yNorm};
}

GraphNode? closestNodeTo(List<GraphNode> nodes, double x, double y) {
  if (nodes.isEmpty) return null;
  GraphNode best = nodes.first;
  double bestD = double.infinity;
  for (final n in nodes) {
    final dx = n.xNorm - x;
    final dy = n.yNorm - y;
    final d = dx*dx + dy*dy;
    if (d < bestD) { bestD = d; best = n; }
  }
  return best;
}

/// Узел для кабинета: сперва по nearest_node_id, если нет — ближайший к центру кабинета.
GraphNode? nodeForRoom(List<GraphNode> nodes, Room r) {
  if (nodes.isEmpty) return null;
  if (r.nearestNodeId != null) {
    final hit = nodes.where((n) => n.id == r.nearestNodeId);
    if (hit.isNotEmpty) return hit.first;
  }
  return closestNodeTo(nodes, r.xNorm, r.yNorm);
}

/// (опционально) пиксели — если когда-нибудь понадобится старый рендер.
List<Offset> buildRoutePixels({
  required Floor floor,
  required List<GraphNode> nodes,
  required List<GraphEdge> edges,
  required GraphNode start,
  required GraphNode goal,
}) {
  final ids = shortestPath(nodes: nodes, edges: edges, startId: start.id, goalId: goal.id);
  if (ids.isEmpty) return const [];
  final w = floor.imageWidth.toDouble();
  final h = floor.imageHeight.toDouble();
  final byId = {for (final n in nodes) n.id: n};
  return [for (final id in ids) Offset(byId[id]!.xNorm*w, byId[id]!.yNorm*h)];
}
