import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bottomnavbar/bottom_nav_bar.dart';
import '../forget_password/forgot_passoword.dart';
import 'login_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  var _isObscured;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginController controller = Get.put(LoginController());

  @override
  void initState() {
    _isObscured = true;
    super.initState();
    _emailController.text = controller.email.value;
    _passwordController.text = controller.password.value;

    // Add listeners to update controller values
    _emailController.addListener(() {
      controller.email.value = _emailController.text;
    });

    _passwordController.addListener(() {
      controller.password.value = _passwordController.text;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showLoginFailedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black54,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Login Failed',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Invalid email or password. Please try again.',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());
    final _formSignInKey = GlobalKey<FormState>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formSignInKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 0),
                  width: Get.size.width / 1.1,
                  child: Center(
                    child: Image.asset(
                      fit: BoxFit.fill,
                      "assets/images/login_page_img.jpeg",
                      height: Get.size.height / 4,
                      width: Get.size.width / 1.8,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    controller: _emailController,
                    cursorColor: Colors.black,
                    onChanged: (value) {
                      controller.email.value = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      label: const Text('Email'),
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'Enter Email',
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.black26),
                    ),
                  ),
                ),
                const SizedBox(height: 25.0),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _isObscured,
                    cursorColor: Colors.black,
                    onChanged: (value) {
                      controller.password.value = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Password';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                        icon: Icon(
                          _isObscured ? Icons.visibility_off : Icons.visibility,
                          size: 25,
                        ),
                      ),
                      label: const Text('Password'),
                      labelStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'Enter Password',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25.0),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      child: Text(
                        'Forget password?',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        Get.to(ForgotPassword());
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 25.0),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formSignInKey.currentState!.validate()) {
                          controller.isLoading.value = true;
                          bool loginSuccess = await controller.loginUser();
                          controller.isLoading.value = false;
                          if (loginSuccess) {
                            Get.offAll(() => const BottomNavBar());
                          } else {
                            _showLoginFailedDialog();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Obx(
                            () => controller.isLoading.value
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
