import 'package:hive_flutter/hive_flutter.dart';
import 'package:updated_smart_home/core/utils/backend_endpoints.dart';
import 'package:updated_smart_home/screans/auth/updated/auth/domain/entities/user_entity.dart';

UserEntity getUser() {
  // var jsonString = SharPref.getString(BackendEndpoints.getUserDataFromLocal);
  // var userEntity = UserModel.fromJson(jsonDecode(jsonString)).toEntity();
  // return userEntity;

  final userBox = Hive.box<UserEntity>(BackendEndpoints.hiveBoxName);
  return userBox.get(BackendEndpoints.hiveUserBoxKey)!;
}
