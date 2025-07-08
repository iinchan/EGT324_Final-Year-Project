
import 'package:flutter/material.dart';
import 'package:elderly_app/auth_page.dart';
import 'package:elderly_app/caregiver_app/caregiver_homepage.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/usertype.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key, required this.name});
  final String name;
  @override
  State<AdminHome> createState() => _adminHomeState();
}

class _adminHomeState extends State<AdminHome> {

  final dbRef = FirebaseDatabase.instance.ref().child("users");
  Future<void> signUserOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("Name");
    prefs.remove("UsertType");
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => const AuthPage()));
  }


  @override
  void initState() {
    //...
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        title: const Text(' W E L C O M E'),
        actions: [IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))],
      ),
      body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text("Care Givers",style: TextStyle(color: Colors.green,fontSize: 30,
                    fontWeight: FontWeight.bold),),
            FutureBuilder(
                future: dbRef.once(),
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.hasData) {
                    Iterable<DataSnapshot>? values = snapshot.data?.snapshot.children;
                    var list = values?.where((element) =>
                        element.child("UserType").value.toString() == UserType.CareGiver.name);
                    return list!.isEmpty ? const AlertDialog(
                      backgroundColor: Color.fromARGB(255, 128, 4, 4),
                      title: Center(
                        child: Text(
                          'No Active CareGiver',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ) : ListView.builder(
                        padding: const EdgeInsets.only(top: 20,bottom: 20,left: 5,right: 5),
                        shrinkWrap: true,
                        itemCount: list.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    caregiverHome(name: list.elementAt(index).
                                    child("Name").value.toString()))),
                            child: Card(
                              elevation: 20,
                              shadowColor: Colors.lightBlueAccent,
                              borderOnForeground: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(padding: const EdgeInsets.only(left: 10,top: 10,bottom: 10),
                                    child: Text(list.elementAt(index).child("Name").value.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          color: Colors.pink
                                      ),),
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  }
                  return const CircularProgressIndicator();
                })
              ],
            ),
          )),
    );
  }

  cardOnTap(String name){
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => caregiverHome(name: name)));
  }
}

