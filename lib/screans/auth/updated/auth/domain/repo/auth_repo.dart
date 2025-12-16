import 'package:dartz/dartz.dart';
import 'package:updated_smart_home/core/errors/failure.dart';
import 'package:updated_smart_home/screans/auth/updated/auth/domain/entities/user_entity.dart';

abstract class AuthRepo {
  Future<Either<Failure, UserEntity>> CreateUserWithEmailAndPassword(
    String email,
    String password,
    String name,
    String ha_url,
    String ha_token
  );
  Future<Either<Failure, UserEntity>> SignWithEmailAndPassword(
    String email,
    String password,
  );
  Future addUserData({required UserEntity user});
  Future<UserEntity> getUserData({required String uID});
  Future saveUserData({required UserEntity user});

  Future<void> SignOut();
}
