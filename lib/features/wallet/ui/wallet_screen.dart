import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waratel_app/core/theming/colors.dart';
import '../../localization/data/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waratel_app/core/di/dependency_injection.dart';
import 'package:waratel_app/core/widgets/custom_app_header.dart';
import 'package:waratel_app/features/wallet/logic/cubit/wallet_cubit.dart';
import 'package:waratel_app/features/wallet/logic/cubit/wallet_state.dart';
import 'package:waratel_app/features/wallet/data/models/wallet_models.dart';
import 'package:waratel_app/features/wallet/ui/withdrawal_bottom_sheet.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => getIt<WalletCubit>()..getWalletData(),
        child: BlocListener<WalletCubit, WalletState>(
          listener: (context, state) {
            if (state is CancelRequestSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green),
              );
            } else if (state is CancelRequestError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: BlocBuilder<WalletCubit, WalletState>(
            buildWhen: (previous, current) =>
                current is WalletLoading ||
                current is WalletSuccess ||
                current is WalletError,
            builder: (context, state) {
              if (state is WalletLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is WalletError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<WalletCubit>().getWalletData(),
                        child: Text('retry'.tr(context)),
                      ),
                    ],
                  ),
                );
              } else if (state is WalletSuccess) {
                final wallet = state.walletData.wallet;
                final recentWithdrawals = state.walletData.recentWithdrawals;
                return RefreshIndicator(
                  onRefresh: () => context.read<WalletCubit>().getWalletData(),
                  child: Column(
                    children: [
                      CustomAppHeader(title: 'wallet_title'.tr(context)),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            children: [
                              // Balance Card
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(20.w),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      ColorsManager.primaryColor,
                                      ColorsManager.primaryColor
                                          .withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ColorsManager.primaryColor
                                          .withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'current_balance'.tr(context),
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        Icon(Icons.account_balance_wallet,
                                            color: Colors.white70, size: 24.sp),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      '${wallet.currentBalance} ${wallet.currency}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 8.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.1),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(4.w),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.timer_outlined,
                                                color: Colors.white,
                                                size: 14.sp),
                                          ),
                                          SizedBox(width: 8.w),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'minutes'.tr(context),
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                '${wallet.totalMinutes}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildActionButton(
                                            icon: Icons.arrow_outward,
                                            label: 'withdraw'.tr(context),
                                            onTap: () => showWithdrawalSheet(
                                                context,
                                                context.read<WalletCubit>()),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 25.h),

                              // Transactions Title
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'transaction_history'.tr(context),
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: ColorsManager.textPrimaryColor,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Navigate to history if needed
                                    },
                                    child: Text('view_all'.tr(context)),
                                  ),
                                ],
                              ),

                              SizedBox(height: 10.h),

                              // Transactions List
                              if (recentWithdrawals.isEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 50.h),
                                  child: Text('no_transactions'.tr(context)),
                                )
                              else
                                ...recentWithdrawals.map((withdrawal) =>
                                    _buildTransactionItem(context, withdrawal)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ));
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    WithdrawalRequest withdrawal,
  ) {
    final bool isPending =
        (withdrawal.status?.toLowerCase().contains('pending') ?? false) ||
            (withdrawal.status?.contains('قيد الانتظار') ?? false);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_upward,
                  color: Colors.red,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'balance_withdrawal'.tr(context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: ColorsManager.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      withdrawal.createdAt ?? '',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11.sp,
                      ),
                    ),
                    if (withdrawal.status != null)
                      Text(
                        withdrawal.status!,
                        style: TextStyle(
                          color: isPending
                              ? Colors.orange
                              : ColorsManager.primaryColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '- ${withdrawal.amount} ${withdrawal.currency ?? ''}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          if (isPending) ...[
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BlocBuilder<WalletCubit, WalletState>(
                  builder: (context, state) {
                    bool isCancelling = state is CancelRequestLoading &&
                        state.requestId == withdrawal.id;
                    return TextButton.icon(
                      onPressed: isCancelling
                          ? null
                          : () => context
                              .read<WalletCubit>()
                              .cancelWithdrawalRequest(withdrawal.id!),
                      icon: isCancelling
                          ? SizedBox(
                              width: 12.w,
                              height: 12.h,
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2))
                          : Icon(Icons.close, color: Colors.red, size: 16.sp),
                      label: Text(
                        'cancel_request'.tr(context),
                        style: TextStyle(color: Colors.red, fontSize: 12.sp),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
