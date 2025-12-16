import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:updated_smart_home/core/services/FireStoreService.dart';
import 'package:updated_smart_home/core/services/api_services.dart';
import 'package:updated_smart_home/core/services/dataBaseService.dart';
import 'package:updated_smart_home/core/services/firebaseAuth_service.dart';
import 'package:updated_smart_home/screans/auth/updated/auth/data/repos/AuthRepoImple.dart';
import 'package:updated_smart_home/screans/auth/updated/auth/domain/repo/auth_repo.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService());
  getIt.registerSingleton<DataBaseService>(Firestoreservice());
  getIt.registerSingleton<ApiServices>(ApiServices(Dio()));
  getIt.registerSingleton<AuthRepo>(
    AuthRepoImplementation(
      firebaseAuthService: getIt<FirebaseAuthService>(),
      dataBaseService: getIt<DataBaseService>(),
    ),
  );
}
