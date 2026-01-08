import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_remind/main.dart';

class ToDoHomeScreen extends StatefulWidget {
  const ToDoHomeScreen({super.key});

  @override
  State<ToDoHomeScreen> createState() => _ToDoAppState();
}

class _ToDoAppState extends State<ToDoHomeScreen> {
  List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  final List<TextEditingController> _editTaskController = [];
  int? editIndex;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    for (var controller in _editTaskController) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      setState(() {
        _tasks = List<Map<String, dynamic>>.from(json.decode(tasksString));
        for (var i = 0; i < _tasks.length; i++) {
          _editTaskController.add(TextEditingController());
        }
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', json.encode(_tasks));
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = themeNotifier.value == ThemeMode.dark;
    themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
    await prefs.setBool('isDarkMode', !isDark);
  }

  void _addTask(String title) {
    if (title.isEmpty) return;
    setState(() {
      _tasks.add({
        'title': title,
        'done': false,
        'isEdit': false,
        'timestamp': DateTime.now().toString(),
      });
      _addController();
    });
    _taskController.clear();
    _saveTasks();
  }

  void _toggleDone(int index) {
    setState(() {
      _tasks[index]['done'] = !_tasks[index]['done'];
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    _editTaskController[index].dispose();
    setState(() {
      _tasks.removeAt(index);
      _deleteController(index);
    });
    _saveTasks();
  }

  void _editTask(String title, int index) {
    if (title.isEmpty) {
      _deleteTask(index);
    } else {
      setState(() {
        _tasks[index]['title'] = title;
        _tasks[index]['isEdit'] = !_tasks[index]['isEdit'];
      });
    }
    _saveTasks();
  }

  void _deleteController(int index) {
    _editTaskController.removeAt(index);
  }

  void _addController() {
    _editTaskController.add(TextEditingController());
  }

  void _editTaskOpeningTextfield(String prevTitle, int ind) {
    _editTaskController[ind].text = prevTitle;
    setState(() {
      _tasks[ind]['isEdit'] = !_tasks[ind]['isEdit'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF1a237e),
                      const Color(0xFF283593),
                      const Color(0xFF1a237e),
                    ]
                  : [
                      Colors.deepPurpleAccent.shade200,
                      Colors.purpleAccent.shade200,
                      Colors.deepPurpleAccent.shade200,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black45 : Colors.black26,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "To Do List",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: _toggleTheme,
                tooltip: isDark
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                : [const Color(0xFF2193b0), const Color(0xFF6dd5ed)],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _taskController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter a new task',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    fillColor: isDark ? const Color(0xFF2a2a3e) : Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      onPressed: () => _addTask(_taskController.text),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: task['done']
                            ? (isDark ? Colors.green[800] : Colors.green[200])
                            : (isDark ? const Color(0xFF2a2a3e) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black45 : Colors.black26,
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 8,
                          left: 0,
                          right: 1,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                task['done']
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                if (task['isEdit'] != true) {
                                  _toggleDone(index);
                                }
                              },
                            ),
                            Expanded(
                              child: task['isEdit']
                                  ? TextField(
                                      controller: _editTaskController[index],
                                      autofocus: true,
                                      maxLines: null,
                                      minLines: 1,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Edit Task',
                                        hintStyle: TextStyle(
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54,
                                        ),
                                        fillColor: isDark
                                            ? const Color(0xFF2a2a3e)
                                            : Colors.white,
                                        filled: true,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        suffixIcon: IconButton(
                                          padding: const EdgeInsets.only(
                                            left: 19,
                                          ),
                                          icon: const Icon(Icons.close),
                                          color: Colors.red.shade500,
                                          iconSize: 24,
                                          onPressed: () {
                                            String prevTask = task['title'];
                                            _editTask(prevTask, index);
                                          },
                                        ),
                                        suffixIconConstraints:
                                            const BoxConstraints(
                                              minHeight: 25,
                                              minWidth: 25,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      task['title'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        decoration: task['done']
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: task['isEdit']
                                      ? IconButton(
                                          icon: const Icon(Icons.check_circle),
                                          iconSize: 25,
                                          color: Colors.lightGreen.shade400,
                                          padding: const EdgeInsets.only(
                                            left: 10.0,
                                            right: 0.0,
                                          ),
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            String editedTask =
                                                _editTaskController[index].text;
                                            _editTask(editedTask, index);
                                          },
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.edit_note,
                                            color: Colors.blue,
                                          ),
                                          iconSize: 40,
                                          padding: const EdgeInsets.only(
                                            left: 0.0,
                                            right: 0.0,
                                          ),
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            if (task['done'] != true) {
                                              String prevTitle = task['title'];
                                              _editTaskOpeningTextfield(
                                                prevTitle,
                                                index,
                                              );
                                            } else {
                                              _toggleDone(index);
                                              String prevTitle = task['title'];
                                              _editTaskOpeningTextfield(
                                                prevTitle,
                                                index,
                                              );
                                            }
                                          },
                                        ),
                                ),
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    iconSize: 29,
                                    padding: const EdgeInsets.only(
                                      right: 12.0,
                                      left: 0,
                                    ),
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _deleteTask(index),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
