import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:updated_smart_home/core/errors/execptions.dart';
import 'package:updated_smart_home/core/errors/failure.dart';
import 'package:updated_smart_home/core/services/dataBaseService.dart';
import 'package:updated_smart_home/core/services/firebaseAuth_service.dart';
import 'package:updated_smart_home/core/utils/backend_endpoints.dart';
import 'package:updated_smart_home/screans/auth/updated/auth/data/models/user_model.dart';
import 'package:updated_smart_home/screans/auth/updated/auth/domain/entities/user_entity.dart';
import 'package:updated_smart_home/screans/auth/updated/auth/domain/repo/auth_repo.dart';

class AuthRepoImplementation extends AuthRepo {
  AuthRepoImplementation({
    required this.firebaseAuthService,
    required this.dataBaseService,
  });

  final FirebaseAuthService firebaseAuthService;
  final DataBaseService dataBaseService;

  @override
  Future<Either<Failure, UserEntity>> CreateUserWithEmailAndPassword(
    String email,
    String password,
    String name,
    String ha_url,
    String ha_token,
  ) async {
    User? user;
    try {
      user = await firebaseAuthService.createUserWithEmailAndPassword(
        email,
        password,
      );

      // إنشاء UserEntity كامل مع HA URL و Token
      UserEntity userEntity = UserEntity(
        uid: user.uid,
        name: name,
        email: email,
        ha_url: ha_url,
        ha_token: ha_token,
      );

      await addUserData(user: userEntity);

      return right(userEntity);
    } on CustomException catch (e) {
      if (user != null) {
        await firebaseAuthService.deleteUser();
      }
      return left(ServerFailure(e.message));
    } catch (e) {
      if (user != null) {
        await firebaseAuthService.deleteUser();
      }

      log("Exception in createUserWithEmailAndPassword: ${e.toString()}");
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> SignWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      User user = await firebaseAuthService.signInWithEmailAndPassword(
        email,
        password,
      );

      var userEntity = await getUserData(uID: user.uid);
      await saveUserData(user: userEntity);

      return right(userEntity);
    } on CustomException catch (e) {
      return left(ServerFailure(e.message));
    }
  }

  @override
  Future addUserData({required UserEntity user}) async {
    await dataBaseService.addData(
      path: BackendEndpoints.addUserData,
      data: UserModel.fromEntity(user).toJson(),
      docID: user.uid,
    );
  }

  Future<void> SignOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<UserEntity> getUserData({required String uID}) async {
    var data =
        await dataBaseService.getData(
              path: BackendEndpoints.getUserData,
              docID: uID,
            )
            as Map<String, dynamic>;

    UserModel userModel = UserModel.fromJson(data);
    UserEntity userEntity = userModel.toEntity();
    return userEntity;
  }

  @override
  Future saveUserData({required UserEntity user}) async {
    // Using Hive to save user data locally
    var userBox = Hive.box<UserEntity>(BackendEndpoints.hiveBoxName);
    await userBox.put(BackendEndpoints.hiveUserBoxKey, user);
  }
}
