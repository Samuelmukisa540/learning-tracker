// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_tracker/constants/appTheme.dart';

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
      await Future.delayed(const Duration(seconds: 1));
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User not authenticated!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textOnDark,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            ),
          ),
        );
        return;
      }

      try {
        // Save study session
        await FirebaseFirestore.instance.collection('study_sessions').add({
          'userId': user.uid,
          'courseId': widget.courseId,
          'courseName': widget.courseName,
          'startTime': _startTime,
          'endTime': DateTime.now(),
          'duration': _seconds,
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'totalStudyTime': FieldValue.increment(_seconds)});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.textOnDark),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Study session saved! Great job!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnDark,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: AppColors.textOnDark),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Error saving session: ${e.toString()}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnDark,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            ),
          ),
        );
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.courseName, style: AppTextStyles.heading5),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: AppSpacing.lg),
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: AppDecorations.successContainer,
                child: Icon(Icons.check, color: AppColors.success, size: 20),
              ),
              onPressed: _finishSession,
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            // Course info card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: AppDecorations.card,
              child: Column(
                children: [
                  Icon(Icons.school, size: 32, color: AppColors.primary),
                  SizedBox(height: AppSpacing.sm),
                  Text('Studying', style: AppTextStyles.labelMedium),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.courseName,
                    style: AppTextStyles.heading6,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Timer display
                    Container(
                      padding: EdgeInsets.all(AppSpacing.xxxl),
                      decoration:
                          _isRunning
                              ? AppDecorations.primaryGradient
                              : AppDecorations.cardElevated,
                      child: Text(
                        _formatTime(_seconds),
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color:
                              _isRunning
                                  ? AppColors.textOnPrimary
                                  : AppColors.textPrimary,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.xxxl),

                    // Control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Play/Pause button
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors:
                                  _isRunning
                                      ? [
                                        AppColors.warning,
                                        AppColors.warningDark,
                                      ]
                                      : AppColors.primaryGradient,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.round,
                            ),
                            boxShadow: [
                              _isRunning
                                  ? AppShadows.medium
                                  : AppShadows.primaryShadow,
                            ],
                          ),
                          child: FloatingActionButton.large(
                            onPressed: _toggleTimer,
                            heroTag: "timer",
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            child: Icon(
                              _isRunning ? Icons.pause : Icons.play_arrow,
                              color: AppColors.textOnPrimary,
                              size: 32,
                            ),
                          ),
                        ),

                        // Stop button
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.error, AppColors.errorDark],
                            ),
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.round,
                            ),
                            boxShadow: [AppShadows.medium],
                          ),
                          child: FloatingActionButton.large(
                            onPressed: _finishSession,
                            heroTag: "stop",
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            child: Icon(
                              Icons.stop,
                              color: AppColors.textOnPrimary,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppSpacing.xxxl),

                    // Status message
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.lg,
                      ),
                      decoration:
                          _isRunning
                              ? AppDecorations.successContainer
                              : AppDecorations.primaryContainer,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isRunning
                                ? Icons.psychology
                                : Icons.lightbulb_outline,
                            color:
                                _isRunning
                                    ? AppColors.success
                                    : AppColors.primary,
                            size: 20,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            _isRunning
                                ? 'Focus time! Keep going!'
                                : 'Ready to study?',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color:
                                  _isRunning
                                      ? AppColors.success
                                      : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Session stats
            if (_seconds > 0)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: AppDecorations.card,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Session Time', style: AppTextStyles.labelMedium),
                        Text(
                          _formatTime(_seconds),
                          style: AppTextStyles.heading6.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (_startTime != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Started', style: AppTextStyles.labelMedium),
                          Text(
                            '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
                            style: AppTextStyles.heading6.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
