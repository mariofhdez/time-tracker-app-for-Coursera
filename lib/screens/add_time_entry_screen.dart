import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/models/project.dart';
import 'package:time_tracker/models/task.dart';
import 'package:time_tracker/models/time_entry.dart';
import 'package:time_tracker/providers/project_provider.dart';
import 'package:time_tracker/providers/task_provider.dart';
import 'package:time_tracker/providers/time_entry_provider.dart';
import 'package:time_tracker/widgets/add_project_dialog.dart';
import 'package:time_tracker/widgets/add_task_dialog.dart';

class AddTimeEntryScreen extends StatefulWidget {
  @override
  _AddTimeEntryScreenState createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String projectId = '';
  String taskId = '';
  double totalTime = 0.0;
  DateTime date = DateTime.now();
  String notes = '';

  // List<String> _dropdown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Time Entry')),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Consumer<ProjectProvider>(
              builder: (context, provider, child) {
                List<Project> projects = provider.projects;
                return DropdownButtonFormField<Project>(
                  value: projects.first,
                  decoration: InputDecoration(labelText: 'Project'),
                  items:
                      projects.map((Project p) {
                        return DropdownMenuItem<Project>(
                          value: p,
                          child: Text(p.name),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value == "Add new project") {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AddProjectDialog(
                              onAdd: (newProject) {
                                Provider.of<ProjectProvider>(
                                  context,
                                  listen: false,
                                ).addProject(newProject);
                                Navigator.pop(context);
                              },
                            ),
                      );
                    }
                  },
                  onSaved: (value) {
                    if (value != null) {
                      projectId = value.id;
                    }
                  },
                );
              },
            ),

            Consumer<TaskProvider>(
              builder: (content, provider, child) {
                List<Task> tasks = provider.tasks;
                return DropdownButtonFormField<Task>(
                  value: tasks.first,
                  decoration: InputDecoration(labelText: 'Task'),
                  items:
                      tasks.map((Task t) {
                        return DropdownMenuItem<Task>(
                          value: t,
                          child: Text(t.name),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value == "Add new task") {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AddTaskDialog(
                              onAdd: (newTask) {
                                Provider.of<TaskProvider>(
                                  context,
                                  listen: false,
                                ).addTask(newTask);
                                Navigator.pop(context);
                              },
                            ),
                      );
                    }
                  },
                  onSaved: (value) {
                    if (value != null) {
                      taskId = value.id;
                    }
                  },
                );
              },
            ),

            // DropdownButtonFormField<String>(
            //   value: projectId,
            //   onChanged: (String? newValue) {
            //     setState(() {
            //       projectId = newValue!;
            //     });
            //   },
            //   decoration: InputDecoration(labelText: 'Project'),
            //   // items: <Project>[],
            //   items:
            //       <String>[
            //         'Project 1',
            //         'Project 2',
            //         'Project 3',
            //       ].map<DropdownMenuItem<String>>((String value) {
            //         return DropdownMenuItem<String>(
            //           value: value,
            //           child: Text(value),
            //         );
            //       }).toList(),
            // ),

            // DropdownButtonFormField<String>(
            //   value: taskId,
            //   onChanged: (String? newValue) {
            //     setState(() {
            //       taskId = newValue!;
            //     });
            //   },
            //   decoration: InputDecoration(labelText: 'Task'),
            //   items:
            //       <String>[
            //         'Task 1',
            //         'Task 2',
            //         'Task 3',
            //       ].map<DropdownMenuItem<String>>((String value) {
            //         return DropdownMenuItem(value: value, child: Text(value));
            //       }).toList(),
            // ),
            TextFormField(
              decoration: InputDecoration(label: Text('Total time (hours)')),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total time';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              onSaved: (value) => totalTime = double.parse(value!),
            ),
            TextFormField(
              decoration: InputDecoration(label: Text('Notes')),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some notes';
                }
                return null;
              },
              onSaved: (value) => notes = value!,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Provider.of<TimeEntryProvider>(
                    context,
                    listen: false,
                  ).addTimeEntry(
                    TimeEntry(
                      id: DateTime.now().toString(),
                      projectId: projectId,
                      taskId: taskId,
                      totalTime: totalTime,
                      date: date,
                      notes: notes,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
