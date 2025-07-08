import 'dart:async'; //added 15th Aug
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

void set_workManagerName(var name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('workManagerName', name);
}

Future<String?> get_workManagerName() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? name = prefs.getString('workManagerName');

  return name;
}

void set_workManagerPeople(List<String> people) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList('workManagerPeople', people);
}

Future<List<String>?> get_workManagerPeople() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? people = prefs.getStringList('workManagerPeople');

  return people;
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    String currentDate = dateFormat.format(DateTime.now());
    DateTime currentDateTime = DateTime.now();

    if (currentDateTime.isAfter(DateTime.parse('$currentDate 11:00:00')) &&
            currentDateTime.isBefore(DateTime.parse('$currentDate 20:20:00')) ||
        currentDateTime.isAfter(DateTime.parse('$currentDate 17:00:00')) &&
            currentDateTime.isBefore(DateTime.parse('$currentDate 17:20:00'))) {
      print('debug');

      String? name = await get_workManagerName();
      String state = 'LastLogoutDate';
      String stateTime = '17:00:00';

      if (currentDateTime.isAfter(DateTime.parse('$currentDate 11:00:00')) &&
          currentDateTime.isBefore(DateTime.parse('$currentDate 17:00:00'))) {
        state = 'LastLoginDate';
        stateTime = '11:00:00';
      }

      print(state);

      await Firebase.initializeApp();
      DatabaseReference ref = FirebaseDatabase.instance.ref();
      DataSnapshot recordSnapshot =
          await ref.child('records/$currentDate/${name!}').get();
      DataSnapshot elderlySnapshot = await ref.child('users').get();

      if (recordSnapshot.exists && elderlySnapshot.exists) {
        List<String> elderlyPeople = [];
        List<String> idleElderlyPeople = [];

        for (var elderlyPerson in elderlySnapshot.children) {
          elderlyPerson.child('Caregivername').exists
              ? elderlyPerson.child('Caregivername').value == name
                  ? elderlyPeople.add(elderlyPerson.key!)
                  : null
              : null;
        }

        print(elderlyPeople);

        for (var elderlyPerson in elderlyPeople) {
          recordSnapshot.child(elderlyPerson).exists
              ? !recordSnapshot.child(elderlyPerson).child(state).exists
                  ? idleElderlyPeople.add(elderlyPerson)
                  : null
              : idleElderlyPeople.add(elderlyPerson);
        }

        print(idleElderlyPeople);

        if (idleElderlyPeople.isNotEmpty) {
          NotificationService().initNotification();
          NotificationService().showNotification(
              1,
              'TYPCCC Notification',
              'The following persons has not responded at $stateTime ${idleElderlyPeople.join(', ')}',
              5);
        }

        set_workManagerPeople(idleElderlyPeople);
      }
    }

    return Future.value(true);
  });
}

class WorkManager {
  void initialization() {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    Workmanager().registerPeriodicTask(
      "1",
      "simplePeriodicTask",
      initialDelay: const Duration(minutes: 15),
      inputData: <String, dynamic>{
        'int': 1,
      },
    );
  }
}
