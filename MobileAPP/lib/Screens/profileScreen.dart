import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:learning_tracker/constants/appTheme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.heading5),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(icon: Icon(Icons.edit_outlined), onPressed: () {}),
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
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(
                  userData,
                  FirebaseAuth.instance.currentUser,
                ),

                SizedBox(height: AppSpacing.xxxl),

                // Stats Cards
                _buildStatsSection(userData),

                SizedBox(height: AppSpacing.xxxl),

                // Account Settings Section
                _buildAccountSection(),

                SizedBox(height: AppSpacing.xl),

                // Logout Button
                _buildLogoutButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData, User? user) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.xxl),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          // Profile Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.primaryGradient,
              ),
              boxShadow: [AppShadows.medium],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.transparent,
              child: Text(
                (userData['name'] ?? 'U')[0].toUpperCase(),
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.textOnPrimary,
                  fontSize: 48,
                ),
              ),
            ),
          ),

          SizedBox(height: AppSpacing.xl),

          // User Name
          Text(
            userData['name'] ?? 'User',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSpacing.sm),

          // User Email
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppBorderRadius.large),
            ),
            child: Text(
              userData['email'] ?? user?.email ?? '',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> userData) {
    final totalHours = ((userData['totalStudyTime'] ?? 0) / 3600)
        .toStringAsFixed(1);
    final memberSince =
        userData['createdAt'] != null
            ? _formatDate((userData['createdAt'] as Timestamp).toDate())
            : 'Unknown';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            'Study Statistics',
            style: AppTextStyles.heading6.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),

        SizedBox(height: AppSpacing.lg),

        Row(
          children: [
            // Study Time Card
            Expanded(
              child: Container(
                padding: EdgeInsets.all(AppSpacing.xl),
                decoration: AppDecorations.successContainer,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.medium,
                        ),
                      ),
                      child: Icon(
                        Icons.timer_outlined,
                        color: AppColors.textOnDark,
                        size: 24,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      '$totalHours hrs',
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Total Study Time',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: AppSpacing.lg),

            // Member Since Card
            Expanded(
              child: Container(
                padding: EdgeInsets.all(AppSpacing.xl),
                decoration: AppDecorations.accentContainer,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.medium,
                        ),
                      ),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.textOnDark,
                        size: 24,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      memberSince,
                      style: AppTextStyles.heading6.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Member Since',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            'Account Settings',
            style: AppTextStyles.heading6.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),

        SizedBox(height: AppSpacing.lg),

        Container(
          decoration: AppDecorations.card,
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: () {},
              ),
              Divider(color: AppColors.border, height: 1),
              _buildSettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage your notification preferences',
                onTap: () {},
              ),
              Divider(color: AppColors.border, height: 1),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy & Security',
                subtitle: 'Manage your privacy settings',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppBorderRadius.small),
                ),
                child: Icon(icon, color: AppColors.textSecondary, size: 20),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.bodyLarge),
                    SizedBox(height: AppSpacing.xs),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textTertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          await _showLogoutDialog();
        },
        icon: Icon(Icons.logout_rounded),
        label: Text('Sign Out'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.textOnDark,
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    await FirebaseAuth.instance.signOut();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }
}
