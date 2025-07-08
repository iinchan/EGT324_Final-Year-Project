import 'package:firebase_database/firebase_database.dart';
class FireBaseDatabase {
  getElderly(careGiverID) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users");
    Query query = ref;
    DataSnapshot event = await query.get();
  }
}