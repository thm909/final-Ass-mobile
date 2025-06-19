import 'package:flutter/material.dart';
import 'submitcompletionscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List tasks = [];
  bool loading = true;

  Future<void> fetchTasks() async {
    setState(() => loading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? w = prefs.getString('worker');
    if (w == null) return;
    var id = json.decode(w)['id'];
    final res = await http.post(
      Uri.parse('http://10.0.2.2/wtms/get_work.php'),
      body: {'worker_id': id.toString()},
    );
    var d = json.decode(res.body);
    tasks = d['status'] == 'success' ? d['tasks'] : [];
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      body:
          loading
              ? Center(child: CircularProgressIndicator())
              : tasks.isEmpty
              ? Center(child: Text('No tasks available'))
              : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: tasks.length,
                itemBuilder: (_, i) {
                  var t = tasks[i];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.task, color: Colors.teal),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  t['title'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Due: ${t['due_date']}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              t['status'] == 'pending'
                                  ? ElevatedButton.icon(
                                    icon: Icon(Icons.send),
                                    label: Text('Submit'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () async {
                                      bool? ok = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => SubmitCompletionScreen(
                                                task: t,
                                              ),
                                        ),
                                      );
                                      if (ok == true) fetchTasks();
                                    },
                                  )
                                  : Chip(
                                    label: Text('Completed'),
                                    backgroundColor: Colors.green[100],
                                    labelStyle: TextStyle(
                                      color: Colors.green[800],
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
    );
  }
}
