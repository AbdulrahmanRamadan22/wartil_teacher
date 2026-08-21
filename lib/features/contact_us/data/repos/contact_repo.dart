import '../api/contact_api.dart';
import '../models/contact_settings_model.dart';

class ContactRepo {
  final ContactApi _contactApi;

  ContactRepo(this._contactApi);

  Future<ContactSettingsResponse?> getContactSettings() async {
    try {
      return await _contactApi.getContactSettings();
    } catch (e) {
      return null;
    }
  }
}
