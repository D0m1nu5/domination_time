import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

void main() {
  runApp(DominationTimeApp());
}

class DominationTimeApp extends StatefulWidget {
  @override
  _DominationTimeAppState createState() => _DominationTimeAppState();
}

class _DominationTimeAppState extends State<DominationTimeApp> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  List<Map<String, dynamic>> appointments = [];

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void scheduleNotification(DateTime scheduledDate, String description) async {
    var androidDetails = AndroidNotificationDetails(
      'channelId', 'channelName',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    var iosDetails = IOSNotificationDetails();
    var generalNotificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await flutterLocalNotificationsPlugin.schedule(
      0,
      'Reminder Domination Time',
      description,
      scheduledDate.subtract(Duration(minutes: 30)),
      generalNotificationDetails,
    );
  }

  void addAppointment() {
    DatePicker.showDateTimePicker(context, showTitleActions: true, onConfirm: (date) {
      TextEditingController descController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Descrizione appuntamento'),
            content: TextField(controller: descController, decoration: InputDecoration(hintText: 'Descrivi il tuo appuntamento')),
            actions: [
              TextButton(
                onPressed: () {
                  if (descController.text.isNotEmpty) {
                    setState(() {
                      appointments.add({'datetime': date, 'description': descController.text});
                    });
                    scheduleNotification(date, descController.text);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Salva'),
              ),
            ],
          );
        },
      );
    }, currentTime: DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Domination Time',
      home: Scaffold(
        appBar: AppBar(title: Text('Domination Time')),
        body: ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            var app = appointments[index];
            return ListTile(
              title: Text(app['description']),
              subtitle: Text(app['datetime'].toString()),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: addAppointment,
          tooltip: 'Aggiungi Appuntamento',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}