import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:time_tracker/models/task.dart';

class TaskProvider with ChangeNotifier{
  final LocalStorage storage;

  List<Task> _tasks = [
    Task(id: '1', name: 'Breakfast'),
    Task(id: '2', name: 'Lunch'),
    Task(id: '3', name: 'Dinner'),
    Task(id: '4', name: 'Treat'),
    Task(id: '5', name: 'Cafe'),
    Task(id: '6', name: 'Restaurant'),
    Task(id: '7', name: 'Train'),
    Task(id: '8', name: 'Vacation'),
    Task(id: '9', name: 'Birthday'),
    Task(id: '10', name: 'Diet'),
    Task(id: '11', name: 'MovieNight'),
    Task(id: '12', name: 'Tech'),
    Task(id: '13', name: 'CarStuff'),
    Task(id: '14', name: 'SelfCare'),
    Task(id: '15', name: 'Streaming'),
  ];
  List<Task> get tasks => _tasks;

  TaskProvider(this.storage){
    _loadTasksFromStorage();
  }

  void _loadTasksFromStorage() async {
    var storedTasks = storage.getItem('tasks');
    if(storedTasks != null){
      _tasks = List<Task>.from(
        (storedTasks as List).map((item) => Task.fromJson(item))
      );
      notifyListeners();
    }
  }

  void addTask(Task task){
    if(!_tasks.any((t)=> t.name == task.name)){
    _tasks.add(task);
    _saveTasksToStorage();
    notifyListeners();
    }
  }

  void _saveTasksToStorage(){
    storage.setItem('tasks', jsonEncode(_tasks.map((t) => t.toJson()).toList));
  }

  void deleteTask(String id){
    _tasks.removeWhere((task )=> task.id == id);
    notifyListeners();
  }

}