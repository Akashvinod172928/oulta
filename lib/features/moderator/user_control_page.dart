import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserControlPage extends StatefulWidget {
  const UserControlPage({Key? key}) : super(key: key);

  @override
  _UserControlPageState createState() => _UserControlPageState();
}

class _UserControlPageState extends State<UserControlPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentSnapshot? _userDoc;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  Future<void> _fetchUser() async {
    if (_emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter an email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _userDoc = null;
      _userData = null;
    });

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() { // Required to update the UI with fetched data
          _userDoc = querySnapshot.docs.first;
          _userData = _userDoc!.data() as Map<String, dynamic>;
        });
      } else {
        Get.snackbar('Not Found', 'No user found with that email.');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfileType(String newType) async {
    if (_userDoc == null) return;

    try {
      await _userDoc!.reference.update({'profileType': newType});
      setState(() {
        _userData!['profileType'] = newType;
      });
      Get.snackbar('Success', "User updated to '$newType'");
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    }
  }

  Future<void> _deleteUser() async {
    if (_userDoc == null) return;

    await Get.defaultDialog(
      title: 'Confirm Deletion',
      middleText: 'Are you sure you want to delete this user? This action cannot be undone.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back(); // Close dialog
        try {
          await _userDoc!.reference.delete();
          setState(() {
            _userDoc = null;
            _userData = null;
          });
          Get.snackbar('Success', 'User has been deleted.');
        } catch (e) {
          Get.snackbar('Error', 'Failed to delete user: $e');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Control')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchCard(),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_userData != null)
              _buildUserDetailsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Find User by Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _fetchUser,
                child: const Text('Fetch User'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetailsCard() {
    final currentType = _userData!['profileType'] ?? 'user';

    return Card(
      margin: const EdgeInsets.only(top: 20),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${_userData!['name'] ?? 'N/A'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Email: ${_userData!['email']}'),
            const SizedBox(height: 8),
            Text('Current Profile Type: $currentType'), // Corrected this line
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _updateProfileType('user'),
                  child: const Text('Set to User'),
                  style: ElevatedButton.styleFrom(backgroundColor: currentType == 'user' ? Colors.grey : Colors.blue),
                ),
                ElevatedButton(
                  onPressed: () => _updateProfileType('ngo'),
                  child: const Text('Set to NGO'),
                   style: ElevatedButton.styleFrom(backgroundColor: currentType == 'ngo' ? Colors.grey : Colors.blue),
                ),
              ],
            ),
            const Divider(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _deleteUser,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete User'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
