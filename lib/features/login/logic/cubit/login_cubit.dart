import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:waratel_app/core/call/call_service.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/core/cache/shared_preferences.dart';
import 'package:waratel_app/features/login/data/repos/repos.dart';
import 'package:waratel_app/features/login/data/models/models.dart';
import 'package:waratel_app/features/login/logic/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo loginRepo;

  LoginCubit(this.loginRepo) : super(LoginInitial());

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isPasswordObscure = true;
  IconData suffixIcon = Icons.visibility_off;

  void changePasswordVisibility() {
    isPasswordObscure = !isPasswordObscure;
    suffixIcon = isPasswordObscure ? Icons.visibility_off : Icons.visibility;
    emit(LoginPasswordVisibilityChanged());
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    emit(LoginLoading());
    try {
      final LoginResponse response = await loginRepo.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.status) {
        // ✅ 1. حفظ التوكن في الجهاز
        if (response.token != null) {
          await SharedPreferencesService.saveToken(response.token!);
        }

        // ✅ 2. حفظ حالة تسجيل الدخول
        await SharedPreferencesService.setLoggedIn(true);

        // ✅ 3. حفظ teacherId لإعادة تفعيل Pusher عند فتح التطبيق مجدداً
        final int? teacherId = response.user?.teacherProfile?.id;
        if (teacherId != null) {
          await SharedPreferencesService.saveTeacherId(teacherId);
          // تفعيل Pusher مباشرةً
          getIt<CallService>().initPusher(teacherId);
        }

        // ✅ 4. طلب صلاحيات الإشعارات (مهم جداً لنظام أندرويد 13+) لكي تظهر المكالمات
        await Permission.notification.request();

        if (!isClosed) emit(LoginSuccess(response.message, response));
      } else {
        if (!isClosed) emit(LoginError(response.message));
      }
    } catch (e) {
      if (!isClosed) {
        emit(LoginError(e.toString().replaceFirst('Exception: ', '')));
      }
    }
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
