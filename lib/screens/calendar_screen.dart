import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = context.watch<TaskProvider>();
    final tasksForSelectedDay = taskProvider.getTasksForDate(_selectedDay);

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(theme),
          _buildCalendar(theme, taskProvider),
          const SizedBox(height: 16),
          _buildTasksHeader(theme, tasksForSelectedDay.length),
          Expanded(
            child: _buildTasksList(tasksForSelectedDay, taskProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(
            'Calendar',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            icon: const Icon(Icons.today_rounded),
            tooltip: 'Today',
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildCalendar(ThemeData theme, TaskProvider taskProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        eventLoader: (day) {
          return taskProvider.getTasksForDate(day);
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: theme.colorScheme.error),
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          markerSize: 6,
          markerMargin: const EdgeInsets.symmetric(horizontal: 1),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.primary),
            borderRadius: BorderRadius.circular(8),
          ),
          formatButtonTextStyle: TextStyle(color: theme.colorScheme.primary),
          leftChevronIcon: Icon(Icons.chevron_left, color: theme.colorScheme.primary),
          rightChevronIcon: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: theme.hintColor,
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: TextStyle(
            color: theme.colorScheme.error.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05);
  }

  Widget _buildTasksHeader(ThemeData theme, int taskCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              DateFormat('EEEE, MMM d').format(_selectedDay),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$taskCount ${taskCount == 1 ? 'task' : 'tasks'}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _addTaskForDate(context),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(List<Task> tasks, TaskProvider taskProvider) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 64,
              color: Theme.of(context).hintColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks for this day',
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _addTaskForDate(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Task'),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: () => _navigateToEditTask(context, task),
          onToggleComplete: () => taskProvider.toggleTaskCompletion(task.id),
          onDelete: () => taskProvider.deleteTask(task.id),
        ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms).slideX(
              begin: 0.05,
              end: 0,
            );
      },
    );
  }

  void _addTaskForDate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          task: Task(
            id: '',
            title: '',
            dueDate: _selectedDay,
          ),
        ),
      ),
    );
  }

  void _navigateToEditTask(BuildContext context, Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(task: task),
      ),
    );
  }
}
