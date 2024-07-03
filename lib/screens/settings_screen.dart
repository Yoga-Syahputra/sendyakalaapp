import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'login_screen.dart';
import 'loading_screen.dart';  
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'change_password_screen.dart'; 

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  final DateFormat _timeFormatter = DateFormat('HH:mm');
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadNotificationTime();
  }

  _loadNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('notificationHour') ?? _selectedTime.hour;
    final minute = prefs.getInt('notificationMinute') ?? _selectedTime.minute;
    setState(() {
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  _saveNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationHour', time.hour);
    await prefs.setInt('notificationMinute', time.minute);
    _scheduleDailyNotification(time);
  }

  _scheduleDailyNotification(TimeOfDay time) async {
    final now = DateTime.now();
    final notificationTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    var androidDetails = const AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: 'description',
      importance: Importance.max,
      priority: Priority.high,
    );
    var generalNotificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Reminder',
      'It\'s time for your scheduled activity!',
      notificationTime.isBefore(now)
          ? tz.TZDateTime.from(notificationTime, tz.local).add(Duration(days: 1))
          : tz.TZDateTime.from(notificationTime, tz.local),
      generalNotificationDetails,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  _resetData(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Reset Data'),
        content: Text('Are you sure you want to reset data? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                setState(() {
                  _selectedTime = TimeOfDay(hour: 0, minute: 0);
                });
                _saveNotificationTime(TimeOfDay(hour: 0, minute: 0));

                // Delete all activities data from Firebase for the logged-in user
                final User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final uid = user.uid;
                  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

                  final List<String> activityNodes = [
                    'actsOfKindness',
                    'exercise',
                    'gratitudes',
                    'journalEntries',
                    'meditation'
                  ];

                  for (String node in activityNodes) {
                    final userActivityRef = databaseRef.child('$node/$uid');
                    await userActivityRef.remove().then((_) {
                      print('Data removed from $node for user $uid');
                    }).catchError((error) {
                      print('Failed to remove data from $node for user $uid: $error');
                    });
                  }
                } else {
                  print('User is not logged in');
                }
              } catch (e) {
                print('Error resetting data: $e');
              }
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
            },
            child: Text('No'),
          ),
        ],
      ),
    );
  }

  _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      _saveNotificationTime(picked);
    }
  }

  _signOut(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              // Navigate to LoadingScreen first
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoadingScreen()),
              );
              // Simulate a delay for loading screen
              await Future.delayed(Duration(seconds: 2));
              // Then navigate to LoginScreen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('No'),
          ),
        ],
      ),
    );
  }

  _navigateToChangePassword(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Notification Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _timeFormatter.format(DateTime(2020, 1, 1, _selectedTime.hour, _selectedTime.minute)),
                      style: TextStyle(fontSize: 18),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickTime(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF003B73),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text('Select Time'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Divider(color: Colors.grey),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _resetData(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  'Reset Data',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _signOut(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _navigateToChangePassword(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  'Change Password',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 20), 
              Text(
                'Sendyakala v 1.0',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
