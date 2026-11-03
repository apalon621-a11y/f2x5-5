import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'task_edit_screen.dart';

enum _TaskAction { edit, delete }

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<String> _tasks = [
    'Купить продукты',
    'Сделать домашку по Flutter',
    'Сходить на тренировку',
  ];

  Future<void> _addTask() async {
    final title = await showDialog<String>(
      context: context,
      builder: (_) => const _AddTaskDialog(),
    );

    if (title == null  title.isEmpty  !mounted) return;
    setState(() => _tasks.add(title));
  }

  Future<void> _editTask(int index) async {
    final newTitle = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskEditScreen(taskName: _tasks[index]),
      ),
    );

    if (newTitle == null  newTitle.isEmpty  !mounted) return;
    setState(() => _tasks[index] = newTitle);
  }

  Future<void> _showTaskMenu(int index) async {
    final action = await showModalBottomSheet<_TaskAction>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Редактировать'),
              onTap: () => Navigator.pop(sheetContext, _TaskAction.edit),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить'),
              onTap: () => Navigator.pop(sheetContext, _TaskAction.delete),
            ),
          ],
        ),
      ),
    );

    if (action == null || !mounted) return;

    switch (action) {
      case _TaskAction.edit:
        await _editTask(index);
      case _TaskAction.delete:
        await _confirmDelete(index);
    }
  }

  Future<void> _confirmDelete(int index) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Удалить задачу?'),
        content: Text(
          'Задача «${_tasks[index]}» будет удалена без возможности '
          'восстановления.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _tasks.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Список задач')),
      body: _tasks.isEmpty
          ? const Center(child: Text('Задач пока нет'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_tasks[index]),
                onTap: () => _editTask(index),
                onLongPress: () => _showTaskMenu(index),
                trailing: IconButton(
                  tooltip: 'Действия с задачей',
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showTaskMenu(index),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Добавить задачу',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddTaskDialog extends StatefulWidget {
  const _AddTaskDialog();

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final TextEditingController _controller = TextEditingController();