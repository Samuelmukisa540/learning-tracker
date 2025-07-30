// ignore: file_names
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_tracker/Screens/courseDetail.dart';
import 'package:learning_tracker/constants/appTheme.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Courses', style: AppTextStyles.heading5),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final courses = snapshot.data!.docs;

          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'No courses yet',
                    style: AppTextStyles.heading5.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Start adding courses to track your learning journey',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: ListView.separated(
              itemCount: courses.length,
              separatorBuilder:
                  (context, index) => SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final course = courses[index].data() as Map<String, dynamic>;
                final courseName = capitalizeFirstLetter(
                  course['title'] ?? 'Unnamed Course',
                );
                final courseDescription =
                    course['description'] ?? 'No description available';

                return Container(
                  decoration: AppDecorations.card,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.medium,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => CourseDetailPage(
                                  courseId: courses[index].id,
                                  courseName: courseName,
                                ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            // Course Avatar
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: AppColors.primaryGradient,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.medium,
                                ),
                                boxShadow: [AppShadows.small],
                              ),
                              child: Center(
                                child: Text(
                                  courseName[0].toUpperCase(),
                                  style: AppTextStyles.heading6.copyWith(
                                    color: AppColors.textOnPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: AppSpacing.lg),

                            // Course Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    courseName,
                                    style: AppTextStyles.heading6,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: AppSpacing.xs),
                                  Text(
                                    courseDescription,
                                    style: AppTextStyles.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: AppSpacing.md),

                            // Arrow Icon
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.small,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
