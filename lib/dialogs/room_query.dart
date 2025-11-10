// lib/dialogs/room_query.dart
import 'package:flutter/material.dart';

Future<String?> askRoomNumber(BuildContext context) async {
  final c = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Введите номер кабинета'),
      content: TextField(
        controller: c,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Например: 114',
          prefixIcon: Icon(Icons.search),
        ),
        onSubmitted: (v) => Navigator.pop(context, v.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        FilledButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Найти')),
      ],
    ),
  );
}
