// lib/utils/pathfinding.dart
import '../models/graph.dart';
import 'dart:collection';

/// Обычный Дейкстра по весам рёбер. Без штрафов, без «упрощателей».
List<int> shortestPath({
  required List<GraphNode> nodes,
  required List<GraphEdge> edges,
  required int startId,
  required int goalId,
}) {
  if (startId == goalId) return [startId];
  if (nodes.isEmpty || edges.isEmpty) return const [];

  final adj = <int, List<GraphEdge>>{};
  for (final e in edges) {
    (adj[e.fromId] ??= <GraphEdge>[]).add(e);
  }

  final dist = <int, double>{};
  final prev = <int, int?>{};
  final seen = <int, bool>{};
  final pq = PriorityQueue<MapEntry<int, double>>((a, b) => a.value.compareTo(b.value));

  for (final n in nodes) {
    dist[n.id] = double.infinity;
    prev[n.id] = null;
    seen[n.id] = false;
  }

  dist[startId] = 0.0;
  pq.add(MapEntry(startId, 0.0));

  while (pq.isNotEmpty) {
    final u = pq.removeFirst().key;
    if (seen[u] == true) continue;
    seen[u] = true;
    if (u == goalId) break;

    for (final e in adj[u] ?? const <GraphEdge>[]) {
      final v = e.toId;
      final alt = (dist[u] ?? double.infinity) + e.weight;
      if (alt < (dist[v] ?? double.infinity)) {
        dist[v] = alt;
        prev[v] = u;
        pq.add(MapEntry(v, alt));
      }
    }
  }

  if (prev[goalId] == null) return const [];
  final path = <int>[];
  int? cur = goalId;
  while (cur != null) {
    path.add(cur);
    cur = prev[cur];
  }
  return path.reversed.toList();
}

class PriorityQueue<T> {
  final int Function(T, T) cmp;
  final List<T> _a = [];
  PriorityQueue(this.cmp);
  bool get isNotEmpty => _a.isNotEmpty;
  void add(T x) { _a.add(x); _up(_a.length - 1); }
  T removeFirst() {
    final res = _a.first;
    final last = _a.removeLast();
    if (_a.isNotEmpty) { _a[0] = last; _down(0); }
    return res;
  }
  void _up(int i) {
    while (i > 0) {
      final p = (i - 1) >> 1;
      if (cmp(_a[i], _a[p]) < 0) { final t=_a[i]; _a[i]=_a[p]; _a[p]=t; i=p; } else break;
    }
  }
  void _down(int i) {
    final n = _a.length;
    while (true) {
      final l=i*2+1, r=l+1;
      var m=i;
      if (l<n && cmp(_a[l], _a[m])<0) m=l;
      if (r<n && cmp(_a[r], _a[m])<0) m=r;
      if (m==i) break;
      final t=_a[i]; _a[i]=_a[m]; _a[m]=t; i=m;
    }
  }
}
