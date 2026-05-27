import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'data_service.dart';
import '../models/user_profile.dart';

class AuthUser {
  final String uid;
  final String email;
  final String? displayName;

  AuthUser({required this.uid, required this.email, this.displayName});
}

class AuthService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api',
  );

  final DataService dataService = DataService();

  // Local stream to broadcast auth state changes
  static final StreamController<AuthUser?> _authStateController =
      StreamController<AuthUser?>.broadcast();

  static AuthUser? _currentAuthUser;

  // Stream of auth changes
  Stream<AuthUser?> get authStateChanges => _authStateController.stream;

  // Get currently logged-in user
  AuthUser? get currentUser => _currentAuthUser;

  // Sign In
  Future<AuthUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'password': password.trim(),
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profileData = data['user'];

        final user = AuthUser(
          uid: profileData['id'] ?? profileData['_id'] ?? 'user_id',
          email: profileData['email'] ?? email.trim(),
          displayName: profileData['displayName'],
        );

        final userProfile = UserProfile.fromMap(profileData);
        dataService.cacheUserProfile(userProfile);
        _currentAuthUser = user;
        _authStateController.add(user);

        return user;
      } else {
        final errData = jsonDecode(response.body);
        throw Exception(errData['message'] ?? 'Failed to log in');
      }
    } catch (e) {
      throw Exception('Unable to sign in: $e');
    }
  }

  // Register
  Future<AuthUser?> registerWithEmailAndPassword(
    String name,
    String email,
    String password, {
    List<String> interests = const [],
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'displayName': name.trim(),
              'email': email.trim(),
              'password': password.trim(),
              'interests': interests,
            }),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final profileData = data['user'];

        final user = AuthUser(
          uid: profileData['id'] ?? profileData['_id'] ?? 'user_id',
          email: profileData['email'] ?? email.trim(),
          displayName: profileData['displayName'],
        );

        final userProfile = UserProfile.fromMap(profileData);
        dataService.cacheUserProfile(userProfile);
        _currentAuthUser = user;
        _authStateController.add(user);

        return user;
      } else {
        final errData = jsonDecode(response.body);
        throw Exception(errData['message'] ?? 'Failed to register');
      }
    } catch (e) {
      throw Exception('Unable to register: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _currentAuthUser = null;
    _authStateController.add(null);
  }
}
