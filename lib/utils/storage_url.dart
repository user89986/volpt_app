import 'package:supabase_flutter/supabase_flutter.dart';

/// Приводит значение из БД к корректному публичному URL.
/// Поддерживает 3 варианта входа:
/// 1) уже полный https-URL -> вернём как есть
/// 2) 'public/...' -> уберём первый 'public/' и построим URL
/// 3) 'maps/...' -> просто построим URL
String resolveStoragePublicUrl(String raw, {String bucket = 'public'}) {
  if (raw.startsWith('http')) return raw;

  // убираем начальный 'public/' если он есть
  final path = raw.startsWith('public/') ? raw.substring('public/'.length) : raw;

  // строим корректный публичный URL из Supabase Storage
  final storage = Supabase.instance.client.storage;
  return storage.from(bucket).getPublicUrl(path);
}
