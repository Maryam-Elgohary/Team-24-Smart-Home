import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:updated_smart_home/screans/auth/updated/auth/domain/repo/auth_repo.dart';

part 'signout_state.dart';

class SignoutCubit extends Cubit<SignoutState> {
  SignoutCubit(this._authRepo) : super(SignoutInitial());
  final AuthRepo _authRepo;

  Future<void> signOut() async {
    emit(SignoutLoading());
    try {
      await _authRepo.SignOut();
      emit(SignoutSuccess());
    } catch (e) {
      emit(SignoutFailed(e.toString()));
    }
  }
}
