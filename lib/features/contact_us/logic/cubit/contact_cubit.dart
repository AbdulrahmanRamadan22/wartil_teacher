import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/contact_repo.dart';
import 'contact_state.dart';

class ContactCubit extends Cubit<ContactState> {
  final ContactRepo _contactRepo;

  ContactCubit(this._contactRepo) : super(ContactInitial());

  Future<void> getContactSettings() async {
    emit(ContactLoading());
    final response = await _contactRepo.getContactSettings();
    if (response != null && response.status) {
      emit(ContactSuccess(response.data));
    } else {
      emit(ContactError('فشل جلب إعدادات التواصل'));
    }
  }
}
