import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotificationPage(),
    );
  }
}

class NotificationPage extends StatefulWidget {
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Notifications Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // await _showNotification();
          },
          child: Text('Show Notification'),
        ),
      ),
    );
  }

  // Future<void> _showNotification() async {
  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //     'your_channel_id',
  //     'your_channel_name',
  //     'your_channel_description',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     ticker: 'ticker',
  //     playSound: true,
  //     sound: RawResourceAndroidNotificationSound('your_sound'), // replace with your custom sound file name
  //     enableVibration: true,
  //     vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]), // adjust the vibration pattern
  //     color: Colors.blue, // notification color
  //     ledColor: Colors.red, // LED color
  //     ledOnMs: 1000, // LED on duration in milliseconds
  //     ledOffMs: 500, // LED off duration in milliseconds
  //   );


  //   var platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
     
  //   );

  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'Title',
  //     'Body',
  //     platformChannelSpecifics,
  //     payload: 'Default_Sound',
  //   );
  // }
}
