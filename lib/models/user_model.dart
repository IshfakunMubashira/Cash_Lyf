class AppUser {
  final String uid;
  final String email;
  final String username;
  final String profession;
  final String currency;
  final bool darkMode;
  final String? photoUrl;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.profession,
    required this.currency,
    required this.darkMode,
    this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'username': username,
    'profession': profession,
    'currency': currency,
    'darkMode': darkMode,
    'photoUrl': photoUrl,
    'createdAt': createdAt,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    uid: json['uid'],
    email: json['email'],
    username: json['username'],
    profession: json['profession'] ?? '',
    currency: json['currency'] ?? '\$',
    darkMode: json['darkMode'] ?? false,
    photoUrl: json['photoUrl'],
    createdAt: (json['createdAt'] as dynamic).toDate(),
  );
}