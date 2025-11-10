// lib/models/graph.dart

class GraphNode {
  final int id;
  final int floorId;
  final double xNorm;
  final double yNorm;
  final String kind;

  GraphNode({
    required this.id,
    required this.floorId,
    required this.xNorm,
    required this.yNorm,
    required this.kind,
  });

  factory GraphNode.fromJson(Map<String, dynamic> json) {
    return GraphNode(
      id: json['id'] as int,
      floorId: json['floor_id'] as int,
      xNorm: (json['x_norm'] as num).toDouble(),
      yNorm: (json['y_norm'] as num).toDouble(),
      kind: json['kind'] as String,
    );
  }
}

class GraphEdge {
  final int id;
  final int floorId;
  final int a;
  final int b;
  final double weight;
  final int fromId;
  final int toId;

  GraphEdge({
    required this.id,
    required this.floorId,
    required this.a,
    required this.b,
    required this.weight,
    required this.fromId,
    required this.toId,
  });

  factory GraphEdge.fromJson(Map<String, dynamic> json) {
    return GraphEdge(
      id: json['id'] as int,
      floorId: json['floor_id'] != null ? json['floor_id'] as int : 1, // дефолт 1
      a: json['a'] is int ? json['a'] as int : 0,
      b: json['b'] is int ? json['b'] as int : 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      fromId: json['from_id'] as int,
      toId: json['to_id'] as int,
    );
  }
}
