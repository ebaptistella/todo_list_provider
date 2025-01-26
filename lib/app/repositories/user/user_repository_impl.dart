import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo_list_provider/app/core/exception/auth_exception.dart';
import 'package:todo_list_provider/app/repositories/user/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseAuth _firebaseAuth;

  UserRepositoryImpl({required FirebaseAuth firebaseAuth}) : _firebaseAuth = firebaseAuth;

  @override
  Future<User?> register(String email, String password) async {
    try {
      final userCredentials = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return userCredentials.user;
    } on FirebaseAuthException catch (e, s) {
      if (e.code == 'email-already-in-use') {
        final loginTypes = await _firebaseAuth.fetchSignInMethodsForEmail(email);
        if (loginTypes.contains('password')) {
          throw AuthException(message: 'E-mail já utilizado, por favor escolha outro e-mail');
        }

        throw AuthException(message: 'Você se cadastrou no Todo List Provider com o Google, por favor utilize ele para entrar.');
      }

      throw AuthException(message: e.message ?? 'Erro ao registrar usuário');
    }
  }

  @override
  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on PlatformException catch (e) {
      throw AuthException(message: e.message ?? 'Erro ao realizar login');
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Erro ao realizar login');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final loginMethod = await _firebaseAuth.fetchSignInMethodsForEmail(email);

      if (loginMethod.contains('password')) {
        await _firebaseAuth.sendPasswordResetEmail(email: email);
      } else if (loginMethod.contains('google')) {
        throw AuthException(message: 'Cadastro realizado com o Google, a senha não pode ser redefinida!');
      } else {
        throw AuthException(message: 'E-mail não encontrado');
      }
    } on PlatformException catch (e) {
      throw AuthException(message: 'Erro ao redefinir a senha');
    }
  }

  @override
  Future<User?> googleLogin() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final loginMethods = await _firebaseAuth.fetchSignInMethodsForEmail(googleUser.email);
        if (loginMethods.contains('password')) {
          throw AuthException(message: 'Você utilizou o e-mail para cadastro');
        }

        final googleAuth = await googleUser.authentication;
        final firebaseProvider = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredentials = await _firebaseAuth.signInWithCredential(firebaseProvider);
        return userCredentials.user;
      }
    } on FirebaseAuthException catch (e, s) {
      if (e.code == 'account-exists-with-different-credentials') {
        throw AuthException(message: 'Você se registrou com os provedores: xxx');
      }

      throw AuthException(message: 'Erro ao realizar login');
    }
  }

  @override
  Future<void> logout() async {
    await GoogleSignIn().signOut();
    _firebaseAuth.signOut();
  }

  @override
  Future<void> updateDisplayName(String name) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      user.reload();
    }
  }
}
