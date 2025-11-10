//lib/models/floor.dart
class Floor {
  final int id;
  final String name;
  final String imageUrl;
  final int imageWidth;
  final int imageHeight;

  Floor({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.imageWidth,
    required this.imageHeight,
  });

  factory Floor.fromJson(Map<String, dynamic> j) => Floor(
        id: j['id'] as int,
        name: j['name'] as String,
        imageUrl: j['image_url'] as String,
        imageWidth: j['image_width'] as int,
        imageHeight: j['image_height'] as int,
      );
}
