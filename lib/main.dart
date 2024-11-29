import 'package:accomodation_app/screens/bottomnavbar/bottom_nav_bar.dart';
import 'package:accomodation_app/screens/historyscreen/download_service.dart';
import 'package:accomodation_app/screens/historyscreen/monthly_download_service.dart';
import 'package:accomodation_app/screens/homescreen/new_home.dart';
import 'package:accomodation_app/screens/login_screen/login_view.dart';
import 'package:accomodation_app/screens/mysharedPref.dart';
import 'package:accomodation_app/screens/splash_screen.dart';
import 'package:accomodation_app/screens/profilepage/profilepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MySharedPref.init();
  await DownloadService.initializeDownloader();
  await MonthlyDownloadService.initializeDownloader();
  WidgetsFlutterBinding.ensureInitialized();

  // // below to show push notifictaions
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  // FlutterLocalNotificationsPlugin();
  // const AndroidInitializationSettings initializationSettingsAndroid =
  // AndroidInitializationSettings('@mipmap/ic_launcher');
  // const InitializationSettings initializationSettings =
  // InitializationSettings(android: initializationSettingsAndroid);
  // flutterLocalNotificationsPlugin.initialize(initializationSettings);


  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Accommodation App',
      theme: ThemeData(
        primarySwatch: Colors.grey, // or use Colors.blueGrey if you want a subtle color
        brightness: Brightness.light, // Use light theme
        scaffoldBackgroundColor: Colors.white, // White background for the whole app
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // White background for the app bar
          foregroundColor: Colors.black, // Black text/icons for contrast
          elevation: 0, // Remove shadow for a flat design
          scrolledUnderElevation: 0, // Prevent color change on scroll
        ),
        cardColor: Colors.white, // Ensure cards are also white
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // Black text for readability
          bodyMedium: TextStyle(color: Colors.black),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: BottomNavBar(),
      // home: ProfilePage(),
      home: SplashScreen()
      // home: SignInScreen(),

    );
  }
}
