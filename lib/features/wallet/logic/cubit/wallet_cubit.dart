import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/wallet_repo.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepo _walletRepo;

  WalletCubit(this._walletRepo) : super(WalletInitial());

  Future<void> getWalletData() async {
    emit(WalletLoading());
    try {
      final response = await _walletRepo.getWalletData();
      if (response.status) {
        emit(WalletSuccess(response.data));
      } else {
        emit(WalletError(response.message));
      }
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> withdraw({
    required String amount,
    String? notes,
    String? accountNumber,
  }) async {
    emit(WithdrawLoading());
    try {
      final response = await _walletRepo.withdraw(
        amount: amount,
        notes: notes,
        accountNumber: accountNumber,
      );
      if (response.status) {
        emit(WithdrawSuccess(response.message, response.data!));
        // Refresh wallet data after success
        getWalletData();
      } else {
        emit(WithdrawError(response.message));
      }
    } catch (e) {
      emit(WithdrawError(e.toString()));
    }
  }

  Future<void> getWithdrawalRequests({int page = 1}) async {
    emit(WalletHistoryLoading());
    try {
      final response = await _walletRepo.getWithdrawalRequests(page: page);
      if (response.status) {
        emit(WalletHistorySuccess(response.data));
      } else {
        emit(WalletHistoryError(response.message));
      }
    } catch (e) {
      emit(WalletHistoryError(e.toString()));
    }
  }

  Future<void> cancelWithdrawalRequest(int requestId) async {
    emit(CancelRequestLoading(requestId));
    try {
      final response = await _walletRepo.cancelWithdrawalRequest(requestId);
      if (response.status) {
        emit(CancelRequestSuccess(response.message, response.data!));
        // Refresh wallet data and history after success
        getWalletData();
        getWithdrawalRequests();
      } else {
        emit(CancelRequestError(response.message));
      }
    } catch (e) {
      emit(CancelRequestError(e.toString()));
    }
  }
}
