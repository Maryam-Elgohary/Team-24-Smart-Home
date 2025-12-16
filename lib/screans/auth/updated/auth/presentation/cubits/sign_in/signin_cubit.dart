import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:updated_smart_home/screans/auth/updated/auth/domain/entities/user_entity.dart';
import 'package:updated_smart_home/screans/auth/updated/auth/domain/repo/auth_repo.dart';

part 'signin_state.dart';

class SigninCubit extends Cubit<SigninState> {
  SigninCubit(this.authRepo) : super(SigninInitial());
  final AuthRepo authRepo;
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    emit(SigninLoading());
    try {
      var result = await authRepo.SignWithEmailAndPassword(email, password);
      result.fold(
        (Failure) => emit(SigninFailed(Failure.message)),
        (userEntity) => emit(SigninSuccess(userEntity)),
      );
    
    } catch (e) {
      emit(SigninFailed("Unexpected error: $e"));
    }
  }
}
