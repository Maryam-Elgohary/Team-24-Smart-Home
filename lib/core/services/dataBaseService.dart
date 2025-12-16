abstract class DataBaseService {
  Future<void> addData({
    required String path,
    required Map<String, dynamic> data,
    String docID,
  });

  Future<dynamic> getData({required String path, String? docID});
}
