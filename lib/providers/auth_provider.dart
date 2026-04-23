import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/device_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DeviceService _deviceService;
  
  User? _user;
  bool _isGuest = false;
  bool _isLoading = true;

  User? get user => _user;
  bool get isGuest => _isGuest;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && !_isGuest;

  // ✅ Fix: Constructor with required parameter
  AuthProvider({required DeviceService deviceService}) : _deviceService = deviceService;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    // Check if user is already signed in
    _user = _authService.currentUser;
    
    if (_user != null) {
      // Check if this device was used before
      final isValidDevice = await _deviceService.validateDeviceForUser(_user!.uid);
      if (!isValidDevice) {
        // New device - sign out and show login
        await _authService.signOut();
        _user = null;
        _isGuest = false;
      }
    } else {
      // Check if guest mode was previously saved
      _isGuest = await _deviceService.getGuestModeStatus();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signIn(email: email, password: password);
      if (user != null) {
        _user = user;
        _isGuest = false;
        
        // Save device for this user
        await _deviceService.saveDeviceForUser(user.uid);
        
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String name, String email, String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signUp(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      if (user != null) {
        _user = user;
        _isGuest = false;
        await _deviceService.saveDeviceForUser(user.uid);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> continueAsGuest() async {
    _isLoading = true;
    notifyListeners();

    _user = null;
    _isGuest = true;
    
    // Save guest mode status
    await _deviceService.saveGuestModeStatus(true);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.signOut();
    _user = null;
    _isGuest = false;
    
    // Clear guest mode status
    await _deviceService.saveGuestModeStatus(false);
    
    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _user = null;
    _isGuest = false;
    _isLoading = false;
    notifyListeners();
  }
}