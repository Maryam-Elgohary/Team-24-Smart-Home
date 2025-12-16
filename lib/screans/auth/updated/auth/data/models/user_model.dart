import 'package:firebase_auth/firebase_auth.dart';
import 'package:updated_smart_home/screans/auth/updated/auth/domain/entities/user_entity.dart';

class UserModel {
  String? uID;
  String? email;
  String? name;
  String? ha_url;
  String? ha_token;

  UserModel({
    required this.uID,
    required this.email,
    required this.name,
    required this.ha_url,
    required this.ha_token,
  });

  /// إنشاء UserModel من Firebase User
  factory UserModel.userFromFirebase(User user) {
    return UserModel(
      uID: user.uid,
      email: user.email ?? "",
      name: user.displayName ?? "",
      ha_url: "", // يتم ملؤه لاحقًا من المستخدم
      ha_token: "", // يتم ملؤه لاحقًا من المستخدم
    );
  }

  /// إنشاء UserModel من UserEntity
  factory UserModel.fromEntity(UserEntity userEntity) {
    return UserModel(
      uID: userEntity.uid,
      email: userEntity.email,
      name: userEntity.name,
      ha_url: userEntity.ha_url,
      ha_token: userEntity.ha_token,
    );
  }

  /// تحويل UserModel إلى UserEntity
  UserEntity toEntity() {
    return UserEntity(
      uid: uID!,
      email: email!,
      name: name!,
      ha_url: ha_url!,
      ha_token: ha_token!,
    );
  }

  /// تحويل UserModel إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'uID': uID,
      'email': email,
      'name': name,
      'ha_url': ha_url,
      'ha_token': ha_token,
    };
  }

  /// إنشاء UserModel من JSON
  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      uID: data['uID'],
      email: data['email'],
      name: data['name'],
      ha_url: data['ha_url'],
      ha_token: data['ha_token'],
    );
  }
}
