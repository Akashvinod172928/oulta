import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FirebaseTestWidget extends StatelessWidget {
  const FirebaseTestWidget({Key? key}) : super(key: key);

  Future<void> testFirebaseConnection() async {
    try {
      print('🔥 Testing Firebase connection...');

      // Test if Firebase is initialized
      final firestore = FirebaseFirestore.instance;
      print('✅ Firebase instance created');

      // Simple write test with timeout
      await firestore
          .collection('test')
          .doc('connection_test')
          .set({
        'message': 'Hello Firebase!',
        'timestamp': FieldValue.serverTimestamp(),
      })
          .timeout(const Duration(seconds: 10));

      print('✅ Write test successful');

      // Test read
      final doc = await firestore
          .collection('test')
          .doc('connection_test')
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists) {
        print('✅ Read test successful: ${doc.data()}');
        Get.snackbar(
          'Success',
          'Firebase connection working!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

    } on FirebaseException catch (e) {
      print('🚫 Firebase Exception: ${e.code} - ${e.message}');
      Get.snackbar(
        'Firebase Error',
        '${e.code}: ${e.message}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    } on TimeoutException catch (e) {
      print('🚫 Timeout: $e');
      Get.snackbar(
        'Timeout',
        'Firebase connection timed out. Check your internet.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      print('🚫 General error: $e');
      Get.snackbar(
        'Error',
        'Failed to connect: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: testFirebaseConnection,
      child: Icon(Icons.cloud_upload),
      tooltip: 'Test Firebase',
    );
  }
}