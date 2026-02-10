import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  String _searchQuery = '';
  TaskCategory? _selectedCategory;
  bool _showCompletedTasks = true;
  int _coinBalance = 0;
  int _totalCoinsEarned = 0;

  final _uuid = const Uuid();

  TaskProvider() {
    _loadTasks();
    _loadBalance();
  }

  List<Task> get tasks => _tasks;
  String get searchQuery => _searchQuery;
  TaskCategory? get selectedCategory => _selectedCategory;
  bool get showCompletedTasks => _showCompletedTasks;
  int get coinBalance => _coinBalance;
  int get totalCoinsEarned => _totalCoinsEarned;

  List<Task> get filteredTasks {
    return _tasks.where((task) {
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!task.title.toLowerCase().contains(query) &&
            !task.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filter by category
      if (_selectedCategory != null && task.category != _selectedCategory) {
        return false;
      }

      // Filter completed tasks
      if (!_showCompletedTasks && task.isCompleted) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        // Completed tasks at the bottom
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        // Sort by priority (high first)
        if (a.priority != b.priority) {
          return b.priority.index.compareTo(a.priority.index);
        }
        // Sort by due date
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        if (a.dueDate != null) return -1;
        if (b.dueDate != null) return 1;
        // Sort by creation date
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  List<Task> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == now.year &&
          task.dueDate!.month == now.month &&
          task.dueDate!.day == now.day;
    }).toList();
  }

  List<Task> get upcomingTasks {
    final now = DateTime.now();
    final endOfWeek = now.add(const Duration(days: 7));
    return _tasks.where((task) {
      if (task.dueDate == null || task.isCompleted) return false;
      return task.dueDate!.isAfter(now) && task.dueDate!.isBefore(endOfWeek);
    }).toList();
  }

  List<Task> get overdueTasks {
    return _tasks.where((task) => task.isOverdue).toList();
  }

  int get completedTasksCount => _tasks.where((t) => t.isCompleted).length;
  int get pendingTasksCount => _tasks.where((t) => !t.isCompleted).length;
  int get totalTasksCount => _tasks.length;

  double get completionRate {
    if (_tasks.isEmpty) return 0;
    return completedTasksCount / totalTasksCount;
  }

  Map<TaskCategory, int> get tasksByCategory {
    final map = <TaskCategory, int>{};
    for (final category in TaskCategory.values) {
      map[category] = _tasks.where((t) => t.category == category).length;
    }
    return map;
  }

  Map<TaskCategory, int> get pendingTasksByCategory {
    final map = <TaskCategory, int>{};
    for (final category in TaskCategory.values) {
      map[category] = _tasks
          .where((t) => t.category == category && !t.isCompleted)
          .length;
    }
    return map;
  }

  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == date.year &&
          task.dueDate!.month == date.month &&
          task.dueDate!.day == date.day;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(TaskCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleShowCompletedTasks() {
    _showCompletedTasks = !_showCompletedTasks;
    notifyListeners();
  }

  void addTask(Task task) {
    final newTask = task.copyWith(id: _uuid.v4());
    _tasks.add(newTask);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveTasks();
    notifyListeners();
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final wasCompleted = task.isCompleted;
      
      _tasks[index] = task.copyWith(
        isCompleted: !wasCompleted,
      );
      
      // Award coins when completing a task, remove when uncompleting
      if (!wasCompleted) {
        _coinBalance += task.difficulty.coinReward;
        _totalCoinsEarned += task.difficulty.coinReward;
      } else {
        _coinBalance -= task.difficulty.coinReward;
        _totalCoinsEarned -= task.difficulty.coinReward;
      }
      
      _saveTasks();
      _saveBalance();
      notifyListeners();
    }
  }

  bool canExtendDeadline(Task task) {
    return task.dueDate != null && _coinBalance >= task.difficulty.deadlineExtensionCost;
  }

  bool extendDeadline(String taskId, {int days = 1}) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return false;
    
    final task = _tasks[index];
    if (task.dueDate == null) return false;
    
    final cost = task.difficulty.deadlineExtensionCost * days;
    if (_coinBalance < cost) return false;
    
    _coinBalance -= cost;
    _tasks[index] = task.copyWith(
      dueDate: task.dueDate!.add(Duration(days: days)),
    );
    
    _saveTasks();
    _saveBalance();
    notifyListeners();
    return true;
  }

  void toggleSubtaskCompletion(String taskId, int subtaskIndex) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final newSubtaskCompleted = List<bool>.from(task.subtaskCompleted);
      newSubtaskCompleted[subtaskIndex] = !newSubtaskCompleted[subtaskIndex];
      
      // Check if all subtasks are completed
      final allCompleted = newSubtaskCompleted.every((c) => c);
      
      _tasks[index] = task.copyWith(
        subtaskCompleted: newSubtaskCompleted,
        isCompleted: allCompleted,
      );
      _saveTasks();
      notifyListeners();
    }
  }

  void addSubtask(String taskId, String subtaskTitle) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(
        subtasks: [...task.subtasks, subtaskTitle],
        subtaskCompleted: [...task.subtaskCompleted, false],
      );
      _saveTasks();
      notifyListeners();
    }
  }

  void removeSubtask(String taskId, int subtaskIndex) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final newSubtasks = List<String>.from(task.subtasks)..removeAt(subtaskIndex);
      final newSubtaskCompleted = List<bool>.from(task.subtaskCompleted)..removeAt(subtaskIndex);
      _tasks[index] = task.copyWith(
        subtasks: newSubtasks,
        subtaskCompleted: newSubtaskCompleted,
      );
      _saveTasks();
      notifyListeners();
    }
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> decoded = json.decode(tasksJson);
      _tasks = decoded.map((e) => Task.fromJson(e)).toList();
      notifyListeners();
    } else {
      // Add sample tasks for demo
      //_addSampleTasks();
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = json.encode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString('tasks', tasksJson);
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    _coinBalance = prefs.getInt('coinBalance') ?? 0;
    _totalCoinsEarned = prefs.getInt('totalCoinsEarned') ?? 0;
    notifyListeners();
  }

  Future<void> _saveBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coinBalance', _coinBalance);
    await prefs.setInt('totalCoinsEarned', _totalCoinsEarned);
  }

  void _addSampleTasks() {
    final now = DateTime.now();
    _tasks = [
      Task(
        id: _uuid.v4(),
        title: 'Complete project proposal',
        description: 'Draft and finalize the Q4 project proposal for the client meeting',
        priority: TaskPriority.high,
        category: TaskCategory.work,
        dueDate: now.add(const Duration(days: 1)),
        subtasks: ['Research competitors', 'Draft outline', 'Create presentation'],
        subtaskCompleted: [true, false, false],
      ),
      Task(
        id: _uuid.v4(),
        title: 'Go to the gym',
        description: 'Leg day workout routine',
        priority: TaskPriority.medium,
        category: TaskCategory.health,
        dueDate: now,
      ),
      Task(
        id: _uuid.v4(),
        title: 'Buy groceries',
        description: 'Milk, eggs, bread, vegetables, fruits',
        priority: TaskPriority.low,
        category: TaskCategory.shopping,
        dueDate: now.add(const Duration(days: 2)),
        subtasks: ['Milk', 'Eggs', 'Bread', 'Vegetables'],
        subtaskCompleted: [false, false, false, false],
      ),
      Task(
        id: _uuid.v4(),
        title: 'Study Flutter animations',
        description: 'Learn about implicit and explicit animations in Flutter',
        priority: TaskPriority.medium,
        category: TaskCategory.study,
        dueDate: now.add(const Duration(days: 3)),
      ),
      Task(
        id: _uuid.v4(),
        title: 'Call mom',
        description: 'Weekly check-in call',
        priority: TaskPriority.high,
        category: TaskCategory.personal,
        dueDate: now,
      ),
      Task(
        id: _uuid.v4(),
        title: 'Review code PR',
        description: 'Review the authentication module pull request',
        priority: TaskPriority.high,
        category: TaskCategory.work,
        dueDate: now.subtract(const Duration(days: 1)),
      ),
    ];
    _saveTasks();
    notifyListeners();
  }

  void clearAllTasks() {
    _tasks.clear();
    _saveTasks();
    notifyListeners();
  }
}
