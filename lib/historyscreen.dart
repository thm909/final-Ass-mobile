import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'editsubmissionscreen.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List subs = [];
  bool loading = true;

  Future<void> load() async {
    setState(() => loading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = json.decode(prefs.getString('worker')!)['id'];
    final res = await http.post(
      Uri.parse('http://10.0.2.2/wtms/get_submissions.php'),
      body: {'worker_id': id.toString()},
    );
    final d = json.decode(res.body);
    subs = d['status'] == 'success' ? d['submissions'] : [];
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Center(child: CircularProgressIndicator());
    if (subs.isEmpty) {
      return Center(
        child: Text(
          'No submission history yet.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: subs.length,
      itemBuilder: (_, i) {
        var s = subs[i];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Text(
              s['task_title'] ?? 'Untitled',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submitted: ${s['submitted_at'] ?? '-'}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 6),
                  Text(
                    s['submission_text'] ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
            trailing: Icon(Icons.edit, color: Colors.teal),
            onTap: () async {
              bool? ok = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditSubmissionScreen(submission: s),
                ),
              );
              if (ok == true) load();
            },
          ),
        );
      },
    );
  }
}
