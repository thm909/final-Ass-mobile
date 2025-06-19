import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubmitCompletionScreen extends StatefulWidget {
  final Map task;
  SubmitCompletionScreen({required this.task});

  @override
  _SubmitCompletionScreenState createState() => _SubmitCompletionScreenState();
}

class _SubmitCompletionScreenState extends State<SubmitCompletionScreen> {
  final ctrl = TextEditingController();
  bool loading = false;

  Future<void> _submit() async {
    if (ctrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Enter completion')));
      return;
    }
    setState(() => loading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = json.decode(prefs.getString('worker')!)['id'];
    final res = await http.post(
      Uri.parse('http://10.0.2.2/wtms/submit_work.php'),
      body: {
        'worker_id': id.toString(),
        'work_id': widget.task['id'].toString(),
        'submission_text': ctrl.text,
      },
    );
    setState(() => loading = false);
    final d = json.decode(res.body);
    if (d['status'] == 'success') {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(d['message'] ?? 'Failed')));
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text('Submit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              widget.task['title'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 5,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            loading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _submit, child: Text('Submit')),
          ],
        ),
      ),
    );
  }
}
