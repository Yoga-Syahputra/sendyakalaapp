import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/loading_screen.dart';
import 'services/auth_service.dart';
import 'services/news_service.dart';
import 'models/progress_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz;


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  tz.initializeTimeZones();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(SendyakalaApp());
}

class SendyakalaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => NewsService()),
        ChangeNotifierProvider(create: (_) => ProgressModel()), // Add this line
      ],
      child: MaterialApp(
        title: 'Sendyakala',
        theme: ThemeData(
          primaryColor: Color(0xFF003B73),
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.poppinsTextTheme().apply(
            bodyColor: const Color.fromARGB(255, 0, 0, 0),
            displayColor: const Color.fromARGB(255, 0, 0, 0),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF003B73),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF003B73),
            selectedItemColor: Color(0xFF003B73),
            unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        home: LoadingScreen(),
      ),
    );
  }
}
