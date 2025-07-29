import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Text(
                    (userData['name'] ?? 'U')[0].toUpperCase(),
                    style: TextStyle(fontSize: 32),
                  ),
                ),
                SizedBox(height: 16),

                Text(
                  userData['name'] ?? 'User',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(userData['email'] ?? ''),

                SizedBox(height: 32),

                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Study Time'),
                            Text(
                              '${((userData['totalStudyTime'] ?? 0) / 3600).toStringAsFixed(1)} hours',
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Member Since'),
                            Text(
                              userData['createdAt'] != null
                                  ? '${(userData['createdAt'] as Timestamp).toDate().day}/${(userData['createdAt'] as Timestamp).toDate().month}/${(userData['createdAt'] as Timestamp).toDate().year}'
                                  : 'Unknown',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
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
