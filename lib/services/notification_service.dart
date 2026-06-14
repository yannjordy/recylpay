import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  void seedNotifications() {
    _notifications.addAll([
      AppNotification(
        id: 'notif_1', title: 'Nouvelle mission', body: 'Une collecte de plastique PET est disponible près de chez vous',
        icon: Icons.recycling_rounded, color: const Color(0xFF2ECC71), createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      AppNotification(
        id: 'notif_2', title: 'Paiement reçu', body: 'Votre retrait de 5 000 FCFA a été effectué avec succès',
        icon: Icons.wallet_rounded, color: const Color(0xFFF1C40F), createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'notif_3', title: 'Mission terminée', body: 'Félicitations! Vous avez complété 3 missions aujourd\'hui',
        icon: Icons.emoji_events_rounded, color: const Color(0xFF3498DB), createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'notif_4', title: 'Nouveau message', body: 'Jean-Paul vous a envoyé un message',
        icon: Icons.message_rounded, color: const Color(0xFF9B59B6), createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: 'notif_5', title: 'Objectif atteint', body: 'Vous avez collecté 500kg ce mois-ci! Continuez!',
        icon: Icons.star_rounded, color: const Color(0xFFE74C3C), createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    DateTime? createdAt,
    this.isRead = false,
  }) : createdAt = createdAt ?? DateTime.now();

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id, title: title, body: body, icon: icon, color: color,
    createdAt: createdAt, isRead: isRead ?? this.isRead,
  );
}
