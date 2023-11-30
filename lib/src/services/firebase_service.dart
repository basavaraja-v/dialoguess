import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dialogue.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Dialogue> getDialogue(int level) async {
    QuerySnapshot snapshot = await _firestore
        .collection('dialogues')
        .where('level', isEqualTo: level)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Dialogue.fromMap(
          snapshot.docs.first.data() as Map<String, dynamic>, level);
    } else {
      throw Exception('Dialogue not found for level $level');
    }
  }
}
