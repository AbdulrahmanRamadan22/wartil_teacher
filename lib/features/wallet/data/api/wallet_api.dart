import 'package:dio/dio.dart';
import '../../../../core/networking/api_constants.dart';
import '../models/wallet_models.dart';

class WalletApi {
  final Dio _dio;

  WalletApi(this._dio);

  Future<WalletResponse> getWalletData() async {
    final response = await _dio.get(ApiConstants.teacherWallet);
    return WalletResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WithdrawRequestResponse> withdraw({
    required String amount,
    String? notes,
    String? accountNumber,
  }) async {
    final response = await _dio.post(
      ApiConstants.teacherWalletWithdraw,
      data: {
        'amount': amount,
        'notes': notes,
        'account_number': accountNumber,
      },
    );
    return WithdrawRequestResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<WithdrawalHistoryResponse> getWithdrawalRequests(
      {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.teacherWalletRequests,
      queryParameters: {'page': page},
    );
    return WithdrawalHistoryResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<CancelWithdrawalResponse> cancelWithdrawalRequest(
      int requestId) async {
    final response = await _dio.delete(
      ApiConstants.teacherCancelWalletRequest(requestId),
    );
    return CancelWithdrawalResponse.fromJson(
        response.data as Map<String, dynamic>);
  }
}
