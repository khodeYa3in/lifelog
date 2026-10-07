import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/theme.dart';
import '../models/app_state.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  final AppState state;

  const HomeScreen({
    super.key,
    required this.state,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  final Uuid uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: tab,
          children: [
            today(),
            calendar(),
            analytics(),
            more(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (index) {
          setState(() {
            tab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'امروز',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'تقویم',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'گزارش',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.grid_view),
            label: 'بیشتر',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TODAY
  // ============================================================

  Widget today() {
    final now = DateTime.now();

    final tasks = widget.state.tasks
        .where(
          (task) =>
              task.start.year == now.year &&
              task.start.month == now.month &&
              task.start.day == now.day,
        )
        .toList()
      ..sort(
        (a, b) => a.start.compareTo(b.start),
      );

    final completed =
        tasks.where((task) => task.status == 'completed').length;

    final score =
        tasks.isEmpty ? 0 : ((completed * 100) ~/ tasks.length);

    return page(
      'TODAY.LOG',
      'امروزت را اجرا کن.',
      ListView(
        padding: const EdgeInsets.only(bottom: 90),
        children: [
          Glass(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DAILY.STATUS',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: Colors.white38,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$score%',
                  style: const TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                LinearProgressIndicator(
                  value: score / 100,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                  children: [
                    metric(
                      'رضایت',
                      '${reviewValue('satisfaction')}%',
                    ),
                    metric(
                      'تمرکز',
                      '${widget.state.focusMinutes}m',
                    ),
                    metric(
                      'تسک',
                      '$completed/${tasks.length}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Glass(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'برنامه امروز',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: addTask,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                if (tasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'برای امروز هنوز تسکی نداری.',
                      style: TextStyle(
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ...tasks.map(
                  (task) => TaskTile(
                    task: task,
                    onToggle: () async {
                      task.status =
                          task.status == 'completed'
                              ? 'planned'
                              : 'completed';

                      await widget.state.save();

                      if (mounted) {
                        setState(() {});
                      }
                    },
                    onFocus: () => focus(task),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          reviewCard(),
        ],
      ),
    );
  }

  // ============================================================
  // CALENDAR
  // ============================================================

  Widget calendar() {
    final now = DateTime.now();

    final days = DateUtils.getDaysInMonth(
      now.year,
      now.month,
    );

    return page(
      'CALENDAR',
      'تقویم',
      GridView.builder(
        padding: const EdgeInsets.only(bottom: 90),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.15,
          crossAxisSpacing: 9,
          mainAxisSpacing: 9,
        ),
        itemCount: days,
        itemBuilder: (context, index) {
          final day = index + 1;

          final count = widget.state.tasks
              .where(
                (task) =>
                    task.start.year == now.year &&
                    task.start.month == now.month &&
                    task.start.day == day,
              )
              .length;

          return Glass(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '$day',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '$count task',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // ANALYTICS
  // ============================================================

  Widget analytics() {
    final all = widget.state.tasks;

    final completed =
        all.where((task) => task.status == 'completed').length;

    final percentage =
        all.isEmpty ? 0 : ((completed * 100) ~/ all.length);

    return page(
      'ANALYTICS',
      'گزارش عملکرد',
      ListView(
        padding: const EdgeInsets.only(bottom: 90),
        children: [
          Row(
            children: [
              Expanded(
                child: Glass(
                  child: metric(
                    'Completion',
                    '$percentage%',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Glass(
                  child: metric(
                    'Focus',
                    '${widget.state.focusMinutes}m',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Glass(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'وضعیت کلی',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 12),
                Text(
                  '$completed از ${all.length} تسک انجام شده',
                  style: const TextStyle(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MORE
  // ============================================================

  Widget more() {
    return page(
      'LIFELOG',
      'بیشتر',
      ListView(
        padding: const EdgeInsets.only(bottom: 90),
        children: [
          menu(
            Icons.edit_note_rounded,
            'ژورنال',
            journal,
          ),
          menu(
            Icons.bedtime_outlined,
            'خواب',
            sleep,
          ),
          menu(
            Icons.repeat_rounded,
            'عادت‌ها و اهداف',
            habits,
          ),
          menu(
            Icons.inbox_outlined,
            'Inbox',
            inbox,
          ),
          menu(
            Icons.settings_outlined,
            'تنظیمات',
            settings,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE
  // ============================================================

  Widget page(
    String eye,
    String title,
    Widget child,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        8,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            eye,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(child: child),
        ],
      ),
    );
  }

  // ============================================================
  // METRIC
  // ============================================================

  Widget metric(
    String title,
    String value,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DAILY REVIEW
  // ============================================================

  int reviewValue(String key) {
    final dateKey = DateTime.now()
        .toIso8601String()
        .substring(0, 10);

    final review =
        widget.state.reviews[dateKey] ?? {};

    final value = review[key];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    return 0;
  }

  Widget reviewCard() {
    const fields = [
      'satisfaction',
      'mood',
      'energy',
      'focus',
      'productivity',
      'sleepQuality',
    ];

    return Glass(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Review',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...fields.map(
            (key) {
              final initial =
                  reviewValue(key).toDouble();

              return _ReviewSlider(
                key: ValueKey(key),
                title: key,
                initialValue: initial,
                onSaved: (value) async {
                  final dateKey = DateTime.now()
                      .toIso8601String()
                      .substring(0, 10);

                  widget.state.reviews[dateKey] ??= {};

                  widget.state.reviews[dateKey][key] =
                      value.round();

                  await widget.state.save();

                  if (mounted) {
                    setState(() {});
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MENU
  // ============================================================

  Widget menu(
    IconData icon,
    String title,
    VoidCallback action,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Glass(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(
            Icons.chevron_left,
          ),
          onTap: action,
        ),
      ),
    );
  }

  // ============================================================
  // ADD TASK
  // ============================================================

  Future<void> addTask() async {
    final titleController =
        TextEditingController();

    final noteController =
        TextEditingController();

    final start = DateTime.now();

    final end = start.add(
      const Duration(hours: 1),
    );

    final saved =
        await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          const Color(0xFF111622),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            20,
            18,
            MediaQuery.of(sheetContext)
                    .viewInsets
                    .bottom +
                25,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Text(
                'تسک جدید',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText: 'عنوان',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration:
                    const InputDecoration(
                  labelText: 'توضیحات',
                ),
              ),
              const SizedBox(height: 15),
              FilledButton(
                onPressed: () {
                  if (titleController.text
                      .trim()
                      .isEmpty) {
                    return;
                  }

                  Navigator.pop(
                    sheetContext,
                    true,
                  );
                },
                child: const SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Text('ذخیره'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (saved == true &&
        titleController.text.trim().isNotEmpty) {
      widget.state.tasks.add(
        TaskItem(
          id: uuid.v4(),
          title: titleController.text.trim(),
          note: noteController.text.trim(),
          start: start,
          end: end,
        ),
      );

      await widget.state.save();

      if (mounted) {
        setState(() {});
      }
    }

    titleController.dispose();
    noteController.dispose();
  }

  // ============================================================
  // FOCUS TIMER
  // ============================================================

  Future<void> focus(TaskItem task) async {
    final startedAt = DateTime.now();

    int seconds = 0;

    Timer? timer;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, update) {
            timer ??= Timer.periodic(
              const Duration(seconds: 1),
              (_) {
                seconds = DateTime.now()
                    .difference(startedAt)
                    .inSeconds;

                update(() {});
              },
            );

            final hours =
                seconds ~/ 3600;

            final minutes =
                (seconds % 3600) ~/ 60;

            final secs =
                seconds % 60;

            return AlertDialog(
              backgroundColor:
                  const Color(0xFF101521),
              title: Text(task.title),
              content: Text(
                '${hours.toString().padLeft(2, '0')}:'
                '${minutes.toString().padLeft(2, '0')}:'
                '${secs.toString().padLeft(2, '0')}',
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                      const Text('پایان Focus'),
                ),
              ],
            );
          },
        );
      },
    );

    timer?.cancel();

    final minutes =
        (seconds / 60).ceil();

    task.focusMinutes += minutes;

    widget.state.focusMinutes += minutes;

    await widget.state.save();

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // GENERIC SHEET
  // ============================================================

  void sheet(
    String title,
    Widget body,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          const Color(0xFF0D121D),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: .82,
          maxChildSize: .95,
          builder: (context, scrollController) {
            return Padding(
              padding:
                  const EdgeInsets.all(18),
              child: ListView(
                controller:
                    scrollController,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  body,
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // JOURNAL
  // ============================================================

  void journal() {
    sheet(
      'ژورنال',
      Column(
        children: [
          FilledButton(
            onPressed: () {
              final controller =
                  TextEditingController();

              showDialog<void>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title:
                        const Text(
                      'نوشته جدید',
                    ),
                    content: TextField(
                      controller: controller,
                      maxLines: 7,
                      decoration:
                          const InputDecoration(
                        hintText:
                            'امروز چه چیزی در ذهنت است؟',
                      ),
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () async {
                          final text =
                              controller.text
                                  .trim();

                          if (text.isEmpty) {
                            return;
                          }

                          widget.state.journal.insert(
                            0,
                            {
                              'text': text,
                              'date': DateTime.now()
                                  .toIso8601String(),
                            },
                          );

                          await widget.state.save();

                          if (dialogContext
                              .mounted) {
                            Navigator.pop(
                              dialogContext,
                            );
                          }

                          if (mounted) {
                            setState(() {});
                          }
                        },
                        child:
                            const Text('ذخیره'),
                      ),
                    ],
                  );
                },
              ).whenComplete(
                controller.dispose,
              );
            },
            child:
                const Text('+ نوشته جدید'),
          ),
          const SizedBox(height: 10),
          ...widget.state.journal.map(
            (entry) {
              return Card(
                child: ListTile(
                  title: Text(
                    entry['text'] ?? '',
                  ),
                  subtitle: Text(
                    entry['date'] ?? '',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SLEEP
  // ============================================================

  void sleep() {
    sheet(
      'خواب',
      Column(
        children: [
          FilledButton(
            onPressed: () async {
              final active = widget.state.sleep
                  .where(
                    (entry) =>
                        entry['end'] == null,
                  )
                  .toList();

              if (active.isEmpty) {
                widget.state.sleep.insert(
                  0,
                  {
                    'start': DateTime.now()
                        .toIso8601String(),
                    'end': null,
                    'quality': 0,
                  },
                );
              } else {
                active.first['end'] =
                    DateTime.now()
                        .toIso8601String();
              }

              await widget.state.save();

              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: Text(
              widget.state.sleep.any(
                (entry) =>
                    entry['end'] == null,
              )
                  ? 'بیدار شدم'
                  : 'خوابیدم',
            ),
          ),
          const SizedBox(height: 10),
          ...widget.state.sleep.map(
            (entry) {
              return ListTile(
                leading: const Icon(
                  Icons.bedtime_outlined,
                ),
                title: Text(
                  entry['end'] == null
                      ? 'در حال خواب'
                      : 'خواب ثبت‌شده',
                ),
                subtitle: Text(
                  entry['start'] ?? '',
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HABITS
  // ============================================================

  void habits() {
    sheet(
      'عادت‌ها و اهداف',
      Column(
        children: [
          const ListTile(
            leading: Icon(
              Icons.repeat_rounded,
            ),
            title: Text('عادت‌ها'),
            subtitle: Text(
              'ساختار Habit در AppState آماده است.',
            ),
          ),
          const ListTile(
            leading: Icon(
              Icons.flag_outlined,
            ),
            title: Text('اهداف'),
            subtitle: Text(
              'ساختار Goal در نسخه فعلی آماده است.',
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text(
              'افزودن عادت',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INBOX
  // ============================================================

  void inbox() {
    final inboxTasks = widget.state.tasks
        .where(
          (task) => task.category == 'Inbox',
        )
        .toList();

    sheet(
      'Inbox',
      inboxTasks.isEmpty
          ? const Padding(
              padding:
                  EdgeInsets.all(30),
              child: Center(
                child: Text(
                  'Inbox خالی است.',
                  style: TextStyle(
                    color: Colors.white54,
                  ),
                ),
              ),
            )
          : Column(
              children: inboxTasks.map(
                (task) {
                  return ListTile(
                    leading: const Icon(
                      Icons.inbox_outlined,
                    ),
                    title:
                        Text(task.title),
                    subtitle:
                        Text(task.note),
                  );
                },
              ).toList(),
            ),
    );
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  void settings() {
    sheet(
      'تنظیمات',
      const Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.dark_mode_outlined,
            ),
            title: Text('Dark Glass'),
            subtitle: Text(
              'تم پیش‌فرض LifeLog',
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.fingerprint,
            ),
            title: Text('Privacy'),
            subtitle: Text(
              'Biometric / PIN scaffold',
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.cloud_outlined,
            ),
            title: Text('Server'),
            subtitle: Text(
              'yasin.iranvirtual.com',
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// REVIEW SLIDER
// ================================================================

class _ReviewSlider extends StatefulWidget {
  final String title;
  final double initialValue;
  final ValueChanged<double> onSaved;

  const _ReviewSlider({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onSaved,
  });

  @override
  State<_ReviewSlider> createState() =>
      _ReviewSliderState();
}

class _ReviewSliderState
    extends State<_ReviewSlider> {
  late double value;

  @override
  void initState() {
    super.initState();

    value = widget.initialValue
        .clamp(0, 100)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title),
            Text('${value.round()}%'),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: (newValue) {
            setState(() {
              value = newValue;
            });
          },
          onChangeEnd: (newValue) {
            widget.onSaved(newValue);
          },
        ),
      ],
    );
  }
}