

import 'package:elderly_app/model/user.dart';
import 'package:elderly_app/model/usertype.dart';
import 'package:firebase_database/firebase_database.dart';

class UserUtil{
  Query getElderly(String name)  {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$name");
    Query query = ref.orderByChild("User Type").equalTo(UserType.Elderly.name.toString());
    return query;
  }

  Query getCareGiver(String name)  {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$name");
    Query query = ref.orderByChild("User Type").equalTo(UserType.CareGiver.name.toString());
    return query;
  }

  Query getAdmin(String name) {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$name");
    Query query = ref.orderByChild("User Type").equalTo(UserType.Admin.name.toString());
    return query;
  }

  DatabaseReference getAssignedElderly(String name) {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users");
    return ref.orderByChild("UserType").equalTo(UserType.Elderly.name.toString()).ref
        .orderByChild("Caregivername").equalTo(name).ref;
  }

  DataSnapshot getAllCareGivers() {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users");
    Query query = ref.orderByChild("User Type").equalTo(UserType.CareGiver.name.toString());
    return getSnapshot(query);
  }

  getSnapshot(Query query) async{
    return await query.get();
  }

  Query getUnAssignedElderly(String name)  {
    DatabaseReference ref = FirebaseDatabase.instance.ref("users");
    Query query = ref.orderByChild("User Type").equalTo(UserType.Elderly.name.toString())
        .orderByChild("Assigned CareGiver").equalTo(null);
    return query;
  }

  static User getUserdetails(DataSnapshot snapshot){
    return User(
        snapshot.child("Name").value.toString(),
        snapshot.child("Age").exists?snapshot.child("Age").value.toString():null,
        snapshot.child("Gender").value.toString(),
        snapshot.child("StayingAlone").value.toString(),
        snapshot.child("BlockNumber").exists?snapshot.child("BlockNumber").value.toString():null,
        snapshot.child("UnitNumber").exists?snapshot.child("UnitNumber").value.toString():null,
        snapshot.child("PostalCode").exists?snapshot.child("PostalCode").value.toString():null,
        snapshot.child("UserType").exists?snapshot.child("UserType").value.toString():null,
        snapshot.child("Caregivername").exists?snapshot.child("Caregivername").value.toString():null,
        null,null,
        snapshot.child("Email").exists?snapshot.child("Email").value.toString():null,
        snapshot.child("PhoneNumber").exists?snapshot.child("PhoneNumber").value.toString():null);
  }
}