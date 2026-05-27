import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
            },
            child: const Text('Mark all as read', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          final notifications = notificationProvider.notifications;

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('You\'re all caught up!', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              return Dismissible(
                key: Key(notification.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => notificationProvider.deleteNotification(notification.id),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: notification.isRead ? 0 : 2,
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getNotifColor(notification.type).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getNotifIcon(notification.type), color: _getNotifColor(notification.type), size: 24),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notification.message, style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(_formatDate(notification.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                    trailing: notification.isRead
                        ? null
                        : Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF2196F3), shape: BoxShape.circle)),
                    onTap: () {
                      if (!notification.isRead) {
                        notificationProvider.markAsRead(notification.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) return 'Just now';
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      }
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('hh:mm a').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  Color _getNotifColor(String type) {
    switch (type.toLowerCase()) {
      case 'success': return Colors.green;
      case 'warning': return Colors.orange;
      case 'alert': return Colors.red;
      default: return const Color(0xFF2196F3);
    }
  }

  IconData _getNotifIcon(String type) {
    switch (type.toLowerCase()) {
      case 'success': return Icons.check_circle;
      case 'warning': return Icons.warning;
      case 'alert': return Icons.notifications_active;
      default: return Icons.info;
    }
  }
}