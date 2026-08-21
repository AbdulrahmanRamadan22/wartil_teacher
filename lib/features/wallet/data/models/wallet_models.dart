class WalletResponse {
  final bool status;
  final String message;
  final WalletData data;

  WalletResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: WalletData.fromJson(
          (json['data'] is Map<String, dynamic>) ? json['data'] : {}),
    );
  }
}

class WalletData {
  final Wallet wallet;
  final List<WithdrawalRequest> recentWithdrawals;

  WalletData({
    required this.wallet,
    required this.recentWithdrawals,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      wallet: Wallet.fromJson(
          (json['wallet'] is Map<String, dynamic>) ? json['wallet'] : {}),
      recentWithdrawals: (json['recent_withdrawals'] as List?)
              ?.map((e) => WithdrawalRequest.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Wallet {
  final num totalMinutes;
  final num hourlyRate;
  final num currentBalance;
  final String currency;

  Wallet({
    required this.totalMinutes,
    required this.hourlyRate,
    required this.currentBalance,
    required this.currency,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      totalMinutes: json['total_minutes'] ?? 0,
      hourlyRate: json['hourly_rate'] ?? 0,
      currentBalance: json['current_balance'] ?? 0,
      currency: json['currency'] ?? 'USD',
    );
  }
}

class WithdrawalRequest {
  final int? id;
  final String? accountNumber;
  final String? amount;
  final String? status;
  final String? createdAt;
  final String? currency;

  WithdrawalRequest({
    this.id,
    this.accountNumber,
    this.amount,
    this.status,
    this.createdAt,
    this.currency,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['request_id'] ?? json['id'],
      accountNumber: json['account_number'],
      amount: json['withdrawn_amount'] ?? json['amount']?.toString(),
      status: json['status'],
      createdAt: json['date'] ?? json['created_at'],
      currency: json['currency'],
    );
  }
}

class WithdrawRequestResponse {
  final bool status;
  final String message;
  final WithdrawalData? data;

  WithdrawRequestResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory WithdrawRequestResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawRequestResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] is Map<String, dynamic>)
          ? WithdrawalData.fromJson(json['data'])
          : null,
    );
  }
}

class WithdrawalData {
  final int requestId;
  final String withdrawnAmount;
  final num remainingBalance;
  final String currency;

  WithdrawalData({
    required this.requestId,
    required this.withdrawnAmount,
    required this.remainingBalance,
    required this.currency,
  });

  factory WithdrawalData.fromJson(Map<String, dynamic> json) {
    return WithdrawalData(
      requestId: json['request_id'] ?? 0,
      withdrawnAmount: json['withdrawn_amount'] ?? '',
      remainingBalance: json['remaining_balance'] ?? 0,
      currency: json['currency'] ?? 'USD',
    );
  }
}

class WithdrawalHistoryResponse {
  final bool status;
  final String message;
  final WithdrawalHistoryData data;

  WithdrawalHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory WithdrawalHistoryResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawalHistoryResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: WithdrawalHistoryData.fromJson(
          (json['data'] is Map<String, dynamic>) ? json['data'] : {}),
    );
  }
}

class WithdrawalHistoryData {
  final int currentPage;
  final List<WithdrawalRequest> data;
  final int lastPage;
  final int total;

  WithdrawalHistoryData({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    required this.total,
  });

  factory WithdrawalHistoryData.fromJson(Map<String, dynamic> json) {
    return WithdrawalHistoryData(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List?)
              ?.map((e) => WithdrawalRequest.fromJson(e))
              .toList() ??
          [],
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}

class CancelWithdrawalResponse {
  final bool status;
  final String message;
  final CancelWithdrawalData? data;

  CancelWithdrawalResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory CancelWithdrawalResponse.fromJson(Map<String, dynamic> json) {
    return CancelWithdrawalResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] is Map<String, dynamic>)
          ? CancelWithdrawalData.fromJson(json['data'])
          : null,
    );
  }
}

class CancelWithdrawalData {
  final num currentBalance;
  final String currency;

  CancelWithdrawalData({
    required this.currentBalance,
    required this.currency,
  });

  factory CancelWithdrawalData.fromJson(Map<String, dynamic> json) {
    return CancelWithdrawalData(
      currentBalance: json['current_balance'] ?? 0,
      currency: json['currency'] ?? 'USD',
    );
  }
}
