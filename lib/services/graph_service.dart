import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/graph.dart';

class GraphService {
  final SupabaseClient db;
  GraphService(this.db);

  Future<List<GraphNode>> getNodes(int floorId) async {
    final res = await db.from('graph_nodes').select().eq('floor_id', floorId);
    final data = List<Map<String, dynamic>>.from(res);
    return data.map(GraphNode.fromJson).toList();
  }

  Future<List<GraphEdge>> getEdges(int floorId) async {
    final res = await db.from('graph_edges').select().eq('floor_id', floorId);
    final data = List<Map<String, dynamic>>.from(res);
    return data.map(GraphEdge.fromJson).toList();
  }

  Future<void> setRoomNearestNode({required int roomId, required int nodeId}) async {
    await db.from('rooms').update({'nearest_node_id': nodeId}).eq('id', roomId);
  }
  
}
