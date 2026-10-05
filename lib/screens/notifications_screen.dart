import 'package:flutter/material.dart';

class NotificationItem {
  final String title;
  final String message;
  final IconData icon;
  final DateTime time;
  final bool isUnread;

  const NotificationItem({
    required this.title,
    required this.message,
    required this.icon,
    required this.time,
    required this.isUnread,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: 'Welcome to Local Rail',
      message:
      'Your Local Rail account is ready. You can now book and manage your train tickets.',
      icon: Icons.train_outlined,
      time: DateTime.now(),
      isUnread: true,
    ),
    NotificationItem(
      title: 'Ticket QR Code',
      message:
      'Keep your ticket QR code ready during your journey for verification.',
      icon: Icons.qr_code_2_outlined,
      time: DateTime.now().subtract(
        const Duration(hours: 2),
      ),
      isUnread: false,
    ),
    NotificationItem(
      title: 'Live Trains',
      message:
      'Check the Live section for current Mumbai local train information.',
      icon: Icons.location_on_outlined,
      time: DateTime.now().subtract(
        const Duration(days: 1),
      ),
      isUnread: false,
    ),
  ];

  int get _unreadCount {
    return _notifications
        .where((notification) => notification.isUnread)
        .length;
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        final notification = _notifications[i];

        _notifications[i] = NotificationItem(
          title: notification.title,
          message: notification.message,
          icon: notification.icon,
          time: notification.time,
          isUnread: false,
        );
      }
    });
  }

  void _clearNotifications() {
    setState(() {
      _notifications.clear();
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    return '${difference.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'read') {
                  _markAllAsRead();
                } else if (value == 'clear') {
                  _clearNotifications();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'read',
                  child: Text('Mark all as read'),
                ),
                PopupMenuItem<String>(
                  value: 'clear',
                  child: Text('Clear notifications'),
                ),
              ],
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                8,
                4,
                8,
                10,
              ),
              child: Text(
                '$_unreadCount unread notification${_unreadCount == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
          ..._notifications.map(
                (notification) =>
                _buildNotificationCard(notification),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
      NotificationItem notification,
      ) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          child: Icon(
            notification.icon,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isUnread
                      ? FontWeight.bold
                      : FontWeight.w600,
                ),
              ),
            ),
            if (notification.isUnread)
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 5,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
              ),
              const SizedBox(height: 5),
              Text(
                _formatTime(notification.time),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 70,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 16),
            const Text(
              'No notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You are all caught up.',
              style: TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}