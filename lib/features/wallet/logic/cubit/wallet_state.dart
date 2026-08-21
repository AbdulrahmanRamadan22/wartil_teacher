import 'package:waratel_app/features/wallet/data/models/wallet_models.dart';

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletSuccess extends WalletState {
  final WalletData walletData;
  WalletSuccess(this.walletData);
}

class WalletError extends WalletState {
  final String message;
  WalletError(this.message);
}

// Withdrawal states
class WithdrawLoading extends WalletState {}

class WithdrawSuccess extends WalletState {
  final String message;
  final WithdrawalData data;
  WithdrawSuccess(this.message, this.data);
}

class WithdrawError extends WalletState {
  final String message;
  WithdrawError(this.message);
}

// History states
class WalletHistoryLoading extends WalletState {}

class WalletHistorySuccess extends WalletState {
  final WithdrawalHistoryData historyData;
  WalletHistorySuccess(this.historyData);
}

class WalletHistoryError extends WalletState {
  final String message;
  WalletHistoryError(this.message);
}

// Cancel states
class CancelRequestLoading extends WalletState {
  final int requestId;
  CancelRequestLoading(this.requestId);
}

class CancelRequestSuccess extends WalletState {
  final String message;
  final CancelWithdrawalData data;
  CancelRequestSuccess(this.message, this.data);
}

class CancelRequestError extends WalletState {
  final String message;
  CancelRequestError(this.message);
}
