import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _subtaskController;
  late TaskPriority _selectedPriority;
  late TaskCategory _selectedCategory;
  late TaskDifficulty _selectedDifficulty;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late List<String> _subtasks;
  late List<bool> _subtaskCompleted;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _subtaskController = TextEditingController();
    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
    _selectedCategory = widget.task?.category ?? TaskCategory.personal;
    _selectedDifficulty = widget.task?.difficulty ?? TaskDifficulty.medium;
    _selectedDate = widget.task?.dueDate;
    _selectedTime = widget.task?.dueDate != null
        ? TimeOfDay.fromDateTime(widget.task!.dueDate!)
        : null;
    _subtasks = List.from(widget.task?.subtasks ?? []);
    _subtaskCompleted = List.from(widget.task?.subtaskCompleted ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        actions: [
          if (isEditing)
            IconButton(
              onPressed: _deleteTask,
              icon: const Icon(Icons.delete_outline_rounded),
              color: Colors.red,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            _buildSectionLabel('Title'),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'What needs to be done?',
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: !isEditing,
            ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.02),
            const SizedBox(height: 24),

            // Description
            _buildSectionLabel('Description'),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Add details...',
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ).animate().fadeIn(duration: 200.ms, delay: 50.ms).slideX(begin: 0.02),
            const SizedBox(height: 24),

            // Priority
            _buildSectionLabel('Priority'),
            _buildPrioritySelector(theme).animate().fadeIn(duration: 200.ms, delay: 100.ms),
            const SizedBox(height: 24),

            // Category
            _buildSectionLabel('Category'),
            _buildCategorySelector(theme).animate().fadeIn(duration: 200.ms, delay: 150.ms),
            const SizedBox(height: 24),

            // Difficulty
            _buildSectionLabel('Difficulty'),
            _buildDifficultySelector(theme).animate().fadeIn(duration: 200.ms, delay: 175.ms),
            const SizedBox(height: 24),

            // Due Date
            _buildSectionLabel('Due Date'),
            _buildDateTimeSelector(theme).animate().fadeIn(duration: 200.ms, delay: 200.ms),
            const SizedBox(height: 24),

            // Subtasks
            _buildSectionLabel('Subtasks'),
            _buildSubtasksSection(theme).animate().fadeIn(duration: 200.ms, delay: 250.ms),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _saveTask,
                child: Text(
                  isEditing ? 'Update Task' : 'Create Task',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ).animate().fadeIn(duration: 200.ms, delay: 300.ms).slideY(begin: 0.1),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildPrioritySelector(ThemeData theme) {
    return Row(
      children: TaskPriority.values.map((priority) {
        final isSelected = _selectedPriority == priority;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: priority != TaskPriority.high ? 12 : 0,
            ),
            child: InkWell(
              onTap: () => setState(() => _selectedPriority = priority),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? priority.color.withOpacity(0.15)
                      : theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? priority.color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      priority.icon,
                      size: 18,
                      color: isSelected ? priority.color : theme.hintColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      priority.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? priority.color : theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelector(ThemeData theme) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: TaskCategory.values.map((category) {
        final isSelected = _selectedCategory == category;
        return InkWell(
          onTap: () => setState(() => _selectedCategory = category),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? category.color.withOpacity(0.15)
                  : theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? category.color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 18,
                  color: isSelected ? category.color : theme.hintColor,
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? category.color : theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultySelector(ThemeData theme) {
    return Row(
      children: TaskDifficulty.values.map((difficulty) {
        final isSelected = _selectedDifficulty == difficulty;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: difficulty != TaskDifficulty.hard ? 12 : 0,
            ),
            child: InkWell(
              onTap: () => setState(() => _selectedDifficulty = difficulty),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? difficulty.color.withOpacity(0.15)
                      : theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? difficulty.color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          difficulty.icon,
                          size: 18,
                          color: isSelected ? difficulty.color : theme.hintColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          difficulty.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? difficulty.color : theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${difficulty.coinReward} coins',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected 
                            ? difficulty.color.withOpacity(0.8) 
                            : theme.hintColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateTimeSelector(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: _selectedDate != null
                        ? theme.colorScheme.primary
                        : theme.hintColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? DateFormat('MMM d, yyyy').format(_selectedDate!)
                          : 'Select date',
                      style: TextStyle(
                        color: _selectedDate != null ? null : theme.hintColor,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_selectedDate != null)
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedDate = null;
                        _selectedTime = null;
                      }),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: theme.hintColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: _selectedDate != null ? _selectTime : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 20,
                    color: _selectedTime != null
                        ? theme.colorScheme.primary
                        : theme.hintColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Select time',
                    style: TextStyle(
                      color: _selectedTime != null
                          ? null
                          : theme.hintColor.withOpacity(
                              _selectedDate != null ? 1 : 0.5,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtasksSection(ThemeData theme) {
    return Column(
      children: [
        // Add subtask field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _subtaskController,
                decoration: const InputDecoration(
                  hintText: 'Add a subtask...',
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _addSubtask(),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: _addSubtask,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Subtasks list
        if (_subtasks.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _subtasks.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 50,
                color: theme.dividerColor.withOpacity(0.3),
              ),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: _subtaskCompleted[index],
                    onChanged: (value) {
                      setState(() {
                        _subtaskCompleted[index] = value ?? false;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  title: Text(
                    _subtasks[index],
                    style: TextStyle(
                      decoration: _subtaskCompleted[index]
                          ? TextDecoration.lineThrough
                          : null,
                      color: _subtaskCompleted[index] ? theme.hintColor : null,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => _removeSubtask(index),
                    icon: Icon(
                      Icons.remove_circle_outline_rounded,
                      color: theme.hintColor,
                    ),
                  ),
                  contentPadding: const EdgeInsets.only(left: 4, right: 4),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subtasks.add(text);
        _subtaskCompleted.add(false);
        _subtaskController.clear();
      });
    }
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
      _subtaskCompleted.removeAt(index);
    });
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a task title'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    DateTime? dueDate = _selectedDate;
    if (dueDate != null && _selectedTime != null) {
      dueDate = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }

    final task = Task(
      id: widget.task?.id ?? '',
      title: title,
      description: _descriptionController.text.trim(),
      priority: _selectedPriority,
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
      dueDate: dueDate,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      isCompleted: widget.task?.isCompleted ?? false,
      subtasks: _subtasks,
      subtaskCompleted: _subtaskCompleted,
    );

    final taskProvider = context.read<TaskProvider>();
    if (isEditing) {
      taskProvider.updateTask(task);
    } else {
      taskProvider.addTask(task);
    }

    Navigator.pop(context);
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(widget.task!.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
