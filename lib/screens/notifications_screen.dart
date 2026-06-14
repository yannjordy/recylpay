import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../utils/extensions.dart';
import '../utils/responsive.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notifService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notifService.seedNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final notifs = _notifService.notifications;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (notifs.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                _notifService.markAllAsRead();
                setState(() {});
              },
              child: const Text('Tout lu'),
            ),
        ],
      ),
      body: DesktopScaffold(child: notifs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.grey.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('Aucune notification', style: TextStyle(color: AppColors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: notifs.length,
              itemBuilder: (_, i) {
                final n = notifs[i];
                return GestureDetector(
                  onTap: () {
                    _notifService.markAsRead(n.id);
                    setState(() {});
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: n.isRead ? AppColors.softBlack : AppColors.green.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: n.isRead ? AppColors.glassBorder : AppColors.green.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: n.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(n.icon, color: n.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(n.title, style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: n.isRead ? AppColors.white : AppColors.green,
                                      fontSize: 14,
                                    )),
                                  ),
                                  if (!n.isRead)
                                    Container(
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(
                                        color: AppColors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(n.body, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(n.createdAt.toRelative(), style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
    );
  }
}
