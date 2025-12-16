part of 'signup_cubit.dart';

@immutable
sealed class SignupState {}

final class SignupInitial extends SignupState {}

final class SignupLoading extends SignupState {}

final class SignupSuccess extends SignupState {
  final UserEntity userEntity;
  SignupSuccess(this.userEntity);
}

final class SignupFailed extends SignupState {
  final String errMessage;

  SignupFailed(this.errMessage);
}
