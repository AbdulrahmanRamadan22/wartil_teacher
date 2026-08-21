import '../../data/models/contact_settings_model.dart';

abstract class ContactState {}

class ContactInitial extends ContactState {}

class ContactLoading extends ContactState {}

class ContactSuccess extends ContactState {
  final ContactSettingsData contactSettings;
  ContactSuccess(this.contactSettings);
}

class ContactError extends ContactState {
  final String error;
  ContactError(this.error);
}
