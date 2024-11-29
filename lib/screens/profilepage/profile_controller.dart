import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../login_screen/login_view.dart';
import '../mysharedPref.dart';
import 'change_password.dart';

class ProfileController extends GetxController {
  final Rx<String?> userName = Rx<String?>(null);
  final Rx<String?> userEmail = Rx<String?>(null);
  final Rx<String?> userGender = Rx<String?>(null);
  final Rx<String?> userDepartment = Rx<String?>(null);
  final Rx<String?> userContact = Rx<String?>(null);
  final Rxn<File?> profileImage = Rxn<File?>();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadProfileImage();
  }

  Future<void> loadUserData() async {
    try {
      await MySharedPref.init();

      userName.value = MySharedPref.getUserName();
      userEmail.value = MySharedPref.getUserEmail();
      userGender.value = MySharedPref.getUserGender();
      userDepartment.value = MySharedPref.getUserDepartment();
      userContact.value = MySharedPref.getUserContact();

      // Debug prints
      print('Loaded UserName: ${userName.value}');
      print('Loaded UserEmail: ${userEmail.value}');
      print('Loaded UserGender: ${userGender.value}');
      print('Loaded UserDepartment: ${userDepartment.value}');
      print('Loaded UserContact: ${userContact.value}');
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Method to handle image selection from different sources
  Future<void> handleImageSelection({required ImageSource source}) async {
    try {
      // Request appropriate permission based on source
      PermissionStatus status;
      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
      } else {
        // For Android 13 and above, we need to request photo permission
        // For older versions, storage permission is needed
        if (Platform.isAndroid) {
          status = await Permission.photos.request();
          // Fallback to storage permission for older Android versions
          if (status.isPermanentlyDenied) {
            status = await Permission.storage.request();
          }
        } else {
          status = await Permission.photos.request();
        }
      }

      if (status.isGranted) {
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          imageQuality: 70, // Compress image to reduce size
          maxWidth: 1000,
          maxHeight: 1000,
        );

        if (pickedFile != null) {
          profileImage.value = File(pickedFile.path);
          // Save the image path to SharedPreferences
          saveProfileImagePath(pickedFile.path);
        }
      } else if (status.isPermanentlyDenied) {
        // Show dialog to open settings
        showPermissionSettingsDialog();
      } else {
        Get.snackbar(
          'Permission Denied',
          'Please grant permission to access ${source == ImageSource.camera ? 'camera' : 'photos'}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void showPermissionSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Permission Required'),
        content: Text('Please enable permission from app settings to access photos.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> saveProfileImagePath(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', path);
    } catch (e) {
      print('Error saving profile image path: $e');
    }
  }

  void removeProfileImage() {
    profileImage.value = null;
    // Also remove from SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('profile_image_path');
    });
  }

  Future<void> loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profile_image_path');
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          profileImage.value = file;
        }
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  void showLogoutDialog() {
    Get.defaultDialog(
      radius: 20,
      title: 'Log Out',
      middleText: 'Are you sure you want to Log out?',
      backgroundColor: Colors.white,
      titleStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      middleTextStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.black,
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        style: TextButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'No',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      confirm: TextButton(
        onPressed: () {
          logout();
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Yes',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  void showImagePickerBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.orange),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  Get.back();
                  handleImageSelection(source: ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.orange),
                title: Text(
                  'Take a Photo',
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  Get.back();
                  handleImageSelection(source: ImageSource.camera);
                },
              ),
              if (profileImage.value != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Remove Photo',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                  onTap: () {
                    Get.back();
                    removeProfileImage();
                  },
                ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
  void showChangePasswordDialog() {
    Get.defaultDialog(
      title: 'Password',
      middleText: 'Are you sure you want to change the password?',
      backgroundColor: Colors.white,
      titleStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      middleTextStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.black,
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        style: TextButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'No',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      confirm: TextButton(
        onPressed: () {
          Get.back();
          Get.to(() => const ChangePassword());
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Yes',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> logout() async {
    Get.back();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAll(() => const SignInScreen());
  }
}