// ignore_for_file: file_names, avoid_types_as_parameter_names

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_tracker/Screens/studyTimer.dart';
import 'package:learning_tracker/constants/appTheme.dart';

class CourseDetailPage extends StatelessWidget {
  final String courseId;
  final String courseName;

  const CourseDetailPage({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  String _formatTotalTime(int totalSeconds) {
    final hours = totalSeconds / 3600;
    if (hours >= 1) {
      return '${hours.toStringAsFixed(1)} hours';
    } else {
      final minutes = totalSeconds / 60;
      return '${minutes.toStringAsFixed(0)} minutes';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == today) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (sessionDate == today.subtract(Duration(days: 1))) {
      return 'Yesterday at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(courseName, style: AppTextStyles.heading5),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('study_sessions')
                .where('userId', isEqualTo: user.uid)
                .where('courseId', isEqualTo: courseId)
                .orderBy('startTime', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'Loading your study data...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final sessions = snapshot.data!.docs;
          final totalTime = sessions.fold(0, (sum, doc) {
            final data = doc.data() as Map<String, dynamic>;
            return sum + (data['duration'] as int? ?? 0);
          });

          final sessionCount = sessions.length;
          final averageSession =
              sessionCount > 0 ? totalTime / sessionCount : 0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course header with stats
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSpacing.xl),
                  decoration: AppDecorations.primaryGradient,
                  child: Column(
                    children: [
                      Icon(
                        Icons.school,
                        size: 48,
                        color: AppColors.textOnPrimary,
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Text(
                        courseName,
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'Keep up the great work!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.xl),

                // Stats cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        decoration: AppDecorations.card,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: AppColors.success,
                                  size: 24,
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Total Time',
                                  style: AppTextStyles.labelMedium,
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              _formatTotalTime(totalTime),
                              style: AppTextStyles.heading6.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        decoration: AppDecorations.card,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  color: AppColors.accent,
                                  size: 24,
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Sessions',
                                  style: AppTextStyles.labelMedium,
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              '$sessionCount',
                              style: AppTextStyles.heading6.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacing.lg),

                // Average session time card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: AppDecorations.card,
                  child: Row(
                    children: [
                      Icon(
                        Icons.bar_chart,
                        color: AppColors.secondary,
                        size: 24,
                      ),
                      SizedBox(width: AppSpacing.lg),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Average Session',
                            style: AppTextStyles.labelMedium,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            sessionCount > 0
                                ? _formatDuration(averageSession.round())
                                : '0m',
                            style: AppTextStyles.heading6.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.xxxl),

                // Start session button
                Container(
                  width: double.infinity,
                  decoration: AppDecorations.primaryGradient,
                  child: ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.large,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_filled,
                          color: AppColors.textOnPrimary,
                          size: 24,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Start Study Session',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.xxxl),

                // Sessions header
                Row(
                  children: [
                    Icon(Icons.history, color: AppColors.textPrimary, size: 24),
                    SizedBox(width: AppSpacing.sm),
                    Text('Study History', style: AppTextStyles.heading5),
                  ],
                ),

                SizedBox(height: AppSpacing.lg),

                // Sessions list
                if (sessions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSpacing.xxxl),
                    decoration: AppDecorations.card,
                    child: Column(
                      children: [
                        Icon(
                          Icons.library_books,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(height: AppSpacing.lg),
                        Text(
                          'No study sessions yet',
                          style: AppTextStyles.heading6.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'Start your first study session to see your progress here!',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: sessions.length,
                    separatorBuilder:
                        (context, index) => SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final session =
                          sessions[index].data() as Map<String, dynamic>;
                      final startTime =
                          (session['startTime'] as Timestamp).toDate();
                      final endTime =
                          session['endTime'] != null
                              ? (session['endTime'] as Timestamp).toDate()
                              : null;
                      final duration = session['duration'] ?? 0;

                      return Container(
                        decoration: AppDecorations.card,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(AppSpacing.lg),
                          leading: Container(
                            padding: EdgeInsets.all(AppSpacing.sm),
                            decoration: AppDecorations.successContainer,
                            child: Icon(
                              Icons.play_circle_filled,
                              color: AppColors.success,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            'Study Session',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: AppSpacing.xs),
                              Text(
                                _formatDate(startTime),
                                style: AppTextStyles.bodySmall,
                              ),
                              if (endTime != null) ...[
                                SizedBox(height: AppSpacing.xs),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: AppColors.textTertiary,
                                    ),
                                    SizedBox(width: AppSpacing.xs),
                                    Text(
                                      'Ended at ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: AppDecorations.primaryContainer,
                            child: Text(
                              _formatDuration(duration),
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
