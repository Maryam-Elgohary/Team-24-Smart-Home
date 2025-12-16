import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:updated_smart_home/core/services/dataBaseService.dart';

class Firestoreservice implements DataBaseService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future<void> addData({
    required String path,
    required Map<String, dynamic> data,
    String? docID,
  }) async {
    if (docID != null) {
      await firestore.collection(path).doc(docID).set(data);
    } else {
      await firestore.collection(path).add(data);
    }
  }
 
  @override
  Future getData({required String path, String? docID}) async {
    var data;
    if (docID != null) {
      data = await firestore.collection(path).doc(docID).get();
    } else {
      data = await firestore.collection(path).get();
    }
    return data.data();
  }
}
