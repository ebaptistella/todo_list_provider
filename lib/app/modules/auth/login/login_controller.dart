import 'package:todo_list_provider/app/core/exception/auth_exception.dart';
import 'package:todo_list_provider/app/core/notifier/default_change_notifier.dart';
import 'package:todo_list_provider/app/services/user/user_service.dart';

class LoginController extends DefaultChangeNotifier {
  final UserService _userService;
  String? infoMessage;

  LoginController({required UserService userService}) : _userService = userService;

  bool get hasInfo => infoMessage != null;

  void login(String email, String password) async {
    showLoadingAndResetState();
    infoMessage = null;
    notifyListeners();

    try {
      final user = await _userService.login(email, password);
      if (user == null) {
        setError('Usuário ou senha inválidos');
      } else {
        success();
      }
    } on AuthException catch (e) {
      setError(e.message);
    } finally {
      hideLoading();
      notifyListeners();
    }
  }

  void forgotPassword(String email) async {
    showLoadingAndResetState();
    infoMessage = null;
    try {
      await _userService.forgotPassword(email);
      infoMessage = 'Informações para redefinir a senha foram enviadas para o seu e-mail';
    } catch (e) {
      if (e is AuthException) {
        setError(e.message);
      } else {
        setError('Erro ao redefinir senha');
      }
    } finally {
      hideLoading();
      notifyListeners();
    }
  }
}
