import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

enum TaskDifficulty { easy, medium, hard }

extension TaskDifficultyExtension on TaskDifficulty {
  String get name {
    switch (this) {
      case TaskDifficulty.easy:
        return 'Easy';
      case TaskDifficulty.medium:
        return 'Medium';
      case TaskDifficulty.hard:
        return 'Hard';
    }
  }

  int get coinReward {
    switch (this) {
      case TaskDifficulty.easy:
        return 10;
      case TaskDifficulty.medium:
        return 25;
      case TaskDifficulty.hard:
        return 50;
    }
  }

  int get deadlineExtensionCost {
    switch (this) {
      case TaskDifficulty.easy:
        return 5;
      case TaskDifficulty.medium:
        return 15;
      case TaskDifficulty.hard:
        return 30;
    }
  }

  Color get color {
    switch (this) {
      case TaskDifficulty.easy:
        return const Color(0xFF10B981);
      case TaskDifficulty.medium:
        return const Color(0xFFF59E0B);
      case TaskDifficulty.hard:
        return const Color(0xFFEF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case TaskDifficulty.easy:
        return Icons.star_outline_rounded;
      case TaskDifficulty.medium:
        return Icons.star_half_rounded;
      case TaskDifficulty.hard:
        return Icons.star_rounded;
    }
  }
}

enum TaskCategory {
  personal,
  work,
  shopping,
  health,
  study,
  other,
}

extension TaskPriorityExtension on TaskPriority {
  String get name {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF10B981);
      case TaskPriority.medium:
        return const Color(0xFFF59E0B);
      case TaskPriority.high:
        return const Color(0xFFEF4444);
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.arrow_downward_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.arrow_upward_rounded;
    }
  }
}

extension TaskCategoryExtension on TaskCategory {
  String get name {
    switch (this) {
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.shopping:
        return 'Shopping';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.study:
        return 'Study';
      case TaskCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskCategory.personal:
        return Icons.person_rounded;
      case TaskCategory.work:
        return Icons.work_rounded;
      case TaskCategory.shopping:
        return Icons.shopping_cart_rounded;
      case TaskCategory.health:
        return Icons.favorite_rounded;
      case TaskCategory.study:
        return Icons.school_rounded;
      case TaskCategory.other:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TaskCategory.personal:
        return const Color(0xFF6366F1);
      case TaskCategory.work:
        return const Color(0xFFF59E0B);
      case TaskCategory.shopping:
        return const Color(0xFF10B981);
      case TaskCategory.health:
        return const Color(0xFFEF4444);
      case TaskCategory.study:
        return const Color(0xFF8B5CF6);
      case TaskCategory.other:
        return const Color(0xFF6B7280);
    }
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskCategory category;
  final TaskDifficulty difficulty;
  final DateTime? dueDate;
  final DateTime createdAt;
  final bool isCompleted;
  final List<String> subtasks;
  final List<bool> subtaskCompleted;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.personal,
    this.difficulty = TaskDifficulty.medium,
    this.dueDate,
    DateTime? createdAt,
    this.isCompleted = false,
    List<String>? subtasks,
    List<bool>? subtaskCompleted,
  })  : createdAt = createdAt ?? DateTime.now(),
        subtasks = subtasks ?? [],
        subtaskCompleted = subtaskCompleted ?? [];

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskCategory? category,
    TaskDifficulty? difficulty,
    DateTime? dueDate,
    DateTime? createdAt,
    bool? isCompleted,
    List<String>? subtasks,
    List<bool>? subtaskCompleted,
    bool clearDueDate = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? List.from(this.subtasks),
      subtaskCompleted: subtaskCompleted ?? List.from(this.subtaskCompleted),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.index,
      'category': category.index,
      'difficulty': difficulty.index,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'subtasks': subtasks,
      'subtaskCompleted': subtaskCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      priority: TaskPriority.values[json['priority'] ?? 1],
      category: TaskCategory.values[json['category'] ?? 0],
      difficulty: TaskDifficulty.values[json['difficulty'] ?? 1],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'] ?? false,
      subtasks: List<String>.from(json['subtasks'] ?? []),
      subtaskCompleted: List<bool>.from(json['subtaskCompleted'] ?? []),
    );
  }

  double get subtaskProgress {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completed = subtaskCompleted.where((c) => c).length;
    return completed / subtasks.length;
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate!.year == tomorrow.year &&
        dueDate!.month == tomorrow.month &&
        dueDate!.day == tomorrow.day;
  }
}
