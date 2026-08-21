import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waratel_app/core/theming/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/features/wallet/logic/cubit/wallet_cubit.dart';
import 'package:waratel_app/features/wallet/logic/cubit/wallet_state.dart';
import 'package:waratel_app/features/localization/data/app_localizations.dart';
import 'package:waratel_app/features/localization/logic/cubit/locale_cubit.dart';
import 'package:waratel_app/features/localization/logic/cubit/locale_state.dart';

class WithdrawalBottomSheet extends StatefulWidget {
  const WithdrawalBottomSheet({super.key});

  @override
  State<WithdrawalBottomSheet> createState() => _WithdrawalBottomSheetState();
}

class _WithdrawalBottomSheetState extends State<WithdrawalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    context.read<WalletCubit>().withdraw(
          amount: _amountController.text.trim(),
          accountNumber: _accountController.text.trim(),
          notes: _notesController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletCubit, WalletState>(
      listener: (context, state) {
        if (state is WithdrawLoading) {
          setState(() => _isLoading = true);
        } else if (state is WithdrawSuccess) {
          setState(() => _isLoading = false);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(
                  fontFamily:
                      context.read<LocaleCubit>().state is ChangeLocaleState &&
                              (context.read<LocaleCubit>().state
                                          as ChangeLocaleState)
                                      .locale
                                      .languageCode ==
                                  'ar'
                          ? 'Cairo'
                          : null,
                ),
              ),
              backgroundColor: ColorsManager.primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
          );
        } else if (state is WithdrawError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(
                  fontFamily:
                      context.read<LocaleCubit>().state is ChangeLocaleState &&
                              (context.read<LocaleCubit>().state
                                          as ChangeLocaleState)
                                      .locale
                                      .languageCode ==
                                  'ar'
                          ? 'Cairo'
                          : null,
                ),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
          );
        }
      },
      child: Padding(
        // يرفع النافذة فوق الكيبورد
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ═══ Handle Bar ═══
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 20.h),

              // ═══ Header ═══
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color:
                            ColorsManager.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.arrow_outward,
                        color: ColorsManager.primaryColor,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'withdrawal_request'.tr(context),
                          style: TextStyle(
                            fontFamily: context.read<LocaleCubit>().state
                                        is ChangeLocaleState &&
                                    (context.read<LocaleCubit>().state
                                                as ChangeLocaleState)
                                            .locale
                                            .languageCode ==
                                        'ar'
                                ? 'Cairo'
                                : null,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: ColorsManager.textPrimaryColor,
                          ),
                        ),
                        Text(
                          'enter_withdrawal_data'.tr(context),
                          style: TextStyle(
                            fontFamily: context.read<LocaleCubit>().state
                                        is ChangeLocaleState &&
                                    (context.read<LocaleCubit>().state
                                                as ChangeLocaleState)
                                            .locale
                                            .languageCode ==
                                        'ar'
                                ? 'Cairo'
                                : null,
                            fontSize: 12.sp,
                            color: ColorsManager.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),
              Divider(height: 1, color: Colors.grey.shade100),
              SizedBox(height: 20.h),

              // ═══ Form ═══
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // ─── حقل المبلغ ───
                        _buildField(
                          context: context,
                          controller: _amountController,
                          label: 'amount_to_withdraw'.tr(context),
                          hint: 'amount_hint'.tr(context),
                          icon: Icons.monetization_on_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'enter_amount_error'.tr(context);
                            }
                            final amount = double.tryParse(v.trim());
                            if (amount == null || amount <= 0) {
                              return 'correct_amount_error'.tr(context);
                            }
                            return null;
                          },
                          suffix: Text(
                            'sar'.tr(context),
                            style: TextStyle(
                              fontFamily: context.read<LocaleCubit>().state
                                          is ChangeLocaleState &&
                                      (context.read<LocaleCubit>().state
                                                  as ChangeLocaleState)
                                              .locale
                                              .languageCode ==
                                          'ar'
                                  ? 'Cairo'
                                  : null,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: ColorsManager.primaryColor,
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // ─── حقل رقم الكاش / الحساب ───
                        _buildField(
                          context: context,
                          controller: _accountController,
                          label: 'account_number_label'.tr(context),
                          hint: 'account_hint'.tr(context),
                          icon: Icons.account_balance_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'enter_account_error'.tr(context);
                            }
                            if (v.trim().length < 5) {
                              return 'short_account_error'.tr(context);
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        // ─── حقل الملاحظة ───
                        _buildField(
                          context: context,
                          controller: _notesController,
                          label: 'notes_optional'.tr(context),
                          hint: 'notes_hint'.tr(context),
                          icon: Icons.notes_outlined,
                          maxLines: 3,
                          validator: (_) => null,
                        ),

                        SizedBox(height: 24.h),

                        // ─── الأزرار ───
                        Row(
                          children: [
                            // زر الإلغاء
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: ColorsManager.primaryColor,
                                  side: BorderSide(
                                      color: ColorsManager.primaryColor,
                                      width: 1.5),
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.r)),
                                ),
                                child: Text(
                                  'cancel'.tr(context),
                                  style: TextStyle(
                                    fontFamily: context
                                                .read<LocaleCubit>()
                                                .state is ChangeLocaleState &&
                                            (context.read<LocaleCubit>().state
                                                        as ChangeLocaleState)
                                                    .locale
                                                    .languageCode ==
                                                'ar'
                                        ? 'Cairo'
                                        : null,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 12.w),

                            // زر الإرسال
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorsManager.primaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: ColorsManager
                                      .primaryColor
                                      .withValues(alpha: 0.5),
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12.r)),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height: 20.h,
                                        width: 20.h,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.send_rounded, size: 18.sp),
                                          SizedBox(width: 6.w),
                                          Text(
                                            'send_request'.tr(context),
                                            style: TextStyle(
                                              fontFamily: context
                                                              .read<LocaleCubit>()
                                                              .state
                                                          is ChangeLocaleState &&
                                                      (context.read<LocaleCubit>().state
                                                                  as ChangeLocaleState)
                                                              .locale
                                                              .languageCode ==
                                                          'ar'
                                                  ? 'Cairo'
                                                  : null,
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
    Widget? suffix,
  }) {
    final isAr = context.read<LocaleCubit>().state is ChangeLocaleState &&
        (context.read<LocaleCubit>().state as ChangeLocaleState)
                .locale
                .languageCode ==
            'ar';
    return Column(
      crossAxisAlignment:
          isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Text(
            label,
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontFamily: isAr ? 'Cairo' : null,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: ColorsManager.textPrimaryColor,
            ),
          ),
        ),
        // Field
        TextFormField(
          controller: controller,
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          textAlign: isAr ? TextAlign.right : TextAlign.left,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: TextStyle(
            fontFamily: isAr ? 'Cairo' : null,
            fontSize: 14.sp,
            color: ColorsManager.textPrimaryColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: isAr ? 'Cairo' : null,
              fontSize: 13.sp,
              color: ColorsManager.textSecondaryColor,
            ),
            hintTextDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            prefixIcon:
                Icon(icon, color: ColorsManager.primaryColor, size: 20.sp),
            suffix: suffix,
            filled: true,
            fillColor: ColorsManager.backgroundColor,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide:
                  BorderSide(color: ColorsManager.primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// دالة مساعدة لعرض النافذة من أي مكان
void showWithdrawalSheet(BuildContext context, WalletCubit walletCubit) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: walletCubit,
      child: const WithdrawalBottomSheet(),
    ),
  );
}
