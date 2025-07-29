import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_tracker/Screens/studyTimer.dart';

class CourseDetailPage extends StatelessWidget {
  final String courseId;
  final String courseName;

  CourseDetailPage({required this.courseId, required this.courseName});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(title: Text(courseName)),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('study_sessions')
                .where('userId', isEqualTo: user.uid)
                .where('courseId', isEqualTo: courseId)
                .orderBy('startTime', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final sessions = snapshot.data!.docs;
          final totalTime = sessions.fold(0, (sum, doc) {
            final data = doc.data() as Map<String, dynamic>;
            return sum + (data['duration'] as int? ?? 0);
          });

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.timer, size: 40, color: Colors.green),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Time Studied'),
                            Text(
                              '${(totalTime / 60).toStringAsFixed(1)} hours',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),
                Text(
                  'Study Sessions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => StudyTimerPage(
                              courseId: courseId,
                              courseName: courseName,
                            ),
                      ),
                    );
                  },
                  child: Text('Start Study Session'),
                ),

                SizedBox(height: 16),

                Expanded(
                  child: ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session =
                          sessions[index].data() as Map<String, dynamic>;
                      final startTime =
                          (session['startTime'] as Timestamp).toDate();
                      final duration = session['duration'] ?? 0;

                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.play_circle_filled),
                          title: Text('Study Session'),
                          subtitle: Text(
                            '${startTime.day}/${startTime.month}/${startTime.year}',
                          ),
                          trailing: Text(
                            '${(duration / 60).toStringAsFixed(0)}m',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
