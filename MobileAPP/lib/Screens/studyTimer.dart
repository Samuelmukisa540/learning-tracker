// ignore: file_names
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudyTimerPage extends StatefulWidget {
  final String courseId;
  final String courseName;

  const StudyTimerPage({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  _StudyTimerPageState createState() => _StudyTimerPageState();
}

class _StudyTimerPageState extends State<StudyTimerPage> {
  int _seconds = 0;
  bool _isRunning = false;
  DateTime? _startTime;

  void _toggleTimer() {
    setState(() {
      if (_isRunning) {
        _pauseTimer();
      } else {
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _isRunning = true;
    _startTime = DateTime.now();

    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (_isRunning) {
        setState(() => _seconds++);
        return true;
      }
      return false;
    });
  }

  void _pauseTimer() {
    _isRunning = false;
  }

  Future<void> _finishSession() async {
    if (_seconds > 0) {
      final user = FirebaseAuth.instance.currentUser!;

      // Save study session
      await FirebaseFirestore.instance.collection('study_sessions').add({
        'userId': user.uid,
        'courseId': widget.courseId,
        'courseName': widget.courseName,
        'startTime': _startTime,
        'endTime': DateTime.now(),
        'duration': _seconds,
      });

      // Update user's total study time
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'totalStudyTime': FieldValue.increment(_seconds)},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Study session saved! Great job!')),
      );
    }

    Navigator.pop(context);
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseName),
        actions: [
          IconButton(icon: Icon(Icons.check), onPressed: _finishSession),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_seconds),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: _toggleTimer,
                  heroTag: "timer",
                  child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                ),
                FloatingActionButton(
                  onPressed: _finishSession,
                  backgroundColor: Colors.red,
                  heroTag: "stop",
                  child: Icon(Icons.stop),
                ),
              ],
            ),

            SizedBox(height: 40),
            Text(
              _isRunning ? 'Focus time! Keep going!' : 'Ready to study?',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
