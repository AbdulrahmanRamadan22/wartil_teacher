import '../api/wallet_api.dart';
import '../models/wallet_models.dart';

class WalletRepo {
  final WalletApi _walletApi;

  WalletRepo(this._walletApi);

  Future<WalletResponse> getWalletData() async {
    try {
      return await _walletApi.getWalletData();
    } catch (e) {
      rethrow;
    }
  }

  Future<WithdrawRequestResponse> withdraw({
    required String amount,
    String? notes,
    String? accountNumber,
  }) async {
    try {
      return await _walletApi.withdraw(
        amount: amount,
        notes: notes,
        accountNumber: accountNumber,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<WithdrawalHistoryResponse> getWithdrawalRequests(
      {int page = 1}) async {
    try {
      return await _walletApi.getWithdrawalRequests(page: page);
    } catch (e) {
      rethrow;
    }
  }

  Future<CancelWithdrawalResponse> cancelWithdrawalRequest(
      int requestId) async {
    try {
      return await _walletApi.cancelWithdrawalRequest(requestId);
    } catch (e) {
      rethrow;
    }
  }
}
