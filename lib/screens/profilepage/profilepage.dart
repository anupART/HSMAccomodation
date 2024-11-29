
import 'package:accomodation_app/screens/profilepage/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';


class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Change the initialization to ensure controller is initialized only once
    final controller = Get.put(ProfileController());  // Change from lazyPut to put
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileImage(),
            const SizedBox(height: 60),
            _buildUserInfoFields(),
            _buildActionButtons(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: Obx(() {
            if (controller.profileImage.value != null) {
              return CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey[200],
                backgroundImage: FileImage(controller.profileImage.value!),
              );
            } else {
              return const CircleAvatar(
                radius: 55,
                backgroundColor: Color(0xFFE5E5E5),
                child: Icon(Icons.person, size: 55, color: Colors.grey),
              );
            }
          }),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: controller.showImagePickerBottomSheet,  // Updated this line
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
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
                  controller.handleImageSelection(source: ImageSource.gallery);
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
                  controller.handleImageSelection(source: ImageSource.camera);
                },
              ),
              if (controller.profileImage.value != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Remove Photo',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                  onTap: () {
                    Get.back();
                    controller.removeProfileImage();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildUserInfoFields() {
    return Column(
      children: [
        _buildTextField('Name', Icons.person, controller.userName),
        _buildTextField('Email', Icons.email_outlined, controller.userEmail),
        _buildTextField('Gender', Icons.person_2_outlined, controller.userGender),
        _buildTextField('Department', Icons.work, controller.userDepartment),
        _buildTextField('Contact', Icons.phone, controller.userContact),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, Rx<String?> value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Obx(() => TextFormField(
        cursorColor: Colors.black,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black,
          ),
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 1.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        readOnly: true,
        controller: TextEditingController(text: value.value ?? 'No $label'),
        style: const TextStyle(
          fontFamily: 'RobotoSlab',
          fontSize: 15,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      )),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomListTile(
          icon: Icons.lock_outline,
          title: 'Change Password',
          onTap: controller.showChangePasswordDialog,
        ),
        CustomListTile(
          icon: Icons.logout,
          title: 'Logout',
          iconColor: Colors.red,
          titleColor: Colors.red,
          onTap: controller.showLogoutDialog,
        ),
      ],
    );
  }
}

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const CustomListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF5F6FA),
          child: Icon(icon, color: iconColor ?? Colors.orange),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: titleColor ?? Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
// so i am giving yoiu code pick image from gellery for that show me how to do that like i am giving you prfile age, helphjer and comtroller i want open galley or acces the galley allow an then get iage fomgakleyand show that image of galley and or ther eis default image