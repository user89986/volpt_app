// lib/utils/build_route_latlng.dart
import 'package:latlong2/latlong.dart';
import '../models/floor.dart';
import '../models/graph.dart';
import 'pathfinding.dart';

/// Преобразует путь узлов в LatLng для flutter_map с CRS Simple.
/// Важно: [scale] должен совпадать со значением S в FloorMap.
List<LatLng> buildRouteLatLng({
  required Floor floor,
  required List<GraphNode> nodes,
  required List<GraphEdge> edges,
  required GraphNode start,
  required GraphNode goal,
  double scale = 0.0009,
}) {
  final ids = shortestPath(nodes: nodes, edges: edges, startId: start.id, goalId: goal.id);
  if (ids.isEmpty) return const [];
  final w = floor.imageWidth.toDouble();
  final h = floor.imageHeight.toDouble();
  final byId = {for (final n in nodes) n.id: n};
  return [
    for (final id in ids)
      LatLng(byId[id]!.yNorm * h * scale, byId[id]!.xNorm * w * scale),
  ];
}
