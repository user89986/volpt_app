import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/floor.dart';
import '../models/graph.dart';
import '../models/room.dart';

import '../dialogs/room_query.dart';
import '../services/floor_repo.dart';
import '../services/graph_service.dart';
import '../services/rooms_service.dart';

import '../utils/route_planner.dart';
import '../utils/build_route_latlng.dart';

import '../widgets/floor_map.dart';

class MapScreen extends StatefulWidget {
  final int floorId;
  const MapScreen({super.key, required this.floorId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const double _scale = 0.0009;

  final _floorRepo = FloorRepo();
  final _roomsService = RoomsService();
  final _graph = GraphService(Supabase.instance.client);

  Floor? _floor;
  List<GraphNode> _nodes = [];
  List<GraphEdge> _edges = [];
  List<Room> _rooms = [];

  List<LatLng> _route = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      final f = await _floorRepo.getFloor(widget.floorId);
      final nodes = await _graph.getNodes(widget.floorId);
      final edges = await _graph.getEdges(widget.floorId);
      final rooms = await _roomsService.fetchRooms(widget.floorId);

      setState(() {
        _floor = f;
        _nodes = nodes;
        _edges = edges;
        _rooms = rooms;
        _route = [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  LatLng _latLngFromNorm(double x, double y) {
    final w = _floor!.imageWidth.toDouble();
    final h = _floor!.imageHeight.toDouble();
    return LatLng(y * h * _scale, x * w * _scale);
  }

  Future<void> _buildRoute() async {
    final roomName = await askRoomNumber(context);
    if (roomName == null || roomName.isEmpty) return;

    try {
      final f = _floor!;
      if (_nodes.isEmpty || _edges.isEmpty) {
        throw Exception('Граф пуст: узлов=${_nodes.length}, рёбер=${_edges.length}');
      }

      final room = _rooms.firstWhere(
        (r) => r.name.trim().toLowerCase() == roomName.trim().toLowerCase(),
        orElse: () => throw Exception('Кабинет "$roomName" не найден'),
      );

      // Старт — узел с kind=='start' или ближайший к центру (0.5, 0.5)
      final start = _nodes.firstWhere(
        (n) => n.kind == 'start',
        orElse: () => closestNodeTo(_nodes, 0.5, 0.5)!,
      );

      final goal = nodeForRoom(_nodes, room);
      if (goal == null) throw Exception('Не удалось подобрать узел для кабинета');

      final poly = buildRouteLatLng(
        floor: f,
        nodes: _nodes,
        edges: _edges,
        start: start,
        goal: goal,
        scale: _scale,
      );

      if (poly.isNotEmpty) {
        // дорисовываем от последнего узла до центра кабинета
        final roomPoint = _latLngFromNorm(room.xNorm, room.yNorm);
        final last = poly.last;
        const eps = 1e-9;
        final isSame = (last.latitude - roomPoint.latitude).abs() < eps &&
                       (last.longitude - roomPoint.longitude).abs() < eps;
        if (!isSame) poly.add(roomPoint);
      }

      setState(() => _route = List<LatLng>.from(poly));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Маршрут до "${room.name}" построен')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка маршрута: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: Center(child: Text('Ошибка: $_error')));
    if (_floor == null) return const Scaffold(body: Center(child: Text('Этаж не найден')));

    return Scaffold(
      appBar: AppBar(title: Text(_floor!.name)),
      body: FloorMap(
        floor: _floor!,
        nodeDots: const [], // скрыли узлы
        roomDots: const [], // скрыли кабинеты
        edgePolylines: const [], // скрыли все рёбра
        pathLatLng: _route, // показываем только маршрут
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fab_route',
            onPressed: _buildRoute,
            icon: const Icon(Icons.alt_route),
            label: const Text('Маршрут'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'fab_refresh',
            onPressed: _loadAll,
            icon: const Icon(Icons.refresh),
            label: const Text('Обновить'),
          ),
        ],
      ),
    );
  }
}
