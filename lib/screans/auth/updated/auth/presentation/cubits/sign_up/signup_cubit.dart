import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:updated_smart_home/screans/auth/updated/auth/domain/entities/user_entity.dart';
import 'package:updated_smart_home/screans/auth/updated/auth/domain/repo/auth_repo.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  SignupCubit(this.authRepo) : super(SignupInitial());
  final AuthRepo authRepo;

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
    String ha_url, // ✅ إضافة HA URL
    String ha_token, // ✅ إضافة HA Token
  ) async {
    emit(SignupLoading());

    var result = await authRepo.CreateUserWithEmailAndPassword(
      email,
      password,
      name,
      ha_url,
      ha_token,
    );

    result.fold(
      (Failure) => emit(SignupFailed(Failure.message)),
      (userEntity) => emit(SignupSuccess(userEntity)),
    );
  }
}
