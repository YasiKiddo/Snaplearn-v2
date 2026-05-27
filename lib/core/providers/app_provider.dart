import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snaplearn/core/models/user_profile.dart';
import 'package:snaplearn/core/services/data_service.dart';
import '../services/auth_service.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DataService _dataService = DataService();
  StreamSubscription<AuthUser?>? _authSubscription;
  AuthUser? _currentUser;
  UserProfile? _userProfile;
  bool _isLoading = true;

  AppProvider() {
    _authSubscription = _authService.authStateChanges.listen((
      AuthUser? user,
    ) async {
      _currentUser = user;
      if (user != null) {
        // Retry logic to handle race conditions during registration
        int retries = 0;
        while (retries < 5) {
          _userProfile = await _dataService.getUserProfile(user.uid);
          if (_userProfile != null) break;

          await Future.delayed(const Duration(milliseconds: 500));
          retries++;
        }

        if (_userProfile != null) {
          if (_userProfile!.isBlocked || _userProfile!.isDeleted) {
            await _authService.signOut();
            _currentUser = null;
            _userProfile = null;
            _selectedIndex = 0;
            _isLoading = false;
            notifyListeners();
            return;
          }
          await updateStreak();
        }
      } else {
        _userProfile = null;
        _selectedIndex = 0;
      }
      _isLoading = false;
      notifyListeners();
    });

    _init();
  }

  void _init() {
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateStreak() async {
    if (_userProfile == null) return;

    final now = DateTime.now();
    final lastLogin = _userProfile!.lastLoginDate;

    if (lastLogin == null) {
      _userProfile = _userProfile!.copyWith(streakCount: 1, lastLoginDate: now);
    } else {
      final difference = DateTime(now.year, now.month, now.day)
          .difference(DateTime(lastLogin.year, lastLogin.month, lastLogin.day))
          .inDays;

      if (difference == 1) {
        _userProfile = _userProfile!.copyWith(
          streakCount: _userProfile!.streakCount + 1,
          lastLoginDate: now,
        );
      } else if (difference > 1) {
        _userProfile = _userProfile!.copyWith(
          streakCount: 1,
          lastLoginDate: now,
        );
      } else {
        return;
      }
    }
    await _dataService.updateUserProfile(_userProfile!);
  }

  // Navigation State
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Auth State
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  AuthUser? get currentUser => _currentUser;
  UserProfile? get userProfile => _userProfile;
  bool get isAdmin => _userProfile?.role == 'admin';
  bool get isInstructor => _userProfile?.role == 'instructor';

  Future<void> refreshProfile() async {
    if (_currentUser != null) {
      _userProfile = await _dataService.getUserProfile(_currentUser!.uid);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
