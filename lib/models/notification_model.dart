class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'info', 'success', 'warning', 'alert'
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'message': message,
    'type': type,
    'isRead': isRead,
    'createdAt': createdAt,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'],
    userId: json['userId'],
    title: json['title'],
    message: json['message'],
    type: json['type'],
    isRead: json['isRead'],
    createdAt: (json['createdAt'] as dynamic).toDate(),
  );
}