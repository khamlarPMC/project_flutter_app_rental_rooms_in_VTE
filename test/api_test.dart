import 'package:flutter_test/flutter_test.dart';
import 'package:app_rental_room/services/auth_service.dart';

void main() {
  test('Test API login with admin', () async {
    print('Starting login test...');
    try {
      final user = await AuthService().login('admin@mail.com', '12345678');
      print('Login result user: $user');
      if (user != null) {
        print('User name: ${user.name}');
        print('User email: ${user.email}');
        print('User role_id: ${user.roleId}');
      } else {
        print('User is null. lastErrorMessage: ${AuthService.lastErrorMessage}');
      }
    } catch (e, stackTrace) {
      print('Exception caught in test: $e');
      print(stackTrace);
    }
  });

  test('Test API login with wrong password', () async {
    print('Starting login test with wrong password...');
    try {
      final user = await AuthService().login('admin@mail.com', 'wrongpassword');
      print('Login result user: $user');
      print('lastErrorMessage: ${AuthService.lastErrorMessage}');
    } catch (e, stackTrace) {
      print('Exception caught in test: $e');
      print(stackTrace);
    }
  });
}
