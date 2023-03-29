import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late double _deviceHeight;

  String? _newTaskContent;
  Box? _box;
  _HomePageState();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight * 0.12,
        title: const Text(
          "Taskly",
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: _taskView(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _taskView() {
    return FutureBuilder(
      future: Hive.openBox('tasks'),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _box = snapshot.data;
          return _taskList();
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _taskList() {
    List tasks = _box!.values.toList();

    return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (BuildContext _context, int _index) {
          var task = Task.fromMap(tasks[_index]);
          return ListTile(
            title: Text(
              task.content,
              style: TextStyle(
                  decoration: task.done ? TextDecoration.lineThrough : null),
            ),
            subtitle: Text(
              task.timeStamp.toIso8601String(),
            ),
            trailing: Icon(
              task.done
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank_outlined,
              color: Colors.blueGrey,
            ),
            onTap: () {
              task.done = !task.done;
              _box!.putAt(_index, task.toMap());
              setState(() {});
            },
            onLongPress: () {
              _deleteTask(_index);
            },
          );
        });
  }

  void _deleteTask(int _index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Are you sure you want to delete?"),
            content: SingleChildScrollView(
              child: Column(
                // ignore: prefer_const_literals_to_create_immutables
                children: <Widget>[
                  const Text(
                      "Confirm will delete your task, Tap cancel to go back."),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _box!.deleteAt(_index);
                  setState(() {});
                },
                child: const Text("confirm"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              )
            ],
          );
        });
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _displayTaskPopup,
      child: const Icon(
        Icons.add,
      ),
    );
  }

  void _displayTaskPopup() {
    showDialog(context: context, builder: builder);
  }

  Widget builder(BuildContext context) {
    return AlertDialog(
      title: const Text("Add new Task!"),
      content: TextField(
        onSubmitted: (value) {
          if (_newTaskContent != null) {
            var _task = Task(
                content: _newTaskContent!,
                timeStamp: DateTime.now(),
                done: false);
            _box!.add(_task.toMap());
            setState(() {
              _newTaskContent = null;
              Navigator.pop(context);
            });
          }
        },
        onChanged: (value) {
          setState(() {
            _newTaskContent = value;
          });
        },
      ),
    );
  }
}
