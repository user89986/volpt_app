import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart'; // <-- здесь и LatLng, и Distance, и всё нужное

import '../models/floor.dart';

class FloorMap extends StatefulWidget {
  const FloorMap({
    super.key,
    required this.floor,
    required this.nodeDots,       // List<fm.Marker>
    required this.roomDots,       // List<fm.Marker>
    required this.edgePolylines,  // List<fm.Polyline>
    required this.pathLatLng,     // List<LatLng>
  });

  final Floor floor;
  final List<fm.Marker> nodeDots;
  final List<fm.Marker> roomDots;
  final List<fm.Polyline> edgePolylines;
  final List<LatLng> pathLatLng;

  @override
  State<FloorMap> createState() => _FloorMapState();
}

class _FloorMapState extends State<FloorMap> {
  static const double _scale = 0.0009;
  static const double _maxZoom = 6.0;

  final _map = fm.MapController();
  late final fm.LatLngBounds _imgBounds;
  double? _minZoom;

  @override
  void initState() {
    super.initState();

    final w = widget.floor.imageWidth.toDouble();
    final h = widget.floor.imageHeight.toDouble();

    // LatLng (из latlong2)
    // LatLngBounds (из flutter_map)
    _imgBounds = fm.LatLngBounds(
      LatLng(0, 0),
      LatLng(h * _scale, w * _scale),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _map.fitCamera(
        fm.CameraFit.bounds(bounds: _imgBounds, padding: const EdgeInsets.all(20)),
      );
      await Future<void>.delayed(const Duration(milliseconds: 60));
      if (!mounted) return;
      setState(() => _minZoom = _map.camera.zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return fm.FlutterMap(
      mapController: _map,
      options: fm.MapOptions(
        crs: const fm.CrsSimple(), // <-- обязательно fm.
        initialCenter: _imgBounds.center,
        initialZoom: 0,
        minZoom: _minZoom ?? -5,
        maxZoom: _maxZoom,
        interactionOptions: const fm.InteractionOptions(
          flags: fm.InteractiveFlag.all & ~fm.InteractiveFlag.rotate,
        ),
      ),
      children: [
        // фон-план (изображение)
        fm.OverlayImageLayer(
          overlayImages: [
            fm.OverlayImage(
              bounds: _imgBounds,
              opacity: 1,
              imageProvider: NetworkImage(widget.floor.imageUrl),
            ),
          ],
        ),

        // Рёбра
        if (widget.edgePolylines.isNotEmpty)
          fm.PolylineLayer(polylines: widget.edgePolylines),

        // Узлы
        if (widget.nodeDots.isNotEmpty)
          fm.MarkerLayer(markers: widget.nodeDots),

        // Кабинеты
        if (widget.roomDots.isNotEmpty)
          fm.MarkerLayer(markers: widget.roomDots),

        // Маршрут (рисуем последним!)
        if (widget.pathLatLng.isNotEmpty)
          fm.PolylineLayer(
            polylines: [
              fm.Polyline(
                points: widget.pathLatLng,
                strokeWidth: 5,
                color: const Color(0xFF1E88E5),
              ),
            ],
          ),
      ],
    );
  }
}
