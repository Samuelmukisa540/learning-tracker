import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_tracker/Screens/studyTimer.dart';
import 'package:learning_tracker/constants/appTheme.dart';

class StudySessionPage extends StatelessWidget {
  const StudySessionPage({super.key});

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Quick Study', style: AppTextStyles.heading5),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            );
          }

          final courses = snapshot.data!.docs;

          return Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  decoration: AppDecorations.primaryContainer,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.medium,
                          ),
                        ),
                        child: Icon(
                          Icons.school,
                          color: AppColors.textOnPrimary,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ready to Study?',
                              style: AppTextStyles.heading4.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              'Select a course to start your focused study session',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.xxl),

                // Courses List Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: Text(
                    'Available Courses',
                    style: AppTextStyles.heading6.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.lg),

                // Courses List
                Expanded(
                  child:
                      courses.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                            itemCount: courses.length,
                            separatorBuilder:
                                (context, index) =>
                                    SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final course =
                                  courses[index].data() as Map<String, dynamic>;
                              return _buildCourseCard(
                                context,
                                courses[index].id,
                                course,
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

  Widget _buildCourseCard(
    BuildContext context,
    String courseId,
    Map<String, dynamic> course,
  ) {
    final courseTitle = capitalizeFirstLetter(
      course['title'] ?? 'Unnamed Course',
    );

    return Container(
      decoration: AppDecorations.card,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => StudyTimerPage(
                      courseId: courseId,
                      courseName: courseTitle,
                    ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Course Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppColors.primaryGradient,
                    ),
                    borderRadius: BorderRadius.circular(AppBorderRadius.large),
                    boxShadow: [AppShadows.small],
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.textOnPrimary,
                    size: 28,
                  ),
                ),

                SizedBox(width: AppSpacing.lg),

                // Course Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courseTitle,
                        style: AppTextStyles.heading6,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Tap to start studying',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppBorderRadius.small),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppBorderRadius.round),
            ),
            child: Icon(
              Icons.library_books_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            'No Courses Available',
            style: AppTextStyles.heading5.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Add some courses to start studying',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
