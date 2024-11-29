import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../login_screen/login_view.dart';
import 'forgot_password_model.dart';


class ForgotPasswordController extends GetxController {

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();


  final isOtpSent = false.obs;
  final isObscured = true.obs;
  final isObscured2 = true.obs;


  Future<void> sendOtp() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      showDialog("Error", "Please enter your email address.");
      return;
    }

    const String apiUrl = "https://beds-accomodation.vercel.app/api/forgotPassword";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final forgetPasswordResponse = ForgetPassword.fromJson(jsonResponse);

        if (forgetPasswordResponse.success == 1) {
          isOtpSent.value = true;
          showDialog("OTP Sent", forgetPasswordResponse.message ?? "OTP has been sent to your email.");
        } else {
          showDialog("Error", forgetPasswordResponse.message ?? "Failed to send OTP. Please try again.");
        }
      } else {
        showDialog("Error", "Server error. Please try again later.");
      }
    } catch (error) {
      showDialog("Error", "An error occurred: ${error.toString()}");
    }
  }

  Future<void> resetPassword() async {
    String email = emailController.text.trim();
    String otp = otpController.text.trim();
    String newPassword = newPasswordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      showDialog("Error", "Passwords do not match.");
      return;
    }

    const String apiUrl = "https://beds-accomodation.vercel.app/api/resetPassword";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "otp": otp,
          "newPassword": newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == 1) {
          showDialog("Success", "Password reset successful. You can now log in with your new password.");

          Future.delayed(const Duration(seconds: 2), () {
            Get.to(() => SignInScreen());
          });
        } else {
          showDialog("Error", jsonResponse['message'] ?? "Failed to reset password. Please try again.");
        }
      } else {
        showDialog("Error", "Server error. Please try again later.");
      }
    } catch (error) {
      showDialog("Error", "An error occurred: ${error.toString()}");
    }
  }

  void showDialog(String title, String content) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}