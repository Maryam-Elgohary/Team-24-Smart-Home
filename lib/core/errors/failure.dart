import 'package:dio/dio.dart';

abstract class Failure {
  final String message;

  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);

  factory ServerFailure.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure("Connection time out time with api");
      case DioExceptionType.sendTimeout:
        return ServerFailure("Send message fail with api");
      case DioExceptionType.receiveTimeout:
        return ServerFailure("receive essage fail with api");
      case DioExceptionType.badCertificate:
        return ServerFailure("Bad certificate receives");
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
          dioException.response!.statusCode!,
          dioException.response!.data!,
        );
      case DioExceptionType.cancel:
        return ServerFailure("Cancel");
      case DioExceptionType.connectionError:
        return ServerFailure("Connection Error");
      case DioExceptionType.unknown:
        return ServerFailure("Unknown");
    }
  }

  factory ServerFailure.fromResponse(
    int statusCode,
    Map<String, dynamic> responseData,
  ) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return ServerFailure(responseData['error']['message']);
    }
    if (statusCode == 404) {
      return ServerFailure("Your request is not found, please try later!");
    }
    if (statusCode == 500) {
      return ServerFailure("The server has an error, please try later!");
    } else {
      return ServerFailure("Something went wrong, please try later!");
    }
  }
}
