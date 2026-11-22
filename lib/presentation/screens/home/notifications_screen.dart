import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Future<void> _markAsRead(
      DocumentReference<Map<String, dynamic>> reference,
      ) async {
    await reference.update({'isRead': true});
  }

  Future<void> _markAllAsRead(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> notifications,
      ) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final notification in notifications) {
      if (notification.data()['isRead'] != true) {
        batch.update(notification.reference, {'isRead': true});
      }
    }

    await batch.commit();
  }

  String _formatDate(dynamic value) {
    if (value is! Timestamp) {
      return 'Just now';
    }

    final difference = DateTime.now().difference(value.toDate());

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }

    return '${difference.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.textDark,
      ),
      body: user == null
          ? const Center(
        child: Text('Sign in to view notifications.'),
      )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('We could not load your notifications.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            );
          }

          final notifications = snapshot.data?.docs ?? [];

          notifications.sort((first, second) {
            final firstDate =
            first.data()['createdAt'] as Timestamp?;
            final secondDate =
            second.data()['createdAt'] as Timestamp?;

            return (secondDate?.millisecondsSinceEpoch ?? 0)
                .compareTo(firstDate?.millisecondsSinceEpoch ?? 0);
          });

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 65,
                    color: AppColors.textLight,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Medicine availability alerts will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            );
          }

          final hasUnread = notifications.any(
                (notification) =>
            notification.data()['isRead'] != true,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
            children: [
              if (hasUnread)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () =>
                        _markAllAsRead(notifications),
                    icon: const Icon(Icons.done_all_rounded),
                    label: const Text('Mark all as read'),
                  ),
                ),

              ...notifications.map((notification) {
                final data = notification.data();
                final isRead = data['isRead'] == true;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isRead
                        ? AppColors.cardWhite
                        : AppColors.stockGreen,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isRead
                          ? AppColors.borderLight
                          : AppColors.primaryGreen
                          .withValues(alpha: 0.25),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    onTap: () =>
                        _markAsRead(notification.reference),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.medication_outlined,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    title: Text(
                      data['title'] ?? 'Medicine available',
                      style: TextStyle(
                        fontWeight: isRead
                            ? FontWeight.w600
                            : FontWeight.w800,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(data['message'] ?? ''),
                          const SizedBox(height: 7),
                          Text(
                            _formatDate(data['createdAt']),
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: isRead
                        ? null
                        : Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppColors.errorRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}