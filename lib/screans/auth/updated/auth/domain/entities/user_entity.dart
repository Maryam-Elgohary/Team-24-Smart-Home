import 'package:hive/hive.dart';

// write the file name .g.dart exactly like this
part 'user_entity.g.dart';
//flutter packages pub run build_runner build

//typeId cannot be repeated in the whole project for other classes
//typeId can be from 0 to 255
@HiveType(typeId: 0)
class UserEntity extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String uid;
  @HiveField(3)
  final String ha_url;
  @HiveField(4)
  final String ha_token;

  UserEntity({
    required this.name,
    required this.email,
    required this.uid,
    required this.ha_url,
    required this.ha_token,
  });
}
