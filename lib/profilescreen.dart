import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginscreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final idCtrl = TextEditingController();

  String workerId = '';
  bool loading = true;
  bool saving = false;

  Future<void> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final workerJson = prefs.getString('worker');

    if (workerJson == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please log in again.')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
      return;
    }

    final workerData = json.decode(workerJson);
    workerId = workerData['id'].toString();
    idCtrl.text = workerId;

    try {
      final res = await http.post(
        Uri.parse('http://10.0.2.2/wtms/get_profile.php'),
        body: {'worker_id': workerId},
      );

      final d = json.decode(res.body);
      if (d['status'] == 'success') {
        nameCtrl.text = d['user']['name'] ?? '';
        emailCtrl.text = d['user']['email'] ?? '';
        phoneCtrl.text = d['user']['phone'] ?? '';
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load profile')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading profile')));
    }

    setState(() => loading = false);
  }

  Future<void> _save() async {
    setState(() => saving = true);

    try {
      final res = await http.post(
        Uri.parse('http://10.0.2.2/wtms/update_profile.php'),
        body: {
          'worker_id': workerId,
          'name': nameCtrl.text,
          'email': emailCtrl.text,
          'phone': phoneCtrl.text,
        },
      );

      final d = json.decode(res.body);
      if (d['status'] == 'success') {
        final user = d['user'];

        // Update TextField content
        setState(() {
          nameCtrl.text = user['name'];
          emailCtrl.text = user['email'];
          phoneCtrl.text = user['phone'];
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('worker', json.encode(user));

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Profile updated')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(d['message'] ?? 'Update failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Server error')));
    }

    setState(() => saving = false);
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('worker');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    bool readOnly = false,
    TextInputType? type,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: ctrl,
        readOnly: readOnly,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: readOnly ? Colors.grey[200] : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTextField("Worker ID", idCtrl, readOnly: true),
                _buildTextField("Name", nameCtrl),
                _buildTextField(
                  "Email",
                  emailCtrl,
                  type: TextInputType.emailAddress,
                ),
                _buildTextField("Phone", phoneCtrl, type: TextInputType.phone),
                const SizedBox(height: 16),
                saving
                    ? CircularProgressIndicator()
                    : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.save),
                        label: Text('Update Profile'),
                        onPressed: _save,
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
