import 'package:flutter/material.dart';

/// A single scheduled block in the daily planner.
class PlannerEntry {
  final String id;
  final DateTime date;
  final int hour; // 0–23
  final String title;
  final String notes;
  final Color color;

  const PlannerEntry({
    required this.id,
    required this.date,
    required this.hour,
    required this.title,
    this.notes = '',
    required this.color,
  });

  PlannerEntry copyWith({
    String? id,
    DateTime? date,
    int? hour,
    String? title,
    String? notes,
    Color? color,
  }) {
    return PlannerEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      hour: hour ?? this.hour,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap({String? userId}) {
    final map = <String, dynamic>{
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'hour': hour,
      'title': title,
      'notes': notes,
      'color': color.toARGB32(),
    };
    if (id.isNotEmpty) map['id'] = id;
    if (userId != null) map['user_id'] = userId;
    return map;
  }

  factory PlannerEntry.fromMap(Map<String, dynamic> map) {
    final parts = (map['date'] as String).split('-');
    return PlannerEntry(
      id: map['id'] as String,
      date: DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      ),
      hour: (map['hour'] as num).toInt(),
      title: map['title'] as String,
      notes: (map['notes'] as String?) ?? '',
      color: Color(map['color'] as int),
    );
  }
}
