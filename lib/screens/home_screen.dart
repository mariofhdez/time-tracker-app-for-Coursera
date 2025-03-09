import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker/models/time_entry.dart';
import 'package:time_tracker/providers/project_provider.dart';
import 'package:time_tracker/providers/task_provider.dart';
import 'package:time_tracker/providers/time_entry_provider.dart';
import 'package:time_tracker/screens/add_time_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Entries'),
        backgroundColor: Colors.teal[800],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [Tab(text: "All entries"), Tab(text: "Grouped by Projects")],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal[800]),
              child: Center(child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            )),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('Projects'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/manage_projects');
              },
            ),
            ListTile(
              leading: Icon(Icons.task),
              title: Text('Tasks'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/manage_tasks');
              },
            ),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [buildAllEntries(context), buildEntriesByProject(context)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTimeEntryScreen()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.teal[700],
        tooltip: 'Add Time Entry',
      ),
    );
  }

  Widget buildAllEntries(BuildContext context) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hourglass_empty,
                  color: Colors.grey[400],
                  size: 120,
                  opticalSize: 72,
                ),
                SizedBox(height: 20),
                Text(
                  "No time entries yet!",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Tap the + button to add your first entry.",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 18,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: provider.entries.length,
          itemBuilder: (context, index) {
            final timeEntry = provider.entries[index];
            return ListTile(
              title: Text(
                '${getProjectById(context, timeEntry.projectId)} - ${timeEntry.totalTime} hours',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${DateFormat('MMM dd, yyyy').format(timeEntry.date)} - Notes: ${timeEntry.notes}',
              ),
              onTap: () {
                Navigator.pushNamed(context,
                '/time_entry',
                arguments: {
                  'entryId': timeEntry.id,
                  'projectName': '${getProjectById(context, timeEntry.projectId)}',
                  'taskName': '${getTaskById(context, timeEntry.taskId)}',
                  'totalTime': timeEntry.totalTime,
                  'date': '${DateFormat('MMM dd, yyyy').format(timeEntry.date)}',
                  'notes': timeEntry.notes,
                }
              );
              },
            );
          },
        );
      },
    );
  }

  Widget buildEntriesByProject(BuildContext context) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hourglass_empty,
                  color: Colors.grey[400],
                  size: 120,
                  opticalSize: 72,
                ),
                SizedBox(height: 20),
                Text(
                  "No time entries yet!",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Tap the + button to add your first entry.",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 18,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }
        var grouped = groupBy(provider.entries, (TimeEntry e) => e.projectId);
        return ListView(
          children:
              grouped.entries.map((entry) {
                String projectName = getProjectById(context, entry.key);
                double total = entry.value.fold(
                  0.0,
                  (double prev, TimeEntry element) => prev + element.totalTime,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "$projectName - Total: ${total.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: entry.value.length,
                      itemBuilder: (context, index) {
                        TimeEntry timeEntry = entry.value[index];
                        return ListTile(
                          title: Text(
                            '${getProjectById(context, timeEntry.projectId)} - ${timeEntry.totalTime} hours',
                          ),
                          subtitle: Text(
                            '${DateFormat('MMM dd, yyyy').format(timeEntry.date)} - Notes: ${timeEntry.notes}',
                          ),
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
        );
      },
    );
  }

  String getProjectById(BuildContext context, String projectId) {
    var project = Provider.of<ProjectProvider>(
      context,
      listen: false,
    ).projects.firstWhere((pro) => pro.id == projectId);
    return project.name;
  }

  String getTaskById(BuildContext context, String taskId){
    var task = Provider.of<TaskProvider>(
      context,
      listen: false
    ).tasks.firstWhere((t) => t.id == taskId);
    return task.name;
  }
}
