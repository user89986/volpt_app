//lib/screens/floors_screen.dart
import 'package:flutter/material.dart';
import '../services/floor_repo.dart';
import '../models/floor.dart';
import 'map_screen.dart';

class FloorsScreen extends StatefulWidget {
  const FloorsScreen({super.key});

  @override
  State<FloorsScreen> createState() => _FloorsScreenState();
}

class _FloorsScreenState extends State<FloorsScreen> {
  final _repo = FloorRepo();
  late Future<List<Floor>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchFloors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Этажи')),
      body: FutureBuilder<List<Floor>>(
        future: _future,
        builder: (c, s) {
          if (s.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s.hasError) {
            return Center(child: Text('Ошибка: ${s.error}'));
          }
          final floors = s.data!;
          return ListView.separated(
            itemCount: floors.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final f = floors[i];
              return ListTile(
                title: Text(f.name),
                subtitle: Text('${f.imageWidth}×${f.imageHeight}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MapScreen(floorId: f.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
