import '../models/user_model.dart';
import 'api_service.dart';
import '../utils/app_constants.dart';

class AuthService {
  static User? currentUser;
  static String? lastErrorMessage;

  // 1. Register
  Future<User?> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    int? age,
    String? gender,
    required int roleId,
    String? village,
    String? district,
    String? province,
  }) async {
    try {
      final response = await ApiService.post(AppApi.endpointRegister, {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'age': age,
        'gender': gender,
        'role_id': roleId,
        'village': village,
        'district': district,
        'province': province,
      });

      // Assuming Laravel returns { "user": {...}, "token": "..." }
      if (response != null && response['token'] != null) {
        ApiService.authToken =
            response['token']; // Save token for future requests
        currentUser = User.fromJson(response['user']);
        lastErrorMessage = null;
        return currentUser;
      }
      return null;
    } on ApiException catch (e) {
      lastErrorMessage = e.message;
      print('Registration error: ${e.message}');
      return null;
    } catch (e) {
      lastErrorMessage = 'An unexpected error occurred';
      print('Registration error: $e');
      return null;
    }
  }

  // 2. Login
  Future<User?> login(String email, String password) async {
    try {
      final response = await ApiService.post(AppApi.endpointLogin, {
        'email': email,
        'password': password,
      });

      if (response != null && response['token'] != null) {
        ApiService.authToken = response['token'];
        currentUser = User.fromJson(response['user']);
        lastErrorMessage = null;
        return currentUser;
      }
      lastErrorMessage = 'Unexpected response from server';
      return null;
    } on ApiException catch (e) {
      // Extract specific field error if available
      if (e.errors != null && e.errors!.containsKey('email')) {
        final emailErrors = e.errors!['email'];
        if (emailErrors is List && emailErrors.isNotEmpty) {
          lastErrorMessage = emailErrors.first.toString();
        } else {
          lastErrorMessage = e.message;
        }
      } else {
        lastErrorMessage = e.message;
      }
      print('Login error: ${lastErrorMessage}');
      return null;
    } catch (e) {
      lastErrorMessage = 'An unexpected error occurred: $e';
      print('Login error: $e');
      return null;
    }
  }

  // 3. Logout
  Future<bool> logout() async {
    try {
      await ApiService.post(AppApi.endpointLogout, {});
      ApiService.authToken = null;
      currentUser = null;
      return true;
    } catch (e) {
      return false;
    }
  }

  // 4. Update Profile
  Future<User?> updateProfile({
    required String name,
    String? phone,
    int? age,
    String? gender,
    String? village,
    String? district,
    String? province,
  }) async {
    try {
      final response = await ApiService.put(AppApi.endpointUser, {
        'name': name,
        'phone': phone,
        'age': age,
        'gender': gender,
        'village': village,
        'district': district,
        'province': province,
      });

      if (response != null && response['user'] != null) {
        currentUser = User.fromJson(response['user']);
        lastErrorMessage = null;
        return currentUser;
      }
      return null;
    } on ApiException catch (e) {
      lastErrorMessage = e.message;
      print('Update profile error: ${e.message}');
      return null;
    } catch (e) {
      lastErrorMessage = 'An unexpected error occurred';
      print('Update profile error: $e');
      return null;
    }
  }

  // 5. Get Profile
  Future<User?> getProfile() async {
    try {
      final response = await ApiService.get(AppApi.endpointUser);
      if (response != null) {
        currentUser = User.fromJson(response);
        return currentUser;
      }
      return null;
    } on ApiException catch (e) {
      lastErrorMessage = e.message;
      print('Get profile error: ${e.message}');
      return null;
    } catch (e) {
      lastErrorMessage = 'An unexpected error occurred';
      print('Get profile error: $e');
      return null;
    }
  }
}
