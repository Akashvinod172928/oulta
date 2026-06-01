import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oulta/features/data/social/services/firebase_service.dart';
import 'package:oulta/features/presentation/account/controller/account_controller.dart';

class ChangeAccountScreen extends StatefulWidget {
  const ChangeAccountScreen({super.key});

  @override
  State<ChangeAccountScreen> createState() => _ChangeAccountScreenState();
}

class _ChangeAccountScreenState extends State<ChangeAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  late final NameController _nameController = Get.isRegistered<NameController>()
      ? Get.find<NameController>()
      : Get.put(NameController());

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _currentTypeController = TextEditingController();

  String _selectedRequestedType = 'NGO'; // Default
  final List<String> _accountTypes = ['NGO', 'Company', 'Group'];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Auto-fill from NameController
    final currentType = _nameController.profileType.value;
    _currentTypeController.text = currentType.isEmpty
        ? 'User'
        : (currentType[0].toUpperCase() + currentType.substring(1));
    _emailController.text = _nameController.userEmail.value;
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _firebaseService.sendAccountChangeRequest(
        email: _emailController.text.trim(),
        contactNumber: _contactController.text.trim(),
        currentType: _currentTypeController.text.trim(),
        requestedType: _selectedRequestedType,
      );

      // Instantly update the user's profile type in Firestore for immediate effect
      final userId = _nameController.userId;
      if (userId.isNotEmpty) {
        // We import cloud_firestore dynamically or ensure it's available.
        // Actually, let's use the repository or direct update:
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'profileType': _selectedRequestedType.toLowerCase(),
        });
        // Update local state and trigger UI refresh
        _nameController.profileType.value = _selectedRequestedType.toLowerCase();
        
        // Also force a reload of the profile data
        await _nameController.loadUserData();
      }

      Get.snackbar(
        'Success',
        'Account type changed to $_selectedRequestedType!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Delay slightly before going back
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send request: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Account Type',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Request to change your account type to proceed as an organization or group.',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Current Account Type
              TextFormField(
                controller: _currentTypeController,
                readOnly: true, // Auto-filled
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  labelText: 'Current Account Type',
                  border: const OutlineInputBorder(),
                  fillColor: Colors.grey[100],
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),

              // Requested Type
              DropdownButtonFormField<String>(
                value: _selectedRequestedType,
                decoration: const InputDecoration(
                  labelText: 'Requested Account Type',
                  border: OutlineInputBorder(),
                ),
                items: _accountTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRequestedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                readOnly: true, // Auto-filled
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: const OutlineInputBorder(),
                  fillColor: Colors.grey[100],
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),

              // Contact Number
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact number';
                  }
                  if (value.length != 10 ||
                      !RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Send Request',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
