import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_tracker/constants/appTheme.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins == 0 ? '${hours}h' : '${hours}h ${mins}m';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Dashboard', style: AppTextStyles.heading5),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),

          SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final totalStudyTime = userData['totalStudyTime'] ?? 0;
          final userName = userData['name'] ?? 'Student';

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Container(
                      padding: EdgeInsets.all(AppSpacing.xxl),
                      decoration: AppDecorations.primaryGradient,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textOnPrimary.withOpacity(
                                      0.8,
                                    ),
                                  ),
                                ),
                                SizedBox(height: AppSpacing.xs),
                                Text(
                                  userName,
                                  style: AppTextStyles.heading2.copyWith(
                                    color: AppColors.textOnPrimary,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Ready to continue learning?',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textOnPrimary.withOpacity(
                                      0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.textOnPrimary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.large,
                              ),
                            ),
                            child: Icon(
                              Icons.school,
                              color: AppColors.textOnPrimary,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSpacing.xxl),

                    // Study Time Stats
                    Container(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      decoration: AppDecorations.card,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSpacing.md),
                            decoration: AppDecorations.secondaryContainer,
                            child: Icon(
                              Icons.timer_outlined,
                              color: AppColors.secondary,
                              size: 28,
                            ),
                          ),
                          SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Study Time',
                                  style: AppTextStyles.labelLarge,
                                ),
                                SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${(totalStudyTime / 60).toStringAsFixed(1)} hours',
                                  style: AppTextStyles.heading3,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: AppDecorations.successContainer,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  color: AppColors.success,
                                  size: 16,
                                ),
                                SizedBox(width: AppSpacing.xs),
                                Text(
                                  '+12%',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSpacing.xxl),

                    SizedBox(height: AppSpacing.lg),

                    // Study Sessions List
                    StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('study_sessions')
                              .where('userId', isEqualTo: user.uid)
                              .orderBy('startTime', descending: true)
                              .limit(5)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          );
                        }

                        final sessions = snapshot.data!.docs;

                        if (sessions.isEmpty) {
                          return Container(
                            height: 200,
                            decoration: AppDecorations.card,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.book_outlined,
                                    size: 48,
                                    color: AppColors.textTertiary,
                                  ),
                                  SizedBox(height: AppSpacing.lg),
                                  Text(
                                    'No study sessions yet',
                                    style: AppTextStyles.heading6,
                                  ),
                                  SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Start your first study session!',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children:
                              sessions.asMap().entries.map((entry) {
                                final index = entry.key;
                                final session =
                                    entry.value.data() as Map<String, dynamic>;
                                final startTime =
                                    (session['startTime'] as Timestamp)
                                        .toDate();
                                final duration = session['duration'] ?? 0;
                                final courseName =
                                    session['courseName'] ?? 'Study Session';

                                return TweenAnimationBuilder<double>(
                                  duration: Duration(
                                    milliseconds: 600 + (index * 100),
                                  ),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 30 * (1 - value)),
                                      child: Opacity(
                                        opacity: value,
                                        child: Container(
                                          margin: EdgeInsets.only(
                                            bottom: AppSpacing.md,
                                          ),
                                          padding: EdgeInsets.all(
                                            AppSpacing.lg,
                                          ),
                                          decoration: AppDecorations.card,
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(
                                                  AppSpacing.sm + 2,
                                                ),
                                                decoration:
                                                    AppDecorations
                                                        .accentContainer,
                                                child: Icon(
                                                  Icons.book_outlined,
                                                  color: AppColors.accent,
                                                  size: 20,
                                                ),
                                              ),
                                              SizedBox(width: AppSpacing.md),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      courseName,
                                                      style:
                                                          AppTextStyles
                                                              .heading6,
                                                    ),
                                                    SizedBox(
                                                      height: AppSpacing.xs,
                                                    ),
                                                    Text(
                                                      _formatDuration(duration),
                                                      style: AppTextStyles
                                                          .bodyMedium
                                                          .copyWith(
                                                            color:
                                                                AppColors
                                                                    .textSecondary,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    '${startTime.day}/${startTime.month}',
                                                    style:
                                                        AppTextStyles
                                                            .labelLarge,
                                                  ),
                                                  SizedBox(
                                                    height: AppSpacing.xs,
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal:
                                                              AppSpacing.sm,
                                                          vertical: 2,
                                                        ),
                                                    decoration:
                                                        AppDecorations
                                                            .primaryContainer,
                                                    child: Text(
                                                      'Completed',
                                                      style: AppTextStyles
                                                          .labelSmall
                                                          .copyWith(
                                                            color:
                                                                AppColors
                                                                    .primary,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
