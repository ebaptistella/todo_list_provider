import 'package:flutter/material.dart';
import 'package:todo_list_provider/app/core/exception/auth_exception.dart';
import 'package:todo_list_provider/app/core/notifier/default_change_notifier.dart';
import 'package:todo_list_provider/app/services/user/user_service.dart';

class RegisterController extends DefaultChangeNotifier {
  final UserService _userService;

  RegisterController({required UserService userService})
      : _userService = userService;

  Future<void> registerUser(String email, String password) async {
    showLoadingAndResetState();
    notifyListeners();

    try {
      final user = await _userService.register(email, password);
      if (user == null) {
        setError('Erro ao registrar usuário!');
      }
    } on AuthException catch (e) {
      setError(e.message);
    } finally {
      if (!hasError) {
        success();
      }
      hideLoading();
      notifyListeners();
    }
  }
}
