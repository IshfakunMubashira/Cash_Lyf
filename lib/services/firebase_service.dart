import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  late final FirebaseApp app;
  late final FirebaseAuth auth;
  late final FirebaseFirestore firestore;
  late final FirebaseStorage storage;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    auth = FirebaseAuth.instanceFor(app: app);
    firestore = FirebaseFirestore.instanceFor(app: app);
    storage = FirebaseStorage.instanceFor(app: app);

    _initialized = true;
  }

  User? get currentUser => auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  String get userId => currentUser?.uid ?? '';
  String get userEmail => currentUser?.email ?? '';
}