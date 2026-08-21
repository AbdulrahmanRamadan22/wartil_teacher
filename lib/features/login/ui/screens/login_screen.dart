import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:waratel_app/core/theming/styles.dart';
import 'package:waratel_app/core/routing/routers.dart';
import 'package:waratel_app/core/helpers/assets.dart';
import 'package:waratel_app/features/login/logic/cubit/login_cubit.dart';
import 'package:waratel_app/features/login/logic/cubit/login_state.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginCubit>(),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.pushReplacementNamed(context, Routes.home);
          } else if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage,
                  style: TextStyle(fontSize: 14.sp),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<LoginCubit>();
          return Scaffold(
            backgroundColor: ColorsManager.backgroundColor,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: SingleChildScrollView(
                  child: Form(
                    key: cubit.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 40.h),

                        // Logo
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ColorsManager.primaryDark,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorsManager.primaryColor
                                      .withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                "assets/icons/app_icon.png",
                                height: 120.h,
                                width: 120.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Subtitle
                        Text(
                          'قم بتسجيل الدخول',
                          textAlign: TextAlign.center,
                          style: TextStyles.font16RegularTextPrimary.copyWith(
                            color: ColorsManager.textSecondaryColor,
                          ),
                        ),

                        SizedBox(height: 60.h),

                        // Email Field
                        _buildTextField(
                          label: 'البريد الإلكتروني',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          controller: cubit.emailController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال البريد الإلكتروني';
                            }
                            if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$')
                                .hasMatch(value.trim())) {
                              return 'بريد إلكتروني غير صحيح';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 24.h),

                        // Password Field
                        _buildTextField(
                          label: 'كلمة المرور',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          isObscure: cubit.isPasswordObscure,
                          controller: cubit.passwordController,
                          suffixIcon: cubit.suffixIcon,
                          onVisibilityToggle: () {
                            cubit.changePasswordVisibility();
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'يرجى إدخال كلمة المرور';
                            }
                            if (value.trim().length < 6) {
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 40.h),

                        // Login Button
                        ElevatedButton(
                          onPressed: () {
                            if (state is! LoginLoading) {
                              cubit.login();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsManager.primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 2,
                          ),
                          child: state is LoginLoading
                              ? SizedBox(
                                  height: 24.h,
                                  width: 24.w,
                                  child: const CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'تسجيل الدخول',
                                  style:
                                      TextStyles.font16SemiBoldWhite.copyWith(
                                    fontSize: 18.sp,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool? isObscure,
    VoidCallback? onVisibilityToggle,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
    IconData? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure ?? false,
        keyboardType: keyboardType,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.sp,
          fontFamily: 'Cairo',
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyles.font14RegularTextSecondary,
          prefixIcon: Icon(
            icon,
            color: ColorsManager.secondaryColor,
            size: 22.sp,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    suffixIcon ?? Icons.visibility_off,
                    color: ColorsManager.secondaryColor,
                    size: 22.sp,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(
              color: ColorsManager.primaryColor,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
