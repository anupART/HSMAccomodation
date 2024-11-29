import 'package:flutter/material.dart';
import 'bottomnavbar/bottom_nav_bar.dart';
import 'login_screen/login_view.dart';
import 'mysharedPref.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    await MySharedPref.init();
    bool isLoggedIn = MySharedPref.getLoginStatus();
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isLoggedIn
              ? const BottomNavBar()
              : const SignInScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage('assets/images/appBarImg.jpeg'),
        ),
      ),
    );
  }
}
