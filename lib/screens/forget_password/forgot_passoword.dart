import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forget_password_controller.dart';

class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key}) {
    Get.put(ForgotPasswordController());
  }

  @override
  Widget build(BuildContext context) {

    final controller = Get.find<ForgotPasswordController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 5,
        backgroundColor: Colors.white,
        title: Text(
          "Forgot Password",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildEmailField(controller),
                Obx(() {
                  if (controller.isOtpSent.value) {
                    return _buildOtpAndPasswordFields(controller);
                  }
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    if (controller.isOtpSent.value) {
                      controller.resetPassword();
                    } else {
                      controller.sendOtp();
                    }
                  },
                  child: Obx(() {
                    return Text(
                      controller.isOtpSent.value ? "Reset Password" : "Send OTP",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField(ForgotPasswordController controller) {
    return TextFormField(

      cursorColor: Colors.black,
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black87,
        ),
        labelText: "Email Address",
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.email),
      ),
    );
  }

  Widget _buildOtpAndPasswordFields(ForgotPasswordController controller) {
    return Column(
      children: [
        const SizedBox(height: 15),
        TextFormField(
          cursorColor: Colors.black,
          controller: controller.otpController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            labelText: "Enter OTP",
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.security),
          ),
        ),
        const SizedBox(height: 15),
        Obx(() => TextFormField(
          cursorColor: Colors.black,
          controller: controller.newPasswordController,
          obscureText: controller.isObscured.value,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            labelText: "New Password",
            filled: true,
            fillColor: Colors.white,
            suffixIcon: IconButton(
              onPressed: () => controller.isObscured.value = !controller.isObscured.value,
              icon: Icon(
                controller.isObscured.value ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
        )),
        const SizedBox(height: 15),
        Obx(() => TextFormField(

          cursorColor: Colors.black,
          controller: controller.confirmPasswordController,
          obscureText: controller.isObscured2.value,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            labelText: "Confirm New Password",
            filled: true,
            fillColor: Colors.white,
            suffixIcon: IconButton(
              onPressed: () => controller.isObscured2.value = !controller.isObscured2.value,
              icon: Icon(
                controller.isObscured2.value ? Icons.visibility_off : Icons.visibility,
              ),
            ),
          ),
        )),
      ],
    );
  }
}