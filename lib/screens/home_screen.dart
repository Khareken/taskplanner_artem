import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/category_filter.dart';
import '../widgets/empty_state.dart';
import 'add_task_screen.dart';
import 'calendar_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildTasksPage(),
          const CalendarScreen(),
          const StatisticsScreen(),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _navigateToAddTask(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Task'),
            ).animate().scale(
                  duration: 300.ms,
                  curve: Curves.easeOutBack,
                )
          : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTasksPage() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          if (_isSearching) _buildSearchBar(),
          _buildCategoryFilter(),
          _buildStatsSection(),
          _buildTasksList(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final themeProvider = context.watch<ThemeProvider>();
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return SliverAppBar(
      floating: true,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Text(
              'My Tasks',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      actions: [
        // Coin balance display
        Consumer<TaskProvider>(
          builder: (context, taskProvider, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    '${taskProvider.coinBalance}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            setState(() => _isSearching = !_isSearching);
            if (!_isSearching) {
              _searchController.clear();
              context.read<TaskProvider>().setSearchQuery('');
            }
          },
          icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
        ),
        IconButton(
          onPressed: () => themeProvider.toggleTheme(),
          icon: Icon(
            themeProvider.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            context.read<TaskProvider>().setSearchQuery(value);
          },
          decoration: InputDecoration(
            hintText: 'Search tasks...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      context.read<TaskProvider>().setSearchQuery('');
                    },
                    icon: const Icon(Icons.clear_rounded),
                  )
                : null,
          ),
          autofocus: true,
        ),
      ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1, end: 0),
    );
  }

  Widget _buildCategoryFilter() {
    return const SliverToBoxAdapter(
      child: CategoryFilter(),
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, _) {
            return StatsCard(
              completedCount: taskProvider.completedTasksCount,
              pendingCount: taskProvider.pendingTasksCount,
              completionRate: taskProvider.completionRate,
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0);
          },
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final tasks = taskProvider.filteredTasks;

        if (tasks.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              isSearching: taskProvider.searchQuery.isNotEmpty,
              hasFilter: taskProvider.selectedCategory != null,
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final task = tasks[index];
                return TaskCard(
                  task: task,
                  onTap: () => _navigateToEditTask(context, task),
                  onToggleComplete: () => taskProvider.toggleTaskCompletion(task.id),
                  onDelete: () => taskProvider.deleteTask(task.id),
                ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms).slideX(
                      begin: 0.05,
                      end: 0,
                      curve: Curves.easeOutCubic,
                    );
              },
              childCount: tasks.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt_rounded),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
        ],
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    if (hour < 21) return 'Good Evening 🌙';
    return 'Good Night 🌜';
  }

  void _navigateToAddTask(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AddTaskScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToEditTask(BuildContext context, Task task) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddTaskScreen(task: task),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }
}
